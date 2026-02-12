import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

/// Servicio para generar archivos PDF
class PdfService {
  final _dateFormat = DateFormat('dd/MM/yyyy');
  final _currencyFormat = NumberFormat.currency(symbol: 'Bs. ', decimalDigits: 2);

  // =========================================================================
  // REPORTES EN PDF
  // =========================================================================

  /// Genera reporte de cartera completa en PDF
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
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.letter,
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Encabezado
              _buildHeader('REPORTE DE CARTERA COMPLETA'),
              pw.SizedBox(height: 20),

              // Período
              _buildPeriodo(fechaInicio, fechaFin),
              pw.SizedBox(height: 30),

              // Resumen General
              pw.Text(
                'RESUMEN GENERAL',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),

              _buildKpiRow('Total Préstamos:', totalPrestamos.toString()),
              _buildKpiRow('Préstamos Activos:', prestamosActivos.toString()),
              _buildKpiRow('Préstamos en Mora:', prestamosEnMora.toString()),
              _buildKpiRow('Préstamos Pagados:', prestamosPagados.toString()),
              pw.SizedBox(height: 15),

              // Indicadores Financieros
              pw.Text(
                'INDICADORES FINANCIEROS',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),

              _buildKpiRow('Cartera Total:', _currencyFormat.format(carteraTotal)),
              _buildKpiRow('Capital por Cobrar:', _currencyFormat.format(capitalPorCobrar)),
              _buildKpiRow('Tasa de Morosidad:', '${tasaMorosidad.toStringAsFixed(2)}%'),
              pw.SizedBox(height: 30),

              // Pie de página
              pw.Spacer(),
              _buildFooter(),
            ],
          );
        },
      ),
    );

    return await _guardarPdf(pdf, 'Reporte_Cartera');
  }

  /// Genera reporte de mora detallada en PDF
  Future<String> generarReporteMora({
    required List<PrestamoMora> prestamosEnMora,
    required double totalMoraAcumulada,
    required DateTime fechaInicio,
    required DateTime fechaFin,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.letter,
        build: (context) {
          return [
            // Encabezado
            _buildHeader('REPORTE DE MORA DETALLADA'),
            pw.SizedBox(height: 20),

            // Período
            _buildPeriodo(fechaInicio, fechaFin),
            pw.SizedBox(height: 20),

            // Resumen
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                color: PdfColors.red50,
                border: pw.Border.all(color: PdfColors.red),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Total Préstamos en Mora: ${prestamosEnMora.length}',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  pw.Text(
                    'Mora Acumulada: ${_currencyFormat.format(totalMoraAcumulada)}',
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.red900,
                    ),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 20),

            // Tabla de préstamos en mora
            _buildTablaMora(prestamosEnMora),

            pw.SizedBox(height: 20),
            _buildFooter(),
          ];
        },
      ),
    );

    return await _guardarPdf(pdf, 'Reporte_Mora');
  }

  /// Genera reporte de movimientos de caja en PDF
  Future<String> generarReporteMovimientos({
    required String nombreCaja,
    required double saldoInicial,
    required double totalIngresos,
    required double totalEgresos,
    required double saldoFinal,
    required List<MovimientoResumen> movimientos,
    required DateTime fechaInicio,
    required DateTime fechaFin,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.letter,
        build: (context) {
          return [
            // Encabezado
            _buildHeader('REPORTE DE MOVIMIENTOS'),
            pw.SizedBox(height: 10),
            pw.Text(
              nombreCaja,
              style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 20),

            // Período
            _buildPeriodo(fechaInicio, fechaFin),
            pw.SizedBox(height: 20),

            // Resumen de saldos
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey),
              ),
              child: pw.Column(
                children: [
                  _buildKpiRow('Saldo Inicial:', _currencyFormat.format(saldoInicial)),
                  _buildKpiRow('Total Ingresos:', _currencyFormat.format(totalIngresos), color: PdfColors.green900),
                  _buildKpiRow('Total Egresos:', _currencyFormat.format(totalEgresos), color: PdfColors.red900),
                  pw.Divider(thickness: 2),
                  _buildKpiRow('Saldo Final:', _currencyFormat.format(saldoFinal), bold: true),
                ],
              ),
            ),
            pw.SizedBox(height: 20),

            // Tabla de movimientos
            if (movimientos.isNotEmpty) _buildTablaMovimientos(movimientos),

            pw.SizedBox(height: 20),
            _buildFooter(),
          ];
        },
      ),
    );

    return await _guardarPdf(pdf, 'Reporte_Movimientos_${nombreCaja.replaceAll(' ', '_')}');
  }

  /// Genera reporte de resumen de pagos en PDF
  Future<String> generarReportePagos({
    required int totalPagos,
    required double totalCobrado,
    required double totalCapital,
    required double totalInteres,
    required double totalMora,
    required Map<String, double> pagosPorMetodo,
    required DateTime fechaInicio,
    required DateTime fechaFin,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.letter,
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Encabezado
              _buildHeader('RESUMEN DE PAGOS'),
              pw.SizedBox(height: 20),

              // Período
              _buildPeriodo(fechaInicio, fechaFin),
              pw.SizedBox(height: 30),

              // Resumen general
              pw.Text(
                'RESUMEN GENERAL',
                style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 10),

              _buildKpiRow('Total de Pagos:', totalPagos.toString()),
              _buildKpiRow('Total Cobrado:', _currencyFormat.format(totalCobrado), bold: true),
              pw.SizedBox(height: 20),

              // Distribución
              pw.Text(
                'DISTRIBUCIÓN',
                style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 10),

              _buildKpiRow('Capital:', _currencyFormat.format(totalCapital)),
              _buildKpiRow('Interés:', _currencyFormat.format(totalInteres)),
              _buildKpiRow('Mora:', _currencyFormat.format(totalMora)),
              pw.SizedBox(height: 20),

              // Pagos por método
              if (pagosPorMetodo.isNotEmpty) ...[
                pw.Text(
                  'PAGOS POR MÉTODO',
                  style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 10),
                ...pagosPorMetodo.entries.map(
                  (entry) => _buildKpiRow(
                    entry.key + ':',
                    _currencyFormat.format(entry.value),
                  ),
                ),
              ],

              pw.Spacer(),
              _buildFooter(),
            ],
          );
        },
      ),
    );

    return await _guardarPdf(pdf, 'Reporte_Pagos');
  }

  /// Genera tabla de amortización en PDF
  Future<String> generarTablaAmortizacion({
    required List<dynamic> cuotas, // Usamos dynamic para evitar problemas de import circular si fuera el caso, pero lo ideal es tipar
    required dynamic prestamo,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.letter,
        orientation: pw.PageOrientation.landscape,
        build: (context) {
          return [
            _buildHeader('TABLA DE AMORTIZACIÓN'),
            pw.SizedBox(height: 10),
            
            // Info del Préstamo
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Código: ${prestamo.codigo}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.Text('Cliente: ${prestamo.nombreCliente ?? "N/A"}'),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text('Monto: ${_currencyFormat.format(prestamo.montoOriginal)}'),
                    pw.Text('Interés: ${prestamo.tasaInteres}%'),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 20),

            // Tabla
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey),
              children: [
                // Encabezados
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                  children: [
                    _buildCelda('#', bold: true),
                    _buildCelda('Fecha', bold: true),
                    _buildCelda('Cuota', bold: true),
                    _buildCelda('Capital', bold: true),
                    _buildCelda('Interés', bold: true),
                    _buildCelda('Saldo', bold: true),
                    _buildCelda('Estado', bold: true),
                  ],
                ),
                // Filas
                ...cuotas.map((c) {
                  return pw.TableRow(
                    children: [
                      _buildCelda(c.numeroCuota.toString()),
                      _buildCelda(_dateFormat.format(c.fechaVencimiento)),
                      _buildCelda(_currencyFormat.format(c.montoCuota)),
                      _buildCelda(_currencyFormat.format(c.capital)),
                      _buildCelda(_currencyFormat.format(c.interes)),
                      _buildCelda(_currencyFormat.format(c.saldoPendiente)),
                      _buildCelda(c.estado.toString().split('.').last.toUpperCase()),
                    ],
                  );
                }).toList(),
              ],
            ),
            
            pw.SizedBox(height: 20),
            _buildFooter(),
          ];
        },
      ),
    );

    return await _guardarPdf(pdf, 'Amortizacion_${prestamo.codigo}');
  }

  // =========================================================================
  // COMPONENTES DE CONSTRUCCIÓN
  // =========================================================================

  /// Construye el encabezado del reporte
  pw.Widget _buildHeader(String titulo) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: PdfColors.blue900,
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'SISTEMA DE GESTIÓN DE PRÉSTAMOS',
            style: pw.TextStyle(
              color: PdfColors.white,
              fontSize: 10,
            ),
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            titulo,
            style: pw.TextStyle(
              color: PdfColors.white,
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// Construye el período del reporte
  pw.Widget _buildPeriodo(DateTime inicio, DateTime fin) {
    return pw.Text(
      'Período: ${_dateFormat.format(inicio)} - ${_dateFormat.format(fin)}',
      style: pw.TextStyle(
        fontSize: 10,
        fontStyle: pw.FontStyle.italic,
      ),
    );
  }

  /// Construye una fila de KPI
  pw.Widget _buildKpiRow(
    String label,
    String value, {
    bool bold = false,
    PdfColor? color,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 3),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  /// Construye tabla de préstamos en mora
  pw.Widget _buildTablaMora(List<PrestamoMora> prestamos) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey),
      children: [
        // Encabezados
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey300),
          children: [
            _buildCelda('Código', bold: true),
            _buildCelda('Cliente', bold: true),
            _buildCelda('Días Mora', bold: true),
            _buildCelda('Mora Acum.', bold: true),
          ],
        ),
        // Datos
        ...prestamos.map(
          (p) => pw.TableRow(
            children: [
              _buildCelda(p.codigo),
              _buildCelda(p.nombreCliente),
              _buildCelda(p.diasMora.toString()),
              _buildCelda(_currencyFormat.format(p.moraAcumulada)),
            ],
          ),
        ),
      ],
    );
  }

  /// Construye tabla de movimientos
  pw.Widget _buildTablaMovimientos(List<MovimientoResumen> movimientos) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey),
      columnWidths: {
        0: const pw.FixedColumnWidth(60),
        1: const pw.FlexColumnWidth(2),
        2: const pw.FixedColumnWidth(50),
        3: const pw.FixedColumnWidth(70),
      },
      children: [
        // Encabezados
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey300),
          children: [
            _buildCelda('Fecha', bold: true),
            _buildCelda('Descripción', bold: true),
            _buildCelda('Tipo', bold: true),
            _buildCelda('Monto', bold: true),
          ],
        ),
        // Datos
        ...movimientos.map(
          (m) => pw.TableRow(
            children: [
              _buildCelda(_dateFormat.format(m.fecha)),
              _buildCelda(m.descripcion, fontSize: 8),
              _buildCelda(m.tipo, fontSize: 8),
              _buildCelda(_currencyFormat.format(m.monto)),
            ],
          ),
        ),
      ],
    );
  }

  /// Construye una celda de tabla
  pw.Widget _buildCelda(String texto, {bool bold = false, double fontSize = 9}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(5),
      child: pw.Text(
        texto,
        style: pw.TextStyle(
          fontSize: fontSize,
          fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }

  /// Construye el pie de página
  pw.Widget _buildFooter() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Divider(thickness: 1),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'Generado el: ${_dateFormat.format(DateTime.now())} ${DateFormat('HH:mm').format(DateTime.now())}',
              style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
            ),
            pw.Text(
              'Sistema de Gestión de Préstamos',
              style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
            ),
          ],
        ),
      ],
    );
  }

  /// Guarda el PDF y retorna la ruta
  Future<String> _guardarPdf(pw.Document pdf, String nombreBase) async {
    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateFormat('yyyyMMdd_HHmm').format(DateTime.now());
    final fileName = '${nombreBase}_$timestamp.pdf';
    final filePath = '${directory.path}/$fileName';

    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());

    return filePath;
  }
}

// =========================================================================
// CLASES DE AYUDA
// =========================================================================

class PrestamoMora {
  final String codigo;
  final String nombreCliente;
  final int diasMora;
  final double moraAcumulada;

  PrestamoMora({
    required this.codigo,
    required this.nombreCliente,
    required this.diasMora,
    required this.moraAcumulada,
  });
}

class MovimientoResumen {
  final DateTime fecha;
  final String tipo;
  final String descripcion;
  final double monto;

  MovimientoResumen({
    required this.fecha,
    required this.tipo,
    required this.descripcion,
    required this.monto,
  });
}