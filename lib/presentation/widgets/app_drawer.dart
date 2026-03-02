import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers/theme_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../config/router/app_router.dart';
import '../../features/caja/presentation/providers/caja_provider.dart';
import '../../features/dashboard/presentation/providers/dashboard_provider.dart';
import '../../features/clientes/presentation/providers/cliente_provider.dart';
import '../../features/prestamos/presentation/providers/prestamo_provider.dart';
import '../../features/pagos/presentation/providers/pago_provider.dart';
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
          
          // Menú
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _buildDrawerItem(
                  context,
                  icon: Icons.add_circle_outline,
                  title: 'Inicio / Generar',
                  route: AppRouter.generarMovimiento,
                  selected: location == AppRouter.generarMovimiento,
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.compare_arrows,
                  title: 'Movimientos',
                  route: AppRouter.movimientos,
                  selected: location == AppRouter.movimientos,
                ),
                
                const Divider(height: 32),
                _buildSectionLabel(context, 'PRÉSTAMOS'),
                _buildDrawerItem(
                  context,
                  icon: Icons.people,
                  title: 'Clientes',
                  route: AppRouter.clientes,
                  selected: location.startsWith(AppRouter.clientes),
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.account_balance,
                  title: 'Préstamos',
                  route: AppRouter.prestamos,
                  selected: location.startsWith(AppRouter.prestamos),
                ),

                const Divider(height: 32),
                // Sección sin nombre
                _buildDrawerItem(
                  context,
                  icon: Icons.account_balance_wallet,
                  title: 'Cajas',
                  route: AppRouter.cajas,
                  selected: location.startsWith(AppRouter.cajas),
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.swap_horiz,
                  title: 'Transferencias',
                  route: AppRouter.transferencia,
                  selected: location.startsWith(AppRouter.transferencia),
                ),

                const Divider(height: 32),
                _buildSectionLabel(context, 'REPORTES'),
                _buildDrawerItem(
                  context,
                  icon: Icons.assessment,
                  title: 'Reportes',
                  route: AppRouter.reportes,
                  selected: location.startsWith(AppRouter.reportes),
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.bar_chart,
                  title: 'Informes',
                  route: AppRouter.informes,
                  selected: location.startsWith(AppRouter.informes),
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.refresh,
                  title: 'Actualizar Sistema',
                  route: AppRouter.gestionDatos,
                  selected: location == AppRouter.gestionDatos,
                  onTapOverride: () {
                    Navigator.pop(context);
                    // Invalidar todos los providers principales
                    ref.invalidate(cajasListProvider);
                    ref.invalidate(cajasActivasProvider);
                    ref.invalidate(saldoTotalProvider);
                    ref.invalidate(resumenGeneralProvider);
                    ref.invalidate(movimientosGeneralesProvider);
                    ref.invalidate(dashboardKPIsProvider);
                    ref.invalidate(dashboardAlertasProvider);
                    ref.invalidate(clientesProvider);
                    ref.invalidate(clientesActivosProvider);
                    ref.invalidate(prestamosListProvider);
                    ref.invalidate(allPagosListProvider);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('✅ Sistema actualizado correctamente'),
                        backgroundColor: Colors.green,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),

                const Divider(height: 32),
                _buildDrawerItem(
                  context,
                  icon: Icons.help_outline,
                  title: 'Ayuda',
                  route: AppRouter.ayuda,
                  selected: location.startsWith(AppRouter.ayuda),
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
          const Text(
            'Modo Oscuro',
            style: TextStyle(
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

  Widget _buildSectionLabel(BuildContext context, String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String route,
    required bool selected,
    VoidCallback? onTapOverride,
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
      onTap: onTapOverride ?? () {
        Navigator.pop(context);
        Future.delayed(const Duration(milliseconds: 100), () {
          context.go(route);
        });
      },
    );
  }
}
