import 'package:flutter/material.dart';
import '../../domain/entities/prestamo.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/theme/app_theme.dart';

class PrestamoTableRow extends StatelessWidget {
  final Prestamo prestamo;
  final VoidCallback onTap;
  final VoidCallback onDetail;

  const PrestamoTableRow({
    super.key,
    required this.prestamo,
    required this.onTap,
    required this.onDetail,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final color = _getEstadoColor(prestamo.estado);

    return InkWell(
      onTap: onDetail,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade100,
            ),
          ),
        ),
        child: Row(
          children: [
            // ID PRÉSTAMO
            Expanded(
              flex: 2,
              child: Text(
                prestamo.codigo,
                style: TextStyle(
                  color: isDark ? Colors.white60 : Colors.grey.shade600,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            // CLIENTE
            Expanded(
              flex: 4,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: AppTheme.primaryBrand.withOpacity(0.1),
                    child: Text(
                      prestamo.nombreCliente?[0].toUpperCase() ?? '?',
                      style: TextStyle(
                        color: AppTheme.primaryBrand,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          prestamo.nombreCliente ?? 'Desconocido',
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black87,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Recurrente', // Placeholder or add to entity if available
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // MONTO
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    Formatters.formatCurrency(prestamo.montoOriginal),
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'Bs.',
                    style: TextStyle(color: Colors.grey, fontSize: 10),
                  ),
                ],
              ),
            ),

            // PENDIENTE
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    Formatters.formatCurrency(prestamo.saldoPendiente),
                    style: TextStyle(
                      color: color,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Bs.',
                    style: TextStyle(color: color.withOpacity(0.5), fontSize: 10),
                  ),
                ],
              ),
            ),

            // PROGRESO
            Expanded(
              flex: 3,
              child: Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: prestamo.porcentajePagado / 100,
                        backgroundColor: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade100,
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                        minHeight: 6,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${prestamo.porcentajePagado.toInt()}%',
                    style: TextStyle(
                      color: isDark ? Colors.white60 : Colors.grey.shade600,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // ESTADO
            Expanded(
              flex: 2,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    prestamo.estado.displayName,
                    style: TextStyle(
                      color: color,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),

            // ACCIÓN
            Expanded(
              flex: 1,
              child: Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  icon: Icon(
                    prestamo.estado == EstadoPrestamo.pagado ? Icons.visibility_outlined : Icons.more_vert_rounded,
                    size: 18,
                    color: isDark ? Colors.white24 : Colors.grey,
                  ),
                  onPressed: onDetail,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getEstadoColor(EstadoPrestamo estado) {
    switch (estado) {
      case EstadoPrestamo.activo:
        return Colors.green;
      case EstadoPrestamo.pagado:
        return Colors.blue;
      case EstadoPrestamo.mora:
        return Colors.red;
      case EstadoPrestamo.cancelado:
        return Colors.grey;
    }
  }
}
