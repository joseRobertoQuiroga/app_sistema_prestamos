import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../database/database_provider.dart';
import '../../domain/usecases/reportes_usecases.dart';
import '../../domain/repositories/reportes_repository.dart';
import '../../data/repositories/reportes_repository_impl.dart';
import '../../data/services/excel_service.dart';
import '../../data/services/pdf_service.dart';
import '../../data/datasources/reportes_local_data_source.dart';

// ============================================================================
// SERVICIOS
// ============================================================================

/// Provider para el servicio de Excel
final excelServiceProvider = Provider<ExcelService>((ref) {
  return ExcelService();
});

/// Provider para el servicio de PDF
final pdfServiceProvider = Provider<PdfService>((ref) {
  return PdfService();
});

// ============================================================================
// DATA SOURCE
// ============================================================================

/// Provider para el data source local de reportes
final reportesLocalDataSourceProvider = Provider<ReportesLocalDataSource>((ref) {
  final database = ref.watch(databaseProvider);
  final excelService = ref.watch(excelServiceProvider);
  final pdfService = ref.watch(pdfServiceProvider);

  return ReportesLocalDataSource(
    database: database,
    excelService: excelService,
    pdfService: pdfService,
  );
});

// ============================================================================
// REPOSITORY
// ============================================================================

/// Provider para el repositorio de reportes
final reportesRepositoryProvider = Provider<ReportesRepository>((ref) {
  final dataSource = ref.watch(reportesLocalDataSourceProvider);
  return ReportesRepositoryImpl(dataSource);
});

// ============================================================================
// USE CASES
// ============================================================================

/// Provider para el caso de uso de generar reporte
final generarReporteUseCaseProvider = Provider<GenerarReporte>((ref) {
  final repository = ref.watch(reportesRepositoryProvider);
  return GenerarReporte(repository);
});

/// Provider para el caso de uso de exportar datos
final exportarDatosUseCaseProvider = Provider<ExportarDatos>((ref) {
  final repository = ref.watch(reportesRepositoryProvider);
  return ExportarDatos(repository);
});

/// Provider para el caso de uso de generar plantilla
final generarPlantillaUseCaseProvider = Provider<GenerarPlantilla>((ref) {
  final repository = ref.watch(reportesRepositoryProvider);
  return GenerarPlantilla(repository);
});

/// Provider para el caso de uso de importar clientes
final importarClientesUseCaseProvider = Provider<ImportarClientes>((ref) {
  final repository = ref.watch(reportesRepositoryProvider);
  return ImportarClientes(repository);
});

/// Provider para el caso de uso de importar préstamos
final importarPrestamosUseCaseProvider = Provider<ImportarPrestamos>((ref) {
  final repository = ref.watch(reportesRepositoryProvider);
  return ImportarPrestamos(repository);
});

// ============================================================================
// ESTADOS DE UI
// ============================================================================

/// Provider para el índice de la tab activa
final tabIndexProvider = StateProvider<int>((ref) => 0);

/// Provider para el período seleccionado
final periodoSeleccionadoProvider = StateProvider<String>((ref) => 'ultimoMes');

/// Provider para el formato seleccionado
final formatoSeleccionadoProvider = StateProvider<String>((ref) => 'pdf');

/// Provider para loading de generación de reporte
final generandoReporteProvider = StateProvider<bool>((ref) => false);

/// Provider para loading de exportación
final exportandoDatosProvider = StateProvider<bool>((ref) => false);

/// Provider para loading de importación
final importandoDatosProvider = StateProvider<bool>((ref) => false);