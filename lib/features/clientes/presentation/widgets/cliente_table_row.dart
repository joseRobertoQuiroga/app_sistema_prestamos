import 'package:flutter/material.dart';
import '../../domain/entities/cliente.dart';
import '../providers/cliente_provider.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/theme/app_theme.dart';

class ClienteTableRow extends StatelessWidget {
  final ClienteDashboardModel item;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ClienteTableRow({
    super.key,
    required this.item,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cliente = item.cliente;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade200,
            ),
          ),
        ),
        child: Row(
          children: [
            // Checkbox placeholder (as seen in mockup)
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark ? Colors.white24 : Colors.grey.shade400,
                  width: 1.5,
                ),
              ),
            ),
            const SizedBox(width: 24),

            // ESTADO
            SizedBox(
              width: 100,
              child: _StatusBadge(status: item.statusGlobal),
            ),

            // CLIENTE / CI
            Expanded(
              flex: 3,
              child: Row(
                children: [
                  _Avatar(
                    nombre: cliente.nombre,
                    activo: cliente.activo,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cliente.nombre,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'CI: ${cliente.ci}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isDark ? Colors.white38 : Colors.grey,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // CONTACTO
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  Icon(
                    Icons.phone_android_outlined,
                    size: 14,
                    color: isDark ? Colors.white38 : Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    cliente.telefono ?? 'N/A',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),

            // DIRECCIÓN
            Expanded(
              flex: 3,
              child: Text(
                cliente.direccion ?? 'N/A',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isDark ? Colors.white38 : Colors.grey,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // SALDO
            SizedBox(
              width: 120,
              child: Text(
                '${Formatters.formatCurrency(item.saldoTotal)} Bs.',
                textAlign: TextAlign.right,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: item.statusGlobal == 'Mora' 
                      ? Colors.red[400] 
                      : (isDark ? Colors.white : Colors.black87),
                ),
              ),
            ),

            // ACCIONES
            const SizedBox(width: 20),
            PopupMenuButton<String>(
              icon: Icon(
                Icons.more_horiz,
                color: isDark ? Colors.white38 : Colors.grey,
              ),
              onSelected: (value) {
                if (value == 'edit') onEdit();
                if (value == 'delete') onDelete();
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit_outlined, size: 20),
                      SizedBox(width: 12),
                      Text('Editar'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline, size: 20, color: Colors.red),
                      SizedBox(width: 12),
                      Text('Eliminar', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case 'Activo':
        color = Colors.green;
        break;
      case 'Mora':
        color = Colors.orange;
        break;
      case 'Inactivo':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Center(
        child: Text(
          status,
          style: TextStyle(
            color: color,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String nombre;
  final bool activo;

  const _Avatar({required this.nombre, required this.activo});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: activo ? AppTheme.primaryBrand.withOpacity(0.2) : Colors.grey.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          nombre.isNotEmpty ? nombre[0].toUpperCase() : '?',
          style: TextStyle(
            color: activo ? AppTheme.primaryBrand : Colors.grey,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
