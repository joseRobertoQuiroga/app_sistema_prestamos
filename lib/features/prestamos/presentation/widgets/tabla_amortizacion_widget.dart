import 'package:flutter/material.dart';
import '../../domain/entities/cuota.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../config/theme/app_theme.dart';
import 'package:open_file/open_file.dart';
import '../../../reportes/data/services/pdf_service.dart';
import '../../domain/entities/prestamo.dart';

class TablaAmortizacionWidget extends StatelessWidget {
  final List<Cuota> cuotas;
  final Prestamo? prestamo;
  final bool showOnlyPending;
  final bool compact;

  const TablaAmortizacionWidget({
    super.key,
    required this.cuotas,
    this.prestamo,
    this.showOnlyPending = false,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final cuotasFiltradas = showOnlyPending
        ? cuotas.where((c) => !c.estaPagada).toList()
        : cuotas;

    if (cuotasFiltradas.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Text('No hay cuotas para mostrar'),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tabla de Amortización',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              if (!compact && prestamo != null)
                TextButton.icon(
                  onPressed: () => _exportarPDF(context),
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text('Exportar PDF'),
                ),
            ],
          ),
        ),

        // Tabla
        if (compact)
          _buildCompactTable(context, cuotasFiltradas)
        else
          _buildFullTable(context, cuotasFiltradas),

        // Totales
        _buildTotales(context, cuotasFiltradas),
      ],
    );
  }

  // ... rest of the code ...

  Future<void> _exportarPDF(BuildContext context) async {
    try {
      if (prestamo == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No hay información del préstamo para generar el PDF')),
        );
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Generando PDF...')),
      );

      final pdfService = PdfService();
      final path = await pdfService.generarTablaAmortizacion(
        cuotas: cuotas,
        prestamo: prestamo,
      );

      await OpenFile.open(path);

    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al generar PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildFullTable(BuildContext context, List<Cuota> cuotas) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: MaterialStateProperty.all(
          Theme.of(context).primaryColor.withOpacity(0.1),
        ),
        columns: const [
          DataColumn(label: Text('#', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Fecha Venc.', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Cuota', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Capital', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Interés', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Saldo', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Pagado', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Mora', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Estado', style: TextStyle(fontWeight: FontWeight.bold))),
        ],
        rows: cuotas.map((cuota) {
          final isVencida = cuota.estaVencida;
          final isPagada = cuota.estaPagada;

          return DataRow(
            color: MaterialStateProperty.all(
              isPagada
                  ? Colors.green.withOpacity(0.05)
                  : isVencida
                      ? Colors.red.withOpacity(0.05)
                      : null,
            ),
            cells: [
              DataCell(Text(cuota.numeroCuota.toString())),
              DataCell(Text(Formatters.formatDate(cuota.fechaVencimiento))),
              DataCell(Text(Formatters.formatCurrency(cuota.montoCuota))),
              DataCell(Text(Formatters.formatCurrency(cuota.capital))),
              DataCell(Text(Formatters.formatCurrency(cuota.interes))),
              DataCell(Text(Formatters.formatCurrency(cuota.saldoPendiente))),
              DataCell(
                Text(
                  Formatters.formatCurrency(cuota.montoPagado),
                  style: TextStyle(
                    color: cuota.montoPagado > 0 ? Colors.green : null,
                  ),
                ),
              ),
              DataCell(
                Text(
                  cuota.montoMora > 0
                      ? Formatters.formatCurrency(cuota.montoMora)
                      : '-',
                  style: TextStyle(
                    color: cuota.montoMora > 0 ? Colors.red : Colors.grey,
                  ),
                ),
              ),
              DataCell(_buildEstadoBadge(cuota.estado)),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCompactTable(BuildContext context, List<Cuota> cuotas) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: cuotas.length,
      itemBuilder: (context, index) {
        final cuota = cuotas[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getEstadoColor(cuota.estado),
              child: Text(
                cuota.numeroCuota.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              Formatters.formatCurrency(cuota.montoCuota),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              Formatters.formatDate(cuota.fechaVencimiento),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildEstadoBadge(cuota.estado),
                if (cuota.montoMora > 0)
                  Text(
                    'Mora: ${Formatters.formatCurrency(cuota.montoMora)}',
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.red,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTotales(BuildContext context, List<Cuota> cuotas) {
    final totalCuotas = cuotas.fold<double>(0, (sum, c) => sum + c.montoCuota);
    final totalCapital = cuotas.fold<double>(0, (sum, c) => sum + c.capital);
    final totalInteres = cuotas.fold<double>(0, (sum, c) => sum + c.interes);
    final totalPagado = cuotas.fold<double>(0, (sum, c) => sum + c.montoPagado);
    final totalMora = cuotas.fold<double>(0, (sum, c) => sum + c.montoMora);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).primaryColor.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Totales',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          _buildTotalRow(context, 'Total Cuotas:', totalCuotas),
          _buildTotalRow(context, 'Capital:', totalCapital),
          _buildTotalRow(context, 'Interés:', totalInteres),
          const Divider(),
          _buildTotalRow(
            context,
            'Pagado:',
            totalPagado,
            color: Colors.green,
            bold: true,
          ),
          if (totalMora > 0)
            _buildTotalRow(
              context,
              'Mora:',
              totalMora,
              color: Colors.red,
            ),
          _buildTotalRow(
            context,
            'Pendiente:',
            totalCuotas - totalPagado,
            color: Colors.orange,
            bold: true,
          ),
        ],
      ),
    );
  }

  Widget _buildTotalRow(
    BuildContext context,
    String label,
    double value, {
    Color? color,
    bool bold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            Formatters.formatCurrency(value),
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEstadoBadge(EstadoCuota estado) {
    final color = AppTheme.getEstadoCuotaColor(estado.toStorageString());

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        estado.displayName,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getEstadoColor(EstadoCuota estado) {
    return AppTheme.getEstadoCuotaColor(estado.toStorageString());
  }


}