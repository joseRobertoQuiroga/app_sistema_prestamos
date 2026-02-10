import 'package:drift/drift.dart';
import '../../../../core/database/database.dart';
import '../services/excel_service.dart' as excel_svc;
import '../services/pdf_service.dart';
import '../services/importacion_service.dart';
import '../../domain/entities/reportes_entities.dart';

/// Data source local para operaciones de reportes
class ReportesLocalDataSource {
  final AppDatabase database;
  final excel_svc.ExcelService excelService;
  final PdfService pdfService;
  final ImportacionService importacionService;

  ReportesLocalDataSource({
    required this.database,
    required this.excelService,
    required this.pdfService,
    required this.importacionService,
  });

  // =========================================================================
  // GENERACIÓN DE REPORTES
  // =========================================================================

  /// Genera reporte de cartera completa
  Future<String> generarReporteCartera(
    ConfiguracionReporte config,
  ) async {
    final rango = config.getRango();

    // Obtener datos
    final prestamos = await (database.select(database.prestamos)
          ..where((tbl) =>
              tbl.fechaRegistro.isBiggerOrEqualValue(rango.start) &
              tbl.fechaRegistro.isSmallerOrEqualValue(rango.end)))
        .get();

    final totalPrestamos = prestamos.length;
    final prestamosActivos = prestamos.where((p) => p.estado == 'ACTIVO').length;
    final prestamosEnMora = prestamos.where((p) => p.estado == 'MORA').length;
    final prestamosPagados = prestamos.where((p) => p.estado == 'PAGADO').length;

    final carteraTotal = prestamos.fold<double>(
      0,
      (sum, p) => sum + p.montoTotal,
    );

    final capitalPorCobrar = prestamos.fold<double>(
      0,
      (sum, p) => sum + p.saldoPendiente,
    );

    final tasaMorosidad = totalPrestamos > 0
        ? (prestamosEnMora / totalPrestamos) * 100
        : 0.0;

    if (config.formato == FormatoReporte.pdf) {
      return await pdfService.generarReporteCartera(
        totalPrestamos: totalPrestamos,
        prestamosActivos: prestamosActivos,
        prestamosEnMora: prestamosEnMora,
        prestamosPagados: prestamosPagados,
        carteraTotal: carteraTotal,
        capitalPorCobrar: capitalPorCobrar,
        tasaMorosidad: tasaMorosidad,
        fechaInicio: rango.start,
        fechaFin: rango.end,
      );
    } else {
      // Excel: Exportar lista de préstamos
      final prestamosConJoin = await _getPrestamosConJoin(rango.start, rango.end);
      return await excelService.exportarPrestamos(prestamosConJoin);
    }
  }

  /// Genera reporte de mora detallada
  Future<String> generarReporteMora(
    ConfiguracionReporte config,
  ) async {
    final rango = config.getRango();

    // Obtener préstamos en mora con JOIN
    final query = database.select(database.prestamos).join([
      leftOuterJoin(
        database.clientes,
        database.clientes.id.equalsExp(database.prestamos.clienteId),
      ),
    ])
      ..where(database.prestamos.estado.equals('MORA'));

    final results = await query.get();

    final prestamosEnMora = results.map((row) {
      final prestamo = row.readTable(database.prestamos);
      final cliente = row.readTableOrNull(database.clientes);

      return PrestamoMora(
        codigo: prestamo.codigo,
        nombreCliente:
            cliente != null ? '${cliente.nombres} ${cliente.apellidos}' : 'N/A',
        diasMora: 0, // TODO: Calcular días de mora
        moraAcumulada: 0, // TODO: Sumar mora de cuotas
      );
    }).toList();

    final totalMoraAcumulada = prestamosEnMora.fold<double>(
      0,
      (sum, p) => sum + p.moraAcumulada,
    );

    if (config.formato == FormatoReporte.pdf) {
      return await pdfService.generarReporteMora(
        prestamosEnMora: prestamosEnMora,
        totalMoraAcumulada: totalMoraAcumulada,
        fechaInicio: rango.start,
        fechaFin: rango.end,
      );
    } else {
      // Excel
      final prestamosConJoin = await _getPrestamosConJoin(
        rango.start,
        rango.end,
        soloMora: true,
      );
      return await excelService.exportarPrestamos(prestamosConJoin);
    }
  }

  /// Genera reporte de movimientos de caja
  Future<String> generarReporteMovimientos(
    ConfiguracionReporte config,
  ) async {
    if (config.cajaId == null) {
      throw Exception('Debe especificar una caja');
    }

    final rango = config.getRango();

    // Obtener caja
    final caja = await (database.select(database.cajas)
          ..where((tbl) => tbl.id.equals(config.cajaId!)))
        .getSingle();

    // Obtener movimientos
    final movimientos = await (database.select(database.movimientos)
          ..where((tbl) =>
              tbl.cajaId.equals(config.cajaId!) &
              tbl.fecha.isBiggerOrEqualValue(rango.start) &
              tbl.fecha.isSmallerOrEqualValue(rango.end))
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.fecha)]))
        .get();

    final saldoInicial = caja.saldoInicial;
    final totalIngresos = movimientos
        .where((m) => m.tipo == 'INGRESO')
        .fold<double>(0, (sum, m) => sum + m.monto);
    final totalEgresos = movimientos
        .where((m) => m.tipo == 'EGRESO')
        .fold<double>(0, (sum, m) => sum + m.monto);
    final saldoFinal = caja.saldoActual;

    if (config.formato == FormatoReporte.pdf) {
      final movimientosResumen = movimientos.map((m) {
        return MovimientoResumen(
          fecha: m.fecha,
          tipo: m.tipo,
          descripcion: m.descripcion,
          monto: m.monto,
        );
      }).toList();

      return await pdfService.generarReporteMovimientos(
        nombreCaja: caja.nombre,
        saldoInicial: saldoInicial,
        totalIngresos: totalIngresos,
        totalEgresos: totalEgresos,
        saldoFinal: saldoFinal,
        movimientos: movimientosResumen,
        fechaInicio: rango.start,
        fechaFin: rango.end,
      );
    } else {
      // Excel
      final movimientosConJoin = await _getMovimientosConJoin(
        config.cajaId!,
        rango.start,
        rango.end,
      );
      return await excelService.exportarMovimientos(movimientosConJoin);
    }
  }

  /// Genera reporte de resumen de pagos
  Future<String> generarReportePagos(
    ConfiguracionReporte config,
  ) async {
    final rango = config.getRango();

    final pagos = await (database.select(database.pagos)
          ..where((tbl) =>
              tbl.fechaPago.isBiggerOrEqualValue(rango.start) &
              tbl.fechaPago.isSmallerOrEqualValue(rango.end)))
        .get();

    final totalPagos = pagos.length;
    final totalCobrado = pagos.fold<double>(0, (sum, p) => sum + p.montoPago);
    final totalCapital = pagos.fold<double>(0, (sum, p) => sum + p.montoCapital);
    final totalInteres = pagos.fold<double>(0, (sum, p) => sum + p.montoInteres);
    final totalMora = pagos.fold<double>(0, (sum, p) => sum + p.montoMora);

    // Agrupar por método de pago
    final pagosPorMetodo = <String, double>{};
    for (final pago in pagos) {
      pagosPorMetodo[pago.metodoPago] =
          (pagosPorMetodo[pago.metodoPago] ?? 0) + pago.montoPago;
    }

    if (config.formato == FormatoReporte.pdf) {
      return await pdfService.generarReportePagos(
        totalPagos: totalPagos,
        totalCobrado: totalCobrado,
        totalCapital: totalCapital,
        totalInteres: totalInteres,
        totalMora: totalMora,
        pagosPorMetodo: pagosPorMetodo,
        fechaInicio: rango.start,
        fechaFin: rango.end,
      );
    } else {
      // Excel
      final pagosConJoin = await _getPagosConJoin(rango.start, rango.end);
      return await excelService.exportarPagos(pagosConJoin);
    }
  }

  // =========================================================================
  // EXPORTACIÓN DE DATOS
  // =========================================================================

  /// Exporta clientes a Excel
  Future<String> exportarClientes() async {
    final clientes = await database.select(database.clientes).get();
    final clientesExport = clientes
        .map((c) => excel_svc.Cliente.fromDrift(c))
        .toList();
    return await excelService.exportarClientes(clientesExport);
  }

  /// Exporta préstamos a Excel
  Future<String> exportarPrestamos() async {
    final prestamos = await _getPrestamosConJoin(
      DateTime(2000),
      DateTime.now(),
    );
    return await excelService.exportarPrestamos(prestamos);
  }

  /// Exporta pagos a Excel
  Future<String> exportarPagos() async {
    final pagos = await _getPagosConJoin(
      DateTime(2000),
      DateTime.now(),
    );
    return await excelService.exportarPagos(pagos);
  }

  /// Exporta movimientos a Excel
  Future<String> exportarMovimientos() async {
    final movimientos = await _getMovimientosConJoin(
      null,
      DateTime(2000),
      DateTime.now(),
    );
    return await excelService.exportarMovimientos(movimientos);
  }

  // =========================================================================
  // PLANTILLAS
  // =========================================================================

  /// Genera plantilla de clientes
  Future<String> generarPlantillaClientes() async {
    return await excelService.generarPlantillaClientes();
  }

  /// Genera plantilla de préstamos
  Future<String> generarPlantillaPrestamos() async {
    return await excelService.generarPlantillaPrestamos();
  }

  // =========================================================================
  // IMPORTACIÓN
  // =========================================================================

  /// Importa clientes desde archivo Excel
  Future<ResultadoImportacion> importarClientes(String rutaArchivo) async {
    return await importacionService.importarClientes(
      rutaArchivo,
      (ci) async {
        final results = await (database.select(database.clientes)
              ..where((tbl) => tbl.numeroDocumento.equals(ci)))
            .get();
        return results.isNotEmpty;
      },
      (cliente) async {
        return await database.into(database.clientes).insert(
              ClientesCompanion.insert(
                nombres: cliente.nombre,
                apellidos: '',
                tipoDocumento: 'CI',
                numeroDocumento: cliente.ci,
                telefono: cliente.telefono ?? '',
                email: Value(cliente.email),
                direccion: cliente.direccion ?? '',
                referencia: Value(cliente.referencia),
                activo: Value(cliente.activo),
                fechaRegistro: Value(cliente.fechaRegistro),
              ),
            );
      },
    );
  }

  /// Importa préstamos desde archivo Excel
  Future<ResultadoImportacion> importarPrestamos(String rutaArchivo) async {
    return await importacionService.importarPrestamos(
      rutaArchivo,
      (ci) async {
        final results = await (database.select(database.clientes)
              ..where((tbl) => tbl.numeroDocumento.equals(ci)))
            .get();
        return results.isNotEmpty ? results.first.id : null;
      },
      (prestamo) async {
        // This is a stub - actual implementation would require full prestamo creation
        // For now just return a dummy ID
        return 0;
      },
    );
  }

  // =========================================================================
  // MÉTODOS DE AYUDA PARA JOINS
  // =========================================================================

  /// Obtiene préstamos con información de cliente y caja
  Future<List<excel_svc.Prestamo>> _getPrestamosConJoin(
    DateTime inicio,
    DateTime fin, {
    bool soloMora = false,
  }) async {
    final query = database.select(database.prestamos).join([
      leftOuterJoin(
        database.clientes,
        database.clientes.id.equalsExp(database.prestamos.clienteId),
      ),
      leftOuterJoin(
        database.cajas,
        database.cajas.id.equalsExp(database.prestamos.cajaId),
      ),
    ])
      ..where(
        database.prestamos.fechaRegistro.isBiggerOrEqualValue(inicio) &
            database.prestamos.fechaRegistro.isSmallerOrEqualValue(fin),
      );

    if (soloMora) {
      query.where(database.prestamos.estado.equals('MORA'));
    }

    final results = await query.get();

    return results.map((row) {
      final prestamo = row.readTable(database.prestamos);
      final cliente = row.readTableOrNull(database.clientes);
      final caja = row.readTableOrNull(database.cajas);

      return excel_svc.Prestamo(
        codigo: prestamo.codigo,
        nombreCliente: cliente != null
            ? '${cliente.nombres} ${cliente.apellidos}'
            : null,
        nombreCaja: caja?.nombre,
        montoOriginal: prestamo.montoOriginal,
        montoTotal: prestamo.montoTotal,
        saldoPendiente: prestamo.saldoPendiente,
        tasaInteres: prestamo.tasaInteres,
        tipoInteres: prestamo.tipoInteres,
        plazoMeses: prestamo.plazoMeses,
        cuotaMensual: prestamo.cuotaMensual,
        fechaInicio: prestamo.fechaInicio,
        fechaVencimiento: prestamo.fechaVencimiento,
        estado: prestamo.estado,
        fechaRegistro: prestamo.fechaRegistro,
      );
    }).toList();
  }

  /// Obtiene pagos con información de préstamo, cliente y caja
  Future<List<excel_svc.Pago>> _getPagosConJoin(
    DateTime inicio,
    DateTime fin,
  ) async {
    final query = database.select(database.pagos).join([
      leftOuterJoin(
        database.prestamos,
        database.prestamos.id.equalsExp(database.pagos.prestamoId),
      ),
      leftOuterJoin(
        database.clientes,
        database.clientes.id.equalsExp(database.pagos.clienteId),
      ),
      leftOuterJoin(
        database.cajas,
        database.cajas.id.equalsExp(database.pagos.cajaId),
      ),
    ])
      ..where(
        database.pagos.fechaPago.isBiggerOrEqualValue(inicio) &
            database.pagos.fechaPago.isSmallerOrEqualValue(fin),
      );

    final results = await query.get();

    return results.map((row) {
      final pago = row.readTable(database.pagos);
      final prestamo = row.readTableOrNull(database.prestamos);
      final cliente = row.readTableOrNull(database.clientes);
      final caja = row.readTableOrNull(database.cajas);

      return excel_svc.Pago(
        codigo: pago.codigo,
        codigoPrestamo: prestamo?.codigo,
        nombreCliente: cliente != null
            ? '${cliente.nombres} ${cliente.apellidos}'
            : null,
        nombreCaja: caja?.nombre,
        montoPago: pago.montoPago,
        montoCapital: pago.montoCapital,
        montoInteres: pago.montoInteres,
        montoMora: pago.montoMora,
        fechaPago: pago.fechaPago,
        metodoPago: pago.metodoPago,
        observaciones: pago.observaciones,
        fechaRegistro: pago.fechaRegistro,
      );
    }).toList();
  }

  /// Obtiene movimientos con información de caja
  Future<List<excel_svc.Movimiento>> _getMovimientosConJoin(
    int? cajaId,
    DateTime inicio,
    DateTime fin,
  ) async {
    final query = database.select(database.movimientos).join([
      leftOuterJoin(
        database.cajas,
        database.cajas.id.equalsExp(database.movimientos.cajaId),
      ),
    ])
      ..where(
        database.movimientos.fecha.isBiggerOrEqualValue(inicio) &
            database.movimientos.fecha.isSmallerOrEqualValue(fin),
      );

    if (cajaId != null) {
      query.where(database.movimientos.cajaId.equals(cajaId));
    }

    final results = await query.get();

    return results.map((row) {
      final movimiento = row.readTable(database.movimientos);
      final caja = row.readTableOrNull(database.cajas);

      return excel_svc.Movimiento(
        codigo: movimiento.codigo,
        nombreCaja: caja?.nombre,
        tipo: movimiento.tipo,
        categoria: movimiento.categoria,
        monto: movimiento.monto,
        saldoAnterior: movimiento.saldoAnterior,
        saldoNuevo: movimiento.saldoNuevo,
        descripcion: movimiento.descripcion,
        fecha: movimiento.fecha,
        fechaRegistro: movimiento.fechaRegistro,
      );
    }).toList();
  }
}