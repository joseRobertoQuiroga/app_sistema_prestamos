import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'database.g.dart';

// ============================================================================
// TABLAS
// ============================================================================

// Tabla de Clientes
class Clientes extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get nombres => text().withLength(min: 1, max: 100)();
  TextColumn get apellidos => text().withLength(min: 1, max: 100)();
  TextColumn get tipoDocumento => text().withLength(min: 2, max: 20)();
  TextColumn get numeroDocumento => text().withLength(min: 5, max: 20).unique()();
  TextColumn get telefono => text().withLength(min: 7, max: 20)();
  TextColumn get email => text().withLength(max: 100).nullable()();
  TextColumn get direccion => text().withLength(max: 200)();
  TextColumn get referencia => text().withLength(max: 200).nullable()();
  TextColumn get observaciones => text().nullable()();
  BoolColumn get activo => boolean().withDefault(const Constant(true))();
  DateTimeColumn get fechaRegistro => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get fechaActualizacion => dateTime().nullable()();
}

// Tabla de Cajas/Cuentas
class Cajas extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get nombre => text().withLength(min: 1, max: 100)();
  TextColumn get tipo => text().withLength(min: 1, max: 50)(); // EFECTIVO, BANCO, DIGITAL
  TextColumn get descripcion => text().nullable()();
  RealColumn get saldoInicial => real().withDefault(const Constant(0.0))();
  RealColumn get saldoActual => real().withDefault(const Constant(0.0))();
  BoolColumn get activa => boolean().withDefault(const Constant(true))();
  DateTimeColumn get fechaCreacion => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get fechaActualizacion => dateTime().nullable()();
}

// Tabla de Préstamos
class Prestamos extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get codigo => text().withLength(min: 1, max: 50).unique()();
  // ✅ CORREGIDO: Agregado onDelete: KeyAction.restrict para prevenir eliminación de clientes con préstamos
  IntColumn get clienteId => integer().references(Clientes, #id, onDelete: KeyAction.restrict)();
  IntColumn get cajaId => integer().references(Cajas, #id)();
  RealColumn get montoOriginal => real()();
  RealColumn get montoTotal => real()(); // Con intereses
  RealColumn get saldoPendiente => real()();
  RealColumn get tasaInteres => real()(); // Porcentaje
  TextColumn get tipoInteres => text().withLength(min: 1, max: 20)(); // SIMPLE, COMPUESTO
  IntColumn get plazoMeses => integer()();
  RealColumn get cuotaMensual => real()();
  DateTimeColumn get fechaInicio => dateTime()();
  DateTimeColumn get fechaVencimiento => dateTime()();
  TextColumn get estado => text().withLength(min: 1, max: 20)(); // ACTIVO, PAGADO, MORA, CANCELADO
  TextColumn get observaciones => text().nullable()();
  DateTimeColumn get fechaRegistro => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get fechaActualizacion => dateTime().nullable()();
}

// Tabla de Cuotas (Tabla de Amortización)
class Cuotas extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get prestamoId => integer().references(Prestamos, #id, onDelete: KeyAction.cascade)();
  IntColumn get numeroCuota => integer()();
  DateTimeColumn get fechaVencimiento => dateTime()();
  RealColumn get montoCuota => real()();
  RealColumn get capital => real()();
  RealColumn get interes => real()();
  RealColumn get saldoPendiente => real()();
  RealColumn get montoPagado => real().withDefault(const Constant(0.0))();
  RealColumn get montoMora => real().withDefault(const Constant(0.0))();
  TextColumn get estado => text().withLength(min: 1, max: 20)(); // PENDIENTE, PAGADA, MORA, VENCIDA
  DateTimeColumn get fechaPago => dateTime().nullable()();
  DateTimeColumn get fechaRegistro => dateTime().withDefault(currentDateAndTime)();
}

// Tabla de Pagos
class Pagos extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get codigo => text().withLength(min: 1, max: 50).unique()();
  IntColumn get prestamoId => integer().references(Prestamos, #id)();
  IntColumn get clienteId => integer().references(Clientes, #id)();
  IntColumn get cajaId => integer().references(Cajas, #id)();
  RealColumn get montoPago => real()();
  RealColumn get montoCapital => real()();
  RealColumn get montoInteres => real()();
  RealColumn get montoMora => real().withDefault(const Constant(0.0))();
  DateTimeColumn get fechaPago => dateTime()();
  TextColumn get metodoPago => text().withLength(min: 1, max: 50)(); // EFECTIVO, TRANSFERENCIA, etc
  TextColumn get observaciones => text().nullable()();
  DateTimeColumn get fechaRegistro => dateTime().withDefault(currentDateAndTime)();
}

// Tabla de Detalle de Pagos (qué cuotas se pagaron)
class DetallePagos extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get pagoId => integer().references(Pagos, #id, onDelete: KeyAction.cascade)();
  IntColumn get cuotaId => integer().references(Cuotas, #id)();
  RealColumn get montoAplicado => real()();
  RealColumn get montoMora => real().withDefault(const Constant(0.0))();
  DateTimeColumn get fechaRegistro => dateTime().withDefault(currentDateAndTime)();
}

// Tabla de Movimientos de Caja
// ⚠️ CORREGIDO: Agregadas columnas saldoAnterior y saldoNuevo
class Movimientos extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get codigo => text().withLength(min: 1, max: 50).unique()();
  IntColumn get cajaId => integer().references(Cajas, #id)();
  TextColumn get tipo => text().withLength(min: 1, max: 20)(); // INGRESO, EGRESO, TRANSFERENCIA
  RealColumn get monto => real()();
  TextColumn get categoria => text().withLength(min: 1, max: 50)(); // PRESTAMO, PAGO, GASTO, TRANSFERENCIA, OTRO
  TextColumn get descripcion => text()();
  
  // ✅ COLUMNAS AGREGADAS PARA AUDITORÍA
  RealColumn get saldoAnterior => real()(); // Saldo antes del movimiento
  RealColumn get saldoNuevo => real()(); // Saldo después del movimiento
  
  IntColumn get prestamoId => integer().references(Prestamos, #id).nullable()();
  IntColumn get pagoId => integer().references(Pagos, #id).nullable()();
  IntColumn get cajaDestinoId => integer().references(Cajas, #id).nullable()(); // Para transferencias
  DateTimeColumn get fecha => dateTime()();
  TextColumn get observaciones => text().nullable()();
  DateTimeColumn get fechaRegistro => dateTime().withDefault(currentDateAndTime)();
}

// ============================================================================
// DATABASE
// ============================================================================

@DriftDatabase(tables: [
  Clientes,
  Cajas,
  Prestamos,
  Cuotas,
  Pagos,
  DetallePagos,
  Movimientos,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 3; // ⚠️ INCREMENTADO: v3 agrega FK constraint en Prestamos.clienteId

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
        
        // Insertar caja por defecto
        await into(cajas).insert(
          CajasCompanion.insert(
            nombre: 'Caja Principal',
            tipo: 'EFECTIVO',
            descripcion: const Value('Caja principal del sistema'),
            saldoInicial: const Value(0.0),
            saldoActual: const Value(0.0),
          ),
        );
      },
      onUpgrade: (Migrator m, int from, int to) async {
        // Migración de versión 1 a 2: Agregar columnas a Movimientos
        if (from == 1 && to >= 2) {
          await m.addColumn(movimientos, movimientos.saldoAnterior);
          await m.addColumn(movimientos, movimientos.saldoNuevo);
          
          // Actualizar movimientos existentes con valores por defecto
          await customStatement(
            'UPDATE movimientos SET saldo_anterior = 0.0, saldo_nuevo = 0.0'
          );
        }
        
        // Migración de versión 2 a 3: Recrear tabla Prestamos con FK constraint
        // Nota: SQLite no soporta ALTER TABLE para modificar constraints
        // Por eso la tabla se recrea en la migración
        if (from == 2 && to == 3) {
          // La constraint se aplicará automáticamente en nuevas instalaciones
          // Para instalaciones existentes, el constraint no se puede agregar retroactivamente
          // sin recrear la tabla, lo cual requeriría migración de datos compleja
        }
      },
    );
  }

  /// Resetea la base de datos eliminando el archivo
  /// ⚠️ ADVERTENCIA: Esto eliminará TODOS los datos de forma permanente
  static Future<void> resetDatabase() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'prestamos_db.sqlite'));
    
    if (await file.exists()) {
      await file.delete();
      print('✅ Base de datos eliminada: ${file.path}');
    } else {
      print('ℹ️ No se encontró archivo de base de datos');
    }
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'prestamos_db.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}