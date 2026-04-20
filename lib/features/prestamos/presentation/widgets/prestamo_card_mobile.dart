import 'package:flutter/material.dart';
import '../../domain/entities/prestamo.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/theme/app_theme.dart';

class PrestamoCardMobile extends StatelessWidget {
  final Prestamo prestamo;
  final VoidCallback onTap;
  final VoidCallback onDetail;

  const PrestamoCardMobile({
    super.key,
    required this.prestamo,
    required this.onTap,
    required this.onDetail,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 0,
      color: isDark ? const Color(0xFF1E2130) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: onDetail,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    prestamo.codigo,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryBrand,
                      fontSize: 12,
                    ),
                  ),
                  _StatusBadge(estado: prestamo.estado),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Cliente ID: ${prestamo.clienteId}', // En un mundo ideal tendríamos el nombre del cliente aquí
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _InfoItem(
                    label: 'Monto',
                    value: Formatters.formatCurrency(prestamo.montoOriginal),
                    isDark: isDark,
                  ),
                  const Spacer(),
                  _InfoItem(
                    label: 'Pendiente',
                    value: Formatters.formatCurrency(prestamo.saldoPendiente),
                    valueColor: prestamo.estado == EstadoPrestamo.mora ? Colors.red : null,
                    isDark: isDark,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _ProgressSection(
                montoOriginal: prestamo.montoOriginal,
                saldoPendiente: prestamo.saldoPendiente,
                isDark: isDark,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final EstadoPrestamo estado;
  const _StatusBadge({required this.estado});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;
    switch (estado) {
      case EstadoPrestamo.activo: color = Colors.green; label = 'ACTIVO'; break;
      case EstadoPrestamo.pagado: color = Colors.blue; label = 'PAGADO'; break;
      case EstadoPrestamo.mora: color = Colors.red; label = 'EN MORA'; break;
      case EstadoPrestamo.cancelado: color = Colors.grey; label = 'CANCELADO'; break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool isDark;

  const _InfoItem({
    required this.label,
    required this.value,
    this.valueColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? (isDark ? Colors.white : Colors.black87),
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

class _ProgressSection extends StatelessWidget {
  final double montoOriginal;
  final double saldoPendiente;
  final bool isDark;

  const _ProgressSection({
    required this.montoOriginal,
    required this.saldoPendiente,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final pagado = montoOriginal - saldoPendiente;
    final progreso = (pagado / montoOriginal).clamp(0.0, 1.0);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Progreso de Pago', style: TextStyle(color: isDark ? Colors.white38 : Colors.grey, fontSize: 10)),
            Text('${(progreso * 100).toStringAsFixed(0)}%', style: TextStyle(color: AppTheme.primaryBrand, fontSize: 10, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progreso,
            backgroundColor: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade100,
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryBrand),
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}
