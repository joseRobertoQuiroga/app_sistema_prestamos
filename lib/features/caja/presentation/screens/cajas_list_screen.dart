import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/caja_provider.dart';
import '../../domain/entities/caja.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/presentation/widgets/app_drawer.dart';

/// Pantalla de lista de cajas
class CajasListScreen extends ConsumerWidget {
  const CajasListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cajasAsync = ref.watch(cajasListProvider);
    final saldoTotalAsync = ref.watch(saldoTotalProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cajas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(cajasListProvider);
              ref.invalidate(saldoTotalProvider);
            },
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: Column(

        children: [
          // Saldo total
          saldoTotalAsync.when(
            data: (saldo) => Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Column(
                children: [
                  Text(
                    'Saldo Total',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    Formatters.formatCurrency(saldo),
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
            loading: () => const LinearProgressIndicator(),
            error: (_, __) => const SizedBox.shrink(),
          ),

          // Lista de cajas
          Expanded(
            child: cajasAsync.when(
              data: (cajas) {
                if (cajas.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.account_balance_wallet_outlined,
                          size: 64,
                          color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No hay cajas registradas',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(cajasListProvider);
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: cajas.length,
                    itemBuilder: (context, index) {
                      return _CajaCard(caja: cajas[index]);
                    },
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text('Error: $error')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showNuevaCajaDialog(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Nueva Caja'),
      ),
    );
  }

  void _showNuevaCajaDialog(BuildContext context, WidgetRef ref) {
    // TODO: Implementar diálogo o navegar a formulario
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Formulario de nueva caja pendiente')),
    );
  }
}

class _CajaCard extends StatelessWidget {
  final Caja caja;

  const _CajaCard({required this.caja});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: caja.activa
              ? Theme.of(context).colorScheme.primaryContainer
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          child: Icon(
            _getIcono(),
            color: caja.activa
                ? Theme.of(context).colorScheme.onPrimaryContainer
                : Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        title: Text(
          caja.nombreCompleto,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (caja.infoCuenta != null) Text(caja.infoCuenta!),
            Text('Tipo: ${caja.tipo}'),
            if (!caja.activa)
              Text(
                'INACTIVA',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
        trailing: Text(
          Formatters.formatCurrency(caja.saldo),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
        ),
        isThreeLine: true,
        onTap: () {
          _showCajaDetail(context, caja);
        },
      ),
    );
  }

  IconData _getIcono() {
    switch (caja.tipo) {
      case 'EFECTIVO':
        return Icons.payments;
      case 'BANCO':
        return Icons.account_balance;
      default:
        return Icons.account_balance_wallet;
    }
  }

  void _showCajaDetail(BuildContext context, Caja caja) {
    // TODO: Navegar a detalle de caja
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Detalle de ${caja.nombre} pendiente')),
    );
  }
}