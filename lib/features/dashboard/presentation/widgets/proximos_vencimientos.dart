import 'package:flutter/material.dart';
import '../../domain/entities/dashboard_entities.dart';
import '../../../../core/utils/formatters.dart';

/// Widget para mostrar próximos vencimientos
class ProximosVencimientosWidget extends StatelessWidget {
  final List<ProximoVencimiento> vencimientos;
  final VoidCallback? onVerTodos;

  const ProximosVencimientosWidget({
    super.key,
    required this.vencimientos,
    this.onVerTodos,
  });

  @override
  Widget build(BuildContext context) {
    if (vencimientos.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Column(
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: 48,
                  color: Colors.green,
                ),
                const SizedBox(height: 8),
                Text(
                  'Sin vencimientos próximos',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  Icons.event,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Próximos Vencimientos',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Spacer(),
                if (onVerTodos != null)
                  TextButton(
                    onPressed: onVerTodos,
                    child: const Text('Ver todos'),
                  ),
              ],
            ),
          ),
          const Divider(height: 1),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: vencimientos.length > 5 ? 5 : vencimientos.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              return _VencimientoItem(vencimiento: vencimientos[index]);
            },
          ),
        ],
      ),
    );
  }
}

class _VencimientoItem extends StatelessWidget {
  final ProximoVencimiento vencimiento;

  const _VencimientoItem({required this.vencimiento});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: _getColor().withOpacity(0.1),
        child: Text(
          '${vencimiento.diasParaVencer}d',
          style: TextStyle(
            color: _getColor(),
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
      title: Text(
        vencimiento.nombreCliente,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Préstamo: ${vencimiento.codigoPrestamo}'),
          Text('Cuota #${vencimiento.numeroCuota}'),
          Text(
            'Vence: ${Formatters.formatDate(vencimiento.fechaVencimiento)}',
            style: TextStyle(
              color: _getColor(),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            Formatters.formatCurrency(vencimiento.montoPendiente),
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          if (vencimiento.esUrgente)
            Chip(
              label: const Text('URGENTE'),
              backgroundColor: theme.colorScheme.errorContainer,
              labelStyle: TextStyle(
                color: theme.colorScheme.onErrorContainer,
                fontSize: 10,
              ),
              padding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
            ),
        ],
      ),
      isThreeLine: true,
      onTap: () {
        // TODO: Navegar al detalle del préstamo
      },
    );
  }

  Color _getColor() {
    if (vencimiento.esUrgente) return Colors.red;
    if (vencimiento.esCercano) return Colors.orange;
    return Colors.blue;
  }
}