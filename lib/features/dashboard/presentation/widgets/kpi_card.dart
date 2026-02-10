import 'package:flutter/material.dart';
import 'package:glass_kit/glass_kit.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/theme/app_theme.dart';

/// Widget para mostrar un KPI en tarjeta con efectos modernos
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
    final isDark = theme.brightness == Brightness.dark;
    final effectiveColor = color ?? theme.colorScheme.primary;

    if (isDark) {
      return GlassContainer.clearGlass(
        height: 160,
        width: double.infinity,
        borderRadius: BorderRadius.circular(20),
        borderWidth: 1.5,
        borderColor: Colors.white.withOpacity(0.1),
        blur: 15,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: _buildContent(context, effectiveColor, true),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: _buildContent(context, effectiveColor, false),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, Color color, bool isDark) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(isDark ? 0.2 : 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icono,
                  color: isDark ? color.withOpacity(0.9) : color,
                  size: 22,
                ),
              ),
              const Spacer(),
              if (trailing != null) trailing!,
            ],
          ),
          const Spacer(),
          Text(
            titulo,
            style: theme.textTheme.labelMedium?.copyWith(
              color: isDark ? Colors.white70 : Colors.black54,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            valor,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : Colors.black87,
              letterSpacing: -0.5,
            ),
          ),
          if (subtitulo != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitulo!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: isDark ? Colors.white54 : Colors.black38,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Widget para mostrar un indicador de salud con diseño premium
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
    final isDark = theme.brightness == Brightness.dark;
    final color = _getColor(porcentaje);

    Widget content = Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          CircularPercentIndicator(
            radius: 45.0,
            lineWidth: 8.0,
            percent: porcentaje / 100,
            center: Text(
              "${porcentaje.toStringAsFixed(0)}%",
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            progressColor: color,
            backgroundColor: isDark ? Colors.white10 : Colors.grey.shade100,
            circularStrokeCap: CircularStrokeCap.round,
            animation: true,
            animationDuration: 1000,
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  titulo,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                if (descripcion != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    descripcion!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark ? Colors.white54 : Colors.black45,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _getStatusText(porcentaje),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    if (isDark) {
      return GlassContainer.clearGlass(
        height: 140,
        width: double.infinity,
        borderRadius: BorderRadius.circular(20),
        blur: 15,
        child: content,
      );
    }

    return Container(
      height: 140,
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

  Color _getColor(double value) {
    if (value >= 80) return const Color(0xFF00C853);
    if (value >= 60) return const Color(0xFFFFAB00);
    return const Color(0xFFFF1744);
  }

  String _getStatusText(double value) {
    if (value >= 80) return "Excelente";
    if (value >= 60) return "Regular";
    return "Crítico";
  }
}
