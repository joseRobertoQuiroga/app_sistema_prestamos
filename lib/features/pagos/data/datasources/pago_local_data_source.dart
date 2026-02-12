import 'package:drift/drift.dart';
import '../models/pago_model.dart';
import '../../domain/entities/resultado_aplicacion_pago.dart';
import '../../domain/entities/detalle_pago.dart';
import '../../../../core/database/database.dart' as db;

/// Data Source Local de Pagos
/// ✅ CORREGIDO: Movimientos con código, saldoAnterior y saldoNuevo
/// 
/// Implementa la lógica de aplicación en cascada:
/// Mora → Interés → Capital
class PagoLocalDataSource {
  final db.AppDatabase database;

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
      // 0. Obtener clienteId del préstamo (requerido por Drift)
      final prestamo = await (database.select(database.prestamos)
            ..where((tbl) => tbl.id.equals(prestamoId)))
          .getSingle();

      final clienteId = prestamo.clienteId;

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
            db.PagosCompanion.insert(
              prestamoId: prestamoId,
              clienteId: clienteId, // ✅ Campo requerido
              codigo: codigo,
              montoPago: monto,
              montoMora: Value(resultado.totalMora),
              montoInteres: resultado.totalInteres,
              montoCapital: resultado.totalCapital,
              fechaPago: fechaPago,
              cajaId: cajaId ?? 1,
              metodoPago: metodoPago ?? 'EFECTIVO',
              observaciones: Value(observaciones),
              fechaRegistro: Value(DateTime.now()),
            ),
          );

      // 5. Guardar los detalles de aplicación
      for (final detalle in resultado.detalles) {
        await database.into(database.detallePagos).insert(
              db.DetallePagosCompanion.insert(
                pagoId: pagoId,
                cuotaId: detalle.cuotaId,
                // ✅ Drift solo guarda montoAplicado y montoMora
                montoAplicado: detalle.montoTotal,
                montoMora: Value(detalle.montoMora),
                fechaRegistro: Value(DateTime.now()),
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
          pagoId: pagoId,
        );
      }

      // 7. Actualizar estados de cuotas y préstamo
      await _actualizarEstados(prestamoId);

      return resultado;
    });
  }

  /// Aplica el pago en cascada sobre las cuotas
  /// Usa db.Cuota en lugar de CuotaData
  Future<ResultadoAplicacionPago> _aplicarPagoEnCascada({
    required List<db.Cuota> cuotas,
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
      // ✅ CORREGIDO: Sumar Capital e Interés al monto pagado
      final nuevoMontoPagado = cuota.montoPagado + montoInteres + montoCapital;
      
      // ✅ CORREGIDO: Acumular la mora pagada
      final nuevaMoraPagada = cuota.montoMora + montoMora;
      
      await (database.update(database.cuotas)
            ..where((tbl) => tbl.id.equals(cuota.id)))
          .write(
        db.CuotasCompanion(
          montoPagado: Value(nuevoMontoPagado),
          montoMora: Value(nuevaMoraPagada),
          fechaPago: Value(fechaPago),
          estado: Value(_determinarEstadoCuota(
            interesTotal: cuota.interes,
            capitalTotal: cuota.capital,
            montoPagado: nuevoMontoPagado, // Ya incluye interés + capital
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
  /// Usa db.Cuota en lugar de CuotaData
  Future<List<db.Cuota>> _getCuotasPendientesOrdenadas(int prestamoId) async {
    return await (database.select(database.cuotas)
          ..where((tbl) => tbl.prestamoId.equals(prestamoId))
          ..where((tbl) => tbl.estado.isNotValue('PAGADA'))
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.fechaVencimiento)]))
        .get();
  }

  /// Calcula la mora acumulada de una cuota
  double _calcularMora(db.Cuota cuota, DateTime fechaPago) {
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
    required double capitalTotal,
    required double montoPagado,
    required DateTime fechaVencimiento,
    required DateTime fechaPago,
  }) {
    // Si se pagó todo el capital + interés
    if (montoPagado >= (interesTotal + capitalTotal - 0.01)) { // Tolerancia por decimales
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
    
    final count = database.selectOnly(database.pagos)
      ..addColumns([database.pagos.id.count()]);
    
    final result = await count.getSingle();
    final total = result.read(database.pagos.id.count()) ?? 0;
    final numero = (total + 1).toString().padLeft(4, '0');
    
    return 'PAG-$yearMonth-$numero';
  }

  /// Registra el movimiento en la caja
  /// ✅ CORREGIDO: Incluye código, saldoAnterior y saldoNuevo
  Future<void> _registrarMovimientoEnCaja({
    required int cajaId,
    required double monto,
    required String descripcion,
    required DateTime fechaPago,
    required int pagoId,
  }) async {
    // Obtener caja actual
    final caja = await (database.select(database.cajas)
          ..where((tbl) => tbl.id.equals(cajaId)))
        .getSingle();

    // ✅ Usar saldoActual (no saldo)
    final saldoAnterior = caja.saldoActual;
    final saldoNuevo = saldoAnterior + monto;

    // ✅ Generar código único para el movimiento
    final now = DateTime.now();
    final codigo = 'MOV-${now.year}${now.month.toString().padLeft(2, '0')}-${now.millisecondsSinceEpoch.toString().substring(8)}';

    // Registrar movimiento de ingreso
    await database.into(database.movimientos).insert(
      db.MovimientosCompanion.insert(
        codigo: codigo, // ✅ Campo obligatorio
        cajaId: cajaId,
        tipo: 'INGRESO',
        categoria: 'PAGO',
        monto: monto,
        descripcion: descripcion,
        fecha: fechaPago,
        // ✅ Campos agregados: saldoAnterior y saldoNuevo
        saldoAnterior: saldoAnterior,
        saldoNuevo: saldoNuevo,
        pagoId: Value(pagoId), // pagoId es nullable, usar Value
        fechaRegistro: Value(DateTime.now()),
        // Observaciones mapeado a referencia si existe, aqui descripcion esta en descripcion.
        // Movimientos tiene observaciones? Sí, para referencia.
      ),
    );

    // Actualizar saldo de caja
    await (database.update(database.cajas)
          ..where((tbl) => tbl.id.equals(cajaId)))
        .write(db.CajasCompanion(
          saldoActual: Value(saldoNuevo), // ✅ Usar saldoActual
          fechaActualizacion: Value(DateTime.now()),
        ));
  }

  /// Actualiza estados de cuotas y préstamo
  Future<void> _actualizarEstados(int prestamoId) async {
    final hoy = DateTime.now();

    // 1. Actualizar estados de cuotas vencidas (solo si siguen PENDIENTE)
    await (database.update(database.cuotas)
          ..where((tbl) => 
              tbl.prestamoId.equals(prestamoId) &
              tbl.fechaVencimiento.isSmallerThanValue(hoy) &
              tbl.estado.equals('PENDIENTE')))
        .write(const db.CuotasCompanion(estado: Value('MORA')));

    // 2. Obtener todas las cuotas paara recalcular totales
    final cuotas = await (database.select(database.cuotas)
          ..where((tbl) => tbl.prestamoId.equals(prestamoId)))
        .get();

    if (cuotas.isEmpty) return;

    // 3. Calcular totales reales sumando las cuotas
    double totalPagadoReal = 0;
    bool tieneMora = false;
    bool todasPagadas = true;

    for (final c in cuotas) {
      totalPagadoReal += c.montoPagado;
      
      if (c.estado == 'MORA') tieneMora = true;
      if (c.estado != 'PAGADA') todasPagadas = false;
    }

    // 4. Determinar nuevo estado del préstamo
    String nuevoEstado;
    if (todasPagadas) {
      nuevoEstado = 'PAGADO';
    } else if (tieneMora) {
      nuevoEstado = 'MORA';
    } else {
      nuevoEstado = 'ACTIVO';
    }

    // 5. Obtener préstamo actual para saldo base
    final prestamo = await (database.select(database.prestamos)
          ..where((tbl) => tbl.id.equals(prestamoId)))
        .getSingle();

    // 6. Recalcular saldo pendiente
    // Nota: saldoPendiente = montoTotal (con interés) - totalPagadoReal
    // Aseguramos que no sea negativo por errores de redondeo
    double nuevoSaldoPendiente = prestamo.montoTotal - totalPagadoReal;
    if (nuevoSaldoPendiente < 0) nuevoSaldoPendiente = 0;

    // 7. Actualizar préstamo con TODOS los datos recalculados
    await (database.update(database.prestamos)
          ..where((tbl) => tbl.id.equals(prestamoId)))
        .write(db.PrestamosCompanion(
          estado: Value(nuevoEstado),
          saldoPendiente: Value(nuevoSaldoPendiente),
          // Si tuvieras un campo montoPagado en la tabla prestamos, lo actualizarías aquí también.
          // Como drift/database.dart define las tablas, asumimos que se deriva o se guarda si existe campo.
          // Revisando Prestamo entity: tiene saldoPendiente.
          fechaActualizacion: Value(DateTime.now()),
        ));
  }

  /// Genera mensaje del resultado
  String _generarMensajeResultado({
    required double montoAplicado,
    required int cuotasAfectadas,
    required int cuotasPagadas,
  }) {
    return 'Pago de Bs. ${montoAplicado.toStringAsFixed(2)} aplicado a $cuotasAfectadas cuota(s). '
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
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.id)]))
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