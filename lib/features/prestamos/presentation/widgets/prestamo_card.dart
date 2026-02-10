import 'package:flutter/material.dart';
import 'package:glass_kit/glass_kit.dart';
import '../../domain/entities/prestamo.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/theme/app_theme.dart';

class PrestamoCard extends StatelessWidget {
  final Prestamo prestamo;
  final VoidCallback onTap;

  const PrestamoCard({
    super.key,
    required this.prestamo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: isDark 
        ? _buildGlassCard(context) 
        : _buildPremiumCard(context),
    );
  }

  Widget _buildGlassCard(BuildContext context) {
    final theme = Theme.of(context);
    final color = _getEstadoColor(prestamo.estado);

    return GlassContainer(
      height: 200,
      width: double.infinity,
      color: Colors.white.withOpacity(0.03),
      borderColor: Colors.white.withOpacity(0.05),
      borderRadius: BorderRadius.circular(24),
      borderWidth: 1,
      blur: 15,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: _buildCardContent(context, color, true),
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumCard(BuildContext context) {
    final theme = Theme.of(context);
    final color = _getEstadoColor(prestamo.estado);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: _buildCardContent(context, color, false),
          ),
        ),
      ),
    );
  }

  Widget _buildCardContent(BuildContext context, Color color, bool isDark) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header: Código y Badge
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  prestamo.codigo,
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white38 : Colors.black38,
                    letterSpacing: 1.0,
                  ),
                ),
                Text(
                  prestamo.nombreCliente ?? 'Cliente desconocido',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
            _buildEstadoBadge(context, color, isDark),
          ],
        ),
        
        const Spacer(),
        
        // Montos Principales
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildAmountInfo(
              context,
              'PRESTADO',
              Formatters.formatCurrency(prestamo.montoOriginal),
              Icons.outbond_rounded,
              isDark ? Colors.white70 : Colors.black54,
            ),
            _buildAmountInfo(
              context,
              'PENDIENTE',
              Formatters.formatCurrency(prestamo.saldoPendiente),
              Icons.pending_actions_rounded,
              color,
            ),
          ],
        ),
        
        const Spacer(),
        
        // Progreso
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'PROGRESO DE PAGO',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontSize: 8,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white38 : Colors.black38,
                  ),
                ),
                const Spacer(),
                Text(
                  '${prestamo.porcentajePagado.toStringAsFixed(1)}%',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Stack(
              children: [
                Container(
                  height: 6,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 1000),
                  height: 6,
                  width: (MediaQuery.of(context).size.width - 72) * (prestamo.porcentajePagado / 100),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color.withOpacity(0.5), color],
                    ),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAmountInfo(BuildContext context, String label, String value, IconData icon, Color color) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 10, color: isDark ? Colors.white24 : Colors.black26),
            const SizedBox(width: 4),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                fontSize: 8,
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white38 : Colors.black38,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w900,
            color: color,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildEstadoBadge(BuildContext context, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
      ),
      child: Text(
        prestamo.estado.displayName.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 8,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Color _getEstadoColor(EstadoPrestamo estado) {
    switch (estado) {
      case EstadoPrestamo.activo: return Colors.green;
      case EstadoPrestamo.pagado: return Colors.blue;
      case EstadoPrestamo.mora: return Colors.red;
      case EstadoPrestamo.cancelado: return Colors.grey;
    }
  }
}
