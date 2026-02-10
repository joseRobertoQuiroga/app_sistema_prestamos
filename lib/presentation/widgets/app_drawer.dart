import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers/theme_provider.dart';
import '../../core/theme/app_theme.dart';

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
                  icon: Icons.assessment,
                  title: 'Reportes',
                  route: '/reportes',
                  selected: location.startsWith('/reportes'),
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
