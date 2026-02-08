import 'package:flutter/material.dart';
import '../../../../core/utils/formatters.dart';

/// Widget para mostrar un KPI en tarjeta
class KPICard extends StatelessWidget {
  final String titulo;
  final String valor;
  final IconData icono;
  final Color? color;
  final String? subtitulo;
  final VoidCallback? onTap;
  final Widget? trailing;

  const KPICard({
    super.key,
    required this.titulo,
    required this.valor,
    required this.icono,
    this.color,
    this.subtitulo,
    this.onTap,
    this.trailing,
  });

  factory KPICard.moneda({
    required String titulo,
    required double valor,
    required IconData icono,
    Color? color,
    String? subtitulo,
    VoidCallback? onTap,
  }) {
    return KPICard(
      titulo: titulo,
      valor: Formatters.formatCurrency(valor),
      icono: icono,
      color: color,
      subtitulo: subtitulo,
      onTap: onTap,
    );
  }

  factory KPICard.numero({
    required String titulo,
    required int valor,
    required IconData icono,
    Color? color,
    String? subtitulo,
    VoidCallback? onTap,
  }) {
    return KPICard(
      titulo: titulo,
      valor: valor.toString(),
      icono: icono,
      color: color,
      subtitulo: subtitulo,
      onTap: onTap,
    );
  }

  factory KPICard.porcentaje({
    required String titulo,
    required double valor,
    required IconData icono,
    Color? color,
    String? subtitulo,
    VoidCallback? onTap,
  }) {
    return KPICard(
      titulo: titulo,
      valor: '${valor.toStringAsFixed(1)}%',
      icono: icono,
      color: color,
      subtitulo: subtitulo,
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveColor = color ?? theme.colorScheme.primary;

    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: effectiveColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      icono,
                      color: effectiveColor,
                      size: 24,
                    ),
                  ),
                  const Spacer(),
                  if (trailing != null) trailing!,
                ],
              ),
              const SizedBox(height: 12),
              Text(
                titulo,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                valor,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: effectiveColor,
                ),
              ),
              if (subtitulo != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitulo!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Widget para mostrar un indicador de salud
class SaludIndicator extends StatelessWidget {
  final String titulo;
  final double porcentaje; // 0-100
  final String? descripcion;

  const SaludIndicator({
    super.key,
    required this.titulo,
    required this.porcentaje,
    this.descripcion,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _getColor(porcentaje);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  titulo,
                  style: theme.textTheme.titleMedium,
                ),
                const Spacer(),
                Text(
                  '${porcentaje.toStringAsFixed(0)}%',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: porcentaje / 100,
                minHeight: 8,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
            if (descripcion != null) ...[
              const SizedBox(height: 8),
              Text(
                descripcion!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getColor(double value) {
    if (value >= 80) return Colors.green;
    if (value >= 60) return Colors.orange;
    return Colors.red;
  }
}