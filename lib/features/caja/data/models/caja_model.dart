import 'package:drift/drift.dart';
import '../../domain/entities/caja.dart';
import '../../domain/entities/movimiento.dart';
import '../../../../core/database/database.dart' as db;

/// Modelo de datos para Cajas (Adapter entre Drift y Domain)
class CajaModel extends Caja {
  const CajaModel({
    super.id,
    required super.nombre,
    required super.tipo,
    super.saldo = 0.0,
    super.numeroCuenta,
    super.banco,
    super.titular,
    super.descripcion,
    super.activa = true,
    required super.fechaCreacion,
    super.fechaActualizacion,
  });

  /// Factory constructor para crear desde un objeto de Drift (db.Caja)
  factory CajaModel.fromDrift(db.Caja data) {
    return CajaModel(
      id: data.id,
      nombre: data.nombre,
      tipo: data.tipo,
      saldo: data.saldoActual,
      descripcion: data.descripcion,
      activa: data.activa,
      fechaCreacion: data.fechaCreacion,
      fechaActualizacion: data.fechaActualizacion,
    );
  }

  /// Convierte a Companion para insertar en Drift
  db.CajasCompanion toCompanion() {
    return db.CajasCompanion(
      id: id != null ? Value(id!) : const Value.absent(),
      nombre: Value(nombre),
      tipo: Value(tipo),
      saldoInicial: const Value(0.0),
      saldoActual: Value(saldo),
      descripcion: Value(descripcion),
      activa: Value(activa),
      fechaCreacion: Value(fechaCreacion ?? DateTime.now()),
      fechaActualizacion: Value(DateTime.now()),
    );
  }

  /// Convierte a Companion para update en Drift
  db.CajasCompanion toCompanionForUpdate() {
    return db.CajasCompanion(
      id: Value(id!),
      nombre: Value(nombre),
      tipo: Value(tipo),
      saldoActual: Value(saldo),
      descripcion: Value(descripcion),
      activa: Value(activa),
      fechaActualizacion: Value(DateTime.now()),
    );
  }

  /// Crea una copia del modelo con campos actualizados
  @override
  CajaModel copyWith({
    int? id,
    String? nombre,
    String? tipo,
    double? saldo,
    String? numeroCuenta,
    String? banco,
    String? titular,
    String? descripcion,
    bool? activa,
    DateTime? fechaCreacion,
    DateTime? fechaActualizacion,
  }) {
    return CajaModel(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      tipo: tipo ?? this.tipo,
      saldo: saldo ?? this.saldo,
      numeroCuenta: numeroCuenta ?? this.numeroCuenta,
      banco: banco ?? this.banco,
      titular: titular ?? this.titular,
      descripcion: descripcion ?? this.descripcion,
      activa: activa ?? this.activa,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      fechaActualizacion: fechaActualizacion ?? this.fechaActualizacion,
    );
  }

  /// Convierte desde una Entidad de Dominio
  factory CajaModel.fromEntity(Caja entity) {
    return CajaModel(
      id: entity.id,
      nombre: entity.nombre,
      tipo: entity.tipo,
      saldo: entity.saldo,
      numeroCuenta: entity.numeroCuenta,
      banco: entity.banco,
      titular: entity.titular,
      descripcion: entity.descripcion,
      activa: entity.activa,
      fechaCreacion: entity.fechaCreacion,
      fechaActualizacion: entity.fechaActualizacion,
    );
  }
}

/// Modelo de datos para Movimientos (Adapter entre Drift y Domain)
class MovimientoModel extends Movimiento {
  MovimientoModel({
    super.id,
    super.codigo,
    required super.cajaId,
    required super.tipo,
    required super.categoria,
    required super.monto,
    required super.descripcion,
    required super.fecha,
    super.prestamoId,
    super.pagoId,
    super.referencia,
    DateTime? fechaRegistro,
    super.saldoAnterior = 0.0,
    super.saldoNuevo = 0.0,
    super.cajaDestinoId,
  }) : super(fechaRegistro: fechaRegistro ?? DateTime.now());

  /// Factory constructor para crear desde un objeto de Drift (db.Movimiento)
  factory MovimientoModel.fromDrift(db.Movimiento data) {
    return MovimientoModel(
      id: data.id,
      codigo: data.codigo,
      cajaId: data.cajaId,
      tipo: data.tipo,
      categoria: data.categoria,
      monto: data.monto,
      descripcion: data.descripcion,
      fecha: data.fecha,
      prestamoId: data.prestamoId,
      pagoId: data.pagoId,
      referencia: data.observaciones,
      fechaRegistro: data.fechaRegistro,
      saldoAnterior: data.saldoAnterior,
      saldoNuevo: data.saldoNuevo,
      cajaDestinoId: data.cajaDestinoId,
    );
  }

  /// Generador de Código Único
  static String generarCodigo() {
    final now = DateTime.now();
    final timestamp = now.millisecondsSinceEpoch;
    return 'MOV-${now.year}${now.month.toString().padLeft(2, '0')}-${timestamp.toString().substring(timestamp.toString().length - 6)}';
  }

  /// Convierte a Companion para insertar en Drift
  db.MovimientosCompanion toCompanion() {
    return db.MovimientosCompanion.insert(
      codigo: codigo ?? generarCodigo(),
      cajaId: cajaId,
      tipo: tipo,
      categoria: categoria,
      monto: monto,
      descripcion: descripcion,
      fecha: fecha,
      saldoAnterior: saldoAnterior,
      saldoNuevo: saldoNuevo,
      cajaDestinoId: Value(cajaDestinoId),
      prestamoId: Value(prestamoId),
      pagoId: Value(pagoId),
      observaciones: Value(referencia),
      fechaRegistro: Value(fechaRegistro ?? DateTime.now()),
    );
  }

  factory MovimientoModel.fromEntity(Movimiento entity) {
    return MovimientoModel(
      id: entity.id,
      codigo: entity.codigo,
      cajaId: entity.cajaId,
      tipo: entity.tipo,
      categoria: entity.categoria,
      monto: entity.monto,
      descripcion: entity.descripcion,
      fecha: entity.fecha,
      prestamoId: entity.prestamoId,
      pagoId: entity.pagoId,
      referencia: entity.referencia,
      fechaRegistro: entity.fechaRegistro,
      saldoAnterior: entity.saldoAnterior,
      saldoNuevo: entity.saldoNuevo,
      cajaDestinoId: entity.cajaDestinoId,
    );
  }
}