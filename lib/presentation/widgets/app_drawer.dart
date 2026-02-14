import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers/theme_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../config/router/app_router.dart';
import '../../features/caja/presentation/providers/caja_provider.dart';
import '../../features/dashboard/presentation/providers/dashboard_provider.dart';
import '../../core/utils/formatters.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).uri.toString();
    final themeMode = ref.watch(themeModeProvider);
    final isDarkMode = themeMode == ThemeMode.dark;

    return Drawer(
      child: Column(
        children: [
          // Header con gradiente
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar/Icono
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.account_balance_wallet,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Título
                    const Text(
                      'Sistema de Préstamos',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Subtítulo
                    Text(
                      'Gestión Financiera',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Toggle de tema
                    _buildThemeToggle(context, ref, isDarkMode),
                  ],
                ),
              ),
            ),
          ),
          
          // Resumen Ejecutivo (Informational Navbar feature)
          _buildExecutiveSummary(context, ref),
          
          const Divider(height: 1),
          
          // Menú
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _buildDrawerItem(
                  context,
                  icon: Icons.dashboard,
                  title: 'Dashboard',
                  route: '/',
                  selected: location == '/',
                ),
                const Divider(height: 1),
                _buildDrawerItem(
                  context,
                  icon: Icons.people,
                  title: 'Clientes',
                  route: '/clientes',
                  selected: location.startsWith('/clientes'),
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.account_balance,
                  title: 'Préstamos',
                  route: '/prestamos',
                  selected: location.startsWith('/prestamos'),
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.payment,
                  title: 'Pagos',
                  route: '/pagos',
                  selected: location.startsWith('/pagos'),
                ),
                const Divider(height: 1),
                _buildDrawerItem(
                  context,
                  icon: Icons.account_balance_wallet,
                  title: 'Cajas',
                  route: '/cajas',
                  selected: location.startsWith('/cajas'),
                ),
                  _buildDrawerItem(
                  context,
                  icon: Icons.swap_horiz,
                  title: 'Transferencias',
                  route: '/transferencias',
                  selected: location.startsWith('/transferencias'),
                ),
                const Divider(height: 1),
                _buildDrawerItem(
                  context,
                  icon: Icons.compare_arrows,
                  title: 'Movimientos',
                  route: AppRouter.movimientos,
                  selected: location == AppRouter.movimientos,
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.add_circle_outline,
                  title: 'Generar Movimiento',
                  route: AppRouter.generarMovimiento,
                  selected: location == AppRouter.generarMovimiento,
                ),
                const Divider(height: 1),
                _buildDrawerItem(
                  context,
                  icon: Icons.assessment,
                  title: 'Reportes',
                  route: '/reportes',
                  selected: location.startsWith('/reportes'),
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.bar_chart,
                  title: 'Informes',
                  route: '/informes',
                  selected: location.startsWith('/informes'),
                ),
                const Divider(height: 1),
                _buildDrawerItem(
                  context,
                  icon: Icons.help_outline,
                  title: 'Ayuda',
                  route: '/ayuda',
                  selected: location.startsWith('/ayuda'),
                ),
                const Divider(height: 1),
                _buildDrawerItem(
                  context,
                  icon: Icons.refresh,
                  title: 'Cargar Datos',
                  route: '/reportes', // Assuming this navigates to the reports/data section
                  selected: false,
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.file_upload,
                  title: 'Importar',
                  route: '/reportes', // Assuming this navigates to the reports/data section
                  selected: false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeToggle(BuildContext context, WidgetRef ref, bool isDarkMode) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isDarkMode ? Icons.dark_mode : Icons.light_mode,
            color: Colors.white,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            isDarkMode ? 'Modo Oscuro' : 'Modo Claro',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 12),
          Switch(
            value: isDarkMode,
            onChanged: (value) {
              ref.read(themeModeProvider.notifier).toggleTheme();
            },
            activeColor: Colors.white,
            activeTrackColor: Colors.white.withOpacity(0.3),
            inactiveThumbColor: Colors.white.withOpacity(0.8),
            inactiveTrackColor: Colors.white.withOpacity(0.2),
          ),
        ],
      ),
    );
  }

  Widget _buildExecutiveSummary(BuildContext context, WidgetRef ref) {
    final kpisAsync = ref.watch(dashboardKPIsProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return kpisAsync.when(
      data: (kpis) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.05) : theme.colorScheme.primary.withOpacity(0.05),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics_outlined, size: 16, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'RESUMEN EJECUTIVO',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSummaryItem(
              context,
              label: 'Saldo Total Cajas',
              value: Formatters.formatCurrency(kpis.saldoTotalCajas),
              icon: Icons.account_balance_wallet,
              color: Colors.green,
            ),
            const SizedBox(height: 12),
            _buildSummaryItem(
              context,
              label: 'Cartera Vigente',
              value: Formatters.formatCurrency(kpis.capitalPorCobrar),
              icon: Icons.pie_chart,
              color: Colors.blue,
            ),
            const SizedBox(height: 12),
            _buildSummaryItem(
              context,
              label: 'Préstamos Activos',
              value: '${kpis.prestamosActivos}',
              icon: Icons.assignment_turned_in,
              color: Colors.orange,
            ),
          ],
        ),
      ),
      loading: () => const AppSummarySkeleton(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildSummaryItem(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String route,
    required bool selected,
  }) {
    final theme = Theme.of(context);
    
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: selected 
              ? theme.colorScheme.primaryContainer 
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon, 
          color: selected 
              ? theme.colorScheme.primary 
              : theme.colorScheme.onSurface.withOpacity(0.6),
          size: 24,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: selected 
              ? theme.colorScheme.primary 
              : theme.colorScheme.onSurface,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          fontSize: 15,
        ),
      ),
      selected: selected,
      selectedTileColor: theme.colorScheme.primaryContainer.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      onTap: () {
        Navigator.pop(context);
        Future.delayed(const Duration(milliseconds: 100), () {
          context.go(route);
        });
      },
    );
  }
}

class AppSummarySkeleton extends StatelessWidget {
  const AppSummarySkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(height: 12, width: 100, color: isDark ? Colors.white12 : Colors.black12),
          const SizedBox(height: 16),
          ...List.generate(3, (index) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Container(height: 28, width: 28, decoration: BoxDecoration(color: isDark ? Colors.white12 : Colors.black12, borderRadius: BorderRadius.circular(8))),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(height: 10, width: 60, color: isDark ? Colors.white10 : Colors.black12),
                      const SizedBox(height: 4),
                      Container(height: 12, width: 120, color: isDark ? Colors.white12 : Colors.black12),
                    ],
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}
