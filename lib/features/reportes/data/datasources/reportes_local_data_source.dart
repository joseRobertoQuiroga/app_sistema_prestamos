import 'package:drift/drift.dart';
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
    final prestamos = await (database.select(database.prestamos)
          ..where((tbl) =>
              tbl.fechaRegistro.isBiggerOrEqualValue(rango.start) &
              tbl.fechaRegistro.isSmallerOrEqualValue(rango.end)))
        .get();

    final totalPrestamos = prestamos.length;
    final prestamosActivos = prestamos.where((p) => p.estado == 'ACTIVO').length;
    final prestamosEnMora = prestamos.where((p) => p.estado == 'MORA').length;
    final prestamosPagados = prestamos.where((p) => p.estado == 'PAGADO').length;
    final carteraTotal = prestamos.fold<double>(0, (sum, p) => sum + p.montoTotal);
    final capitalPorCobrar = prestamos.fold<double>(0, (sum, p) => sum + p.saldoPendiente);
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
    final prestamosEnMora = results.map((row) {
      final prestamo = row.readTable(database.prestamos);
      final cliente = row.readTableOrNull(database.clientes);
      return PrestamoMora(
        codigo: prestamo.codigo,
        nombreCliente: cliente != null ? '${cliente.nombres} ${cliente.apellidos}' : 'N/A',
        diasMora: 0,
        moraAcumulada: 0,
      );
    }).toList();

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
    if (config.cajaId == null) throw Exception('Debe especificar una caja');

    final rango = config.getRango();
    final caja = await (database.select(database.cajas)..where((tbl) => tbl.id.equals(config.cajaId!))).getSingle();
    final movimientos = await (database.select(database.movimientos)
          ..where((tbl) =>
              tbl.cajaId.equals(config.cajaId!) &
              tbl.fecha.isBiggerOrEqualValue(rango.start) &
              tbl.fecha.isSmallerOrEqualValue(rango.end))
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.fecha)]))
        .get();

    final saldoInicial = caja.saldoInicial;
    final totalIngresos = movimientos.where((m) => m.tipo == 'INGRESO').fold<double>(0, (sum, m) => sum + m.monto);
    final totalEgresos = movimientos.where((m) => m.tipo == 'EGRESO').fold<double>(0, (sum, m) => sum + m.monto);
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
      final movimientosConJoin = await _getMovimientosConJoin(config.cajaId!, rango.start, rango.end);
      return await excelService.exportarMovimientos(movimientosConJoin);
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
    
    // Obtener movimientos del cliente (préstamos y pagos)
    final prestamos = await (database.select(database.prestamos)
          ..where((tbl) => tbl.clienteId.equals(config.clienteId!))
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.fechaRegistro)]))
        .get();

    final pagos = await (database.select(database.pagos)
          ..where((tbl) => tbl.clienteId.equals(config.clienteId!))
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.fechaPago)]))
        .get();

    // Unificar y ordenar cronológicamente
    final items = <excel_svc.ItemEstadoCuenta>[];
    double saldoAcumulado = 0;

    for (final p in prestamos) {
      saldoAcumulado += p.montoTotal;
      items.add(excel_svc.ItemEstadoCuenta(
        fecha: p.fechaInicio,
        concepto: 'Préstamo ${p.codigo}',
        monto: p.montoTotal, // Cargo positivo
        saldo: saldoAcumulado,
        tipo: 'CARGO',
      ));
    }

    for (final p in pagos) {
      saldoAcumulado -= p.montoPago;
      items.add(excel_svc.ItemEstadoCuenta(
        fecha: p.fechaPago,
        concepto: 'Pago ${p.codigo} (${p.metodoPago})',
        monto: -p.montoPago, // Abono negativo
        saldo: saldoAcumulado,
        tipo: 'ABONO',
      ));
    }

    items.sort((a, b) => a.fecha.compareTo(b.fecha));

    if (config.formato == FormatoReporte.pdf) {
      throw Exception('Formato PDF no implementado para este reporte');
    } else {
      return await excelService.exportarEstadoCuentaCliente(items);
    }
  }

  Future<String> generarReporteProyeccion(ConfiguracionReporte config) async {
    final rango = config.getRango();
    
    // Obtener cuotas pendientes en el rango
    final query = database.select(database.cuotas).join([
      leftOuterJoin(database.prestamos, database.prestamos.id.equalsExp(database.cuotas.prestamoId)),
      leftOuterJoin(database.clientes, database.clientes.id.equalsExp(database.prestamos.clienteId)),
    ])..where(
        database.cuotas.estado.equals('PENDIENTE') &
        database.cuotas.fechaVencimiento.isBiggerOrEqualValue(rango.start) &
        database.cuotas.fechaVencimiento.isSmallerOrEqualValue(rango.end)
      )..orderBy([OrderingTerm.asc(database.cuotas.fechaVencimiento)]);

    final results = await query.get();

    final items = results.map((row) {
      final cuota = row.readTable(database.cuotas);
      final prestamo = row.readTable(database.prestamos);
      final cliente = row.readTable(database.clientes);

      // Calcular mora estimada si ya venció
      double moraEst = 0;
      if (cuota.fechaVencimiento.isBefore(DateTime.now())) {
        final diasAtraso = DateTime.now().difference(cuota.fechaVencimiento).inDays;
        // Lógica simple de mora: 0.5% por día (ejemplo, ajustar según negocio)
        moraEst = cuota.saldoPendiente * 0.005 * diasAtraso;
      }

      return excel_svc.ItemProyeccion(
        fechaVencimiento: cuota.fechaVencimiento,
        nombreCliente: '${cliente.nombres} ${cliente.apellidos}',
        codigoPrestamo: prestamo.codigo,
        numeroCuota: cuota.numeroCuota,
        montoCuota: cuota.montoCuota,
        moraEstimada: moraEst,
        totalCobrar: cuota.saldoPendiente + moraEst, // Aproximado
      );
    }).toList();

    return await excelService.exportarProyeccionCobros(items);
  }

  Future<String> generarReporteCancelados(ConfiguracionReporte config) async {
    final rango = config.getRango();
    final prestamos = await _getPrestamosConJoin(rango.start, rango.end);
    
    // Filtrar pagados o cancelados
    final cancelados = prestamos.where((p) => p.estado == 'PAGADO' || p.estado == 'CANCELADO').toList();

    return await excelService.exportarPrestamosCancelados(cancelados);
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

    return await excelService.exportarRendimientoCartera(datos);
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

  // =========================================================================
  // ✅ IMPORTACIÓN - COMPLETA Y FUNCIONAL
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
        final partes = cliente.nombre.split(' ');
        final nombres = partes.length > 1 
            ? partes.sublist(0, partes.length ~/ 2).join(' ') 
            : cliente.nombre;
        final apellidos = partes.length > 1 
            ? partes.sublist(partes.length ~/ 2).join(' ') 
            : '';
        
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

  /// ✅ Importa préstamos desde archivo Excel - IMPLEMENTACIÓN COMPLETA
  Future<ResultadoImportacion> importarPrestamos(String rutaArchivo) async {
    return await importacionService.importarPrestamos(
      rutaArchivo,
      // Obtener cliente por CI
      (ci) async {
        final results = await (database.select(database.clientes)
              ..where((tbl) => tbl.numeroDocumento.equals(ci)))
            .get();
        return results.isNotEmpty ? results.first.id : null;
      },
      // Obtener caja por nombre
      (nombreCaja) async {
        final results = await (database.select(database.cajas)
              ..where((tbl) => tbl.nombre.equals(nombreCaja)))
            .get();
        return results.isNotEmpty ? results.first.id : null;
      },
      // ✅ GUARDAR PRÉSTAMO COMPLETO
      (prestamoImportacion) async {
        return await _crearPrestamoCompleto(prestamoImportacion);
      },
    );
  }

  // =========================================================================
  // ✅ LÓGICA COMPLETA DE CREACIÓN DE PRÉSTAMO
  // =========================================================================

  /// Crea un préstamo completo con tabla de amortización y movimientos
  Future<int> _crearPrestamoCompleto(PrestamoImportacion datos) async {
    // 1. Generar código único
    final codigo = await _generarCodigoPrestamo();

    // 2. Calcular valores del préstamo
    final tasaMensual = datos.tasaInteres / 12 / 100; // Convertir anual a mensual
    
    double cuotaMensual;
    double montoTotal;

    if (datos.tipoInteres == 'SIMPLE') {
      // Interés simple
      final interesTotal = datos.montoOriginal * (datos.tasaInteres / 100) * (datos.plazoMeses / 12);
      montoTotal = datos.montoOriginal + interesTotal;
      cuotaMensual = montoTotal / datos.plazoMeses;
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
        // Interés simple: interés constante sobre monto original
        interes = (montoOriginal * tasaInteres / 100) / 12;
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