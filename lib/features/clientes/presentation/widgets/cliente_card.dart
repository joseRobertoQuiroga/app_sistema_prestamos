import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:glass_kit/glass_kit.dart';
import '../../domain/entities/cliente.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/theme/app_theme.dart';

/// Widget de tarjeta para mostrar información de un cliente con diseño premium
class ClienteCard extends StatelessWidget {
  final Cliente cliente;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool showActions;

  const ClienteCard({
    super.key,
    required this.cliente,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.showActions = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Widget content = Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Avatar con inicial y gradiente
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: cliente.activo 
                    ? AppTheme.primaryGradient 
                    : LinearGradient(colors: [Colors.grey.shade400, Colors.grey.shade600]),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: (cliente.activo ? AppTheme.primaryBrand : Colors.grey).withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    cliente.nombre.isNotEmpty ? cliente.nombre[0].toUpperCase() : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      Formatters.capitalizeWords(cliente.nombre),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.white : Colors.black87,
                        letterSpacing: -0.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'CI: ${Formatters.formatDocument(cliente.ci)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark ? Colors.white38 : Colors.black45,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              
              if (!cliente.activo)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'INACTIVO',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.error,
                      fontWeight: FontWeight.w900,
                      fontSize: 8,
                    ),
                  ),
                ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Contact Info Bar
          Row(
            children: [
              if (cliente.telefono != null)
                _buildCompactInfo(
                  context,
                  icon: Icons.phone_android_rounded,
                  label: Formatters.formatPhone(cliente.telefono!),
                  color: Colors.blue.shade400,
                ),
              if (cliente.telefono != null && cliente.email != null)
                const SizedBox(width: 16),
              if (cliente.email != null)
                Expanded(
                  child: _buildCompactInfo(
                    context,
                    icon: Icons.alternate_email_rounded,
                    label: cliente.email!,
                    color: Colors.orange.shade400,
                  ),
                ),
            ],
          ),
          
          if (cliente.direccion != null && cliente.direccion!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.location_on_rounded,
                  size: 14,
                  color: isDark ? Colors.white24 : Colors.black26,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    cliente.direccion!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark ? Colors.white38 : Colors.black38,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],

          if (showActions && (onEdit != null || onDelete != null)) ...[
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (onEdit != null)
                  _buildActionButton(
                    context,
                    icon: Icons.edit_note_rounded,
                    label: 'Editar',
                    color: AppTheme.primaryBrand,
                    onTap: onEdit!,
                  ),
                if (onEdit != null && onDelete != null) const SizedBox(width: 12),
                if (onDelete != null)
                  _buildActionButton(
                    context,
                    icon: Icons.delete_sweep_rounded,
                    label: 'Eliminar',
                    color: Colors.red.shade400,
                    onTap: onDelete!,
                  ),
              ],
            ),
          ],
        ],
      ),
    );

    if (isDark) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.03),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(24),
                child: content,
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: content,
        ),
      ),
    );
  }

  Widget _buildCompactInfo(BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color.withOpacity(0.8)),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: isDark ? Colors.white70 : Colors.black87,
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
