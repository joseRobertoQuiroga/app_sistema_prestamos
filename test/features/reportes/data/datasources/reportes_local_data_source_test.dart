import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sistema_prestamos/core/database/database.dart';
import 'package:sistema_prestamos/features/reportes/data/datasources/reportes_local_data_source.dart';
import 'package:sistema_prestamos/features/reportes/data/services/excel_service.dart' as excel_svc;
import 'package:sistema_prestamos/features/reportes/data/services/importacion_service.dart';
import 'package:sistema_prestamos/features/reportes/data/services/pdf_service.dart';
import 'package:sistema_prestamos/features/reportes/domain/entities/reportes_entities.dart';

class FakeExcelService extends Fake implements excel_svc.ExcelService {
  bool exportarPrestamosLlamado = false;
  
  @override
  Future<String> exportarPrestamos(List<excel_svc.Prestamo> prestamos) async {
    exportarPrestamosLlamado = true;
    return 'ruta/al/excel.xlsx';
  }
}

class FakePdfService extends Fake implements PdfService {
  bool generarReporteCarteraLlamado = false;
  bool generarReporteMoraLlamado = false;
  
  @override
  Future<String> generarReporteCartera({
    required int totalPrestamos,
    required int prestamosActivos,
    required int prestamosEnMora,
    required int prestamosPagados,
    required double carteraTotal,
    required double capitalPorCobrar,
    required double tasaMorosidad,
    required DateTime fechaInicio,
    required DateTime fechaFin,
    required List<PrestamoCartera> prestamos,
  }) async {
    generarReporteCarteraLlamado = true;
    return 'ruta/al/pdf.pdf';
  }

  @override
  Future<String> generarReporteMora({
    required List<PrestamoMora> prestamosEnMora,
    required double totalMoraAcumulada,
    required DateTime fechaInicio,
    required DateTime fechaFin,
  }) async {
    generarReporteMoraLlamado = true;
    return 'ruta/al/mora.pdf';
  }

  @override
  Future<String> generarReporteMovimientos({
    required String nombreCaja,
    required double saldoInicial,
    required double totalIngresos,
    required double totalEgresos,
    required double saldoFinal,
    required List<MovimientoResumen> movimientos,
    required DateTime fechaInicio,
    required DateTime fechaFin,
    String? tituloReporte,
  }) async {
    return 'ruta/al/movimientos.pdf';
  }
}

class FakeImportacionService extends Fake implements ImportacionService {}

void main() {
  late AppDatabase database;
  late ReportesLocalDataSource dataSource;
  late FakeExcelService fakeExcelService;
  late FakePdfService fakePdfService;
  late FakeImportacionService fakeImportacionService;

  setUp(() async {
    database = AppDatabase(NativeDatabase.memory());
    fakeExcelService = FakeExcelService();
    fakePdfService = FakePdfService();
    fakeImportacionService = FakeImportacionService();
    
    dataSource = ReportesLocalDataSource(
      database: database,
      excelService: fakeExcelService,
      pdfService: fakePdfService,
      importacionService: fakeImportacionService,
    );
  });

  tearDown(() async {
    await database.close();
  });

  group('ReportesLocalDataSource - generarReporteCartera', () {
    test('Debe llamar al servicio PDF con los datos procesados correctamente', () async {
      // 1. Preparar datos de prueba
      final fecha = DateTime.now();
      
      // Insertar un cliente
      final clienteId = await database.into(database.clientes).insert(
        ClientesCompanion(
          nombres: const Value('Juan'),
          apellidos: const Value('Perez'),
          tipoDocumento: const Value('CI'),
          numeroDocumento: const Value('1234567'),
          telefono: const Value('77777777'),
          direccion: const Value('Calle Falsa 123'),
        ),
      );

      // Insertar una caja
      final cajaId = await database.into(database.cajas).insert(
        CajasCompanion(
          nombre: const Value('Caja Test'),
          tipo: const Value('EFECTIVO'),
          saldoInicial: const Value(1000.0),
          saldoActual: const Value(1000.0),
        ),
      );

      // Insertar un préstamo
      await database.into(database.prestamos).insert(
        PrestamosCompanion(
          codigo: const Value('P-001'),
          clienteId: Value(clienteId),
          cajaId: Value(cajaId),
          montoOriginal: const Value(1000.0),
          montoTotal: const Value(1200.0),
          saldoPendiente: const Value(1200.0),
          tasaInteres: const Value(20.0),
          tipoInteres: const Value('SIMPLE'),
          plazoMeses: const Value(12),
          cuotaMensual: const Value(100.0),
          fechaInicio: Value(fecha),
          fechaVencimiento: Value(fecha.add(const Duration(days: 365))),
          estado: const Value('ACTIVO'),
          fechaRegistro: Value(fecha),
        ),
      );

      // 2. Ejecutar
      final config = ConfiguracionReporte(
        tipo: TipoReporte.carteraCompleta,
        formato: FormatoReporte.pdf,
        periodo: PeriodoReporte.todoElTiempo,
      );
      
      final result = await dataSource.generarReporteCartera(config);

      // 3. Verificar
      expect(result, 'ruta/al/pdf.pdf');
      expect(fakePdfService.generarReporteCarteraLlamado, true);
    });

    test('Debe llamar al servicio Excel para exportar cartera', () async {
      final config = ConfiguracionReporte(
        tipo: TipoReporte.carteraCompleta,
        formato: FormatoReporte.excel,
        periodo: PeriodoReporte.todoElTiempo,
      );
      
      final result = await dataSource.generarReporteCartera(config);

      expect(result, 'ruta/al/excel.xlsx');
      expect(fakeExcelService.exportarPrestamosLlamado, true);
    });
  });

  group('ReportesLocalDataSource - generarReporteMora', () {
    test('Debe procesar correctamente préstamos en mora', () async {
      // Insertar un cliente y una caja (ya sabemos que funciona)
      final clienteId = await database.into(database.clientes).insert(
        ClientesCompanion(
          nombres: const Value('Pedro'),
          apellidos: const Value('Gomez'),
          tipoDocumento: const Value('CI'),
          numeroDocumento: const Value('7654321'),
          telefono: const Value('66666666'),
          direccion: const Value('Calle Real 456'),
        ),
      );
      
      final cajaId = await database.into(database.cajas).insert(
        CajasCompanion(
          nombre: const Value('Caja Mora'),
          tipo: const Value('EFECTIVO'),
        ),
      );

      // Insertar un préstamo en MORA
      final fecha = DateTime.now();
      await database.into(database.prestamos).insert(
        PrestamosCompanion(
          codigo: const Value('P-MORA'),
          clienteId: Value(clienteId),
          cajaId: Value(cajaId),
          montoOriginal: const Value(500.0),
          montoTotal: const Value(600.0),
          saldoPendiente: const Value(600.0),
          tasaInteres: const Value(20.0),
          tipoInteres: const Value('SIMPLE'),
          plazoMeses: const Value(6),
          cuotaMensual: const Value(100.0),
          fechaInicio: Value(fecha.subtract(const Duration(days: 60))),
          fechaVencimiento: Value(fecha.subtract(const Duration(days: 30))),
          estado: const Value('MORA'),
        ),
      );

      final config = ConfiguracionReporte(
        tipo: TipoReporte.moraDetallada,
        formato: FormatoReporte.pdf,
        periodo: PeriodoReporte.todoElTiempo,
      );
      
      final result = await dataSource.generarReporteMora(config);

      expect(result, 'ruta/al/mora.pdf');
      expect(fakePdfService.generarReporteMoraLlamado, true);
    });
  });

  group('ReportesLocalDataSource - generarReporteMovimientos', () {
    test('Debe procesar correctamente movimientos de caja', () async {
      final cajaId = await database.into(database.cajas).insert(
        CajasCompanion(
          nombre: const Value('Caja Movs'),
          tipo: const Value('EFECTIVO'),
        ),
      );

      final fecha = DateTime.now();
      await database.into(database.movimientos).insert(
        MovimientosCompanion(
          codigo: const Value('M-001'),
          cajaId: Value(cajaId),
          tipo: const Value('INGRESO'),
          monto: const Value(100.0),
          categoria: const Value('OTRO'),
          descripcion: const Value('Ingreso test'),
          saldoAnterior: const Value(0.0),
          saldoNuevo: const Value(100.0),
          fecha: Value(fecha),
        ),
      );

      final config = ConfiguracionReporte(
        tipo: TipoReporte.movimientosCaja,
        formato: FormatoReporte.pdf,
        periodo: PeriodoReporte.todoElTiempo,
        cajaId: cajaId,
      );
      
      final result = await dataSource.generarReporteMovimientos(config);

      expect(result, 'ruta/al/movimientos.pdf');
    });
  });
}
