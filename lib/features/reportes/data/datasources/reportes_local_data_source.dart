import 'package:drift/drift.dart';
import 'package:intl/intl.dart';
import '../../../../core/database/database.dart';
import '../services/excel_service.dart' as excel_svc;
import '../services/pdf_service.dart';
import '../services/importacion_service.dart';
import '../../domain/entities/reportes_entities.dart';
import '../../../clientes/domain/entities/cliente.dart' as cliente_entity;

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
  // GENERACIÓN DE REPORTES (sin cambios - mantiene tu código)
  // =========================================================================

  Future<String> generarReporteCartera(ConfiguracionReporte config) async {
    final rango = config.getRango();
    
    // Fetch loans with client names
    final query = database.select(database.prestamos).join([
      leftOuterJoin(database.clientes, database.clientes.id.equalsExp(database.prestamos.clienteId)),
    ])..where(
        (database.prestamos.fechaRegistro.isBiggerOrEqualValue(rango.start) &
        database.prestamos.fechaRegistro.isSmallerOrEqualValue(rango.end)) &
        (database.prestamos.estado.equals('ACTIVO') | database.prestamos.estado.equals('MORA'))
    );

    final results = await query.get();
    print('REPORT_DS: Cartera - Encontrados ${results.length} préstamos en rango');
    
    // Fetch all payments for these loans to calculate actual totals
    final prestamoIds = results.map((r) => r.readTable(database.prestamos).id).toList();
    final pagosMap = <int, double>{};
    
    if (prestamoIds.isNotEmpty) {
      final pagos = await (database.select(database.pagos)
            ..where((tbl) => tbl.prestamoId.isIn(prestamoIds)))
          .get();
      for (final pago in pagos) {
        pagosMap[pago.prestamoId] = (pagosMap[pago.prestamoId] ?? 0) + pago.montoPago;
      }
    }

    final prestamosList = <PrestamoCartera>[];
    int totalPrestamos = results.length;
    int prestamosActivos = 0;
    int prestamosEnMora = 0;
    int prestamosPagados = 0;
    double carteraTotal = 0;
    double capitalPorCobrar = 0;

    for (final row in results) {
      final p = row.readTable(database.prestamos);
      final c = row.readTableOrNull(database.clientes);
      final nombreCliente = c != null ? '${c.nombres} ${c.apellidos}' : 'N/A';
      final totalPagado = pagosMap[p.id] ?? 0;

      // Counts
      if (p.estado == 'ACTIVO') prestamosActivos++;
      if (p.estado == 'MORA') prestamosEnMora++;
      if (p.estado == 'PAGADO') prestamosPagados++;

      // Calculations - Improved for Wilson accuracy (Total actual = pagado + pendiente)
      final actualTotal = p.tipoInteres == 'WILSON' 
          ? (totalPagado + p.saldoPendiente) 
          : p.montoTotal;
          
      carteraTotal += actualTotal;
      capitalPorCobrar += p.saldoPendiente;

      prestamosList.add(PrestamoCartera(
        codigo: p.codigo,
        nombreCliente: nombreCliente,
        montoOriginal: p.montoOriginal,
        saldoPendiente: p.saldoPendiente,
        montoPagado: totalPagado,
      ));
    }

    final tasaMorosidad = totalPrestamos > 0 ? (prestamosEnMora / totalPrestamos) * 100 : 0.0;

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
        prestamos: prestamosList,
      );
    } else {
      final prestamosConJoin = await _getPrestamosConJoin(rango.start, rango.end);
      return await excelService.exportarPrestamos(prestamosConJoin);
    }
  }

  Future<String> generarReporteMora(ConfiguracionReporte config) async {
    final rango = config.getRango();
    final query = database.select(database.prestamos).join([
      leftOuterJoin(database.clientes, database.clientes.id.equalsExp(database.prestamos.clienteId)),
    ])..where(database.prestamos.estado.equals('MORA'));

    final results = await query.get();
    print('REPORT_DS: Mora - Encontrados ${results.length} préstamos en mora');
    final now = DateTime.now();

    final prestamosEnMora = <PrestamoMora>[];
    for (final row in results) {
      final prestamo = row.readTable(database.prestamos);
      final cliente = row.readTableOrNull(database.clientes);
      
      double totalMora = 0;
      int diasMora = 0;

      if (prestamo.tipoInteres.toUpperCase() == 'WILSON') {
        // Cálculo de mora Wilson: Interés mensual * (días retraso / 30)
        final ultimoPago = await (database.select(database.pagos)
              ..where((tbl) => tbl.prestamoId.equals(prestamo.id))
              ..orderBy([(tbl) => OrderingTerm.desc(tbl.fechaPago)])
              ..limit(1))
            .getSingleOrNull();

        final fechaReferencia = ultimoPago?.fechaPago ?? prestamo.fechaInicio;
        final diferenciaDias = now.difference(fechaReferencia).inDays;

        if (diferenciaDias > 30) {
          diasMora = diferenciaDias - 30;
          final interesMensual = prestamo.saldoPendiente * (prestamo.tasaInteres / 100);
          totalMora = (interesMensual * diasMora / 30).ceil().toDouble();
        }
      } else {
        // Obtener cuotas para calcular mora exacta de préstamos normales
        final cuotas = await (database.select(database.cuotas)
              ..where((tbl) => tbl.prestamoId.equals(prestamo.id)))
            .get();
            
        totalMora = cuotas.fold<double>(0, (sum, c) => sum + (c.montoMora));
        diasMora = now.isAfter(prestamo.fechaVencimiento)
            ? now.difference(prestamo.fechaVencimiento).inDays
            : 0;
            
        // Si no ha vencido el préstamo pero hay cuotas en mora, buscar la más antigua
        if (diasMora == 0) {
          final cuotasMora = cuotas.where((c) => c.estado == 'MORA').toList();
          if (cuotasMora.isNotEmpty) {
            cuotasMora.sort((a, b) => a.fechaVencimiento.compareTo(b.fechaVencimiento));
            diasMora = now.difference(cuotasMora.first.fechaVencimiento).inDays;
          }
        }
      }

      prestamosEnMora.add(PrestamoMora(
        codigo: prestamo.codigo,
        nombreCliente: cliente != null ? '${cliente.nombres} ${cliente.apellidos}' : 'N/A',
        diasMora: diasMora,
        moraAcumulada: totalMora,
      ));
    }

    final totalMoraAcumulada = prestamosEnMora.fold<double>(0, (sum, p) => sum + p.moraAcumulada);

    if (config.formato == FormatoReporte.pdf) {
      return await pdfService.generarReporteMora(
        prestamosEnMora: prestamosEnMora,
        totalMoraAcumulada: totalMoraAcumulada,
        fechaInicio: rango.start,
        fechaFin: rango.end,
      );
    } else {
      final prestamosConJoin = await _getPrestamosConJoin(rango.start, rango.end, soloMora: true);
      return await excelService.exportarPrestamos(prestamosConJoin);
    }
  }

  Future<String> generarReporteMovimientos(ConfiguracionReporte config) async {
    final rango = config.getRango();
    
    // Obtener movimientos según filtros
    final query = database.select(database.movimientos);
    
    if (config.cajaId != null) {
      query.where((tbl) => tbl.cajaId.equals(config.cajaId!));
    }
    
    query.where((tbl) => 
      tbl.fecha.isBiggerOrEqualValue(rango.start) & 
      tbl.fecha.isSmallerOrEqualValue(rango.end)
    );

    // Filtrar por tipo si es resumen de ingresos o egresos
    if (config.tipo == TipoReporte.resumenIngresos) {
      query.where((tbl) => tbl.tipo.equals('INGRESO'));
    } else if (config.tipo == TipoReporte.resumenEgresos) {
      query.where((tbl) => tbl.tipo.equals('EGRESO'));
    }

    // Ordenar por categoría y luego por fecha para facilitar lectura agrupada
    query.orderBy([(tbl) => OrderingTerm.asc(tbl.categoria), (tbl) => OrderingTerm.asc(tbl.fecha)]);

    final movimientos = await query.get();
    print('REPORT_DS: Movimientos - Encontrados ${movimientos.length} registros');

    String nombreCaja = 'Consolidado General';
    double saldoInicial = 0;
    double saldoFinal = 0;

    if (config.cajaId != null) {
      final caja = await (database.select(database.cajas)..where((tbl) => tbl.id.equals(config.cajaId!))).getSingle();
      nombreCaja = caja.nombre;
      saldoInicial = caja.saldoInicial;
      saldoFinal = caja.saldoActual;
    }

    final totalIngresos = movimientos.where((m) => m.tipo == 'INGRESO').fold<double>(0, (sum, m) => sum + m.monto);
    final totalEgresos = movimientos.where((m) => m.tipo == 'EGRESO').fold<double>(0, (sum, m) => sum + m.monto);

    if (config.formato == FormatoReporte.pdf) {
      final movimientosResumen = movimientos.map((m) {
        return MovimientoResumen(
          fecha: m.fecha,
          tipo: m.tipo,
          descripcion: m.descripcion,
          categoria: m.categoria,
          monto: m.monto,
        );
      }).toList();

      final tituloReporte = config.tipo == TipoReporte.resumenIngresos 
          ? 'RESUMEN DE INGRESOS' 
          : config.tipo == TipoReporte.resumenEgresos 
              ? 'RESUMEN DE EGRESOS' 
              : 'REPORTE DE MOVIMIENTOS';

      return await pdfService.generarReporteMovimientos(
        nombreCaja: nombreCaja,
        saldoInicial: saldoInicial,
        totalIngresos: totalIngresos,
        totalEgresos: totalEgresos,
        saldoFinal: saldoFinal,
        movimientos: movimientosResumen,
        fechaInicio: rango.start,
        fechaFin: rango.end,
        tituloReporte: tituloReporte,
      );
    } else {
      final movimientosConJoin = await _getMovimientosConJoin(config.cajaId, rango.start, rango.end);
      
      // Filtrar el join también si es necesario
      var filtrados = movimientosConJoin;
      if (config.tipo == TipoReporte.resumenIngresos) {
        filtrados = filtrados.where((m) => m.tipo == 'INGRESO').toList();
      } else if (config.tipo == TipoReporte.resumenEgresos) {
        filtrados = filtrados.where((m) => m.tipo == 'EGRESO').toList();
      }
      
      // Ordenar por categoría para Excel
      filtrados.sort((a, b) => a.categoria.compareTo(b.categoria));
      
      return await excelService.exportarMovimientos(filtrados);
    }
  }

  Future<String> generarReportePagos(ConfiguracionReporte config) async {
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

    final pagosPorMetodo = <String, double>{};
    for (final pago in pagos) {
      pagosPorMetodo[pago.metodoPago] = (pagosPorMetodo[pago.metodoPago] ?? 0) + pago.montoPago;
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
      final pagosConJoin = await _getPagosConJoin(rango.start, rango.end);
      return await excelService.exportarPagos(pagosConJoin);
    }
  }

  // =========================================================================
  // ✅ NUEVOS REPORTES
  // =========================================================================

  Future<String> generarReporteEstadoCuenta(ConfiguracionReporte config) async {
    if (config.clienteId == null) throw Exception('Debe seleccionar un cliente');

    final rango = config.getRango();
    
    // Obtener cliente
    final cliente = await (database.select(database.clientes)
          ..where((tbl) => tbl.id.equals(config.clienteId!)))
        .getSingle();

    // Obtener préstamos del cliente
    final prestamos = await (database.select(database.prestamos)
          ..where((tbl) => tbl.clienteId.equals(config.clienteId!))
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.fechaRegistro)]))
        .get();

    final pagos = await (database.select(database.pagos)
          ..where((tbl) => tbl.clienteId.equals(config.clienteId!))
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.fechaPago)]))
        .get();

    if (config.formato == FormatoReporte.pdf) {
      // Construir listas tipadas para el PDF
      final pagosResumen = pagos.map((p) {
        final prestamoCod = prestamos.firstWhere(
          (pr) => pr.id == p.prestamoId,
          orElse: () => prestamos.first,
        );
        return PagoResumen(
          fecha: p.fechaPago,
          codigoPrestamo: prestamoCod.codigo,
          monto: p.montoPago,
          montoCapital: p.montoCapital,
          montoInteres: p.montoInteres,
          metodoPago: p.metodoPago,
        );
      }).toList();

      final prestamosResumen = prestamos.map((p) => PrestamoResumen(
        codigo: p.codigo,
        montoOriginal: p.montoOriginal,
        saldoPendiente: p.saldoPendiente,
        estado: p.estado,
      )).toList();

      return await pdfService.generarReporteEstadoCuentaCliente(
        nombreCliente: '${cliente.nombres} ${cliente.apellidos}',
        documentoCliente: cliente.numeroDocumento,
        pagos: pagosResumen,
        prestamos: prestamosResumen,
        fechaInicio: rango.start,
        fechaFin: rango.end,
      );
    } else {
      // Construir items para Excel (lógica original)
      final items = <excel_svc.ItemEstadoCuenta>[];
      double saldoAcumulado = 0;

      for (final p in prestamos) {
        saldoAcumulado += p.montoTotal;
        items.add(excel_svc.ItemEstadoCuenta(
          fecha: p.fechaInicio,
          concepto: 'Préstamo ${p.codigo}',
          monto: p.montoTotal,
          saldo: saldoAcumulado,
          tipo: 'CARGO',
        ));
      }

      for (final p in pagos) {
        saldoAcumulado -= p.montoPago;
        items.add(excel_svc.ItemEstadoCuenta(
          fecha: p.fechaPago,
          concepto: 'Pago ${p.codigo} (${p.metodoPago})',
          monto: -p.montoPago,
          saldo: saldoAcumulado,
          tipo: 'ABONO',
        ));
      }

      items.sort((a, b) => a.fecha.compareTo(b.fecha));
      return await excelService.exportarEstadoCuentaCliente(items);
    }
  }

  Future<String> generarReporteProyeccion(ConfiguracionReporte config) async {
    final rango = config.getRango();
    final now = DateTime.now();
    
    // Obtener préstamos activos para proyectar cobros
    final query = database.select(database.prestamos).join([
      leftOuterJoin(database.clientes, database.clientes.id.equalsExp(database.prestamos.clienteId)),
    ])..where(database.prestamos.estado.isIn(['ACTIVO', 'Activo', 'MORA', 'En Mora', 'Mora', 'VENCIDA', 'Vencida']));

    final results = await query.get();
    final pdfItems = <ProyeccionItem>[];
    double totalProyectado = 0;

    for (final row in results) {
      final prestamo = row.readTable(database.prestamos);
      final cliente = row.readTableOrNull(database.clientes);
      final nombreCliente = cliente != null ? '${cliente.nombres} ${cliente.apellidos}' : 'N/A';

      if (prestamo.tipoInteres.toUpperCase() == 'WILSON') {
        // Proyección Wilson: Interés mensual sobre saldo pendiente
        final ultimoPago = await (database.select(database.pagos)
              ..where((tbl) => tbl.prestamoId.equals(prestamo.id))
              ..orderBy([(tbl) => OrderingTerm.desc(tbl.fechaPago)])
              ..limit(1))
            .getSingleOrNull();

        final fechaReferencia = ultimoPago?.fechaPago ?? prestamo.fechaInicio;
        final proximoVencimiento = DateTime(fechaReferencia.year, fechaReferencia.month + 1, fechaReferencia.day);
        
        // Si el próximo pago cae en el rango o ya pasó (mora)
        if (proximoVencimiento.isBefore(rango.end)) {
          final interesMensual = prestamo.saldoPendiente * (prestamo.tasaInteres / 100);
          final diasFaltantes = proximoVencimiento.difference(now).inDays;
          final enMora = now.isAfter(proximoVencimiento);
          final diasMora = enMora ? now.difference(proximoVencimiento).inDays : 0;

          pdfItems.add(ProyeccionItem(
            fechaVencimiento: proximoVencimiento,
            nombreCliente: nombreCliente,
            codigoPrestamo: prestamo.codigo,
            numeroCuota: 0,
            montoCuota: interesMensual,
            diasFaltantes: diasFaltantes,
            enMora: enMora,
            diasMora: diasMora,
          ));
          totalProyectado += interesMensual;
        }
      } else {
        // Préstamos con cuotas: Buscar cuotas pendientes
        final cuotas = await (database.select(database.cuotas)
              ..where((tbl) => tbl.prestamoId.equals(prestamo.id) & 
                               tbl.estado.isNotIn(['PAGADA', 'CANCELADA', 'Pagada', 'Cancelada', 'pagada', 'cancelada'])))
            .get();

        print('DEBUG PRY - Préstamo ${prestamo.codigo}: ${cuotas.length} cuotas no pagadas encontradas.');

        for (final cuota in cuotas) {
          final isBeforeEnd = cuota.fechaVencimiento.isBefore(rango.end);
          print('DEBUG PRY - Cuota ${cuota.numeroCuota}: vence ${cuota.fechaVencimiento}. Is before ${rango.end}? $isBeforeEnd');
          if (isBeforeEnd) {
            final diasFaltantes = cuota.fechaVencimiento.difference(now).inDays;
            final enMora = cuota.estado.toUpperCase() == 'MORA' || cuota.estado.toUpperCase() == 'EN MORA' || now.isAfter(cuota.fechaVencimiento);
            final diasMora = enMora ? now.difference(cuota.fechaVencimiento).inDays : 0;

            pdfItems.add(ProyeccionItem(
              fechaVencimiento: cuota.fechaVencimiento,
              nombreCliente: nombreCliente,
              codigoPrestamo: prestamo.codigo,
              numeroCuota: cuota.numeroCuota,
              montoCuota: cuota.montoCuota,
              diasFaltantes: diasFaltantes,
              enMora: enMora,
              diasMora: diasMora,
            ));
            totalProyectado += cuota.montoCuota;
          }
        }
      }

    }

    // Ordenar por fecha de vencimiento
    pdfItems.sort((a, b) => a.fechaVencimiento.compareTo(b.fechaVencimiento));

    if (config.formato == FormatoReporte.pdf) {
      return await pdfService.generarReporteProyeccionCobros(
        items: pdfItems,
        totalProyectado: totalProyectado,
        totalCuotas: pdfItems.length,
        fechaInicio: rango.start,
        fechaFin: rango.end,
      );
    } else {
      return await excelService.generarExcelGenerico(
        titulo: 'Proyección de Cobros',
        headers: ['Vencimiento', 'Cliente', 'Préstamo', 'Monto'],
        rows: pdfItems.map((i) => [
          DateFormat('dd/MM/yy').format(i.fechaVencimiento),
          i.nombreCliente,
          i.codigoPrestamo,
          i.montoCuota.toStringAsFixed(2),
        ]).toList(),
      );
    }
  }

  Future<String> generarReporteResumenPrestamo(ConfiguracionReporte config) async {
    if (config.prestamoId == null) throw Exception('Debe seleccionar un préstamo');

    final prestamo = await (database.select(database.prestamos)
          ..where((tbl) => tbl.id.equals(config.prestamoId!)))
        .getSingle();
    
    final cliente = await (database.select(database.clientes)
          ..where((tbl) => tbl.id.equals(prestamo.clienteId)))
        .getSingle();

    final pagos = await (database.select(database.pagos)
          ..where((tbl) => tbl.prestamoId.equals(prestamo.id))
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.fechaPago)]))
        .get();

    double totalPagado = 0;
    double capitalRestante = prestamo.montoOriginal;
    final List<List<String>> reportRows = [];
    
    for (final p in pagos) {
      totalPagado += p.montoPago;
      capitalRestante -= p.montoCapital;
      
      reportRows.add([
        DateFormat('dd/MM/yyyy').format(p.fechaPago),
        p.codigo,
        'Bs. ${p.montoPago.toStringAsFixed(2)}',
        'Bs. ${p.montoCapital.toStringAsFixed(2)}',
        'Bs. ${p.montoInteres.toStringAsFixed(2)}',
        'Bs. ${p.montoMora.toStringAsFixed(2)}',
        'Bs. ${capitalRestante.toStringAsFixed(2)}',
      ]);
    }

    if (config.formato == FormatoReporte.pdf) {
      return await pdfService.generarPdfTabla(
        titulo: 'RESUMEN EJECUTIVO DE PRÉSTAMO',
        subtitulo: 'Préstamo: ${prestamo.codigo} - Cliente: ${cliente.nombres} ${cliente.apellidos}\n'
                  'Monto Original: Bs. ${prestamo.montoOriginal.toStringAsFixed(2)} | '
                  'Total Pagado: Bs. ${totalPagado.toStringAsFixed(2)} | '
                  'Saldo Pendiente: Bs. ${prestamo.saldoPendiente.toStringAsFixed(2)}',
        headers: ['Fecha', 'Código Pago', 'Monto', 'Capital', 'Interés', 'Mora', 'Saldo Cap.'],
        rows: reportRows,
        nombreArchivo: 'Resumen_Prestamo_${prestamo.codigo}',
      );
    } else {
      final items = pagos.map((p) => excel_svc.Pago(
        codigo: p.codigo,
        codigoPrestamo: prestamo.codigo,
        nombreCliente: '${cliente.nombres} ${cliente.apellidos}',
        montoPago: p.montoPago,
        montoCapital: p.montoCapital,
        montoInteres: p.montoInteres,
        montoMora: p.montoMora,
        fechaPago: p.fechaPago,
        metodoPago: p.metodoPago,
        observaciones: p.observaciones,
        fechaRegistro: p.fechaRegistro,
      )).toList();
      return await excelService.exportarPagos(items);
    }
  }

  Future<String> generarReporteCancelados(ConfiguracionReporte config) async {
    final rango = config.getRango();
    final prestamos = await _getPrestamosConJoin(rango.start, rango.end);
    
    // Filtrar pagados o cancelados
    final cancelados = prestamos.where((p) => p.estado == 'PAGADO' || p.estado == 'CANCELADO').toList();

    // Obtener pagos para calcular totales reales de Wilson
    final prestamoIds = cancelados.map((p) => p.id).whereType<int>().toList();
    final pagosMap = <int, double>{};
    
    if (prestamoIds.isNotEmpty) {
      final pagos = await (database.select(database.pagos)
            ..where((tbl) => tbl.prestamoId.isIn(prestamoIds)))
          .get();
      for (final pago in pagos) {
        pagosMap[pago.prestamoId] = (pagosMap[pago.prestamoId] ?? 0) + pago.montoPago;
      }
    }

    if (config.formato == FormatoReporte.pdf) {
      double granTotalPagado = 0;
      final rows = cancelados.map<List<String>>((p) {
        final totalPagado = p.tipoInteres == 'WILSON' 
            ? (pagosMap[p.id] ?? 0) 
            : p.montoTotal;
        granTotalPagado += totalPagado;
        
        return [
          p.codigo,
          p.nombreCliente ?? 'N/A',
          'Bs. ${p.montoOriginal.toStringAsFixed(2)}',
          'Bs. ${totalPagado.toStringAsFixed(2)}',
          DateFormat('dd/MM/yy').format(p.fechaInicio),
          DateFormat('dd/MM/yy').format(p.fechaVencimiento),
        ];
      }).toList();

      // Añadir fila de total
      rows.add([
        'TOTAL',
        '',
        '',
        'Bs. ${granTotalPagado.toStringAsFixed(2)}',
        '',
        '',
      ]);

      return await pdfService.generarPdfTabla(
        titulo: 'REPORTE DE PRÉSTAMOS CANCELADOS',
        subtitulo: 'Historial de préstamos pagados y cerrados en el periodo',
        headers: ['Código', 'Cliente', 'Monto Orig.', 'Total Pagado', 'Inicio', 'Fin'],
        rows: rows,
        nombreArchivo: 'Prestamos_Cancelados',
      );
    } else {
      return await excelService.exportarPrestamosCancelados(cancelados);
    }
  }

  Future<String> generarReporteRendimiento(ConfiguracionReporte config) async {
    final rango = config.getRango();
    final pagos = await (database.select(database.pagos)
          ..where((tbl) =>
              tbl.fechaPago.isBiggerOrEqualValue(rango.start) &
              tbl.fechaPago.isSmallerOrEqualValue(rango.end)))
        .get();

    final interesCobrado = pagos.fold<double>(0, (sum, p) => sum + p.montoInteres);
    final moraCobrada = pagos.fold<double>(0, (sum, p) => sum + p.montoMora);
    final capitalRecuperado = pagos.fold<double>(0, (sum, p) => sum + p.montoCapital);

    final datos = {
      'Capital Recuperado': capitalRecuperado,
      'Interés Ganado': interesCobrado,
      'Mora Cobrada': moraCobrada,
      'Total Ingresos Financieros': interesCobrado + moraCobrada,
      'Total Recaudado': capitalRecuperado + interesCobrado + moraCobrada,
    };

    if (config.formato == FormatoReporte.pdf) {
      return await pdfService.generarPdfTabla(
        titulo: 'RENDIMIENTO DE CARTERA',
        subtitulo: 'Resumen de ingresos financieros y recuperación de capital',
        headers: ['Concepto', 'Monto'],
        rows: datos.entries.map<List<String>>((e) => [
          e.key,
          'Bs. ${e.value.toStringAsFixed(2)}',
        ]).toList(),
        nombreArchivo: 'Rendimiento_Cartera',
      );
    } else {
      return await excelService.exportarRendimientoCartera(datos);
    }
  }

  // =========================================================================
  // EXPORTACIÓN (sin cambios)
  // =========================================================================

  Future<String> exportarClientes() async {
    final clientes = await database.select(database.clientes).get();
    final clientesExcel = clientes.map((c) => excel_svc.Cliente.fromDrift(c)).toList();
    return await excelService.exportarClientes(clientesExcel);
  }

  Future<String> exportarPrestamos() async {
    final prestamos = await _getPrestamosConJoin(DateTime(2000), DateTime.now());
    return await excelService.exportarPrestamos(prestamos);
  }

  Future<String> exportarPagos() async {
    final pagos = await _getPagosConJoin(DateTime(2000), DateTime.now());
    return await excelService.exportarPagos(pagos);
  }

  Future<String> exportarMovimientos() async {
    final movimientos = await _getMovimientosConJoin(null, DateTime(2000), DateTime.now());
    return await excelService.exportarMovimientos(movimientos);
  }

  // =========================================================================
  // PLANTILLAS (sin cambios)
  // =========================================================================

  Future<String> generarPlantillaClientes() async {
    return await excelService.generarPlantillaClientes();
  }

  Future<String> generarPlantillaPrestamos() async {
    return await excelService.generarPlantillaPrestamos();
  }

  Future<String> generarPlantillaWilsonCompleto() async {
    return await excelService.generarPlantillaWilsonCompleto();
  }

  // =========================================================================
  // IMPORTACIÓN DE DATOS
  // =========================================================================

  /// Importa clientes desde archivo Excel
  Future<ResultadoImportacion> importarClientes(String rutaArchivo) async {
    return await importacionService.importarClientes(
      rutaArchivo,
      // Verificar si CI existe
      (ci) async {
        final results = await (database.select(database.clientes)
              ..where((tbl) => tbl.numeroDocumento.equals(ci)))
            .get();
        return results.isNotEmpty;
      },
      // Guardar cliente
      (cliente) async {
        final partes = cliente.nombreCompleto.split(' ');
        final nombres = partes[0];
        final apellidos = partes.length > 1 ? partes.sublist(1).join(' ') : '';
        
        return await database.into(database.clientes).insert(
          ClientesCompanion.insert(
            nombres: nombres,
            apellidos: apellidos,
            tipoDocumento: 'CI',
            numeroDocumento: cliente.ci,
            telefono: cliente.telefono ?? '',
            email: Value(cliente.email),
            direccion: cliente.direccion ?? '',
            referencia: Value(cliente.referencia),
            observaciones: Value(cliente.notas),
            activo: Value(cliente.activo),
            fechaRegistro: Value(cliente.fechaRegistro),
          ),
        );
      },
    );
  }

  Future<ResultadoImportacion> importarPrestamos(String rutaArchivo) async {
    return await importacionService.importarPrestamos(
      rutaArchivo,
      (ci) async {
        final results = await (database.select(database.clientes)
              ..where((tbl) => tbl.numeroDocumento.equals(ci)))
            .get();
        return results.isNotEmpty ? results.first.id : null;
      },
      (nombreCaja) async {
        final results = await (database.select(database.cajas)
              ..where((tbl) => tbl.nombre.equals(nombreCaja)))
            .get();
        return results.isNotEmpty ? results.first.id : null;
      },
      _crearPrestamoCompleto,
    );
  }

  /// ✅ Importa préstamos desde archivo Excel - IMPLEMENTACIÓN COMPLETA
  Future<ResultadoImportacion> importarWilsonCompleto(String rutaArchivo) async {
    final resultadoParsing = await importacionService.importarWilsonCompleto(
      rutaArchivo,
      (ci) async {
        final results = await (database.select(database.clientes)
              ..where((tbl) => tbl.numeroDocumento.equals(ci)))
            .get();
        return results.isNotEmpty ? results.first.id : null;
      },
      (nombreCaja) async {
        final results = await (database.select(database.cajas)
              ..where((tbl) => tbl.nombre.equals(nombreCaja)))
            .get();
        return results.isNotEmpty ? results.first.id : null;
      },
    );

    if (resultadoParsing.prestamo == null) {
      return ResultadoImportacion(
        totalRegistros: 1,
        registrosExitosos: 0,
        registrosConError: 1,
        errores: resultadoParsing.errores,
        fechaProceso: resultadoParsing.fechaProceso,
      );
    }

    final prestamoData = resultadoParsing.prestamo!;
    final pagosData = resultadoParsing.pagos;
    final errores = List<ErrorImportacion>.from(resultadoParsing.errores);

    try {
      return await database.transaction(() async {
        // 1. Crear el préstamo base
        final prestamoId = await _crearPrestamoCompleto(prestamoData);

        // 2. Aplicar pagos históricos uno por uno
        int pagosExitosos = 0;
        for (final pagoData in pagosData) {
          try {
            await _registrarPagoWilsonHistorico(
              prestamoId: prestamoId,
              monto: pagoData.monto,
              fechaPago: pagoData.fecha,
              cajaId: prestamoData.cajaId,
              metodoPago: pagoData.metodo,
              observaciones: pagoData.observaciones,
              esAbonoCapital: pagoData.esAbonoCapital,
            );
            pagosExitosos++;
          } catch (e) {
            errores.add(ErrorImportacion(
              fila: 0, // No tenemos fila exacta aquí fácilmente sin pasarla
              campo: 'Historial Pagos',
              mensaje: 'Error aplicando pago de ${pagoData.monto}: $e',
            ));
          }
        }

        return ResultadoImportacion(
          totalRegistros: 1 + pagosData.length,
          registrosExitosos: 1 + pagosExitosos,
          registrosConError: pagosData.length - pagosExitosos,
          errores: errores,
          fechaProceso: DateTime.now(),
        );
      });
    } catch (e) {
      return ResultadoImportacion(
        totalRegistros: 1 + pagosData.length,
        registrosExitosos: 0,
        registrosConError: 1 + pagosData.length,
        errores: [ErrorImportacion(fila: 0, campo: 'general', mensaje: e.toString())],
        fechaProceso: DateTime.now(),
      );
    }
  }

  /// Registro de pago histórico simplificado para importación
  /// Basado en el flujo de PagoLocalDataSource
  Future<void> _registrarPagoWilsonHistorico({
    required int prestamoId,
    required double monto,
    required DateTime fechaPago,
    required int cajaId,
    required String metodoPago,
    String? observaciones,
    bool esAbonoCapital = false,
  }) async {
    // 1. Obtener préstamo actual
    final prestamo = await (database.select(database.prestamos)
          ..where((tbl) => tbl.id.equals(prestamoId)))
        .getSingle();

    final saldoActual = prestamo.saldoPendiente;
    final montoOriginal = prestamo.montoOriginal; // Base correcta
    final tasaMensual = prestamo.tasaInteres / 100;

    // 3. Calcular deuda histórica (Importación secuencial)
    final todosLosPagos = await (database.select(database.pagos)
          ..where((tbl) => tbl.prestamoId.equals(prestamoId)))
        .get();

    double interesTotalPagado = 0;
    double moraYaPagadaEnMes = 0;
    for (final p in todosLosPagos) {
      interesTotalPagado += p.montoInteres;
      if (p.fechaPago.year == fechaPago.year && p.fechaPago.month == fechaPago.month) {
        moraYaPagadaEnMes += p.montoMora ?? 0;
      }
    }

    // 4. Calcular deuda
    final interesMensualBase = montoOriginal * tasaMensual;
    
    int mesesVencidos = (fechaPago.year - prestamo.fechaInicio.year) * 12 + (fechaPago.month - prestamo.fechaInicio.month);
    if (fechaPago.day < prestamo.fechaInicio.day) mesesVencidos--;
    if (mesesVencidos < 0) mesesVencidos = 0;

    double interesADeudar = (mesesVencidos * interesMensualBase) - interesTotalPagado;
    if (interesADeudar < 0) interesADeudar = 0;

    double moraTotalCalculada = 0;
    final vencimientoActual = DateTime(fechaPago.year, fechaPago.month, prestamo.fechaInicio.day);
    if (fechaPago.isAfter(vencimientoActual)) {
      final diasRetraso = fechaPago.difference(vencimientoActual).inDays;
      if (diasRetraso > 0) {
        moraTotalCalculada = (interesMensualBase * diasRetraso / 30).ceilToDouble();
      }
    }
    double moraADeudar = (moraTotalCalculada - moraYaPagadaEnMes);
    if (moraADeudar < 0) moraADeudar = 0;

    if (esAbonoCapital) {
      moraADeudar = 0;
      interesADeudar = 0;
    }

    double montoRestante = monto;
    double montoMora = montoRestante >= moraADeudar ? moraADeudar : montoRestante;
    montoRestante -= montoMora;
    double montoInteres = montoRestante >= interesADeudar ? interesADeudar : montoRestante;
    montoRestante -= montoInteres;
    double montoCapital = montoRestante >= saldoActual ? saldoActual : montoRestante;
    montoRestante -= montoCapital;

    double nuevoSaldo = saldoActual - montoCapital;
    if (nuevoSaldo < 0.01) nuevoSaldo = 0;

    // Generar código de pago
    final codigoPago = 'PAG-IMP-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';

    // Insertar pago
    final pagoId = await database.into(database.pagos).insert(
      PagosCompanion.insert(
        prestamoId: prestamoId,
        clienteId: prestamo.clienteId,
        codigo: codigoPago,
        montoPago: monto - montoRestante,
        montoMora: Value(montoMora),
        montoInteres: montoInteres,
        montoCapital: montoCapital,
        fechaPago: fechaPago,
        cajaId: cajaId,
        metodoPago: metodoPago,
        observaciones: Value(observaciones),
        fechaRegistro: Value(DateTime.now()),
      ),
    );

    // Actualizar préstamo
    await (database.update(database.prestamos)
          ..where((tbl) => tbl.id.equals(prestamoId)))
        .write(PrestamosCompanion(
          saldoPendiente: Value(nuevoSaldo),
          estado: Value(nuevoSaldo <= 0 ? 'PAGADO' : 'ACTIVO'),
          fechaActualizacion: Value(DateTime.now()),
        ));

    // Registrar movimiento en caja
    // Primero obtener saldo actual de la caja
    final caja = await (database.select(database.cajas)..where((tbl) => tbl.id.equals(cajaId))).getSingle();
    final saldoAnterior = caja.saldoActual;
    final saldoNuevo = saldoAnterior + (monto - montoRestante);

    final codigoMov = 'MOV-IMP-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';

    await database.into(database.movimientos).insert(
      MovimientosCompanion.insert(
        codigo: codigoMov,
        cajaId: cajaId,
        tipo: 'INGRESO',
        categoria: 'PAGO',
        monto: monto - montoRestante,
        saldoAnterior: saldoAnterior,
        saldoNuevo: saldoNuevo,
        descripcion: 'Pago importado préstamo ${prestamo.codigo}',
        fecha: fechaPago,
        pagoId: Value(pagoId),
        fechaRegistro: Value(DateTime.now()),
      ),
    );

    // Actualizar saldo de caja
    await (database.update(database.cajas)..where((tbl) => tbl.id.equals(cajaId)))
        .write(CajasCompanion(
          saldoActual: Value(saldoNuevo),
          fechaActualizacion: Value(DateTime.now()),
        ));
  }

  // =========================================================================
  // ✅ LÓGICA COMPLETA DE CREACIÓN DE PRÉSTAMO
  // =========================================================================

  /// Crea un préstamo completo con tabla de amortización y movimientos
  Future<int> _crearPrestamoCompleto(PrestamoImportacion datos) async {
    // 1. Generar código único
    final codigo = await _generarCodigoPrestamo();

    // 2. Calcular valores del préstamo
    double tasaMensual;
    if (datos.tipoInteres == 'WILSON') {
      tasaMensual = datos.tasaInteres / 100; // Tasa mensual directa
    } else {
      tasaMensual = datos.tasaInteres / 12 / 100; // Convertir anual a mensual
    }
    
    double cuotaMensual;
    double montoTotal;

    if (datos.tipoInteres == 'SIMPLE') {
      // Interés simple
      final interesTotal = datos.montoOriginal * (datos.tasaInteres / 100) * (datos.plazoMeses / 12);
      montoTotal = datos.montoOriginal + interesTotal;
      cuotaMensual = montoTotal / datos.plazoMeses;
    } else if (datos.tipoInteres == 'WILSON') {
      // Wilson: Interés simple mensual directo
      final interesTotal = datos.montoOriginal * tasaMensual * datos.plazoMeses;
      montoTotal = datos.montoOriginal + interesTotal;
      
      final capitalMensual = datos.montoOriginal / datos.plazoMeses;
      final interesMensual = datos.montoOriginal * tasaMensual;
      cuotaMensual = capitalMensual + interesMensual;
    } else {
      // Interés compuesto (amortización francesa)
      if (tasaMensual == 0) {
        cuotaMensual = datos.montoOriginal / datos.plazoMeses;
        montoTotal = datos.montoOriginal;
      } else {
        cuotaMensual = datos.montoOriginal * 
            (tasaMensual * pow(1 + tasaMensual, datos.plazoMeses)) /
            (pow(1 + tasaMensual, datos.plazoMeses) - 1);
        montoTotal = cuotaMensual * datos.plazoMeses;
      }
    }

    final fechaVencimiento = DateTime(
      datos.fechaInicio.year,
      datos.fechaInicio.month + datos.plazoMeses,
      datos.fechaInicio.day,
    );

    // 3. Insertar préstamo
    final prestamoId = await database.into(database.prestamos).insert(
      PrestamosCompanion.insert(
        codigo: codigo,
        clienteId: datos.clienteId,
        cajaId: datos.cajaId,
        montoOriginal: datos.montoOriginal,
        montoTotal: montoTotal,
        saldoPendiente: montoTotal,  // ✅ Corregido: sin Value() porque es campo obligatorio
        tasaInteres: datos.tasaInteres,
        tipoInteres: datos.tipoInteres,
        plazoMeses: datos.plazoMeses,
        cuotaMensual: cuotaMensual,
        fechaInicio: datos.fechaInicio,
        fechaVencimiento: fechaVencimiento,
        estado: 'ACTIVO',
        observaciones: Value(datos.observaciones),
        fechaRegistro: Value(DateTime.now()),
      ),
    );

    // 4. Generar tabla de amortización (cuotas)
    await _generarCuotas(
      prestamoId: prestamoId,
      montoOriginal: datos.montoOriginal,
      tasaInteres: datos.tasaInteres,
      tipoInteres: datos.tipoInteres,
      plazoMeses: datos.plazoMeses,
      cuotaMensual: cuotaMensual,
      fechaInicio: datos.fechaInicio,
    );

    // 5. Registrar movimiento de caja (desembolso)
    await _registrarDesembolso(
      cajaId: datos.cajaId,
      prestamoId: prestamoId,
      monto: datos.montoOriginal,
      fecha: datos.fechaInicio,
    );

    return prestamoId;
  }

  /// Genera código único para el préstamo
  Future<String> _generarCodigoPrestamo() async {
    final fecha = DateTime.now();
    final anio = fecha.year.toString().substring(2);
    final mes = fecha.month.toString().padLeft(2, '0');
    
    // Obtener último número de secuencia del mes
    final ultimoPrestamo = await (database.select(database.prestamos)
          ..where((tbl) => tbl.codigo.like('P$anio$mes%'))
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.codigo)])
          ..limit(1))
        .getSingleOrNull();

    int secuencia = 1;
    if (ultimoPrestamo != null) {
      final ultimoCodigo = ultimoPrestamo.codigo;
      final partes = ultimoCodigo.split('-');
      if (partes.length == 2) {
        secuencia = (int.tryParse(partes[1]) ?? 0) + 1;
      }
    }

    return 'P$anio$mes-${secuencia.toString().padLeft(4, '0')}';
  }

  /// Genera las cuotas del préstamo (tabla de amortización)
  Future<void> _generarCuotas({
    required int prestamoId,
    required double montoOriginal,
    required double tasaInteres,
    required String tipoInteres,
    required int plazoMeses,
    required double cuotaMensual,
    required DateTime fechaInicio,
  }) async {
    double saldoPendiente = montoOriginal;
    final tasaMensual = tasaInteres / 12 / 100;

    for (int i = 1; i <= plazoMeses; i++) {
      final fechaVencimiento = DateTime(
        fechaInicio.year,
        fechaInicio.month + i,
        fechaInicio.day,
      );

      double interes;
      double capital;

      if (tipoInteres == 'SIMPLE') {
        // Interés simple: interés constante sobre monto original (Tasa es Anual)
        interes = (montoOriginal * tasaInteres / 100) / 12;
        capital = cuotaMensual - interes;
      } else if (tipoInteres == 'WILSON') {
        // Wilson: interés constante sobre monto original (Tasa es Mensual)
        interes = montoOriginal * (tasaInteres / 100);
        capital = cuotaMensual - interes;
      } else {
        // Interés compuesto: sobre saldo pendiente
        if (tasaMensual == 0) {
          interes = 0;
          capital = cuotaMensual;
        } else {
          interes = saldoPendiente * tasaMensual;
          capital = cuotaMensual - interes;
        }
      }

      // Ajustar última cuota por redondeos
      if (i == plazoMeses) {
        capital = saldoPendiente;
        cuotaMensual = capital + interes;
      }

      await database.into(database.cuotas).insert(
        CuotasCompanion.insert(
          prestamoId: prestamoId,
          numeroCuota: i,
          fechaVencimiento: fechaVencimiento,
          montoCuota: cuotaMensual,
          capital: capital,
          interes: interes,
          saldoPendiente: saldoPendiente - capital,
          montoPagado: const Value(0),
          montoMora: const Value(0),
          estado: 'PENDIENTE',
        ),
      );

      saldoPendiente -= capital;
    }
  }

  /// Registra el movimiento de desembolso en la caja
  Future<void> _registrarDesembolso({
    required int cajaId,
    required int prestamoId,
    required double monto,
    required DateTime fecha,
  }) async {
    // Obtener caja y saldo actual
    final caja = await (database.select(database.cajas)
          ..where((tbl) => tbl.id.equals(cajaId)))
        .getSingle();

    final saldoAnterior = caja.saldoActual;
    final saldoNuevo = saldoAnterior - monto; // Egreso

    // Generar código de movimiento
    final codigoMovimiento = await _generarCodigoMovimiento();

    // Insertar movimiento
    await database.into(database.movimientos).insert(
      MovimientosCompanion.insert(
        codigo: codigoMovimiento,
        cajaId: cajaId,
        tipo: 'EGRESO',
        categoria: 'PRESTAMO',
        monto: monto,
        saldoAnterior: saldoAnterior,
        saldoNuevo: saldoNuevo,
        descripcion: 'Desembolso de préstamo importado',
        prestamoId: Value(prestamoId),
        fecha: fecha,
      ),
    );

    // Actualizar saldo de caja
    await (database.update(database.cajas)..where((tbl) => tbl.id.equals(cajaId)))
        .write(CajasCompanion(
          saldoActual: Value(saldoNuevo),
          fechaActualizacion: Value(DateTime.now()),
        ));
  }

  /// Genera código único para movimiento
  Future<String> _generarCodigoMovimiento() async {
    final fecha = DateTime.now();
    final anio = fecha.year.toString().substring(2);
    final mes = fecha.month.toString().padLeft(2, '0');
    
    final ultimoMovimiento = await (database.select(database.movimientos)
          ..where((tbl) => tbl.codigo.like('M$anio$mes%'))
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.codigo)])
          ..limit(1))
        .getSingleOrNull();

    int secuencia = 1;
    if (ultimoMovimiento != null) {
      final ultimoCodigo = ultimoMovimiento.codigo;
      final partes = ultimoCodigo.split('-');
      if (partes.length == 2) {
        secuencia = (int.tryParse(partes[1]) ?? 0) + 1;
      }
    }

    return 'M$anio$mes-${secuencia.toString().padLeft(4, '0')}';
  }

  // =========================================================================
  // MÉTODOS DE AYUDA PARA JOINS (sin cambios)
  // =========================================================================

  Future<List<excel_svc.Prestamo>> _getPrestamosConJoin(
    DateTime inicio,
    DateTime fin, {
    bool soloMora = false,
  }) async {
    final query = database.select(database.prestamos).join([
      leftOuterJoin(database.clientes, database.clientes.id.equalsExp(database.prestamos.clienteId)),
      leftOuterJoin(database.cajas, database.cajas.id.equalsExp(database.prestamos.cajaId)),
    ])..where(
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
        id: prestamo.id,
        codigo: prestamo.codigo,
        nombreCliente: cliente != null ? '${cliente.nombres} ${cliente.apellidos}' : null,
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

  Future<List<excel_svc.Pago>> _getPagosConJoin(DateTime inicio, DateTime fin) async {
    final query = database.select(database.pagos).join([
      leftOuterJoin(database.prestamos, database.prestamos.id.equalsExp(database.pagos.prestamoId)),
      leftOuterJoin(database.clientes, database.clientes.id.equalsExp(database.pagos.clienteId)),
      leftOuterJoin(database.cajas, database.cajas.id.equalsExp(database.pagos.cajaId)),
    ])..where(
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
        nombreCliente: cliente != null ? '${cliente.nombres} ${cliente.apellidos}' : null,
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

  Future<List<excel_svc.Movimiento>> _getMovimientosConJoin(
    int? cajaId,
    DateTime inicio,
    DateTime fin,
  ) async {
    final query = database.select(database.movimientos).join([
      leftOuterJoin(database.cajas, database.cajas.id.equalsExp(database.movimientos.cajaId)),
    ])..where(
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

// Helper para cálculo de potencia (no está en dart:core por defecto)
double pow(double base, int exponent) {
  double result = 1.0;
  for (int i = 0; i < exponent; i++) {
    result *= base;
  }
  return result;
}