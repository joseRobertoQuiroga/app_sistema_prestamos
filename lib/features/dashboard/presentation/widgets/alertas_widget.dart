import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:glass_kit/glass_kit.dart';
import '../../domain/entities/dashboard_entities.dart';

/// Widget para mostrar alertas del dashboard con diseño modernizado
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Widget content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.warning_amber_rounded,
                  color: theme.colorScheme.error,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Alertas (${alertas.length})',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.2,
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
        if (alertas.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                children: [
                  Icon(
                    Icons.check_circle_outline_rounded,
                    size: 48,
                    color: Colors.green.withOpacity(0.6),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Sin alertas pendientes',
                    style: theme.textTheme.bodyMedium?.copyWith(color: isDark ? Colors.white70 : Colors.black54),
                  ),
                ],
              ),
            ),
          )
        else ...[
          const Divider(height: 1),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: alertas.length > 5 ? 5 : alertas.length,
            separatorBuilder: (_, __) => Divider(
              height: 1, 
              color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade100,
              indent: 72,
            ),
            itemBuilder: (context, index) {
              return _AlertaItem(alerta: alertas[index]);
            },
          ),
        ],
      ],
    );

    if (isDark) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.03),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: content,
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: content,
    );
  }
}

class _AlertaItem extends StatelessWidget {
  final DashboardAlerta alerta;

  const _AlertaItem({required this.alerta});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: _getColor().withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          _getIcono(),
          color: _getColor(),
          size: 18,
        ),
      ),
      title: Text(
        alerta.titulo,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white : Colors.black87,
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          alerta.mensaje,
          style: theme.textTheme.bodySmall?.copyWith(
            color: isDark ? Colors.white54 : Colors.black45,
          ),
        ),
      ),
      trailing: alerta.esAlta
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.colorScheme.error.withOpacity(0.2)),
              ),
              child: Text(
                'URGENTE',
                style: TextStyle(
                  color: theme.colorScheme.error,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                ),
              ),
            )
          : null,
      onTap: () {
        // Navegar al detalle
      },
    );
  }

  IconData _getIcono() {
    switch (alerta.tipo) {
      case 'VENCIMIENTO':
        return Icons.event_busy_rounded;
      case 'MORA':
        return Icons.error_outline_rounded;
      case 'BAJO_SALDO':
        return Icons.account_balance_wallet_rounded;
      default:
        return Icons.info_outline_rounded;
    }
  }

  Color _getColor() {
    switch (alerta.severidad) {
      case 'ALTA':
        return const Color(0xFFFF1744);
      case 'MEDIA':
        return const Color(0xFFFFAB00);
      case 'BAJA':
        return const Color(0xFF2979FF);
      default:
        return Colors.grey;
    }
  }
}
