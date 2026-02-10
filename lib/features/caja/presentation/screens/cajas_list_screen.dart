import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/caja_provider.dart';
import '../../domain/entities/caja.dart';
import 'caja_form_screen.dart'; // ✅ IMPORT AGREGADO
import 'caja_detail_screen.dart'; // ✅ IMPORT AGREGADO
import '../../../../core/utils/formatters.dart';
import '../../../../presentation/widgets/app_drawer.dart';

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
                        const SizedBox(height: 8),
                        Text(
                          'Presiona el botón + para crear una',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(cajasListProvider);
                    ref.invalidate(saldoTotalProvider);
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: cajas.length,
                    itemBuilder: (context, index) {
                      return _CajaCard(
                        caja: cajas[index],
                        onTap: () => _navegarADetalle(context, cajas[index]),
                      );
                    },
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('Error: $error'),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => ref.invalidate(cajasListProvider),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navegarANuevaCaja(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Nueva Caja'),
      ),
    );
  }

  // ✅ MÉTODO CORREGIDO - Navega al formulario SIN const
  void _navegarANuevaCaja(BuildContext context, WidgetRef ref) async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CajaFormScreen(), // ✅ SIN const
      ),
    );

    // Si se creó la caja, refrescar lista
    if (resultado == true) {
      ref.invalidate(cajasListProvider);
      ref.invalidate(saldoTotalProvider);
    }
  }

  // ✅ MÉTODO CORREGIDO - Navega al detalle
  void _navegarADetalle(BuildContext context, Caja caja) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CajaDetailScreen(cajaId: caja.id!),
      ),
    );
  }
}

class _CajaCard extends StatelessWidget {
  final Caja caja;
  final VoidCallback onTap;

  const _CajaCard({
    required this.caja,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Icono
                  CircleAvatar(
                    radius: 24,
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
                  const SizedBox(width: 16),
                  
                  // Nombre y tipo
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          caja.nombreCompleto,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          caja.tipo,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                        if (caja.infoCuenta != null)
                          Text(
                            caja.infoCuenta!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                      ],
                    ),
                  ),
                  
                  // Saldo
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        Formatters.formatCurrency(caja.saldo),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      if (!caja.activa)
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'INACTIVA',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
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
}