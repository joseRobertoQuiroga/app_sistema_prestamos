import 'package:flutter/material.dart';
import '../../../../core/utils/formatters.dart';
import '../../../pagos/domain/entities/pago.dart';
import '../../../reportes/data/services/pdf_service.dart';

/// Historial de Pagos Wilson — Tabla de pagos reales con variación de capital
/// 
/// Muestra el historial real de pagos realizados para un préstamo Wilson:
/// #, Fecha, Pago Total, Mora, Interés, Capital, Saldo Restante
/// Incluye totales y exportación a PDF.
class HistorialPagosWilsonWidget extends StatelessWidget {
  final List<Pago> pagos;
  final double montoOriginal;
  final double saldoActual;
  final double tasaInteres;
  final String codigoPrestamo;
  final String? nombreCliente;
  final bool mostrarExportar;

  const HistorialPagosWilsonWidget({
    super.key,
    required this.pagos,
    required this.montoOriginal,
    required this.saldoActual,
    required this.tasaInteres,
    required this.codigoPrestamo,
    this.nombreCliente,
    this.mostrarExportar = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Ordenar pagos por fecha ascendente
    final pagosOrdenados = List<Pago>.from(pagos)
      ..sort((a, b) => a.fechaPago.compareTo(b.fechaPago));

    // Calcular saldo progresivo
    final filasConSaldo = _calcularSaldoProgresivo(pagosOrdenados);

    // Calcular totales
    double totalPago = 0;
    double totalMora = 0;
    double totalInteres = 0;
    double totalCapital = 0;
    for (final pago in pagosOrdenados) {
      totalPago += pago.montoTotal;
      totalMora += pago.montoMora;
      totalInteres += pago.montoInteres;
      totalCapital += pago.montoCapital;
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.tertiaryContainer.withOpacity(0.3),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.history,
                  color: theme.colorScheme.tertiary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'HISTORIAL DE PAGOS',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.tertiary,
                  ),
                ),
                const Spacer(),
                if (mostrarExportar && pagosOrdenados.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.picture_as_pdf, size: 20),
                    tooltip: 'Exportar PDF',
                    onPressed: () => _exportarPdf(context),
                    color: theme.colorScheme.tertiary,
                  ),
              ],
            ),
          ),

          if (pagosOrdenados.isEmpty)
            Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.receipt_long_outlined,
                      size: 48,
                      color: theme.colorScheme.outline.withOpacity(0.5),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'No se han registrado pagos aún',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else ...[
            // Tabla
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 14,
                headingRowHeight: 36,
                dataRowMinHeight: 32,
                dataRowMaxHeight: 40,
                headingTextStyle: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                columns: const [
                  DataColumn(label: Text('#')),
                  DataColumn(label: Text('Fecha')),
                  DataColumn(label: Text('Pago'), numeric: true),
                  DataColumn(label: Text('Mora'), numeric: true),
                  DataColumn(label: Text('Interés'), numeric: true),
                  DataColumn(label: Text('Capital'), numeric: true),
                  DataColumn(label: Text('Saldo'), numeric: true),
                ],
                rows: [
                  // Fila inicial (saldo original)
                  DataRow(
                    color: WidgetStateProperty.all(
                      theme.colorScheme.primaryContainer.withOpacity(0.2),
                    ),
                    cells: [
                      const DataCell(Text('-')),
                      DataCell(Text(Formatters.formatDate(DateTime.now()))),
                      const DataCell(Text('-')),
                      const DataCell(Text('-')),
                      const DataCell(Text('-')),
                      const DataCell(Text('-')),
                      DataCell(Text(
                        Formatters.formatCurrency(montoOriginal),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      )),
                    ],
                  ),
                  // Filas de pagos
                  ...filasConSaldo.asMap().entries.map((entry) {
                    final i = entry.key;
                    final fila = entry.value;
                    final pago = fila['pago'] as Pago;
                    return DataRow(
                      color: WidgetStateProperty.resolveWith<Color?>(
                        (states) => i.isOdd
                            ? theme.colorScheme.surfaceContainerHighest
                                .withOpacity(0.3)
                            : null,
                      ),
                      cells: [
                        DataCell(Text('${i + 1}')),
                        DataCell(Text(Formatters.formatDate(pago.fechaPago))),
                        DataCell(Text(
                          Formatters.formatCurrency(pago.montoTotal),
                          style: TextStyle(
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        )),
                        DataCell(Text(
                          pago.montoMora > 0
                              ? Formatters.formatCurrency(pago.montoMora)
                              : '-',
                          style: TextStyle(
                            color: pago.montoMora > 0 ? Colors.red.shade700 : null,
                          ),
                        )),
                        DataCell(Text(Formatters.formatCurrency(pago.montoInteres))),
                        DataCell(Text(Formatters.formatCurrency(pago.montoCapital))),
                        DataCell(Text(
                          Formatters.formatCurrency(fila['saldoRestante'] as double),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: (fila['saldoRestante'] as double) <= 0
                                ? Colors.green.shade700
                                : null,
                          ),
                        )),
                      ],
                    );
                  }),
                  // Fila de totales
                  DataRow(
                    color: WidgetStateProperty.all(
                      theme.colorScheme.primaryContainer.withOpacity(0.3),
                    ),
                    cells: [
                      const DataCell(Text('')),
                      DataCell(Text(
                        'TOTALES',
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      )),
                      DataCell(Text(
                        Formatters.formatCurrency(totalPago),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      )),
                      DataCell(Text(
                        Formatters.formatCurrency(totalMora),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: totalMora > 0 ? Colors.red.shade700 : null,
                        ),
                      )),
                      DataCell(Text(
                        Formatters.formatCurrency(totalInteres),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      )),
                      DataCell(Text(
                        Formatters.formatCurrency(totalCapital),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      )),
                      DataCell(Text(
                        Formatters.formatCurrency(saldoActual),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: saldoActual <= 0 ? Colors.green.shade700 : null,
                        ),
                      )),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Calcula el saldo restante progresivo después de cada pago
  List<Map<String, dynamic>> _calcularSaldoProgresivo(List<Pago> pagosOrdenados) {
    double saldo = montoOriginal;
    final filas = <Map<String, dynamic>>[];

    for (final pago in pagosOrdenados) {
      saldo -= pago.montoCapital;
      if (saldo < 0.01) saldo = 0;
      filas.add({
        'pago': pago,
        'saldoRestante': saldo,
      });
    }

    return filas;
  }

  /// Exporta el historial de pagos a PDF
  Future<void> _exportarPdf(BuildContext context) async {
    try {
      final pdfService = PdfService();
      
      // Construir datos para el PDF
      final headers = ['#', 'Fecha', 'Pago', 'Mora', 'Interés', 'Capital', 'Saldo'];
      final rows = <List<String>>[];
      
      double saldo = montoOriginal;
      for (int i = 0; i < pagos.length; i++) {
        final pago = pagos[i];
        saldo -= pago.montoCapital;
        if (saldo < 0.01) saldo = 0;
        
        rows.add([
          '${i + 1}',
          Formatters.formatDate(pago.fechaPago),
          Formatters.formatCurrency(pago.montoTotal),
          Formatters.formatCurrency(pago.montoMora),
          Formatters.formatCurrency(pago.montoInteres),
          Formatters.formatCurrency(pago.montoCapital),
          Formatters.formatCurrency(saldo),
        ]);
      }

      final ruta = await pdfService.generarPdfTabla(
        titulo: 'Historial de Pagos Wilson — $codigoPrestamo',
        subtitulo: nombreCliente != null 
            ? 'Cliente: $nombreCliente | Tasa: ${tasaInteres.toStringAsFixed(1)}% mensual'
            : 'Tasa: ${tasaInteres.toStringAsFixed(1)}% mensual',
        headers: headers,
        rows: rows,
        nombreArchivo: 'historial_wilson_$codigoPrestamo',
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PDF exportado: $ruta'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al exportar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
