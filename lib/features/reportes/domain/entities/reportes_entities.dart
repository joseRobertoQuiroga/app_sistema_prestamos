import 'package:equatable/equatable.dart';

// ============================================================================
// ENUMS
// ============================================================================

/// Tipos de reportes disponibles en el sistema
enum TipoReporte {
  estadoCuentaCliente,
  carteraCompleta,
  moraDetallada,
  movimientosCaja,
  proyeccionCobros,
  resumenPagos,
}

/// Formatos de salida para los reportes
enum FormatoReporte {
  pdf,
  excel,
}

/// Períodos de tiempo para filtrar reportes
enum PeriodoReporte {
  ultimoMes,
  ultimoTrimestre,
  ultimoAnio,
  personalizado,
}

/// Tipos de datos que se pueden exportar
enum TipoDatoExportacion {
  clientes,
  prestamos,
  pagos,
  movimientos,
}

/// Tipos de plantillas para importación
enum TipoPlantilla {
  clientes,
  prestamos,
}

// ============================================================================
// ENTIDADES
// ============================================================================

/// Configuración para generar un reporte
class ConfiguracionReporte extends Equatable {
  final TipoReporte tipo;
  final FormatoReporte formato;
  final PeriodoReporte periodo;
  final DateTime? fechaInicio;
  final DateTime? fechaFin;
  final int? clienteId; // Para reportes específicos de cliente
  final int? cajaId; // Para reportes específicos de caja

  const ConfiguracionReporte({
    required this.tipo,
    required this.formato,
    required this.periodo,
    this.fechaInicio,
    this.fechaFin,
    this.clienteId,
    this.cajaId,
  });

  /// Obtiene el rango de fechas según el período
  DateTimeRange getRango() {
    if (periodo == PeriodoReporte.personalizado) {
      return DateTimeRange(
        start: fechaInicio!,
        end: fechaFin!,
      );
    }

    final ahora = DateTime.now();
    DateTime inicio;

    switch (periodo) {
      case PeriodoReporte.ultimoMes:
        inicio = DateTime(ahora.year, ahora.month - 1, ahora.day);
        break;
      case PeriodoReporte.ultimoTrimestre:
        inicio = DateTime(ahora.year, ahora.month - 3, ahora.day);
        break;
      case PeriodoReporte.ultimoAnio:
        inicio = DateTime(ahora.year - 1, ahora.month, ahora.day);
        break;
      case PeriodoReporte.personalizado:
        inicio = fechaInicio!;
        break;
    }

    return DateTimeRange(
      start: inicio,
      end: ahora,
    );
  }

  /// Obtiene el nombre del período para mostrar
  String getPeriodoNombre() {
    switch (periodo) {
      case PeriodoReporte.ultimoMes:
        return 'Último Mes';
      case PeriodoReporte.ultimoTrimestre:
        return 'Último Trimestre';
      case PeriodoReporte.ultimoAnio:
        return 'Último Año';
      case PeriodoReporte.personalizado:
        return 'Personalizado';
    }
  }

  @override
  List<Object?> get props => [
        tipo,
        formato,
        periodo,
        fechaInicio,
        fechaFin,
        clienteId,
        cajaId,
      ];
}

/// Resultado de generar un reporte
class ResultadoReporte extends Equatable {
  final String rutaArchivo;
  final String nombreArchivo;
  final TipoReporte tipo;
  final FormatoReporte formato;
  final DateTime fechaGeneracion;
  final int registrosProcesados;

  const ResultadoReporte({
    required this.rutaArchivo,
    required this.nombreArchivo,
    required this.tipo,
    required this.formato,
    required this.fechaGeneracion,
    this.registrosProcesados = 0,
  });

  @override
  List<Object?> get props => [
        rutaArchivo,
        nombreArchivo,
        tipo,
        formato,
        fechaGeneracion,
        registrosProcesados,
      ];
}

/// Resultado de una importación de datos
class ResultadoImportacion extends Equatable {
  final int registrosExitosos;
  final int registrosConError;
  final int totalRegistros;
  final List<ErrorImportacion> errores;
  final DateTime fechaProceso;

  const ResultadoImportacion({
    required this.registrosExitosos,
    required this.registrosConError,
    required this.totalRegistros,
    required this.errores,
    required this.fechaProceso,
  });

  bool get exitoso => registrosConError == 0;
  bool get parcial => registrosExitosos > 0 && registrosConError > 0;
  double get porcentajeExito =>
      totalRegistros > 0 ? (registrosExitosos / totalRegistros) * 100 : 0;

  /// Agrupa errores por tipo de campo para mostrar resumen
  Map<String, int> getErroresAgrupados() {
    final agrupados = <String, int>{};
    for (final error in errores) {
      agrupados[error.campo] = (agrupados[error.campo] ?? 0) + 1;
    }
    return agrupados;
  }

  /// Obtiene un resumen de errores en texto plano
  String getResumenErrores() {
    if (errores.isEmpty) return 'Sin errores';
    
    final agrupados = getErroresAgrupados();
    final buffer = StringBuffer();
    buffer.writeln('Errores encontrados:');
    agrupados.forEach((campo, cantidad) {
      buffer.writeln('  • $campo: $cantidad error(es)');
    });
    return buffer.toString();
  }

  @override
  List<Object?> get props => [
        registrosExitosos,
        registrosConError,
        totalRegistros,
        errores,
        fechaProceso,
      ];
}

/// Error ocurrido durante la importación
class ErrorImportacion extends Equatable {
  final int fila;
  final String campo;
  final String mensaje;
  final String? valorProblematico;

  const ErrorImportacion({
    required this.fila,
    required this.campo,
    required this.mensaje,
    this.valorProblematico,
  });

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.write('Fila $fila - $campo: $mensaje');
    if (valorProblematico != null) {
      buffer.write(' (Valor: "$valorProblematico")');
    }
    return buffer.toString();
  }

  @override
  List<Object?> get props => [fila, campo, mensaje, valorProblematico];
}

// ============================================================================
// EXTENSIONES DE AYUDA
// ============================================================================

/// Extensión para TipoReporte
extension TipoReporteExtension on TipoReporte {
  String get nombre {
    switch (this) {
      case TipoReporte.estadoCuentaCliente:
        return 'Estado de Cuenta por Cliente';
      case TipoReporte.carteraCompleta:
        return 'Cartera Completa';
      case TipoReporte.moraDetallada:
        return 'Mora Detallada';
      case TipoReporte.movimientosCaja:
        return 'Movimientos de Caja';
      case TipoReporte.proyeccionCobros:
        return 'Proyección de Cobros';
      case TipoReporte.resumenPagos:
        return 'Resumen de Pagos';
    }
  }

  String get descripcion {
    switch (this) {
      case TipoReporte.estadoCuentaCliente:
        return 'Detalle completo de préstamos y pagos de un cliente';
      case TipoReporte.carteraCompleta:
        return 'Estado general de todos los préstamos';
      case TipoReporte.moraDetallada:
        return 'Préstamos y cuotas en mora';
      case TipoReporte.movimientosCaja:
        return 'Ingresos, egresos y transferencias';
      case TipoReporte.proyeccionCobros:
        return 'Cuotas próximas a cobrar';
      case TipoReporte.resumenPagos:
        return 'Total cobrado y distribución';
    }
  }
}

/// Extensión para FormatoReporte
extension FormatoReporteExtension on FormatoReporte {
  String get extension {
    switch (this) {
      case FormatoReporte.pdf:
        return 'pdf';
      case FormatoReporte.excel:
        return 'xlsx';
    }
  }

  String get mimeType {
    switch (this) {
      case FormatoReporte.pdf:
        return 'application/pdf';
      case FormatoReporte.excel:
        return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
    }
  }
}

/// Extensión para TipoDatoExportacion
extension TipoDatoExportacionExtension on TipoDatoExportacion {
  String get nombre {
    switch (this) {
      case TipoDatoExportacion.clientes:
        return 'Clientes';
      case TipoDatoExportacion.prestamos:
        return 'Préstamos';
      case TipoDatoExportacion.pagos:
        return 'Pagos';
      case TipoDatoExportacion.movimientos:
        return 'Movimientos';
    }
  }

  String get nombreArchivo {
    switch (this) {
      case TipoDatoExportacion.clientes:
        return 'Clientes';
      case TipoDatoExportacion.prestamos:
        return 'Prestamos';
      case TipoDatoExportacion.pagos:
        return 'Pagos';
      case TipoDatoExportacion.movimientos:
        return 'Movimientos';
    }
  }
}

/// Extensión para TipoPlantilla
extension TipoPlantillaExtension on TipoPlantilla {
  String get nombre {
    switch (this) {
      case TipoPlantilla.clientes:
        return 'Plantilla de Clientes';
      case TipoPlantilla.prestamos:
        return 'Plantilla de Préstamos';
    }
  }

  String get nombreArchivo {
    switch (this) {
      case TipoPlantilla.clientes:
        return 'Plantilla_Clientes';
      case TipoPlantilla.prestamos:
        return 'Plantilla_Prestamos';
    }
  }
}

// ============================================================================
// CLASE DE AYUDA PARA RANGOS DE FECHA
// ============================================================================

class DateTimeRange {
  final DateTime start;
  final DateTime end;

  const DateTimeRange({required this.start, required this.end});

  Duration get duration => end.difference(start);
  int get days => duration.inDays;
}