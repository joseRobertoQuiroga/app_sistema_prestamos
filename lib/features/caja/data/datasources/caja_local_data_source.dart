import 'package:drift/drift.dart';
import '../models/caja_model.dart';
import '../../domain/entities/resumen_caja.dart';
import '../../../../core/database/database.dart';

/// Data Source Local de Cajas
class CajaLocalDataSource {
  final AppDatabase database;

  CajaLocalDataSource(this.database);

  // ============= CRUD CAJAS =============

  Future<List<CajaModel>> getCajas() async {
    final cajas = await database.select(database.cajas).get();
    return cajas.map((c) => CajaModel.fromDrift(c)).toList();
  }

  Future<CajaModel> getCajaById(int id) async {
    final caja = await (database.select(database.cajas)
          ..where((tbl) => tbl.id.equals(id)))
        .getSingleOrNull();

    if (caja == null) {
      throw Exception('Caja con ID $id no encontrada');
    }

    return CajaModel.fromDrift(caja);
  }

  Future<List<CajaModel>> getCajasActivas() async {
    final cajas = await (database.select(database.cajas)
          ..where((tbl) => tbl.activa.equals(true))
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.nombre)]))
        .get();

    return cajas.map((c) => CajaModel.fromDrift(c)).toList();
  }

  Future<CajaModel> createCaja(CajaModel caja) async {
    final id = await database.into(database.cajas).insert(caja.toCompanion());
    return caja.copyWith(id: id) as CajaModel;
  }

  Future<CajaModel> updateCaja(CajaModel caja) async {
    if (caja.id == null) {
      throw Exception('La caja debe tener un ID para actualizarse');
    }

    final updated = await (database.update(database.cajas)
          ..where((tbl) => tbl.id.equals(caja.id!)))
        .write(caja.toCompanionForUpdate());

    if (updated == 0) {
      throw Exception('Caja con ID ${caja.id} no encontrada');
    }

    return caja;
  }

  Future<void> deleteCaja(int id) async {
    // Verificar que no tenga movimientos
    final movimientos = await (database.select(database.movimientos)
          ..where((tbl) => tbl.cajaId.equals(id)))
        .get();

    if (movimientos.isNotEmpty) {
      throw Exception('No se puede eliminar una caja con movimientos');
    }

    final deleted = await (database.delete(database.cajas)
          ..where((tbl) => tbl.id.equals(id)))
        .go();

    if (deleted == 0) {
      throw Exception('Caja con ID $id no encontrada');
    }
  }

  Future<void> toggleActivaCaja(int id, bool activa) async {
    await (database.update(database.cajas)
          ..where((tbl) => tbl.id.equals(id)))
        .write(CajasCompanion(
          activa: Value(activa),
          fechaActualizacion: Value(DateTime.now()),
        ));
  }

  // ============= MOVIMIENTOS =============

  Future<MovimientoModel> registrarIngreso({
    required int cajaId,
    required double monto,
    required String categoria,
    required String descripcion,
    required DateTime fecha,
    String? referencia,
  }) async {
    return await database.transaction(() async {
      // Obtener caja actual
      final caja = await getCajaById(cajaId);
      final saldoAnterior = caja.saldo;
      final saldoNuevo = saldoAnterior + monto;

      // Crear movimiento
      final movimientoId = await database.into(database.movimientos).insert(
            MovimientosCompanion.insert(
              cajaId: cajaId,
              tipo: 'INGRESO',
              categoria: categoria,
              monto: monto,
              descripcion: descripcion,
              fecha: fecha,
              saldoAnterior: saldoAnterior,
              saldoNuevo: saldoNuevo,
              referencia: Value(referencia),
              fechaRegistro: DateTime.now(),
            ),
          );

      // Actualizar saldo de caja
      await (database.update(database.cajas)
            ..where((tbl) => tbl.id.equals(cajaId)))
          .write(CajasCompanion(
        saldo: Value(saldoNuevo),
        fechaActualizacion: Value(DateTime.now()),
      ));

      // Obtener movimiento creado
      final movimiento = await (database.select(database.movimientos)
            ..where((tbl) => tbl.id.equals(movimientoId)))
          .getSingle();

      return MovimientoModel.fromDrift(movimiento);
    });
  }

  Future<MovimientoModel> registrarEgreso({
    required int cajaId,
    required double monto,
    required String categoria,
    required String descripcion,
    required DateTime fecha,
    String? referencia,
  }) async {
    return await database.transaction(() async {
      // Obtener caja actual
      final caja = await getCajaById(cajaId);
      
      // Verificar saldo suficiente
      if (caja.saldo < monto) {
        throw Exception('Saldo insuficiente en ${caja.nombre}');
      }

      final saldoAnterior = caja.saldo;
      final saldoNuevo = saldoAnterior - monto;

      // Crear movimiento
      final movimientoId = await database.into(database.movimientos).insert(
            MovimientosCompanion.insert(
              cajaId: cajaId,
              tipo: 'EGRESO',
              categoria: categoria,
              monto: monto,
              descripcion: descripcion,
              fecha: fecha,
              saldoAnterior: saldoAnterior,
              saldoNuevo: saldoNuevo,
              referencia: Value(referencia),
              fechaRegistro: DateTime.now(),
            ),
          );

      // Actualizar saldo de caja
      await (database.update(database.cajas)
            ..where((tbl) => tbl.id.equals(cajaId)))
          .write(CajasCompanion(
        saldo: Value(saldoNuevo),
        fechaActualizacion: Value(DateTime.now()),
      ));

      // Obtener movimiento creado
      final movimiento = await (database.select(database.movimientos)
            ..where((tbl) => tbl.id.equals(movimientoId)))
          .getSingle();

      return MovimientoModel.fromDrift(movimiento);
    });
  }

  Future<List<MovimientoModel>> registrarTransferencia({
    required int cajaOrigenId,
    required int cajaDestinoId,
    required double monto,
    required String descripcion,
    required DateTime fecha,
    String? referencia,
  }) async {
    return await database.transaction(() async {
      // Obtener cajas
      final cajaOrigen = await getCajaById(cajaOrigenId);
      final cajaDestino = await getCajaById(cajaDestinoId);

      // Verificar saldo suficiente
      if (cajaOrigen.saldo < monto) {
        throw Exception('Saldo insuficiente en ${cajaOrigen.nombre}');
      }

      // 1. Crear movimiento de SALIDA en caja origen
      final salidaId = await database.into(database.movimientos).insert(
            MovimientosCompanion.insert(
              cajaId: cajaOrigenId,
              tipo: 'TRANSFERENCIA',
              categoria: 'TRANSFERENCIA',
              monto: monto,
              descripcion: 'Transferencia a ${cajaDestino.nombre}: $descripcion',
              fecha: fecha,
              saldoAnterior: cajaOrigen.saldo,
              saldoNuevo: cajaOrigen.saldo - monto,
              cajaDestinoId: Value(cajaDestinoId),
              referencia: Value(referencia),
              fechaRegistro: DateTime.now(),
            ),
          );

      // 2. Actualizar saldo caja origen
      await (database.update(database.cajas)
            ..where((tbl) => tbl.id.equals(cajaOrigenId)))
          .write(CajasCompanion(
        saldo: Value(cajaOrigen.saldo - monto),
        fechaActualizacion: Value(DateTime.now()),
      ));

      // 3. Crear movimiento de ENTRADA en caja destino
      final entradaId = await database.into(database.movimientos).insert(
            MovimientosCompanion.insert(
              cajaId: cajaDestinoId,
              tipo: 'TRANSFERENCIA',
              categoria: 'TRANSFERENCIA',
              monto: monto,
              descripcion: 'Transferencia desde ${cajaOrigen.nombre}: $descripcion',
              fecha: fecha,
              saldoAnterior: cajaDestino.saldo,
              saldoNuevo: cajaDestino.saldo + monto,
              cajaDestinoId: Value(cajaOrigenId), // Referencia cruzada
              referencia: Value(referencia),
              fechaRegistro: DateTime.now(),
            ),
          );

      // 4. Actualizar saldo caja destino
      await (database.update(database.cajas)
            ..where((tbl) => tbl.id.equals(cajaDestinoId)))
          .write(CajasCompanion(
        saldo: Value(cajaDestino.saldo + monto),
        fechaActualizacion: Value(DateTime.now()),
      ));

      // Obtener movimientos creados
      final salida = await (database.select(database.movimientos)
            ..where((tbl) => tbl.id.equals(salidaId)))
          .getSingle();

      final entrada = await (database.select(database.movimientos)
            ..where((tbl) => tbl.id.equals(entradaId)))
          .getSingle();

      return [
        MovimientoModel.fromDrift(salida),
        MovimientoModel.fromDrift(entrada),
      ];
    });
  }

  Future<List<MovimientoModel>> getMovimientos() async {
    final movimientos = await (database.select(database.movimientos)
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.fecha)]))
        .get();

    return movimientos.map((m) => MovimientoModel.fromDrift(m)).toList();
  }

  Future<List<MovimientoModel>> getMovimientosByCaja(int cajaId) async {
    final movimientos = await (database.select(database.movimientos)
          ..where((tbl) => tbl.cajaId.equals(cajaId))
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.fecha)]))
        .get();

    return movimientos.map((m) => MovimientoModel.fromDrift(m)).toList();
  }

  Future<List<MovimientoModel>> getMovimientosPorPeriodo({
    required int cajaId,
    required DateTime inicio,
    required DateTime fin,
  }) async {
    final movimientos = await (database.select(database.movimientos)
          ..where((tbl) =>
              tbl.cajaId.equals(cajaId) &
              tbl.fecha.isBiggerOrEqualValue(inicio) &
              tbl.fecha.isSmallerOrEqualValue(fin))
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.fecha)]))
        .get();

    return movimientos.map((m) => MovimientoModel.fromDrift(m)).toList();
  }

  // ============= CONSULTAS =============

  Future<double> getSaldoTotal() async {
    final cajas = await getCajasActivas();
    return cajas.fold(0.0, (sum, caja) => sum + caja.saldo);
  }

  Future<ResumenCaja> getResumenCaja(int cajaId) async {
    final caja = await getCajaById(cajaId);
    final movimientos = await getMovimientosByCaja(cajaId);

    double totalIngresos = 0;
    double totalEgresos = 0;
    double totalTransferenciasEntrada = 0;
    double totalTransferenciasSalida = 0;
    DateTime? ultimoMovimiento;

    for (final mov in movimientos) {
      if (mov.tipo == 'INGRESO' && mov.categoria != 'TRANSFERENCIA') {
        totalIngresos += mov.monto;
      } else if (mov.tipo == 'EGRESO' && mov.categoria != 'TRANSFERENCIA') {
        totalEgresos += mov.monto;
      } else if (mov.tipo == 'TRANSFERENCIA') {
        // Determinar si es entrada o salida
        if (mov.cajaId == cajaId && mov.saldoNuevo < mov.saldoAnterior) {
          totalTransferenciasSalida += mov.monto;
        } else if (mov.cajaId == cajaId && mov.saldoNuevo > mov.saldoAnterior) {
          totalTransferenciasEntrada += mov.monto;
        }
      }

      if (ultimoMovimiento == null || mov.fecha.isAfter(ultimoMovimiento)) {
        ultimoMovimiento = mov.fecha;
      }
    }

    return ResumenCaja(
      caja: caja,
      totalIngresos: totalIngresos,
      totalEgresos: totalEgresos,
      totalTransferenciasEntrada: totalTransferenciasEntrada,
      totalTransferenciasSalida: totalTransferenciasSalida,
      cantidadMovimientos: movimientos.length,
      ultimoMovimiento: ultimoMovimiento,
    );
  }

  Future<Map<String, double>> getResumenGeneral() async {
    final cajas = await getCajasActivas();
    final movimientos = await getMovimientos();

    double saldoTotal = 0;
    double totalIngresos = 0;
    double totalEgresos = 0;

    for (final caja in cajas) {
      saldoTotal += caja.saldo;
    }

    for (final mov in movimientos) {
      if (mov.tipo == 'INGRESO' && mov.categoria != 'TRANSFERENCIA') {
        totalIngresos += mov.monto;
      } else if (mov.tipo == 'EGRESO' && mov.categoria != 'TRANSFERENCIA') {
        totalEgresos += mov.monto;
      }
    }

    return {
      'saldoTotal': saldoTotal,
      'totalIngresos': totalIngresos,
      'totalEgresos': totalEgresos,
      'cantidadCajas': cajas.length.toDouble(),
      'cantidadMovimientos': movimientos.length.toDouble(),
    };
  }
}