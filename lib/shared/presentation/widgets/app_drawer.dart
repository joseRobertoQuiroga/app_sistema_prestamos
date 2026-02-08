import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Icon(
                  Icons.account_balance_wallet,
                  size: 48,
                  color: Colors.white,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Sistema de Préstamos',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Gestión Financiera',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.dashboard,
            title: 'Dashboard',
            route: '/',
            selected: location == '/',
          ),
          const Divider(),
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
          const Divider(),
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
          const Divider(),
          _buildDrawerItem(
            context,
            icon: Icons.assessment,
            title: 'Reportes',
            route: '/reportes',
            selected: location.startsWith('/reportes'),
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
    return ListTile(
      leading: Icon(icon, color: selected ? Theme.of(context).primaryColor : null),
      title: Text(
        title,
        style: TextStyle(
          color: selected ? Theme.of(context).primaryColor : null,
          fontWeight: selected ? FontWeight.bold : null,
        ),
      ),
      selected: selected,
      onTap: () {
        context.go(route);
        Navigator.pop(context); // Cerrar drawer
      },
    );
  }
}
