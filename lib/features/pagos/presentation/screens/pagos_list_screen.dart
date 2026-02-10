import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/pago.dart';
import '../providers/pago_provider.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../presentation/widgets/app_drawer.dart';

/// Pantalla principal de lista de todos los pagos
class PagosListScreen extends ConsumerWidget {
  const PagosListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Pagos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Filtros próximamente')),
              );
            },
          ),
        ],
      ),
      drawer: const AppDrawer(),
      // ✅ SOLUCIÓN: Envolver body en SingleChildScrollView
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tarjeta informativa
            Card(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'Los pagos se registran desde el detalle de cada préstamo',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Accesos rápidos
            Text(
              'Acciones rápidas',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            
            // Botones de navegación
            // ✅ CAMBIO: Usar Column en lugar de GridView con shrinkWrap
            _buildQuickActionsGrid(context),
            
            const SizedBox(height: 24),
            
            // Información adicional
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.help_outline,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '¿Cómo registrar un pago?',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildStep('1', 'Ve a la sección de Préstamos'),
                    _buildStep('2', 'Selecciona el préstamo a pagar'),
                    _buildStep('3', 'Presiona el botón "Registrar Pago"'),
                    _buildStep('4', 'Ingresa el monto y confirma'),
                  ],
                ),
              ),
            ),
            
            // ✅ Espacio final para evitar que el FAB tape contenido
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  // ✅ NUEVO: Método para construir el grid de acciones
  Widget _buildQuickActionsGrid(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildQuickActionCard(
                context,
                icon: Icons.account_balance_wallet,
                title: 'Ver Préstamos',
                subtitle: 'Gestionar préstamos activos',
                color: Colors.blue,
                onTap: () => context.go('/prestamos'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildQuickActionCard(
                context,
                icon: Icons.assessment,
                title: 'Reportes',
                subtitle: 'Ver estadísticas de pagos',
                color: Colors.purple,
                onTap: () => context.go('/reportes'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildQuickActionCard(
                context,
                icon: Icons.account_balance,
                title: 'Cajas',
                subtitle: 'Gestionar cajas',
                color: Colors.green,
                onTap: () => context.go('/cajas'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildQuickActionCard(
                context,
                icon: Icons.history,
                title: 'Movimientos',
                subtitle: 'Ver todos los movimientos',
                color: Colors.orange,
                onTap: () => context.go('/movimientos'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(height: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 12,
            child: Text(
              number,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}