import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/reportes_entities.dart';
import '../../domain/repositories/reportes_repository.dart';
import '../datasources/reportes_local_data_source.dart';

/// Implementación del repositorio de reportes
class ReportesRepositoryImpl implements ReportesRepository {
  final ReportesLocalDataSource dataSource;

  ReportesRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, ResultadoReporte>> generarReporte(
    ConfiguracionReporte configuracion,
  ) async {
    try {
      String rutaArchivo;

      // Generar reporte según el tipo
      switch (configuracion.tipo) {
        case TipoReporte.carteraCompleta:
          rutaArchivo = await dataSource.generarReporteCartera(configuracion);
          break;

        case TipoReporte.moraDetallada:
          rutaArchivo = await dataSource.generarReporteMora(configuracion);
          break;

        case TipoReporte.movimientosCaja:
          rutaArchivo = await dataSource.generarReporteMovimientos(configuracion);
          break;

        case TipoReporte.resumenPagos:
          rutaArchivo = await dataSource.generarReportePagos(configuracion);
          break;

        case TipoReporte.estadoCuentaCliente:
          rutaArchivo = await dataSource.generarReporteEstadoCuenta(configuracion);
          break;

        case TipoReporte.proyeccionCobros:
          rutaArchivo = await dataSource.generarReporteProyeccion(configuracion);
          break;

        case TipoReporte.prestamosCancelados:
          rutaArchivo = await dataSource.generarReporteCancelados(configuracion);
          break;

        case TipoReporte.resumenPrestamo:
          rutaArchivo = await dataSource.generarReporteEstadoCuenta(configuracion);
          break;

        case TipoReporte.resumenEgresos:
        case TipoReporte.resumenIngresos:
          rutaArchivo = await dataSource.generarReporteMovimientos(configuracion);
          break;
      }

      // Extraer nombre del archivo de la ruta
      final nombreArchivo = rutaArchivo.split('/').last;

      final resultado = ResultadoReporte(
        rutaArchivo: rutaArchivo,
        nombreArchivo: nombreArchivo,
        tipo: configuracion.tipo,
        formato: configuracion.formato,
        fechaGeneracion: DateTime.now(),
        registrosProcesados: 0, // TODO: Calcular
      );

      return Right(resultado);
    } catch (e) {
      return Left(ServerFailure('Error al generar reporte: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, String>> exportarDatos(
    TipoDatoExportacion tipo,
  ) async {
    try {
      String rutaArchivo;

      switch (tipo) {
        case TipoDatoExportacion.clientes:
          rutaArchivo = await dataSource.exportarClientes();
          break;

        case TipoDatoExportacion.prestamos:
          rutaArchivo = await dataSource.exportarPrestamos();
          break;

        case TipoDatoExportacion.pagos:
          rutaArchivo = await dataSource.exportarPagos();
          break;

        case TipoDatoExportacion.movimientos:
          rutaArchivo = await dataSource.exportarMovimientos();
          break;
      }

      return Right(rutaArchivo);
    } catch (e) {
      return Left(ServerFailure('Error al exportar datos: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, String>> generarPlantilla(
    TipoPlantilla tipo,
  ) async {
    try {
      String rutaArchivo;

      switch (tipo) {
        case TipoPlantilla.clientes:
          rutaArchivo = await dataSource.generarPlantillaClientes();
          break;

        case TipoPlantilla.prestamos:
          rutaArchivo = await dataSource.generarPlantillaPrestamos();
          break;
      }

      return Right(rutaArchivo);
    } catch (e) {
      return Left(ServerFailure('Error al generar plantilla: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, ResultadoImportacion>> importarClientes(
    String rutaArchivo,
  ) async {
    try {
      final resultado = await dataSource.importarClientes(rutaArchivo);
      return Right(resultado);
    } catch (e) {
      return Left(ServerFailure('Error al importar clientes: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, ResultadoImportacion>> importarPrestamos(
    String rutaArchivo,
  ) async {
    try {
      final resultado = await dataSource.importarPrestamos(rutaArchivo);
      return Right(resultado);
    } catch (e) {
      return Left(ServerFailure('Error al importar préstamos: ${e.toString()}'));
    }
  }
}