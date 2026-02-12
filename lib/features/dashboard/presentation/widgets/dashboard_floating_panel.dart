import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/dashboard_provider.dart';
import 'alertas_widget.dart';
import 'proximos_vencimientos_widget.dart';
import 'package:go_router/go_router.dart';

/// Panel flotante lateral derecho del dashboard
/// Contiene Alertas, Calendario y Accesos Rápidos
class DashboardFloatingPanel extends ConsumerStatefulWidget {
  const DashboardFloatingPanel({super.key});

  @override
  ConsumerState<DashboardFloatingPanel> createState() => _DashboardFloatingPanelState();
}

class _DashboardFloatingPanelState extends ConsumerState<DashboardFloatingPanel> {
  int _selectedSection = 0; // 0: Alertas, 1: Calendario, 2: Accesos

  @override
  Widget build(BuildContext context) {
    final alertasAsync = ref.watch(dashboardAlertasProvider);
    final vencimientosAsync = ref.watch(proximosVencimientosProvider(30));
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      // width: 350, // Removed fixed width to allow flexibility
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.black.withOpacity(0.3)
            : Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.1)
              : Colors.grey.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Column(
            children: [
              // Header con selector de sección
              _buildHeader(theme, isDark, alertasAsync, vencimientosAsync),
              
              const Divider(height: 1),

              // Contenido scrollable
              Expanded(
                child: IndexedStack(
                  index: _selectedSection,
                  children: [
                    // Alertas
                    alertasAsync.when(
                      data: (alertas) => _buildScrollableSection(
                        AlertasWidget(alertas: alertas),
                      ),
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (error, _) => Center(child: Text('Error: $error')),
                    ),
                    
                    // Vencimientos
                    vencimientosAsync.when(
                      data: (vencimientos) => _buildScrollableSection(
                        ProximosVencimientosWidget(vencimientos: vencimientos),
                      ),
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (error, _) => Center(child: Text('Error: $error')),
                    ),
                    
                    // Accesos Rápidos
                    _buildScrollableSection(_buildAccesosRapidos(context)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 600.ms).slideX(begin: 0.2, end: 0);
  }

  Widget _buildHeader(
    ThemeData theme,
    bool isDark,
    AsyncValue alertasAsync,
    AsyncValue vencimientosAsync,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _buildSectionButton(
            icon: Icons.notifications_active_rounded,
            label: 'Alertas',
            index: 0,
            color: const Color(0xFFFF5252),
            count: alertasAsync.valueOrNull?.length,
            theme: theme,
            isDark: isDark,
          ),
          const SizedBox(width: 8),
          _buildSectionButton(
            icon: Icons.calendar_month_rounded,
            label: 'Calendario',
            index: 1,
            color: const Color(0xFF2979FF),
            count: vencimientosAsync.valueOrNull?.length,
            theme: theme,
            isDark: isDark,
          ),
          const SizedBox(width: 8),
          _buildSectionButton(
            icon: Icons.grid_view_rounded,
            label: 'Accesos',
            index: 2,
            color: const Color(0xFF00C853),
            theme: theme,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionButton({
    required IconData icon,
    required String label,
    required int index,
    required Color color,
    int? count,
    required ThemeData theme,
    required bool isDark,
  }) {
    final isSelected = _selectedSection == index;

    return Expanded(
      child: Material(
        color: isSelected
            ? color.withOpacity(isDark ? 0.2 : 0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () => setState(() => _selectedSection = index),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: isSelected && !isDark
                ? BoxDecoration(
                    border: Border.all(color: color.withOpacity(0.2)),
                    borderRadius: BorderRadius.circular(12),
                  )
                : null,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(
                      icon,
                      size: 18,
                      color: isSelected
                          ? color
                          : (isDark ? Colors.white38 : Colors.black38),
                    ),
                    if (count != null && count > 0)
                      Positioned(
                        right: -6,
                        top: -6,
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: const BoxDecoration(
                            color: Color(0xFFFF1744),
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            count.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: isSelected ? FontWeight.w900 : FontWeight.w500,
                    color: isSelected
                        ? (isDark ? Colors.white : Colors.black87)
                        : (isDark ? Colors.white38 : Colors.black38),
                    fontSize: 9,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScrollableSection(Widget child) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(8),
      child: child,
    );
  }

  Widget _buildAccesosRapidos(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          _AccesoRapidoItem(
            titulo: 'Clientes',
            icono: Icons.people_alt_rounded,
            color: const Color(0xFF2979FF),
            onTap: () => context.go('/clientes'),
          ),
          const SizedBox(height: 8),
          _AccesoRapidoItem(
            titulo: 'Préstamos',
            icono: Icons.fact_check_rounded,
            color: const Color(0xFFFFAB00),
            onTap: () => context.go('/prestamos'),
          ),
          const SizedBox(height: 8),
          _AccesoRapidoItem(
            titulo: 'Registrar Pago',
            icono: Icons.payments_rounded,
            color: const Color(0xFF00C853),
            onTap: () => context.go('/pagos/form'),
          ),
          const SizedBox(height: 8),
          _AccesoRapidoItem(
            titulo: 'Cajas',
            icono: Icons.account_balance_rounded,
            color: const Color(0xFFD500F9),
            onTap: () => context.go('/cajas'),
          ),
        ],
      ),
    );
  }
}

class _AccesoRapidoItem extends StatelessWidget {
  final String titulo;
  final IconData icono;
  final Color color;
  final VoidCallback? onTap;

  const _AccesoRapidoItem({
    required this.titulo,
    required this.icono,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? theme.cardColor : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.05)
              : Colors.grey.shade100,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icono, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    titulo,
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: isDark ? Colors.white38 : Colors.black26,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
