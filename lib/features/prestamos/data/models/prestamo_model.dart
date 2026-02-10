import 'package:drift/drift.dart' as drift;
import '../../domain/entities/prestamo.dart';
import '../../../../core/database/database.dart' as db;

/// Modelo de Préstamo - Capa de Datos
/// ✅ CORREGIDO: Mapeo completo entre entidad y Drift
/// 
/// Utiliza alias 'db' para evitar conflictos con la entidad 'Prestamo'
class PrestamoModel extends Prestamo {
  const PrestamoModel({
    super.id,
    required super.codigo,
    required super.clienteId,
    required super.cajaId,
    required super.montoOriginal,
    required super.montoTotal,
    required super.saldoPendiente,
    required super.tasaInteres,
    required super.tipoInteres,
    required super.plazoMeses,
    required super.cuotaMensual,
    required super.fechaInicio,
    required super.fechaVencimiento,
    required super.estado,
    super.observaciones,
    required super.fechaRegistro,
    super.fechaActualizacion,
    super.nombreCliente,
    super.nombreCaja,
  });

  /// Convertir desde Drift a Modelo
  /// ✅ CORREGIDO: Recibe db.Prestamo y opcionalmente nombres de cliente y caja
  factory PrestamoModel.fromDrift(
    db.Prestamo data, {
    String? nombreCliente,
    String? nombreCaja,
  }) {
    return PrestamoModel(
      id: data.id,
      codigo: data.codigo,
      clienteId: data.clienteId,
      cajaId: data.cajaId,
      montoOriginal: data.montoOriginal,
      montoTotal: data.montoTotal,
      saldoPendiente: data.saldoPendiente,
      tasaInteres: data.tasaInteres,
      // ✅ Convertir string de BD a enum TipoInteres
      // Si la entidad tiene lógica de parseo, usarla. Si no, convertir manualmente.
      // Asumimos que TipoInteres tiene un método o factory fromString
      tipoInteres: _parseTipoInteres(data.tipoInteres), 
      plazoMeses: data.plazoMeses,
      cuotaMensual: data.cuotaMensual,
      fechaInicio: data.fechaInicio,
      fechaVencimiento: data.fechaVencimiento,
      // ✅ Convertir string de BD a enum EstadoPrestamo
      estado: _parseEstado(data.estado),
      observaciones: data.observaciones,
      fechaRegistro: data.fechaRegistro,
      fechaActualizacion: data.fechaActualizacion,
      nombreCliente: nombreCliente,
      nombreCaja: nombreCaja,
    );
  }

  /// Convertir a Companion para INSERT
  db.PrestamosCompanion toCompanion() {
    return db.PrestamosCompanion.insert(
      codigo: codigo,
      clienteId: clienteId,
      cajaId: cajaId,
      montoOriginal: montoOriginal,
      montoTotal: montoTotal,
      saldoPendiente: saldoPendiente,
      tasaInteres: tasaInteres,
      tipoInteres: _enumToString(tipoInteres),
      plazoMeses: plazoMeses,
      cuotaMensual: cuotaMensual,
      fechaInicio: fechaInicio,
      fechaVencimiento: fechaVencimiento,
      estado: _enumToString(estado),
      observaciones: drift.Value(observaciones),
      fechaRegistro: drift.Value(fechaRegistro),
      fechaActualizacion: drift.Value(fechaActualizacion),
    );
  }

  /// Convertir a Companion para UPDATE
  db.PrestamosCompanion toCompanionForUpdate() {
    return db.PrestamosCompanion(
      id: drift.Value(id!),
      codigo: drift.Value(codigo),
      clienteId: drift.Value(clienteId),
      cajaId: drift.Value(cajaId),
      montoOriginal: drift.Value(montoOriginal),
      montoTotal: drift.Value(montoTotal),
      saldoPendiente: drift.Value(saldoPendiente),
      tasaInteres: drift.Value(tasaInteres),
      tipoInteres: drift.Value(_enumToString(tipoInteres)),
      plazoMeses: drift.Value(plazoMeses),
      cuotaMensual: drift.Value(cuotaMensual),
      fechaInicio: drift.Value(fechaInicio),
      fechaVencimiento: drift.Value(fechaVencimiento),
      estado: drift.Value(_enumToString(estado)),
      observaciones: drift.Value(observaciones),
      fechaActualizacion: drift.Value(DateTime.now()),
    );
  }

  /// Copiar desde entidad
  factory PrestamoModel.fromEntity(Prestamo prestamo) {
    return PrestamoModel(
      id: prestamo.id,
      codigo: prestamo.codigo,
      clienteId: prestamo.clienteId,
      cajaId: prestamo.cajaId,
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
      observaciones: prestamo.observaciones,
      fechaRegistro: prestamo.fechaRegistro,
      fechaActualizacion: prestamo.fechaActualizacion,
      nombreCliente: prestamo.nombreCliente,
      nombreCaja: prestamo.nombreCaja,
    );
  }

  // --- Helpers para Enums ---
  
  static TipoInteres _parseTipoInteres(String value) {
    return TipoInteres.values.firstWhere(
      (e) => e.name == value,
      orElse: () => TipoInteres.simple, // Fallback por defecto
    );
  }

  static EstadoPrestamo _parseEstado(String value) {
    return EstadoPrestamo.values.firstWhere(
      (e) => e.name == value,
      orElse: () => EstadoPrestamo.activo, // Fallback
    );
  }

  static String _enumToString(Object e) => e.toString().split('.').last;
}