import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/pago.dart';
import '../providers/pago_provider.dart';
import '../../../../core/utils/formatters.dart';

/// Widget para mostrar el historial de pagos de un préstamo
class HistorialPagosWidget extends ConsumerWidget {
  final int prestamoId;

  const HistorialPagosWidget({super.key, required this.prestamoId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pagosAsync = ref.watch(pagosListProvider(prestamoId));
    final resumenAsync = ref.watch(resumenPagosProvider(prestamoId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Resumen
        resumenAsync.when(
          data: (resumen) => _buildResumen(context, resumen),
          loading: () => const LinearProgressIndicator(),
          error: (_, __) => const SizedBox.shrink(),
        ),
        
        const SizedBox(height: 16),
        
        // Lista de pagos
        pagosAsync.when(
          data: (pagos) => pagos.isEmpty
              ? _buildEmpty(context)
              : Column(
                  children: pagos.map((pago) => _buildPagoCard(context, pago)).toList(),
                ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(child: Text('Error: $error')),
        ),
      ],
    );
  }

  Widget _buildResumen(BuildContext context, Map<String, double> resumen) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Resumen de Pagos',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const Divider(),
            _buildResumenRow(context, 'Total pagado', resumen['totalPagado'] ?? 0),
            _buildResumenRow(context, 'Mora', resumen['totalMora'] ?? 0),
            _buildResumenRow(context, 'Interés', resumen['totalInteres'] ?? 0),
            _buildResumenRow(context, 'Capital', resumen['totalCapital'] ?? 0),
          ],
        ),
      ),
    );
  }

  Widget _buildResumenRow(BuildContext context, String label, double monto) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            Formatters.formatCurrency(monto),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPagoCard(BuildContext context, Pago pago) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Icon(
            Icons.payments,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
        title: Text(
          Formatters.formatCurrency(pago.montoTotal),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Código: ${pago.codigo}'),
            Text('Fecha: ${Formatters.formatDate(pago.fechaPago)}'),
            Text(pago.resumen),
            if (pago.metodoPago != null)
              Text('Método: ${pago.metodoPago}'),
          ],
        ),
        isThreeLine: true,
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          _mostrarDetalle(context, pago);
        },
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No hay pagos registrados',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarDetalle(BuildContext context, Pago pago) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Pago ${pago.codigo}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetalleRow('Monto total', Formatters.formatCurrency(pago.montoTotal)),
              _buildDetalleRow('Mora', Formatters.formatCurrency(pago.montoMora)),
              _buildDetalleRow('Interés', Formatters.formatCurrency(pago.montoInteres)),
              _buildDetalleRow('Capital', Formatters.formatCurrency(pago.montoCapital)),
              const Divider(),
              _buildDetalleRow('Fecha', Formatters.formatDate(pago.fechaPago)),
              if (pago.metodoPago != null)
                _buildDetalleRow('Método', pago.metodoPago!),
              if (pago.referencia != null)
                _buildDetalleRow('Referencia', pago.referencia!),
              if (pago.observaciones != null) ...[
                const SizedBox(height: 8),
                Text('Observaciones:', style: Theme.of(context).textTheme.labelSmall),
                Text(pago.observaciones!),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetalleRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value),
        ],
      ),
    );
  }
}