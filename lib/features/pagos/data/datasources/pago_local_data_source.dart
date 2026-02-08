import 'package:drift/drift.dart';
import '../models/pago_model.dart';
import '../../domain/entities/resultado_aplicacion_pago.dart';
import '../../domain/entities/detalle_pago.dart';
import '../../../../core/database/database.dart';

/// Data Source Local de Pagos
/// 
/// Implementa la lógica de aplicación en cascada:
/// Mora → Interés → Capital
class PagoLocalDataSource {
  final AppDatabase database;

  PagoLocalDataSource(this.database);

  /// Registra un pago y lo aplica en cascada a las cuotas
  Future<ResultadoAplicacionPago> registrarPago({
    required int prestamoId,
    required double monto,
    required DateTime fechaPago,
    int? cajaId,
    String? metodoPago,
    String? referencia,
    String? observaciones,
  }) async {
    return await database.transaction(() async {
      // 1. Generar código de pago
      final codigo = await _generarCodigoPago();

      // 2. Obtener cuotas pendientes ordenadas por vencimiento
      final cuotasPendientes = await _getCuotasPendientesOrdenadas(prestamoId);

      if (cuotasPendientes.isEmpty) {
        throw Exception('No hay cuotas pendientes para este préstamo');
      }

      // 3. Aplicar el pago en cascada
      final resultado = await _aplicarPagoEnCascada(
        cuotas: cuotasPendientes,
        montoDisponible: monto,
        fechaPago: fechaPago,
      );

      // 4. Crear el registro de pago
      final pagoId = await database.into(database.pagos).insert(
            PagosCompanion.insert(
              prestamoId: prestamoId,
              codigo: codigo,
              montoTotal: monto,
              montoMora: resultado.totalMora,
              montoInteres: resultado.totalInteres,
              montoCapital: resultado.totalCapital,
              fechaPago: fechaPago,
              cajaId: Value(cajaId),
              metodoPago: Value(metodoPago),
              referencia: Value(referencia),
              observaciones: Value(observaciones),
              fechaRegistro: DateTime.now(),
            ),
          );

      // 5. Guardar los detalles de aplicación
      for (final detalle in resultado.detalles) {
        await database.into(database.detallePagos).insert(
              DetallePagosCompanion.insert(
                pagoId: pagoId,
                cuotaId: detalle.cuotaId,
                numeroCuota: detalle.numeroCuota,
                montoMora: detalle.montoMora,
                montoInteres: detalle.montoInteres,
                montoCapital: detalle.montoCapital,
                montoTotal: detalle.montoTotal,
                fechaRegistro: DateTime.now(),
              ),
            );
      }

      // 6. Registrar movimiento en caja si se especificó
      if (cajaId != null) {
        await _registrarMovimientoEnCaja(
          cajaId: cajaId,
          monto: monto,
          descripcion: 'Pago de préstamo $codigo',
          fechaPago: fechaPago,
        );
      }

      // 7. Actualizar estados de cuotas y préstamo
      await _actualizarEstados(prestamoId);

      return resultado;
    });
  }

  /// Aplica el pago en cascada sobre las cuotas
  Future<ResultadoAplicacionPago> _aplicarPagoEnCascada({
    required List<CuotaData> cuotas,
    required double montoDisponible,
    required DateTime fechaPago,
  }) async {
    double montoRestante = montoDisponible;
    double totalMora = 0;
    double totalInteres = 0;
    double totalCapital = 0;
    final List<DetallePago> detalles = [];
    final List<int> cuotasPagadas = [];

    for (final cuota in cuotas) {
      if (montoRestante <= 0) break;

      // Calcular mora acumulada
      final mora = _calcularMora(cuota, fechaPago);
      final interesesPendiente = cuota.interes - cuota.montoPagado;
      final capitalPendiente = cuota.capital;

      double montoMora = 0;
      double montoInteres = 0;
      double montoCapital = 0;

      // Cascada: Mora → Interés → Capital
      
      // 1. Cubrir mora
      if (mora > 0 && montoRestante > 0) {
        montoMora = montoRestante >= mora ? mora : montoRestante;
        montoRestante -= montoMora;
        totalMora += montoMora;
      }

      // 2. Cubrir interés
      if (interesesPendiente > 0 && montoRestante > 0) {
        montoInteres = montoRestante >= interesesPendiente 
            ? interesesPendiente 
            : montoRestante;
        montoRestante -= montoInteres;
        totalInteres += montoInteres;
      }

      // 3. Cubrir capital
      if (capitalPendiente > 0 && montoRestante > 0) {
        montoCapital = montoRestante >= capitalPendiente 
            ? capitalPendiente 
            : montoRestante;
        montoRestante -= montoCapital;
        totalCapital += montoCapital;
      }

      // Actualizar la cuota
      final nuevoMontoPagado = cuota.montoPagado + montoInteres;
      final nuevaMora = (cuota.montoMora + montoMora) - montoMora; // Reset mora pagada
      
      await (database.update(database.cuotas)
            ..where((tbl) => tbl.id.equals(cuota.id)))
          .write(
        CuotasCompanion(
          montoPagado: Value(nuevoMontoPagado),
          montoMora: Value(nuevaMora > 0 ? nuevaMora : 0),
          fechaPago: Value(fechaPago),
          estado: Value(_determinarEstadoCuota(
            interesTotal: cuota.interes,
            interesPagado: nuevoMontoPagado,
            fechaVencimiento: cuota.fechaVencimiento,
            fechaPago: fechaPago,
          )),
        ),
      );

      // Guardar detalle si hubo aplicación
      if (montoMora > 0 || montoInteres > 0 || montoCapital > 0) {
        detalles.add(DetallePago(
          pagoId: 0, // Se asignará después
          cuotaId: cuota.id,
          numeroCuota: cuota.numeroCuota,
          montoMora: montoMora,
          montoInteres: montoInteres,
          montoCapital: montoCapital,
          montoTotal: montoMora + montoInteres + montoCapital,
          fechaRegistro: DateTime.now(),
        ));

        // Verificar si la cuota quedó pagada
        if (nuevoMontoPagado >= cuota.interes) {
          cuotasPagadas.add(cuota.id);
        }
      }
    }

    return ResultadoAplicacionPago(
      montoOriginal: montoDisponible,
      montoAplicado: montoDisponible - montoRestante,
      montoRestante: montoRestante,
      totalMora: totalMora,
      totalInteres: totalInteres,
      totalCapital: totalCapital,
      detalles: detalles,
      cuotasPagadas: cuotasPagadas,
      mensaje: _generarMensajeResultado(
        montoAplicado: montoDisponible - montoRestante,
        cuotasAfectadas: detalles.length,
        cuotasPagadas: cuotasPagadas.length,
      ),
    );
  }

  /// Obtiene cuotas pendientes ordenadas por vencimiento
  Future<List<CuotaData>> _getCuotasPendientesOrdenadas(int prestamoId) async {
    return await (database.select(database.cuotas)
          ..where((tbl) => tbl.prestamoId.equals(prestamoId))
          ..where((tbl) => tbl.estado.isNotValue('PAGADA'))
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.fechaVencimiento)]))
        .get();
  }

  /// Calcula la mora acumulada de una cuota
  double _calcularMora(CuotaData cuota, DateTime fechaPago) {
    if (fechaPago.isBefore(cuota.fechaVencimiento) || 
        fechaPago.isAtSameMomentAs(cuota.fechaVencimiento)) {
      return 0;
    }

    final diasRetraso = fechaPago.difference(cuota.fechaVencimiento).inDays;
    if (diasRetraso <= 0) return 0;

    const tasaMoraDiaria = 0.005; // 0.5% diario
    return cuota.interes * tasaMoraDiaria * diasRetraso;
  }

  /// Determina el estado de una cuota después del pago
  String _determinarEstadoCuota({
    required double interesTotal,
    required double interesPagado,
    required DateTime fechaVencimiento,
    required DateTime fechaPago,
  }) {
    if (interesPagado >= interesTotal) {
      return 'PAGADA';
    } else if (fechaPago.isAfter(fechaVencimiento)) {
      return 'MORA';
    } else {
      return 'PENDIENTE';
    }
  }

  /// Genera código único para el pago
  Future<String> _generarCodigoPago() async {
    final now = DateTime.now();
    final yearMonth = '${now.year}${now.month.toString().padLeft(2, '0')}';
    
    final count = await database.selectOnly(database.pagos)
      ..addColumns([database.pagos.id.count()]);
    
    final result = await count.getSingle();
    final total = result.read(database.pagos.id.count()) ?? 0;
    final numero = (total + 1).toString().padLeft(4, '0');
    
    return 'PAG-$yearMonth-$numero';
  }

  /// Registra el movimiento en la caja
  Future<void> _registrarMovimientoEnCaja({
    required int cajaId,
    required double monto,
    required String descripcion,
    required DateTime fechaPago,
  }) async {
    // Obtener caja actual
    final caja = await (database.select(database.cajas)
          ..where((tbl) => tbl.id.equals(cajaId)))
        .getSingle();

    // Registrar movimiento de ingreso
    await database.into(database.movimientos).insert(
      MovimientosCompanion.insert(
        cajaId: cajaId,
        tipo: 'INGRESO',
        categoria: 'PAGO',
        monto: monto,
        descripcion: descripcion,
        fecha: fechaPago,
        saldoAnterior: caja.saldo,
        saldoNuevo: caja.saldo + monto,
        fechaRegistro: DateTime.now(),
      ),
    );

    // Actualizar saldo de caja
    await (database.update(database.cajas)
          ..where((tbl) => tbl.id.equals(cajaId)))
        .write(CajasCompanion(saldo: Value(caja.saldo + monto)));
  }

  /// Actualiza estados de cuotas y préstamo
  Future<void> _actualizarEstados(int prestamoId) async {
    // Actualizar estados de cuotas vencidas
    final hoy = DateTime.now();
    await (database.update(database.cuotas)
          ..where((tbl) => 
              tbl.prestamoId.equals(prestamoId) &
              tbl.fechaVencimiento.isSmallerThanValue(hoy) &
              tbl.estado.equals('PENDIENTE')))
        .write(const CuotasCompanion(estado: Value('MORA')));

    // Verificar estado del préstamo
    final cuotasPendientes = await (database.select(database.cuotas)
          ..where((tbl) => tbl.prestamoId.equals(prestamoId))
          ..where((tbl) => tbl.estado.isNotValue('PAGADA')))
        .get();

    String nuevoEstado;
    if (cuotasPendientes.isEmpty) {
      nuevoEstado = 'PAGADO';
    } else if (cuotasPendientes.any((c) => c.estado == 'MORA')) {
      nuevoEstado = 'MORA';
    } else {
      nuevoEstado = 'ACTIVO';
    }

    await (database.update(database.prestamos)
          ..where((tbl) => tbl.id.equals(prestamoId)))
        .write(PrestamosCompanion(estado: Value(nuevoEstado)));
  }

  /// Genera mensaje del resultado
  String _generarMensajeResultado({
    required double montoAplicado,
    required int cuotasAfectadas,
    required int cuotasPagadas,
  }) {
    return 'Pago de Bs. $montoAplicado aplicado a $cuotasAfectadas cuota(s). '
        '$cuotasPagadas cuota(s) pagada(s) completamente.';
  }

  // Métodos de consulta básicos
  
  Future<List<PagoModel>> getPagos() async {
    final pagos = await database.select(database.pagos).get();
    return pagos.map((p) => PagoModel.fromDrift(p)).toList();
  }

  Future<PagoModel> getPagoById(int id) async {
    final pago = await (database.select(database.pagos)
          ..where((tbl) => tbl.id.equals(id)))
        .getSingleOrNull();
    
    if (pago == null) throw Exception('Pago no encontrado');
    return PagoModel.fromDrift(pago);
  }

  Future<List<PagoModel>> getPagosByPrestamo(int prestamoId) async {
    final pagos = await (database.select(database.pagos)
          ..where((tbl) => tbl.prestamoId.equals(prestamoId))
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.fechaPago)]))
        .get();
    
    return pagos.map((p) => PagoModel.fromDrift(p)).toList();
  }

  Future<List<DetallePagoModel>> getDetallesPago(int pagoId) async {
    final detalles = await (database.select(database.detallePagos)
          ..where((tbl) => tbl.pagoId.equals(pagoId))
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.numeroCuota)]))
        .get();
    
    return detalles.map((d) => DetallePagoModel.fromDrift(d)).toList();
  }

  Future<Map<String, double>> getResumenPagos(int prestamoId) async {
    final pagos = await getPagosByPrestamo(prestamoId);
    
    double totalPagado = 0;
    double totalMora = 0;
    double totalInteres = 0;
    double totalCapital = 0;

    for (final pago in pagos) {
      totalPagado += pago.montoTotal;
      totalMora += pago.montoMora;
      totalInteres += pago.montoInteres;
      totalCapital += pago.montoCapital;
    }

    return {
      'totalPagado': totalPagado,
      'totalMora': totalMora,
      'totalInteres': totalInteres,
      'totalCapital': totalCapital,
    };
  }
}