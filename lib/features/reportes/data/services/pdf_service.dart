import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

/// Servicio para generar archivos PDF con diseño profesional
class PdfService {
  final _dateFormat = DateFormat('dd/MM/yyyy');
  final _currencyFormat = NumberFormat.currency(symbol: 'Bs. ', decimalDigits: 2);

  // =========================================================================
  // PALETA DE COLORES
  // =========================================================================
  static const _azulOscuro = PdfColor.fromInt(0xFF1A2E5A);
  static const _azulMedio = PdfColor.fromInt(0xFF1976D2);
  static const _azulClaro = PdfColor.fromInt(0xFFE3F2FD);
  static const _verdeOscuro = PdfColor.fromInt(0xFF1B5E20);
  static const _verdeClaro = PdfColor.fromInt(0xFFE8F5E9);
  static const _rojoOscuro = PdfColor.fromInt(0xFFB71C1C);
  static const _rojoClaro = PdfColor.fromInt(0xFFFFEBEE);
  static const _naranjaOscuro = PdfColor.fromInt(0xFFE65100);
  static const _naranjaClaro = PdfColor.fromInt(0xFFFFF3E0);
  static const _grisFondo = PdfColor.fromInt(0xFFF8FAFC);
  static const _grisLinea = PdfColor.fromInt(0xFFE2E8F0);
  static const _grisTexto = PdfColor.fromInt(0xFF64748B);
  static const _grisFila = PdfColor.fromInt(0xFFF1F5F9);
  static const _blanco = PdfColors.white;

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
    final reportId = 'RPT-CAR-${DateFormat('yyyyMMdd').format(DateTime.now())}';

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.letter,
        margin: const pw.EdgeInsets.symmetric(horizontal: 32, vertical: 28),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildHeaderPremium(
                categoria: 'REPORTE FINANCIERO',
                titulo: 'Cartera Activa y Mora',
                subtitulo: 'Estado general de préstamos activos, pendientes y en mora',
                reportId: reportId,
                fechaInicio: fechaInicio,
                fechaFin: fechaFin,
              ),
              pw.SizedBox(height: 20),

              // KPI Cards Row
              pw.Row(
                children: [
                  pw.Expanded(child: _buildKpiCard(
                    label: 'TOTAL PRÉSTAMOS',
                    value: totalPrestamos.toString(),
                    subValue: '$prestamosActivos activos · $prestamosPagados pagados',
                    accentColor: _azulMedio,
                  )),
                  pw.SizedBox(width: 12),
                  pw.Expanded(child: _buildKpiCard(
                    label: 'CARTERA TOTAL',
                    value: _currencyFormat.format(carteraTotal),
                    subValue: 'Capital por cobrar: ${_currencyFormat.format(capitalPorCobrar)}',
                    accentColor: _verdeOscuro,
                  )),
                  pw.SizedBox(width: 12),
                  pw.Expanded(child: _buildKpiCard(
                    label: 'TASA DE MORA',
                    value: '${tasaMorosidad.toStringAsFixed(1)}%',
                    subValue: tasaMorosidad > 5 ? '⚠ Alto Riesgo' : prestamosEnMora > 0 ? '$prestamosEnMora préstamos en mora' : 'Sin mora detectada',
                    accentColor: tasaMorosidad > 5 ? _rojoOscuro : tasaMorosidad > 2 ? _naranjaOscuro : _verdeOscuro,
                    highlight: tasaMorosidad > 5,
                  )),
                ],
              ),
              pw.SizedBox(height: 20),

              // Desglose
              _buildSectionTitle('DESGLOSE DE ESTADOS'),
              pw.SizedBox(height: 8),
              pw.Row(
                children: [
                  pw.Expanded(child: _buildStatRow('Préstamos Activos', prestamosActivos.toString(), _azulMedio)),
                  pw.Expanded(child: _buildStatRow('En Mora', prestamosEnMora.toString(), _rojoOscuro)),
                  pw.Expanded(child: _buildStatRow('Cancelados', prestamosPagados.toString(), _verdeOscuro)),
                ],
              ),

              pw.Spacer(),
              _buildFooterPremium(),
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
    final reportId = 'RPT-MOR-${DateFormat('yyyyMMdd').format(DateTime.now())}';

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.letter,
        margin: const pw.EdgeInsets.symmetric(horizontal: 32, vertical: 28),
        build: (context) {
          return [
            _buildHeaderPremium(
              categoria: 'REPORTE DE RIESGO',
              titulo: 'Mora Detallada',
              subtitulo: 'Préstamos con cuotas vencidas y días de atraso',
              reportId: reportId,
              fechaInicio: fechaInicio,
              fechaFin: fechaFin,
            ),
            pw.SizedBox(height: 16),

            // Alerta de mora
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: pw.BoxDecoration(
                color: _rojoClaro,
                borderRadius: pw.BorderRadius.circular(6),
                border: pw.Border.all(color: _rojoOscuro, width: 0.5),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('ALERTA DE CARTERA EN MORA', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: _rojoOscuro)),
                      pw.SizedBox(height: 2),
                      pw.Text('${prestamosEnMora.length} préstamos requieren atención inmediata',
                          style: const pw.TextStyle(fontSize: 8, color: _rojoOscuro)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('MORA ACUMULADA', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: _rojoOscuro)),
                      pw.Text(_currencyFormat.format(totalMoraAcumulada),
                          style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: _rojoOscuro)),
                    ],
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 16),

            // Tabla de mora
            if (prestamosEnMora.isNotEmpty) _buildTablaMora(prestamosEnMora),
            if (prestamosEnMora.isEmpty) pw.Container(
              padding: const pw.EdgeInsets.all(20),
              child: pw.Center(child: pw.Text('No hay préstamos en mora en el período seleccionado.',
                  style: const pw.TextStyle(fontSize: 10, color: _grisTexto))),
            ),

            pw.SizedBox(height: 16),
            _buildFooterPremium(),
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
    String? tituloReporte,
  }) async {
    final pdf = pw.Document();
    final esIngresos = tituloReporte?.contains('INGRESO') == true;
    final esEgresos = tituloReporte?.contains('EGRESO') == true;
    final reportId = 'RPT-MOV-${DateFormat('yyyyMMdd').format(DateTime.now())}';
    final categoria = esIngresos ? 'REPORTE DE INGRESOS' : esEgresos ? 'REPORTE DE EGRESOS' : 'FLUJO DE CAJA';
    final titulo = esIngresos ? 'Resumen de Ingresos' : esEgresos ? 'Resumen de Egresos' : 'Movimientos de Caja';

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.letter,
        margin: const pw.EdgeInsets.symmetric(horizontal: 32, vertical: 28),
        build: (context) {
          final balanceNeto = totalIngresos - totalEgresos;
          return [
            _buildHeaderPremium(
              categoria: categoria,
              titulo: titulo,
              subtitulo: 'Caja: $nombreCaja',
              reportId: reportId,
              fechaInicio: fechaInicio,
              fechaFin: fechaFin,
            ),
            pw.SizedBox(height: 16),

            // KPI Cards
            pw.Row(
              children: [
                pw.Expanded(child: _buildKpiCard(
                  label: 'TOTAL INGRESOS',
                  value: _currencyFormat.format(totalIngresos),
                  subValue: 'Entradas registradas',
                  accentColor: _verdeOscuro,
                )),
                pw.SizedBox(width: 12),
                pw.Expanded(child: _buildKpiCard(
                  label: 'TOTAL EGRESOS',
                  value: _currencyFormat.format(totalEgresos),
                  subValue: 'Salidas registradas',
                  accentColor: _rojoOscuro,
                )),
                pw.SizedBox(width: 12),
                pw.Expanded(child: _buildKpiCard(
                  label: 'BALANCE NETO',
                  value: _currencyFormat.format(balanceNeto),
                  subValue: balanceNeto >= 0 ? 'Flujo positivo' : 'Flujo negativo',
                  accentColor: balanceNeto >= 0 ? _verdeOscuro : _rojoOscuro,
                  highlight: balanceNeto < 0,
                )),
              ],
            ),
            pw.SizedBox(height: 6),

            // Saldos
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: pw.BoxDecoration(
                color: _grisFondo,
                border: pw.Border.all(color: _grisLinea),
                borderRadius: pw.BorderRadius.circular(4),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  _buildInlineKpi('Saldo Inicial', _currencyFormat.format(saldoInicial)),
                  _buildInlineKpi('Saldo Final', _currencyFormat.format(saldoFinal), bold: true),
                ],
              ),
            ),
            pw.SizedBox(height: 14),

            if (movimientos.isNotEmpty) _buildTablaMovimientos(movimientos),
            if (movimientos.isEmpty) pw.Container(
              padding: const pw.EdgeInsets.all(20),
              child: pw.Center(child: pw.Text('No hay movimientos en el período seleccionado.',
                  style: const pw.TextStyle(fontSize: 10, color: _grisTexto))),
            ),

            pw.SizedBox(height: 16),
            _buildFooterPremium(),
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
    final reportId = 'RPT-PAG-${DateFormat('yyyyMMdd').format(DateTime.now())}';

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.letter,
        margin: const pw.EdgeInsets.symmetric(horizontal: 32, vertical: 28),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildHeaderPremium(
                categoria: 'REPORTE DE COBROS',
                titulo: 'Resumen de Pagos',
                subtitulo: 'Total cobrado desglosado por capital, interés y mora',
                reportId: reportId,
                fechaInicio: fechaInicio,
                fechaFin: fechaFin,
              ),
              pw.SizedBox(height: 20),

              // KPIs
              pw.Row(
                children: [
                  pw.Expanded(child: _buildKpiCard(
                    label: 'TOTAL COBRADO',
                    value: _currencyFormat.format(totalCobrado),
                    subValue: '$totalPagos transacciones',
                    accentColor: _azulMedio,
                  )),
                  pw.SizedBox(width: 12),
                  pw.Expanded(child: _buildKpiCard(
                    label: 'CAPITAL RECUPERADO',
                    value: _currencyFormat.format(totalCapital),
                    subValue: '${totalCobrado > 0 ? ((totalCapital / totalCobrado) * 100).toStringAsFixed(1) : '0'}% del total',
                    accentColor: _verdeOscuro,
                  )),
                  pw.SizedBox(width: 12),
                  pw.Expanded(child: _buildKpiCard(
                    label: 'INTERESES + MORA',
                    value: _currencyFormat.format(totalInteres + totalMora),
                    subValue: 'Interés: ${_currencyFormat.format(totalInteres)} | Mora: ${_currencyFormat.format(totalMora)}',
                    accentColor: _naranjaOscuro,
                  )),
                ],
              ),
              pw.SizedBox(height: 20),

              // Distribución por método
              if (pagosPorMetodo.isNotEmpty) ...[
                _buildSectionTitle('DISTRIBUCIÓN POR MÉTODO DE PAGO'),
                pw.SizedBox(height: 8),
                pw.Table(
                  border: pw.TableBorder.all(color: _grisLinea, width: 0.5),
                  columnWidths: const {
                    0: pw.FlexColumnWidth(2),
                    1: pw.FlexColumnWidth(2),
                    2: pw.FlexColumnWidth(1),
                  },
                  children: [
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(color: _azulOscuro),
                      children: [
                        _buildCeldaHeader('MÉTODO DE PAGO'),
                        _buildCeldaHeader('MONTO'),
                        _buildCeldaHeader('% DEL TOTAL'),
                      ],
                    ),
                    ...pagosPorMetodo.entries.map((entry) {
                      final pct = totalCobrado > 0 ? (entry.value / totalCobrado * 100) : 0.0;
                      return pw.TableRow(
                        decoration: const pw.BoxDecoration(color: _blanco),
                        children: [
                          _buildCelda(entry.key),
                          _buildCelda(_currencyFormat.format(entry.value), bold: true, color: _verdeOscuro),
                          _buildCelda('${pct.toStringAsFixed(1)}%'),
                        ],
                      );
                    }),
                  ],
                ),
              ],

              pw.Spacer(),
              _buildFooterPremium(),
            ],
          );
        },
      ),
    );

    return await _guardarPdf(pdf, 'Reporte_Pagos');
  }

  /// Genera tabla de amortización en PDF
  Future<String> generarTablaAmortizacion({
    required List<dynamic> cuotas,
    required dynamic prestamo,
  }) async {
    final pdf = pw.Document();
    final reportId = 'AMO-${prestamo.codigo}';

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.letter,
        orientation: pw.PageOrientation.landscape,
        margin: const pw.EdgeInsets.symmetric(horizontal: 28, vertical: 24),
        build: (context) {
          return [
            _buildHeaderPremium(
              categoria: 'TABLA FINANCIERA',
              titulo: 'Tabla de Amortización',
              subtitulo: 'Préstamo: ${prestamo.codigo} — Cliente: ${prestamo.nombreCliente ?? 'N/A'}',
              reportId: reportId,
              fechaInicio: DateTime.now(),
              fechaFin: DateTime.now(),
            ),
            pw.SizedBox(height: 10),

            // Info del préstamo
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: pw.BoxDecoration(
                color: _grisFondo,
                border: pw.Border.all(color: _grisLinea),
                borderRadius: pw.BorderRadius.circular(4),
              ),
              child: pw.Row(
                children: [
                  pw.Expanded(child: _buildInlineKpi('Monto Original', _currencyFormat.format(prestamo.montoOriginal))),
                  pw.Expanded(child: _buildInlineKpi('Tasa de Interés', '${prestamo.tasaInteres}%')),
                  pw.Expanded(child: _buildInlineKpi('Plazo', '${prestamo.plazoMeses} meses')),
                  pw.Expanded(child: _buildInlineKpi('Saldo Pendiente', _currencyFormat.format(prestamo.saldoPendiente), bold: true)),
                ],
              ),
            ),
            pw.SizedBox(height: 14),

            // Tabla de amortización
            pw.Table(
              border: pw.TableBorder.all(color: _grisLinea, width: 0.5),
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: _azulOscuro),
                  children: [
                    _buildCeldaHeader('#'),
                    _buildCeldaHeader('FECHA'),
                    _buildCeldaHeader('CUOTA'),
                    _buildCeldaHeader('CAPITAL'),
                    _buildCeldaHeader('INTERÉS'),
                    _buildCeldaHeader('SALDO'),
                    _buildCeldaHeader('ESTADO'),
                  ],
                ),
                ...cuotas.asMap().entries.map((entry) {
                  final i = entry.key;
                  final c = entry.value;
                  final estadoStr = c.estado.toString().split('.').last.toUpperCase();
                  final isPaid = estadoStr == 'PAGADO';
                  return pw.TableRow(
                    decoration: pw.BoxDecoration(
                      color: i.isEven ? _blanco : _grisFila,
                    ),
                    children: [
                      _buildCelda(c.numeroCuota.toString()),
                      _buildCelda(_dateFormat.format(c.fechaVencimiento)),
                      _buildCelda(_currencyFormat.format(c.montoCuota), bold: true),
                      _buildCelda(_currencyFormat.format(c.capital)),
                      _buildCelda(_currencyFormat.format(c.interes)),
                      _buildCelda(_currencyFormat.format(c.saldoPendiente)),
                      _buildCeldaBadge(estadoStr, isPaid ? _verdeOscuro : _azulMedio, isPaid ? _verdeClaro : _azulClaro),
                    ],
                  );
                }),
              ],
            ),

            pw.SizedBox(height: 14),
            _buildFooterPremium(),
          ];
        },
      ),
    );

    return await _guardarPdf(pdf, 'Amortizacion_${prestamo.codigo}');
  }

  /// Genera reporte de estado de cuenta de cliente
  Future<String> generarReporteEstadoCuentaCliente({
    required String nombreCliente,
    required String documentoCliente,
    required List<PagoResumen> pagos,
    required List<PrestamoResumen> prestamos,
    required DateTime fechaInicio,
    required DateTime fechaFin,
  }) async {
    final pdf = pw.Document();
    final reportId = 'RPT-CLI-${DateFormat('yyyyMMdd').format(DateTime.now())}';

    final totalPrestado = prestamos.fold<double>(0, (sum, p) => sum + p.montoOriginal);
    final totalPagado = pagos.fold<double>(0, (sum, p) => sum + p.monto);
    final saldoActual = prestamos.fold<double>(0, (sum, p) => sum + p.saldoPendiente);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.letter,
        margin: const pw.EdgeInsets.symmetric(horizontal: 32, vertical: 28),
        build: (context) {
          return [
            _buildHeaderPremium(
              categoria: 'ESTADO DE CUENTA',
              titulo: 'Historial del Cliente',
              subtitulo: 'Registro completo de préstamos y pagos del cliente',
              reportId: reportId,
              fechaInicio: fechaInicio,
              fechaFin: fechaFin,
            ),
            pw.SizedBox(height: 14),

            // Info del cliente
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: pw.BoxDecoration(
                gradient: const pw.LinearGradient(colors: [_azulOscuro, _azulMedio]),
                borderRadius: pw.BorderRadius.circular(6),
              ),
              child: pw.Row(
                children: [
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('CLIENTE', style: const pw.TextStyle(fontSize: 8, color: _blanco)),
                        pw.SizedBox(height: 2),
                        pw.Text(nombreCliente, style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: _blanco)),
                        pw.Text('CI: $documentoCliente', style: const pw.TextStyle(fontSize: 9, color: _blanco)),
                      ],
                    ),
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      _buildInlineKpi('Total Préstamos', '${prestamos.length}', light: true),
                      pw.SizedBox(height: 4),
                      _buildInlineKpi('Total Pagos', '${pagos.length}', light: true),
                    ],
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 12),

            // KPIs
            pw.Row(
              children: [
                pw.Expanded(child: _buildKpiCard(label: 'MONTO PRESTADO', value: _currencyFormat.format(totalPrestado), subValue: '${prestamos.length} préstamo(s)', accentColor: _azulMedio)),
                pw.SizedBox(width: 10),
                pw.Expanded(child: _buildKpiCard(label: 'TOTAL PAGADO', value: _currencyFormat.format(totalPagado), subValue: '${pagos.length} pago(s)', accentColor: _verdeOscuro)),
                pw.SizedBox(width: 10),
                pw.Expanded(child: _buildKpiCard(label: 'SALDO ACTUAL', value: _currencyFormat.format(saldoActual), subValue: saldoActual > 0 ? 'Deuda pendiente' : 'Saldado', accentColor: saldoActual > 0 ? _naranjaOscuro : _verdeOscuro)),
              ],
            ),
            pw.SizedBox(height: 16),

            // Tabla de pagos
            if (pagos.isNotEmpty) ...[
              _buildSectionTitle('HISTORIAL DE PAGOS'),
              pw.SizedBox(height: 6),
              pw.Table(
                border: pw.TableBorder.all(color: _grisLinea, width: 0.5),
                columnWidths: const {
                  0: pw.FixedColumnWidth(70),
                  1: pw.FlexColumnWidth(2),
                  2: pw.FlexColumnWidth(2),
                  3: pw.FlexColumnWidth(2),
                  4: pw.FlexColumnWidth(1.5),
                },
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: _azulOscuro),
                    children: [
                      _buildCeldaHeader('FECHA'),
                      _buildCeldaHeader('PRÉSTAMO'),
                      _buildCeldaHeader('MONTO TOTAL'),
                      _buildCeldaHeader('CAPITAL'),
                      _buildCeldaHeader('MÉTODO'),
                    ],
                  ),
                  ...pagos.asMap().entries.map((entry) {
                    final i = entry.key;
                    final p = entry.value;
                    return pw.TableRow(
                      decoration: pw.BoxDecoration(color: i.isEven ? _blanco : _grisFila),
                      children: [
                        _buildCelda(_dateFormat.format(p.fecha)),
                        _buildCelda(p.codigoPrestamo),
                        _buildCelda(_currencyFormat.format(p.monto), bold: true, color: _verdeOscuro),
                        _buildCelda(_currencyFormat.format(p.montoCapital)),
                        _buildCelda(p.metodoPago),
                      ],
                    );
                  }),
                ],
              ),
            ],

            pw.SizedBox(height: 16),
            _buildFooterPremium(),
          ];
        },
      ),
    );

    return await _guardarPdf(pdf, 'EstadoCuenta_${nombreCliente.replaceAll(' ', '_')}');
  }

  /// Genera reporte de proyección de cobros
  Future<String> generarReporteProyeccionCobros({
    required List<ProyeccionItem> items,
    required double totalProyectado,
    required int totalCuotas,
    required DateTime fechaInicio,
    required DateTime fechaFin,
  }) async {
    final pdf = pw.Document();
    final reportId = 'RPT-PRY-${DateFormat('yyyyMMdd').format(DateTime.now())}';

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.letter,
        margin: const pw.EdgeInsets.symmetric(horizontal: 32, vertical: 28),
        build: (context) {
          return [
            _buildHeaderPremium(
              categoria: 'PROYECCIÓN FINANCIERA',
              titulo: 'Proyección de Cobros',
              subtitulo: 'Cuotas próximas a vencer y flujo esperado de caja',
              reportId: reportId,
              fechaInicio: fechaInicio,
              fechaFin: fechaFin,
            ),
            pw.SizedBox(height: 14),

            pw.Row(
              children: [
                pw.Expanded(child: _buildKpiCard(
                  label: 'TOTAL PROYECTADO',
                  value: _currencyFormat.format(totalProyectado),
                  subValue: 'Flujo esperado en el período',
                  accentColor: _azulMedio,
                )),
                pw.SizedBox(width: 12),
                pw.Expanded(child: _buildKpiCard(
                  label: 'CUOTAS A VENCER',
                  value: totalCuotas.toString(),
                  subValue: 'Cuotas pendientes de cobro',
                  accentColor: _naranjaOscuro,
                )),
              ],
            ),
            pw.SizedBox(height: 16),

            if (items.isNotEmpty) ...[
              _buildSectionTitle('DETALLE DE CUOTAS PROYECTADAS'),
              pw.SizedBox(height: 6),
              pw.Table(
                border: pw.TableBorder.all(color: _grisLinea, width: 0.5),
                columnWidths: const {
                  0: pw.FixedColumnWidth(70),
                  1: pw.FlexColumnWidth(2.5),
                  2: pw.FlexColumnWidth(2),
                  3: pw.FixedColumnWidth(45),
                  4: pw.FlexColumnWidth(2),
                  5: pw.FlexColumnWidth(2),
                },
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: _azulOscuro),
                    children: [
                      _buildCeldaHeader('VENCIMIENTO'),
                      _buildCeldaHeader('CLIENTE'),
                      _buildCeldaHeader('PRÉSTAMO'),
                      _buildCeldaHeader('CUOTA #'),
                      _buildCeldaHeader('MONTO CUOTA'),
                      _buildCeldaHeader('MORA EST.'),
                    ],
                  ),
                  ...items.asMap().entries.map((entry) {
                    final i = entry.key;
                    final c = entry.value;
                    final vencio = c.fechaVencimiento.isBefore(DateTime.now());
                    return pw.TableRow(
                      decoration: pw.BoxDecoration(color: i.isEven ? _blanco : _grisFila),
                      children: [
                        _buildCelda(_dateFormat.format(c.fechaVencimiento), color: vencio ? _rojoOscuro : null),
                        _buildCelda(c.nombreCliente),
                        _buildCelda(c.codigoPrestamo),
                        _buildCelda(c.numeroCuota.toString()),
                        _buildCelda(_currencyFormat.format(c.montoCuota), bold: true),
                        _buildCelda(c.moraEstimada > 0 ? _currencyFormat.format(c.moraEstimada) : '-',
                            color: c.moraEstimada > 0 ? _rojoOscuro : null),
                      ],
                    );
                  }),
                ],
              ),
            ],

            pw.SizedBox(height: 16),
            _buildFooterPremium(),
          ];
        },
      ),
    );

    return await _guardarPdf(pdf, 'Proyeccion_Cobros');
  }

  /// Genera un PDF con una tabla genérica (diseño premium)
  Future<String> generarPdfTabla({
    required String titulo,
    String? subtitulo,
    required List<String> headers,
    required List<List<String>> rows,
    required String nombreArchivo,
    String? categoria,
  }) async {
    final pdf = pw.Document();
    final reportId = 'RPT-${DateFormat('yyyyMMddHHmm').format(DateTime.now())}';

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.letter,
        margin: const pw.EdgeInsets.symmetric(horizontal: 32, vertical: 28),
        build: (context) {
          return [
            _buildHeaderPremium(
              categoria: categoria ?? 'REPORTE',
              titulo: titulo,
              subtitulo: subtitulo ?? 'Informe generado automáticamente',
              reportId: reportId,
              fechaInicio: DateTime.now(),
              fechaFin: DateTime.now(),
            ),
            pw.SizedBox(height: 16),

            pw.Table(
              border: pw.TableBorder.all(color: _grisLinea, width: 0.5),
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: _azulOscuro),
                  children: headers.map((h) => _buildCeldaHeader(h)).toList(),
                ),
                ...rows.asMap().entries.map((entry) {
                  final i = entry.key;
                  final row = entry.value;
                  return pw.TableRow(
                    decoration: pw.BoxDecoration(color: i.isEven ? _blanco : _grisFila),
                    children: row.map((cell) => _buildCelda(cell)).toList(),
                  );
                }),
              ],
            ),

            pw.SizedBox(height: 16),
            _buildFooterPremium(),
          ];
        },
      ),
    );

    return await _guardarPdf(pdf, nombreArchivo);
  }

  // =========================================================================
  // COMPONENTES PREMIUM DE CONSTRUCCIÓN
  // =========================================================================

  /// Header premium con dos columnas: info izquierda, metadatos derecha
  pw.Widget _buildHeaderPremium({
    required String categoria,
    required String titulo,
    required String subtitulo,
    required String reportId,
    required DateTime fechaInicio,
    required DateTime fechaFin,
  }) {
    final now = DateTime.now();
    return pw.Container(
      decoration: const pw.BoxDecoration(color: _azulOscuro),
      padding: const pw.EdgeInsets.all(16),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'SISTEMA DE GESTIÓN DE PRÉSTAMOS',
                      style: const pw.TextStyle(fontSize: 8, color: _blanco),
                    ),
                    pw.SizedBox(height: 2),
                    pw.Text(
                      categoria,
                      style: const pw.TextStyle(fontSize: 8, color: PdfColors.blue100),
                    ),
                    pw.SizedBox(height: 6),
                    pw.Text(
                      titulo,
                      style: pw.TextStyle(
                        fontSize: 22,
                        fontWeight: pw.FontWeight.bold,
                        color: _blanco,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      subtitulo,
                      style: const pw.TextStyle(fontSize: 9, color: PdfColors.blueGrey200),
                    ),
                  ],
                ),
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text(
                    'Generado el: ${_dateFormat.format(now)}',
                    style: const pw.TextStyle(fontSize: 8, color: _blanco),
                  ),
                  pw.Text(
                    'Hora: ${DateFormat('HH:mm').format(now)}',
                    style: const pw.TextStyle(fontSize: 8, color: _blanco),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    'Período: ${_dateFormat.format(fechaInicio)} - ${_dateFormat.format(fechaFin)}',
                    style: const pw.TextStyle(fontSize: 8, color: PdfColors.blueGrey200),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: pw.BoxDecoration(
                      color: _azulMedio,
                      borderRadius: pw.BorderRadius.circular(3),
                    ),
                    child: pw.Text(
                      'ID: $reportId',
                      style: const pw.TextStyle(fontSize: 8, color: _blanco),
                    ),
                  ),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 10),
          pw.Divider(thickness: 0.5, color: PdfColors.blueGrey700),
        ],
      ),
    );
  }

  /// Tarjeta KPI con valor grande y etiqueta pequeña
  pw.Widget _buildKpiCard({
    required String label,
    required String value,
    required String subValue,
    required PdfColor accentColor,
    bool highlight = false,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: highlight ? const PdfColor.fromInt(0xFFFFF0F0) : _blanco,
        border: pw.Border(left: pw.BorderSide(color: accentColor, width: 3)),
        boxShadow: [const pw.BoxShadow(color: PdfColors.grey200, blurRadius: 2, offset: PdfPoint(0, 1))],
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(label, style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold, color: _grisTexto)),
          pw.SizedBox(height: 4),
          pw.Container(height: 2, width: 24, color: accentColor),
          pw.SizedBox(height: 6),
          pw.Text(
            value,
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: accentColor),
          ),
          pw.SizedBox(height: 3),
          pw.Text(subValue, style: const pw.TextStyle(fontSize: 7, color: _grisTexto)),
        ],
      ),
    );
  }

  /// Widget de KPI en línea (para paneles horizontales)
  pw.Widget _buildInlineKpi(String label, String value, {bool bold = false, bool light = false}) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(label, style: pw.TextStyle(fontSize: 7, color: light ? PdfColors.blueGrey200 : _grisTexto)),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 10,
            fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
            color: light ? _blanco : null,
          ),
        ),
      ],
    );
  }

  /// Título de sección
  pw.Widget _buildSectionTitle(String title) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(title, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: _azulOscuro)),
        pw.SizedBox(height: 4),
        pw.Container(height: 1.5, color: _azulMedio),
      ],
    );
  }

  /// Fila de stat horizontal
  pw.Widget _buildStatRow(String label, String value, PdfColor color) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 10),
      margin: const pw.EdgeInsets.only(right: 4),
      decoration: pw.BoxDecoration(
        color: _grisFondo,
        border: pw.Border.all(color: _grisLinea),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: const pw.TextStyle(fontSize: 8, color: _grisTexto)),
          pw.Text(value, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  /// Construye tabla de préstamos en mora
  pw.Widget _buildTablaMora(List<PrestamoMora> prestamos) {
    return pw.Table(
      border: pw.TableBorder.all(color: _grisLinea, width: 0.5),
      columnWidths: const {
        0: pw.FixedColumnWidth(75),
        1: pw.FlexColumnWidth(3),
        2: pw.FixedColumnWidth(60),
        3: pw.FlexColumnWidth(2),
      },
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: _azulOscuro),
          children: [
            _buildCeldaHeader('CÓDIGO'),
            _buildCeldaHeader('CLIENTE'),
            _buildCeldaHeader('DÍAS MORA'),
            _buildCeldaHeader('MORA ACUM.'),
          ],
        ),
        ...prestamos.asMap().entries.map((entry) {
          final i = entry.key;
          final p = entry.value;
          final diasColor = p.diasMora > 30 ? _rojoOscuro : p.diasMora > 7 ? _naranjaOscuro : _verdeOscuro;
          return pw.TableRow(
            decoration: pw.BoxDecoration(color: i.isEven ? _blanco : _grisFila),
            children: [
              _buildCelda(p.codigo, bold: true),
              _buildCelda(p.nombreCliente),
              _buildCeldaBadge(
                '${p.diasMora} días',
                diasColor,
                p.diasMora > 30 ? _rojoClaro : p.diasMora > 7 ? _naranjaClaro : _verdeClaro,
              ),
              _buildCelda(_currencyFormat.format(p.moraAcumulada), bold: true, color: _rojoOscuro),
            ],
          );
        }),
      ],
    );
  }

  /// Construye tabla de movimientos agrupados por categoría
  pw.Widget _buildTablaMovimientos(List<MovimientoResumen> movimientos) {
    final agrupados = <String, List<MovimientoResumen>>{};
    for (final m in movimientos) {
      agrupados.putIfAbsent(m.categoria, () => []).add(m);
    }

    final rows = <pw.TableRow>[];
    rows.add(pw.TableRow(
      decoration: const pw.BoxDecoration(color: _azulOscuro),
      children: [
        _buildCeldaHeader('FECHA'),
        _buildCeldaHeader('DESCRIPCIÓN'),
        _buildCeldaHeader('TIPO'),
        _buildCeldaHeader('MONTO'),
      ],
    ));

    int rowIndex = 0;
    for (final entry in agrupados.entries) {
      // Sub-encabezado de categoría
      rows.add(pw.TableRow(
        decoration: const pw.BoxDecoration(color: _azulClaro),
        children: [
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 6),
            child: pw.Text('CATEGORÍA: ${entry.key}',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8, color: _azulOscuro)),
          ),
          pw.SizedBox(),
          pw.SizedBox(),
          pw.SizedBox(),
        ],
      ));

      for (final m in entry.value) {
        final isIngreso = m.tipo == 'INGRESO';
        rows.add(pw.TableRow(
          decoration: pw.BoxDecoration(color: rowIndex.isEven ? _blanco : _grisFila),
          children: [
            _buildCelda(_dateFormat.format(m.fecha)),
            _buildCelda(m.descripcion, fontSize: 8),
            _buildCeldaBadge(
              m.tipo,
              isIngreso ? _verdeOscuro : _rojoOscuro,
              isIngreso ? _verdeClaro : _rojoClaro,
            ),
            _buildCelda(
              _currencyFormat.format(m.monto),
              bold: true,
              color: isIngreso ? _verdeOscuro : _rojoOscuro,
            ),
          ],
        ));
        rowIndex++;
      }

      // Subtotal de categoría
      final subTotal = entry.value.fold<double>(0, (sum, m) => sum + m.monto);
      rows.add(pw.TableRow(
        decoration: const pw.BoxDecoration(color: _grisFondo),
        children: [
          pw.SizedBox(),
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(vertical: 3, horizontal: 6),
            child: pw.Text('Subtotal ${entry.key}',
                style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: _grisTexto)),
          ),
          pw.SizedBox(),
          _buildCelda(_currencyFormat.format(subTotal), bold: true),
        ],
      ));
    }

    return pw.Table(
      border: pw.TableBorder.all(color: _grisLinea, width: 0.5),
      columnWidths: const {
        0: pw.FixedColumnWidth(70),
        1: pw.FlexColumnWidth(3),
        2: pw.FixedColumnWidth(70),
        3: pw.FlexColumnWidth(2),
      },
      children: rows,
    );
  }

  /// Celda de encabezado (oscura)
  pw.Widget _buildCeldaHeader(String texto) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      child: pw.Text(
        texto,
        style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: _blanco),
      ),
    );
  }

  /// Celda de datos con soporte de color y negrita
  pw.Widget _buildCelda(String texto, {bool bold = false, double fontSize = 8.5, PdfColor? color}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 5),
      child: pw.Text(
        texto,
        style: pw.TextStyle(
          fontSize: fontSize,
          fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: color,
        ),
      ),
    );
  }

  /// Celda con badge de color (para estado, tipo, días)
  pw.Widget _buildCeldaBadge(String texto, PdfColor textColor, PdfColor bgColor) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 3),
      child: pw.Container(
        padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: pw.BoxDecoration(
          color: bgColor,
          borderRadius: pw.BorderRadius.circular(3),
        ),
        child: pw.Text(
          texto,
          style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold, color: textColor),
        ),
      ),
    );
  }

  /// Footer profesional
  pw.Widget _buildFooterPremium() {
    final now = DateTime.now();
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Divider(thickness: 0.5, color: _grisLinea),
        pw.SizedBox(height: 4),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Generado el: ${_dateFormat.format(now)} ${DateFormat('HH:mm').format(now)}',
                  style: const pw.TextStyle(fontSize: 7, color: _grisTexto),
                ),
                pw.Text(
                  'Sistema de Gestión de Préstamos v2.4',
                  style: pw.TextStyle(fontSize: 7, color: _azulMedio),
                ),
              ],
            ),
            pw.Row(
              children: [
                pw.Text(
                  '🔒 Documento Confidencial  |  ',
                  style: const pw.TextStyle(fontSize: 7, color: _grisTexto),
                ),
                pw.Text(
                  'Para uso interno exclusivamente',
                  style: const pw.TextStyle(fontSize: 7, color: _grisTexto),
                ),
              ],
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
  final String categoria;
  final double monto;

  MovimientoResumen({
    required this.fecha,
    required this.tipo,
    required this.descripcion,
    required this.categoria,
    required this.monto,
  });
}

class PagoResumen {
  final DateTime fecha;
  final String codigoPrestamo;
  final double monto;
  final double montoCapital;
  final double montoInteres;
  final String metodoPago;

  PagoResumen({
    required this.fecha,
    required this.codigoPrestamo,
    required this.monto,
    required this.montoCapital,
    required this.montoInteres,
    required this.metodoPago,
  });
}

class PrestamoResumen {
  final String codigo;
  final double montoOriginal;
  final double saldoPendiente;
  final String estado;

  PrestamoResumen({
    required this.codigo,
    required this.montoOriginal,
    required this.saldoPendiente,
    required this.estado,
  });
}

class ProyeccionItem {
  final DateTime fechaVencimiento;
  final String nombreCliente;
  final String codigoPrestamo;
  final int numeroCuota;
  final double montoCuota;
  final double moraEstimada;

  ProyeccionItem({
    required this.fechaVencimiento,
    required this.nombreCliente,
    required this.codigoPrestamo,
    required this.numeroCuota,
    required this.montoCuota,
    required this.moraEstimada,
  });
}