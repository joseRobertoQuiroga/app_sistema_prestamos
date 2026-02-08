import 'package:drift/drift.dart';
import '../../../../data/database/database.dart';
import '../../domain/entities/prestamo.dart';
import '../../domain/entities/cuota.dart';
import '../models/prestamo_model.dart';
import '../models/cuota_model.dart';

class PrestamoLocalDataSource {
  final AppDatabase database;

  PrestamoLocalDataSource(this.database);

  // ============================================================================
  // OPERACIONES DE PRÉSTAMOS
  // ============================================================================

  // Obtener todos los préstamos con información de cliente y caja
  Future<List<PrestamoModel>> getPrestamos() async {
    final query = database.select(database.prestamos).join([
      leftOuterJoin(
        database.clientes,
        database.clientes.id.equalsExp(database.prestamos.clienteId),
      ),
      leftOuterJoin(
        database.cajas,
        database.cajas.id.equalsExp(database.prestamos.cajaId),
      ),
    ]);

    final results = await query.get();

    return results.map((row) {
      final prestamoData = row.readTable(database.prestamos);
      final clienteData = row.readTableOrNull(database.clientes);
      final cajaData = row.readTableOrNull(database.cajas);

      return PrestamoModel.fromDrift(
        prestamoData,
        nombreCliente: clienteData != null
            ? '${clienteData.nombres} ${clienteData.apellidos}'
            : null,
        nombreCaja: cajaData?.nombre,
      );
    }).toList();
  }

  // Obtener préstamo por ID con información relacionada
  Future<PrestamoModel?> getPrestamoById(int id) async {
    final query = database.select(database.prestamos).join([
      leftOuterJoin(
        database.clientes,
        database.clientes.id.equalsExp(database.prestamos.clienteId),
      ),
      leftOuterJoin(
        database.cajas,
        database.cajas.id.equalsExp(database.prestamos.cajaId),
      ),
    ])..where(database.prestamos.id.equals(id));

    final result = await query.getSingleOrNull();

    if (result == null) return null;

    final prestamoData = result.readTable(database.prestamos);
    final clienteData = result.readTableOrNull(database.clientes);
    final cajaData = result.readTableOrNull(database.cajas);

    return PrestamoModel.fromDrift(
      prestamoData,
      nombreCliente: clienteData != null
          ? '${clienteData.nombres} ${clienteData.apellidos}'
          : null,
      nombreCaja: cajaData?.nombre,
    );
  }

  // Obtener préstamos por cliente
  Future<List<PrestamoModel>> getPrestamosByCliente(int clienteId) async {
    final query = database.select(database.prestamos).join([
      leftOuterJoin(
        database.clientes,
        database.clientes.id.equalsExp(database.prestamos.clienteId),
      ),
      leftOuterJoin(
        database.cajas,
        database.cajas.id.equalsExp(database.prestamos.cajaId),
      ),
    ])..where(database.prestamos.clienteId.equals(clienteId));

    final results = await query.get();

    return results.map((row) {
      final prestamoData = row.readTable(database.prestamos);
      final clienteData = row.readTableOrNull(database.clientes);
      final cajaData = row.readTableOrNull(database.cajas);

      return PrestamoModel.fromDrift(
        prestamoData,
        nombreCliente: clienteData != null
            ? '${clienteData.nombres} ${clienteData.apellidos}'
            : null,
        nombreCaja: cajaData?.nombre,
      );
    }).toList();
  }

  // Obtener préstamos por estado
  Future<List<PrestamoModel>> getPrestamosByEstado(EstadoPrestamo estado) async {
    final query = database.select(database.prestamos).join([
      leftOuterJoin(
        database.clientes,
        database.clientes.id.equalsExp(database.prestamos.clienteId),
      ),
      leftOuterJoin(
        database.cajas,
        database.cajas.id.equalsExp(database.prestamos.cajaId),
      ),
    ])..where(database.prestamos.estado.equals(estado.toStorageString()));

    final results = await query.get();

    return results.map((row) {
      final prestamoData = row.readTable(database.prestamos);
      final clienteData = row.readTableOrNull(database.clientes);
      final cajaData = row.readTableOrNull(database.cajas);

      return PrestamoModel.fromDrift(
        prestamoData,
        nombreCliente: clienteData != null
            ? '${clienteData.nombres} ${clienteData.apellidos}'
            : null,
        nombreCaja: cajaData?.nombre,
      );
    }).toList();
  }

  // Buscar préstamos por código o nombre de cliente
  Future<List<PrestamoModel>> searchPrestamos(String query) async {
    final searchQuery = '%${query.toLowerCase()}%';

    final queryBuilder = database.select(database.prestamos).join([
      leftOuterJoin(
        database.clientes,
        database.clientes.id.equalsExp(database.prestamos.clienteId),
      ),
      leftOuterJoin(
        database.cajas,
        database.cajas.id.equalsExp(database.prestamos.cajaId),
      ),
    ])..where(
        database.prestamos.codigo.lower().like(searchQuery) |
        database.clientes.nombres.lower().like(searchQuery) |
        database.clientes.apellidos.lower().like(searchQuery),
      );

    final results = await queryBuilder.get();

    return results.map((row) {
      final prestamoData = row.readTable(database.prestamos);
      final clienteData = row.readTableOrNull(database.clientes);
      final cajaData = row.readTableOrNull(database.cajas);

      return PrestamoModel.fromDrift(
        prestamoData,
        nombreCliente: clienteData != null
            ? '${clienteData.nombres} ${clienteData.apellidos}'
            : null,
        nombreCaja: cajaData?.nombre,
      );
    }).toList();
  }

  // Obtener préstamos activos
  Future<List<PrestamoModel>> getPrestamosActivos() async {
    return getPrestamosByEstado(EstadoPrestamo.activo);
  }

  // Obtener préstamos en mora
  Future<List<PrestamoModel>> getPrestamosEnMora() async {
    return getPrestamosByEstado(EstadoPrestamo.mora);
  }

  // Crear préstamo (sin cuotas)
  Future<int> createPrestamo(PrestamoModel prestamo) async {
    return await database.into(database.prestamos).insert(
      prestamo.toCompanion(),
    );
  }

  // Crear préstamo con cuotas (transacción)
  Future<int> createPrestamoWithCuotas(
    PrestamoModel prestamo,
    List<CuotaModel> cuotas,
  ) async {
    return await database.transaction(() async {
      // 1. Insertar préstamo
      final prestamoId = await database.into(database.prestamos).insert(
        prestamo.toCompanion(),
      );

      // 2. Insertar cuotas
      for (final cuota in cuotas) {
        final cuotaWithPrestamoId = CuotaModel.fromEntity(
          cuota.copyWith(prestamoId: prestamoId),
        );
        await database.into(database.cuotas).insert(
          cuotaWithPrestamoId.toCompanion(),
        );
      }

      // 3. Registrar movimiento de egreso en la caja
      await _registrarMovimientoEgreso(
        cajaId: prestamo.cajaId,
        monto: prestamo.montoOriginal,
        prestamoId: prestamoId,
      );

      return prestamoId;
    });
  }

  // Registrar movimiento de egreso por préstamo
  Future<void> _registrarMovimientoEgreso({
    required int cajaId,
    required double monto,
    required int prestamoId,
  }) async {
    final now = DateTime.now();
    final codigo = 'MOV-${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-${now.millisecondsSinceEpoch.toString().substring(8)}';

    await database.into(database.movimientos).insert(
      MovimientosCompanion.insert(
        codigo: codigo,
        cajaId: cajaId,
        tipo: 'EGRESO',
        monto: monto,
        categoria: 'PRESTAMO',
        descripcion: 'Desembolso de préstamo',
        prestamoId: Value(prestamoId),
        fecha: now,
      ),
    );

    // Actualizar saldo de la caja
    final caja = await (database.select(database.cajas)
          ..where((tbl) => tbl.id.equals(cajaId)))
        .getSingle();

    await (database.update(database.cajas)
          ..where((tbl) => tbl.id.equals(cajaId)))
        .write(
      CajasCompanion(
        saldoActual: Value(caja.saldoActual - monto),
        fechaActualizacion: Value(DateTime.now()),
      ),
    );
  }

  // Actualizar préstamo
  Future<bool> updatePrestamo(PrestamoModel prestamo) async {
    return await (database.update(database.prestamos)
          ..where((tbl) => tbl.id.equals(prestamo.id!)))
        .write(prestamo.toCompanionForUpdate());
  }

  // Eliminar préstamo
  Future<int> deletePrestamo(int id) async {
    // Las cuotas se eliminan en cascada por la configuración de Drift
    return await (database.delete(database.prestamos)
          ..where((tbl) => tbl.id.equals(id)))
        .go();
  }

  // Cancelar préstamo
  Future<bool> cancelarPrestamo(int id) async {
    return await (database.update(database.prestamos)
          ..where((tbl) => tbl.id.equals(id)))
        .write(
      PrestamosCompanion(
        estado: Value(EstadoPrestamo.cancelado.toStorageString()),
        fechaActualizacion: Value(DateTime.now()),
      ),
    );
  }

  // ============================================================================
  // OPERACIONES DE CUOTAS
  // ============================================================================

  // Obtener cuotas por préstamo
  Future<List<CuotaModel>> getCuotasByPrestamo(int prestamoId) async {
    final cuotasData = await (database.select(database.cuotas)
          ..where((tbl) => tbl.prestamoId.equals(prestamoId))
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.numeroCuota)]))
        .get();

    return cuotasData.map((c) => CuotaModel.fromDrift(c)).toList();
  }

  // Obtener cuota por ID
  Future<CuotaModel?> getCuotaById(int id) async {
    final cuotaData = await (database.select(database.cuotas)
          ..where((tbl) => tbl.id.equals(id)))
        .getSingleOrNull();

    if (cuotaData == null) return null;

    return CuotaModel.fromDrift(cuotaData);
  }

  // Obtener cuotas pendientes
  Future<List<CuotaModel>> getCuotasPendientes(int prestamoId) async {
    final cuotasData = await (database.select(database.cuotas)
          ..where((tbl) =>
              tbl.prestamoId.equals(prestamoId) &
              tbl.estado.isNotIn([
                EstadoCuota.pagada.toStorageString(),
              ]))
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.fechaVencimiento)]))
        .get();

    return cuotasData.map((c) => CuotaModel.fromDrift(c)).toList();
  }

  // Obtener cuotas vencidas
  Future<List<CuotaModel>> getCuotasVencidas(int prestamoId) async {
    final now = DateTime.now();
    final cuotasData = await (database.select(database.cuotas)
          ..where((tbl) =>
              tbl.prestamoId.equals(prestamoId) &
              tbl.fechaVencimiento.isSmallerThanValue(now) &
              tbl.estado.isNotIn([EstadoCuota.pagada.toStorageString()]))
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.fechaVencimiento)]))
        .get();

    return cuotasData.map((c) => CuotaModel.fromDrift(c)).toList();
  }

  // Actualizar cuota
  Future<bool> updateCuota(CuotaModel cuota) async {
    return await (database.update(database.cuotas)
          ..where((tbl) => tbl.id.equals(cuota.id!)))
        .write(cuota.toCompanionForUpdate());
  }

  // ============================================================================
  // ACTUALIZACIÓN DE ESTADOS
  // ============================================================================

  // Actualizar estado del préstamo basado en cuotas
  Future<void> actualizarEstadoPrestamo(int prestamoId) async {
    final prestamo = await getPrestamoById(prestamoId);
    if (prestamo == null) return;

    final cuotas = await getCuotasByPrestamo(prestamoId);
    if (cuotas.isEmpty) return;

    // Calcular saldo pendiente
    double saldoPendiente = 0;
    bool tieneCuotasVencidas = false;
    bool todasPagadas = true;

    for (final cuota in cuotas) {
      saldoPendiente += cuota.saldoCuota;
      
      if (!cuota.estaPagada) {
        todasPagadas = false;
        if (cuota.estaVencida) {
          tieneCuotasVencidas = true;
        }
      }
    }

    // Determinar nuevo estado
    EstadoPrestamo nuevoEstado;
    if (todasPagadas) {
      nuevoEstado = EstadoPrestamo.pagado;
    } else if (tieneCuotasVencidas) {
      nuevoEstado = EstadoPrestamo.mora;
    } else {
      nuevoEstado = EstadoPrestamo.activo;
    }

    // Actualizar préstamo
    await (database.update(database.prestamos)
          ..where((tbl) => tbl.id.equals(prestamoId)))
        .write(
      PrestamosCompanion(
        saldoPendiente: Value(saldoPendiente),
        estado: Value(nuevoEstado.toStorageString()),
        fechaActualizacion: Value(DateTime.now()),
      ),
    );
  }

  // Actualizar estados de las cuotas
  Future<void> actualizarEstadosCuotas(int prestamoId) async {
    final cuotas = await getCuotasByPrestamo(prestamoId);
    final now = DateTime.now();

    for (final cuota in cuotas) {
      EstadoCuota nuevoEstado;

      if (cuota.estaPagada) {
        nuevoEstado = EstadoCuota.pagada;
      } else if (now.isAfter(cuota.fechaVencimiento)) {
        // Calcular mora
        final mora = cuota.calcularMora();
        nuevoEstado = EstadoCuota.mora;

        // Actualizar cuota con mora
        await (database.update(database.cuotas)
              ..where((tbl) => tbl.id.equals(cuota.id!)))
            .write(
          CuotasCompanion(
            estado: Value(nuevoEstado.toStorageString()),
            montoMora: Value(mora),
          ),
        );
        continue;
      } else {
        nuevoEstado = EstadoCuota.pendiente;
      }

      // Actualizar estado si cambió
      if (cuota.estado != nuevoEstado) {
        await (database.update(database.cuotas)
              ..where((tbl) => tbl.id.equals(cuota.id!)))
            .write(
          CuotasCompanion(
            estado: Value(nuevoEstado.toStorageString()),
          ),
        );
      }
    }
  }

  // ============================================================================
  // UTILIDADES
  // ============================================================================

  // Verificar si un código de préstamo ya existe
  Future<bool> codigoExists(String codigo) async {
    final count = await (database.selectOnly(database.prestamos)
          ..addColumns([database.prestamos.id.count()])
          ..where(database.prestamos.codigo.equals(codigo)))
        .getSingle();

    return count.read(database.prestamos.id.count())! > 0;
  }
}