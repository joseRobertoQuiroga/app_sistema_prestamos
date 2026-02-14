import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Pantalla de Informe: Resumen de Ingresos
/// Placeholder por implementar con datos reales
class ResumenIngresosScreen extends ConsumerWidget {
  const ResumenIngresosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.trending_up,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Resumen de Ingresos',
            style: theme.textTheme.titleLarge?.copyWith(
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Esta funcionalidad mostrará un resumen detallado de todos los ingresos:\n\n'
              '• Filtros por fecha y caja\n'
              '• Ingresos por pagos de préstamos\n'
              '• Ingresos manuales\n'
              '• Transferencias entre cajas\n'
              '• Análisis y comparativas\n'
              '• Exportar a Excel',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
