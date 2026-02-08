import 'package:flutter/material.dart';
import '../../domain/entities/dashboard_entities.dart';
import '../../../../core/utils/formatters.dart';

/// Widget para mostrar alertas del dashboard
class AlertasWidget extends StatelessWidget {
  final List<DashboardAlerta> alertas;
  final VoidCallback? onVerTodas;

  const AlertasWidget({
    super.key,
    required this.alertas,
    this.onVerTodas,
  });

  @override
  Widget build(BuildContext context) {
    if (alertas.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Icon(
                Icons.check_circle_outline,
                size: 48,
                color: Colors.green,
              ),
              const SizedBox(height: 8),
              Text(
                'Sin alertas',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                'Todo está en orden',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
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
                  Icons.warning_amber_rounded,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(width: 8),
                Text(
                  'Alertas (${alertas.length})',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Spacer(),
                if (onVerTodas != null)
                  TextButton(
                    onPressed: onVerTodas,
                    child: const Text('Ver todas'),
                  ),
              ],
            ),
          ),
          const Divider(height: 1),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: alertas.length > 5 ? 5 : alertas.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              return _AlertaItem(alerta: alertas[index]);
            },
          ),
        ],
      ),
    );
  }
}

class _AlertaItem extends StatelessWidget {
  final DashboardAlerta alerta;

  const _AlertaItem({required this.alerta});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: _getColor().withOpacity(0.1),
        child: Icon(
          _getIcono(),
          color: _getColor(),
          size: 20,
        ),
      ),
      title: Text(
        alerta.titulo,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(alerta.mensaje),
      trailing: alerta.esAlta
          ? Chip(
              label: const Text('Urgente'),
              backgroundColor: theme.colorScheme.errorContainer,
              labelStyle: TextStyle(
                color: theme.colorScheme.onErrorContainer,
                fontSize: 11,
              ),
              padding: EdgeInsets.zero,
            )
          : null,
      onTap: () {
        // TODO: Navegar al detalle según tipo de alerta
      },
    );
  }

  IconData _getIcono() {
    switch (alerta.tipo) {
      case 'VENCIMIENTO':
        return Icons.event_busy;
      case 'MORA':
        return Icons.error_outline;
      case 'BAJO_SALDO':
        return Icons.account_balance_wallet;
      default:
        return Icons.info_outline;
    }
  }

  Color _getColor() {
    switch (alerta.severidad) {
      case 'ALTA':
        return Colors.red;
      case 'MEDIA':
        return Colors.orange;
      case 'BAJA':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}