import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:glass_kit/glass_kit.dart';
import '../../../prestamos/domain/entities/cuota.dart';
import '../../../../core/utils/formatters.dart';

/// Widget para mostrar próximas cuotas a vencer en el dashboard con diseño premium
class ProximosVencimientosWidget extends StatelessWidget {
  final List<Cuota> vencimientos;
  final VoidCallback? onVerTodos;

  const ProximosVencimientosWidget({
    super.key,
    required this.vencimientos,
    this.onVerTodos,
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
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.event_note_rounded,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Próximos Vencimientos',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.2,
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
        if (vencimientos.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    size: 48,
                    color: theme.colorScheme.primary.withOpacity(0.3),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No hay vencimientos próximos',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
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
            itemCount: vencimientos.length > 5 ? 5 : vencimientos.length,
            separatorBuilder: (_, __) => Divider(
              height: 1, 
              color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade100,
              indent: 72,
            ),
            itemBuilder: (context, index) {
              return _VencimientoItem(cuota: vencimientos[index]);
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

class _VencimientoItem extends StatelessWidget {
  final Cuota cuota;

  const _VencimientoItem({required this.cuota});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final diasParaVencer = cuota.fechaVencimiento.difference(DateTime.now()).inDays;
    final esUrgente = diasParaVencer <= 3;
    final color = _getColor(diasParaVencer);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${diasParaVencer}',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ),
              Text(
                'días',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 8,
                ),
              ),
            ],
          ),
        ),
      ),
      title: Text(
        'Cuota #${cuota.numeroCuota}',
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white : Colors.black87,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text(
            'Prestamo ID: ${cuota.prestamoId}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: isDark ? Colors.white38 : Colors.black38,
            ),
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              Icon(Icons.access_time_rounded, size: 12, color: color),
              const SizedBox(width: 4),
              Text(
                Formatters.formatDate(cuota.fechaVencimiento),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            Formatters.formatCurrency(cuota.saldoCuota),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
              color: theme.colorScheme.primary,
            ),
          ),
          if (esUrgente) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: theme.colorScheme.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'URGENTE',
                style: TextStyle(
                  color: theme.colorScheme.error,
                  fontSize: 8,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ],
      ),
      onTap: () {
        // Navegar al detalle del préstamo
      },
    );
  }

  Color _getColor(int dias) {
    if (dias < 0) return const Color(0xFFFF1744); // Vencida
    if (dias <= 3) return const Color(0xFFFF5252);
    if (dias <= 7) return const Color(0xFFFFAB00);
    return const Color(0xFF2979FF);
  }
}
