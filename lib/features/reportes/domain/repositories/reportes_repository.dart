import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/reportes_entities.dart';

/// Repositorio para la gestión de reportes, exportación e importación
abstract class ReportesRepository {
  /// Genera un reporte según la configuración proporcionada
  /// 
  /// Retorna [ResultadoReporte] con la ruta del archivo generado
  /// o [Failure] si ocurre algún error
  Future<Either<Failure, ResultadoReporte>> generarReporte(
    ConfiguracionReporte configuracion,
  );

  /// Exporta datos a Excel según el tipo especificado
  /// 
  /// Retorna la ruta del archivo Excel generado
  /// o [Failure] si ocurre algún error
  Future<Either<Failure, String>> exportarDatos(
    TipoDatoExportacion tipo,
  );

  /// Genera una plantilla de Excel para importación
  /// 
  /// Retorna la ruta de la plantilla generada
  /// o [Failure] si ocurre algún error
  Future<Either<Failure, String>> generarPlantilla(
    TipoPlantilla tipo,
  );

  /// Importa clientes desde un archivo Excel
  /// 
  /// [rutaArchivo] es la ruta del archivo Excel a importar
  /// 
  /// Retorna [ResultadoImportacion] con el resultado del proceso
  /// o [Failure] si ocurre algún error crítico
  Future<Either<Failure, ResultadoImportacion>> importarClientes(
    String rutaArchivo,
  );

  /// Importa préstamos desde un archivo Excel
  /// 
  /// [rutaArchivo] es la ruta del archivo Excel a importar
  /// 
  /// Retorna [ResultadoImportacion] con el resultado del proceso
  /// o [Failure] si ocurre algún error crítico
  Future<Either<Failure, ResultadoImportacion>> importarPrestamos(
    String rutaArchivo,
  );
}