import 'package:flutter/material.dart';

/// Widget para mostrar detalles de un crédito (activo o pagado)
class DetalleCreditoWidget extends StatelessWidget {
  final dynamic prestamo;
  final bool esActivo;

  const DetalleCreditoWidget({
    super.key,
    required this.prestamo,
    required this.esActivo,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final saldoPendiente = prestamo.saldoPendiente ?? 0.0;
    final porcentajePagado = prestamo.porcentajePagado ?? 0.0;

    Color estadoColor;
    String estadoTexto;
    IconData estadoIcono;

    if (esActivo) {
      if (prestamo.enMora) {
        estadoColor = Colors.red;
        estadoTexto = 'EN MORA';
        estadoIcono = Icons.warning_amber;
      } else if (porcentajePagado > 0) {
        estadoColor = Colors.blue;
        estadoTexto = 'AL DÍA';
        estadoIcono = Icons.check_circle_outline;
      } else {
        estadoColor = Colors.orange;
        estadoTexto = 'PENDIENTE';
        estadoIcono = Icons.schedule;
      }
    } else {
      estadoColor = Colors.green;
      estadoTexto = 'PAGADO';
      estadoIcono = Icons.check_circle;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: estadoColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(estadoIcono, color: estadoColor),
        ),
        title: Text(
          prestamo.codigo ?? 'Sin código',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Row(
          children: [
            Chip(
              label: Text(
                estadoTexto,
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
              ),
              backgroundColor: estadoColor.withOpacity(0.2),
              labelPadding: const EdgeInsets.symmetric(horizontal: 4),
              visualDensity: VisualDensity.compact,
            ),
            const SizedBox(width: 8),
            Text('Bs. ${prestamo.montoOriginal.toStringAsFixed(2)}'),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildDetalleFila('Monto Original:', 'Bs. ${prestamo.montoOriginal.toStringAsFixed(2)}', theme),
                _buildDetalleFila('Monto Total:', 'Bs. ${prestamo.montoTotal.toStringAsFixed(2)}', theme),
                _buildDetalleFila('Pagado:', 'Bs. ${prestamo.montoPagado.toStringAsFixed(2)}', theme),
                if (esActivo) ...[
                  Divider(color: Colors.grey[300]),
                  _buildDetalleFila(
                    'Saldo Pendiente:',
                    'Bs. ${saldoPendiente.toStringAsFixed(2)}',
                    theme,
                    estaDestacado: true,
                    color: estadoColor,
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: porcentajePagado / 100,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(estadoColor),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${porcentajePagado.toStringAsFixed(1)}% Completado',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
                Divider(color: Colors.grey[300]),
                _buildDetalleFila('Tasa:', '${prestamo.tasaInteres}% ${prestamo.tipoInteres.toString().split('.').last}', theme),
                _buildDetalleFila('Plazo:', '${prestamo.plazoMeses} meses', theme),
                _buildDetalleFila('Fecha Inicio:', '${prestamo.fechaInicio.day}/${prestamo.fechaInicio.month}/${prestamo.fechaInicio.year}', theme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetalleFila(
    String label,
    String valor,
    ThemeData theme, {
    bool estaDestacado = false,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: estaDestacado ? FontWeight.bold : FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          Text(
            valor,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: estaDestacado ? FontWeight.bold : FontWeight.normal,
              color: color ?? (estaDestacado ? Colors.black : null),
            ),
          ),
        ],
      ),
    );
  }
}
