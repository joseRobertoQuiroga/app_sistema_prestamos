import 'package:drift/drift.dart';
import '../../domain/entities/dashboard_entities.dart';
import '../../../../core/database/database.dart';

/// Data Source del Dashboard
/// ✅ CORREGIDO: Usa saldoActual y concatena nombres+apellidos
class DashboardLocalDataSource {
  final AppDatabase database;

  DashboardLocalDataSource(this.database);

  /// Calcula todos los KPIs del sistema
  Future<DashboardKPIs> getKPIs() async {
    // Obtener datos de préstamos
    final prestamos = await database.select(database.prestamos).get();
    final cuotas = await database.select(database.cuotas).get();
    final pagos = await database.select(database.pagos).get();
    final cajas = await (database.select(database.cajas)
          ..where((tbl) => tbl.activa.equals(true)))
        .get();
    final clientes = await database.select(database.clientes).get();
    
    // Calcular totales de cartera
    double carteraTotal = 0;
    double capitalPorCobrar = 0;
    int totalPrestamos = prestamos.length;
    int prestamosActivos = 0;
    int prestamosEnMora = 0;
    int prestamosPagados = 0;
    int prestamosCancelados = 0;

    for (final prestamo in prestamos) {
      carteraTotal += prestamo.montoTotal;
      capitalPorCobrar += prestamo.saldoPendiente;

      switch (prestamo.estado) {
        case 'ACTIVO':
          prestamosActivos++;
          break;
        case 'MORA':
          prestamosEnMora++;
          break;
        case 'PAGADO':
          prestamosPagados++;
          break;
        case 'CANCELADO':
          prestamosCancelados++;
          break;
      }
    }

    // Calcular intereses y mora
    double interesesGanados = 0;
    double moraCobrada = 0;

    for (final pago in pagos) {
      interesesGanados += pago.montoInteres;
      moraCobrada += pago.montoMora;
    }

    // Calcular saldo total de cajas
    /// ✅ CORREGIDO: Usar saldoActual en lugar de saldo
    double saldoTotalCajas = 0;
    for (final caja in cajas) {
      saldoTotalCajas += caja.saldoActual;
    }

    // Calcular movimientos del mes actual
    final inicioMes = DateTime(DateTime.now().year, DateTime.now().month, 1);
    final finMes = DateTime(DateTime.now().year, DateTime.now().month + 1, 0);

    final movimientosMes = await (database.select(database.movimientos)
          ..where((tbl) =>
              tbl.fecha.isBiggerOrEqualValue(inicioMes) &
              tbl.fecha.isSmallerOrEqualValue(finMes)))
        .get();

    double ingresosDelMes = 0;
    double egresosDelMes = 0;

    for (final mov in movimientosMes) {
      if (mov.tipo == 'INGRESO') {
        ingresosDelMes += mov.monto;
      } else if (mov.tipo == 'EGRESO') {
        egresosDelMes += mov.monto;
      }
    }

    // Clientes
    final clientesActivos = clientes.where((c) => c.activo).length;

    // Calcular tasas
    final tasaMorosidad = totalPrestamos > 0
        ? (prestamosEnMora / totalPrestamos) * 100
        : 0.0;

    final porcentajeCarteraPagada = totalPrestamos > 0
        ? (prestamosPagados / totalPrestamos) * 100
        : 0.0;

    return DashboardKPIs(
      carteraTotal: carteraTotal,
      capitalPorCobrar: capitalPorCobrar,
      interesesGanados: interesesGanados,
      moraCobrada: moraCobrada,
      totalPrestamos: totalPrestamos,
      prestamosActivos: prestamosActivos,
      prestamosEnMora: prestamosEnMora,
      prestamosPagados: prestamosPagados,
      prestamosCancelados: prestamosCancelados,
      saldoTotalCajas: saldoTotalCajas,
      ingresosDelMes: ingresosDelMes,
      egresosDelMes: egresosDelMes,
      totalClientes: clientes.length,
      clientesActivos: clientesActivos,
      tasaMorosidad: tasaMorosidad,
      porcentajeCarteraPagada: porcentajeCarteraPagada,
    );
  }

  /// Genera alertas del sistema
  Future<List<DashboardAlerta>> getAlertas() async {
    final alertas = <DashboardAlerta>[];
    final hoy = DateTime.now();

    // Alertas de cuotas próximas a vencer
    final cuotasProximas = await (database.select(database.cuotas)
          ..where((tbl) =>
              tbl.estado.equals('PENDIENTE') &
              tbl.fechaVencimiento.isBiggerOrEqualValue(hoy) &
              tbl.fechaVencimiento.isSmallerOrEqualValue(
                  hoy.add(const Duration(days: 7)))))
        .get();

    for (final cuota in cuotasProximas) {
      final diasParaVencer = cuota.fechaVencimiento.difference(hoy).inDays;
      alertas.add(DashboardAlerta(
        tipo: 'VENCIMIENTO',
        severidad: diasParaVencer <= 3 ? 'ALTA' : 'MEDIA',
        titulo: 'Cuota próxima a vencer',
        mensaje: 'Cuota #${cuota.numeroCuota} vence en $diasParaVencer días',
        fecha: hoy,
        cuotaId: cuota.id,
        prestamoId: cuota.prestamoId,
      ));
    }

    // Alertas de préstamos en mora
    final prestamosEnMora = await (database.select(database.prestamos)
          ..where((tbl) => tbl.estado.equals('MORA')))
        .get();

    for (final prestamo in prestamosEnMora) {
      alertas.add(DashboardAlerta(
        tipo: 'MORA',
        severidad: 'ALTA',
        titulo: 'Préstamo en mora',
        mensaje: 'Préstamo ${prestamo.codigo} tiene pagos vencidos',
        fecha: hoy,
        prestamoId: prestamo.id,
      ));
    }

    // Alertas de saldo bajo en cajas
    /// ✅ CORREGIDO: Usar saldoActual
    final cajas = await (database.select(database.cajas)
          ..where((tbl) => 
              tbl.activa.equals(true) & 
              tbl.saldoActual.isSmallerThanValue(1000)))
        .get();

    for (final caja in cajas) {
      alertas.add(DashboardAlerta(
        tipo: 'BAJO_SALDO',
        severidad: caja.saldoActual < 500 ? 'ALTA' : 'MEDIA',
        titulo: 'Saldo bajo en caja',
        mensaje: '${caja.nombre} tiene saldo bajo: Bs. ${caja.saldoActual.toStringAsFixed(2)}',
        fecha: hoy,
      ));
    }

    return alertas;
  }

  /// Obtiene próximos vencimientos
  /// ✅ CORREGIDO: Concatena nombres y apellidos del cliente
  Future<List<ProximoVencimiento>> getProximosVencimientos({int dias = 30}) async {
    final hoy = DateTime.now();
    final fechaLimite = hoy.add(Duration(days: dias));

    final query = database.select(database.cuotas).join([
      innerJoin(
        database.prestamos,
        database.prestamos.id.equalsExp(database.cuotas.prestamoId),
      ),
      innerJoin(
        database.clientes,
        database.clientes.id.equalsExp(database.prestamos.clienteId),
      ),
    ])
      ..where(
        database.cuotas.estado.equals('PENDIENTE') &
            database.cuotas.fechaVencimiento.isBiggerOrEqualValue(hoy) &
            database.cuotas.fechaVencimiento.isSmallerOrEqualValue(fechaLimite),
      )
      ..orderBy([OrderingTerm.asc(database.cuotas.fechaVencimiento)]);

    final resultados = await query.get();

    return resultados.map((row) {
      final cuota = row.readTable(database.cuotas);
      final prestamo = row.readTable(database.prestamos);
      final cliente = row.readTable(database.clientes);

      final diasParaVencer = cuota.fechaVencimiento.difference(hoy).inDays;

      return ProximoVencimiento(
        cuotaId: cuota.id,
        prestamoId: prestamo.id,
        codigoPrestamo: prestamo.codigo,
        // ✅ CORREGIDO: Concatenar nombres + apellidos
        nombreCliente: '${cliente.nombres} ${cliente.apellidos}'.trim(),
        numeroCuota: cuota.numeroCuota,
        fechaVencimiento: cuota.fechaVencimiento,
        montoCuota: cuota.montoCuota,
        montoInteres: cuota.interes,
        montoPendiente: cuota.interes - cuota.montoPagado,
        diasParaVencer: diasParaVencer,
      );
    }).toList();
  }

  /// Obtiene préstamos en mora
  /// ✅ CORREGIDO: Concatena nombres y apellidos
  Future<List<Map<String, dynamic>>> getPrestamosEnMora() async {
    final query = database.select(database.prestamos).join([
      innerJoin(
        database.clientes,
        database.clientes.id.equalsExp(database.prestamos.clienteId),
      ),
    ])
      ..where(database.prestamos.estado.equals('MORA'))
      ..orderBy([OrderingTerm.desc(database.prestamos.fechaInicio)]);

    final resultados = await query.get();

    return resultados.map((row) {
      final prestamo = row.readTable(database.prestamos);
      final cliente = row.readTable(database.clientes);

      return {
        'prestamoId': prestamo.id,
        'codigo': prestamo.codigo,
        // ✅ CORREGIDO: Concatenar nombres + apellidos
        'clienteNombre': '${cliente.nombres} ${cliente.apellidos}'.trim(),
        'monto': prestamo.montoOriginal,
        'saldoPendiente': prestamo.saldoPendiente,
        'fechaInicio': prestamo.fechaInicio,
      };
    }).toList();
  }

  /// Obtiene distribución de cartera por estado
  Future<Map<String, double>> getDistribucionCartera() async {
    final prestamos = await database.select(database.prestamos).get();

    final distribucion = <String, double>{
      'ACTIVO': 0,
      'MORA': 0,
      'PAGADO': 0,
      'CANCELADO': 0,
    };

    for (final prestamo in prestamos) {
      distribucion[prestamo.estado] = 
          (distribucion[prestamo.estado] ?? 0) + prestamo.saldoPendiente;
    }

    return distribucion;
  }

  /// Obtiene movimientos por categoría del mes actual
  Future<Map<String, double>> getMovimientosPorCategoria() async {
    final inicioMes = DateTime(DateTime.now().year, DateTime.now().month, 1);
    final finMes = DateTime(DateTime.now().year, DateTime.now().month + 1, 0);

    final movimientos = await (database.select(database.movimientos)
          ..where((tbl) =>
              tbl.fecha.isBiggerOrEqualValue(inicioMes) &
              tbl.fecha.isSmallerOrEqualValue(finMes)))
        .get();

    final porCategoria = <String, double>{};

    for (final mov in movimientos) {
      porCategoria[mov.categoria] = 
          (porCategoria[mov.categoria] ?? 0) + mov.monto;
    }

    return porCategoria;
  }
}