import '../../domain/entities/caja.dart';
import '../../domain/entities/movimiento.dart';
import '../../../../core/database/database.dart';

/// Modelo de Caja - Capa de Datos
class CajaModel extends Caja {
  const CajaModel({
    super.id,
    required super.nombre,
    required super.tipo,
    required super.saldo,
    super.numeroCuenta,
    super.banco,
    super.titular,
    super.descripcion,
    super.activa,
    required super.fechaCreacion,
    super.fechaActualizacion,
  });

  factory CajaModel.fromEntity(Caja caja) {
    return CajaModel(
      id: caja.id,
      nombre: caja.nombre,
      tipo: caja.tipo,
      saldo: caja.saldo,
      numeroCuenta: caja.numeroCuenta,
      banco: caja.banco,
      titular: caja.titular,
      descripcion: caja.descripcion,
      activa: caja.activa,
      fechaCreacion: caja.fechaCreacion,
      fechaActualizacion: caja.fechaActualizacion,
    );
  }

  factory CajaModel.fromDrift(CajaData data) {
    return CajaModel(
      id: data.id,
      nombre: data.nombre,
      tipo: data.tipo,
      // DRIFT: saldoActual -> DOMAIN: saldo
      saldo: data.saldoActual,
      // Campos que NO existen en Drift se dejan en null
      numeroCuenta: null, 
      banco: null, 
      titular: null,
      descripcion: data.descripcion,
      activa: data.activa,
      fechaCreacion: data.fechaCreacion,
      fechaActualizacion: data.fechaActualizacion,
    );
  }

  CajasCompanion toCompanion() {
    return CajasCompanion.insert(
      nombre: nombre,
      tipo: tipo,
      // DOMAIN: saldo -> DRIFT: saldoActual
      saldoActual: Value(saldo), 
      // Drift no tiene numeroCuenta, banco, titular. Se ignoran.
      descripcion: Value(descripcion),
      activa: Value(activa),
      fechaCreacion: Value(fechaCreacion),
      fechaActualizacion: Value(fechaActualizacion),
    );
  }

  CajasCompanion toCompanionForUpdate() {
    return CajasCompanion(
      id: Value(id!),
      nombre: Value(nombre),
      tipo: Value(tipo),
      saldoActual: Value(saldo), // Actualizar saldoActual
      descripcion: Value(descripcion),
      activa: Value(activa),
      fechaActualizacion: Value(DateTime.now()),
    );
  }
}

/// Modelo de Movimiento - Capa de Datos
class MovimientoModel extends Movimiento {
  const MovimientoModel({
    super.id,
    required super.cajaId,
    required super.tipo,
    required super.categoria,
    required super.monto,
    required super.descripcion,
    required super.fecha,
    required super.saldoAnterior,
    required super.saldoNuevo,
    super.cajaDestinoId,
    super.prestamoId,
    super.pagoId,
    super.referencia,
    required super.fechaRegistro,
  });

  factory MovimientoModel.fromEntity(Movimiento movimiento) {
    return MovimientoModel(
      id: movimiento.id,
      cajaId: movimiento.cajaId,
      tipo: movimiento.tipo,
      categoria: movimiento.categoria,
      monto: movimiento.monto,
      descripcion: movimiento.descripcion,
      fecha: movimiento.fecha,
      saldoAnterior: movimiento.saldoAnterior,
      saldoNuevo: movimiento.saldoNuevo,
      cajaDestinoId: movimiento.cajaDestinoId,
      prestamoId: movimiento.prestamoId,
      pagoId: movimiento.pagoId,
      referencia: movimiento.referencia,
      fechaRegistro: movimiento.fechaRegistro,
    );
  }

  factory MovimientoModel.fromDrift(MovimientoData data) {
    return MovimientoModel(
      id: data.id,
      cajaId: data.cajaId,
      tipo: data.tipo,
      categoria: data.categoria,
      monto: data.monto,
      descripcion: data.descripcion,
      fecha: data.fecha,
      saldoAnterior: data.saldoAnterior,
      saldoNuevo: data.saldoNuevo,
      cajaDestinoId: data.cajaDestinoId,
      prestamoId: data.prestamoId,
      pagoId: data.pagoId,
      referencia: data.referencia,
      fechaRegistro: data.fechaRegistro,
    );
  }

  MovimientosCompanion toCompanion() {
    return MovimientosCompanion.insert(
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
      referencia: Value(referencia),
      fechaRegistro: fechaRegistro,
    );
  }
}