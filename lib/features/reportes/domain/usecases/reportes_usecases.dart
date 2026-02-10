import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/reportes_entities.dart';
import '../repositories/reportes_repository.dart';

// ============================================================================
// USE CASE: GENERAR REPORTE
// ============================================================================

/// Caso de uso para generar reportes
class GenerarReporte {
  final ReportesRepository repository;

  GenerarReporte(this.repository);

  /// Genera un reporte según la configuración proporcionada
  Future<Either<Failure, ResultadoReporte>> call(
    ConfiguracionReporte configuracion,
  ) async {
    // Validaciones básicas
    if (configuracion.periodo == PeriodoReporte.personalizado) {
      if (configuracion.fechaInicio == null || configuracion.fechaFin == null) {
        return Left(
          ValidationFailure(
            'Las fechas de inicio y fin son obligatorias para período personalizado',
          ),
        );
      }

      if (configuracion.fechaInicio!.isAfter(configuracion.fechaFin!)) {
        return Left(
          ValidationFailure(
            'La fecha de inicio no puede ser posterior a la fecha de fin',
          ),
        );
      }
    }

    // Validaciones específicas por tipo de reporte
    if (configuracion.tipo == TipoReporte.estadoCuentaCliente &&
        configuracion.clienteId == null) {
      return Left(
        ValidationFailure(
          'Debe especificar un cliente para el estado de cuenta',
        ),
      );
    }

    if (configuracion.tipo == TipoReporte.movimientosCaja &&
        configuracion.cajaId == null) {
      return Left(
        ValidationFailure(
          'Debe especificar una caja para el reporte de movimientos',
        ),
      );
    }

    // Delegar al repositorio
    return await repository.generarReporte(configuracion);
  }
}

// ============================================================================
// USE CASE: EXPORTAR DATOS
// ============================================================================

/// Caso de uso para exportar datos a Excel
class ExportarDatos {
  final ReportesRepository repository;

  ExportarDatos(this.repository);

  /// Exporta datos del tipo especificado a Excel
  Future<Either<Failure, String>> call(
    TipoDatoExportacion tipo,
  ) async {
    return await repository.exportarDatos(tipo);
  }
}

// ============================================================================
// USE CASE: GENERAR PLANTILLA
// ============================================================================

/// Caso de uso para generar plantillas de importación
class GenerarPlantilla {
  final ReportesRepository repository;

  GenerarPlantilla(this.repository);

  /// Genera una plantilla de Excel para importación
  Future<Either<Failure, String>> call(
    TipoPlantilla tipo,
  ) async {
    return await repository.generarPlantilla(tipo);
  }
}

// ============================================================================
// USE CASE: IMPORTAR CLIENTES
// ============================================================================

/// Caso de uso para importar clientes desde Excel
class ImportarClientes {
  final ReportesRepository repository;

  ImportarClientes(this.repository);

  /// Importa clientes desde un archivo Excel
  Future<Either<Failure, ResultadoImportacion>> call(
    String rutaArchivo,
  ) async {
    // Validar que se proporcionó una ruta
    if (rutaArchivo.isEmpty) {
      return Left(
        ValidationFailure('Debe seleccionar un archivo para importar'),
      );
    }

    // Validar extensión del archivo
    if (!rutaArchivo.toLowerCase().endsWith('.xlsx') &&
        !rutaArchivo.toLowerCase().endsWith('.xls')) {
      return Left(
        ValidationFailure('El archivo debe ser un Excel (.xlsx o .xls)'),
      );
    }

    // Delegar al repositorio
    return await repository.importarClientes(rutaArchivo);
  }
}

// ============================================================================
// USE CASE: IMPORTAR PRÉSTAMOS
// ============================================================================

/// Caso de uso para importar préstamos desde Excel
class ImportarPrestamos {
  final ReportesRepository repository;

  ImportarPrestamos(this.repository);

  /// Importa préstamos desde un archivo Excel
  Future<Either<Failure, ResultadoImportacion>> call(
    String rutaArchivo,
  ) async {
    // Validar que se proporcionó una ruta
    if (rutaArchivo.isEmpty) {
      return Left(
        ValidationFailure('Debe seleccionar un archivo para importar'),
      );
    }

    // Validar extensión del archivo
    if (!rutaArchivo.toLowerCase().endsWith('.xlsx') &&
        !rutaArchivo.toLowerCase().endsWith('.xls')) {
      return Left(
        ValidationFailure('El archivo debe ser un Excel (.xlsx o .xls)'),
      );
    }

    // Delegar al repositorio
    return await repository.importarPrestamos(rutaArchivo);
  }
}