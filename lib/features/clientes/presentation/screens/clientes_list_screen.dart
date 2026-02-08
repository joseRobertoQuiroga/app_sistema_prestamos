import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/cliente_provider.dart';
import '../widgets/cliente_card.dart';
import '../widgets/cliente_search_bar.dart';
import 'cliente_form_screen.dart';
import 'cliente_detail_screen.dart';
import '../../../../shared/presentation/widgets/app_drawer.dart';

/// Pantalla principal de lista de clientes
class ClientesListScreen extends ConsumerWidget {
  const ClientesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(clientesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Clientes'),
        actions: [
          // Botón de refrescar
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(clientesProvider.notifier).loadClientes();
            },
            tooltip: 'Refrescar',
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: Column(

        children: [
          // Barra de búsqueda
          ClienteSearchBar(
            initialQuery: state.searchQuery,
            onSearch: (query) {
              ref.read(clientesProvider.notifier).searchClientes(query);
            },
            onClear: () {
              ref.read(clientesProvider.notifier).clearSearch();
            },
          ),

          // Contador de clientes
          if (!state.isLoading && state.clientes.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text(
                    '${state.clientes.length} ${state.clientes.length == 1 ? 'cliente' : 'clientes'}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 8),

          // Lista de clientes
          Expanded(
            child: _buildBody(context, ref, state),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToForm(context),
        icon: const Icon(Icons.add),
        label: const Text('Nuevo Cliente'),
      ),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, ClientesState state) {
    // Mostrar loading
    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // Mostrar error
    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              state.error!,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () {
                ref.read(clientesProvider.notifier).loadClientes();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    // Mostrar lista vacía
    if (state.clientes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              state.searchQuery.isNotEmpty
                  ? Icons.search_off
                  : Icons.people_outline,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              state.searchQuery.isNotEmpty
                  ? 'No se encontraron clientes'
                  : 'No hay clientes registrados',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              state.searchQuery.isNotEmpty
                  ? 'Intenta con otra búsqueda'
                  : 'Agrega tu primer cliente',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.7),
                  ),
            ),
            if (state.searchQuery.isEmpty) ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () => _navigateToForm(context),
                icon: const Icon(Icons.add),
                label: const Text('Agregar Cliente'),
              ),
            ],
          ],
        ),
      );
    }

    // Mostrar lista de clientes
    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(clientesProvider.notifier).loadClientes();
      },
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 80),
        itemCount: state.clientes.length,
        itemBuilder: (context, index) {
          final cliente = state.clientes[index];
          return ClienteCard(
            cliente: cliente,
            onTap: () => _navigateToDetail(context, cliente.id!),
            onEdit: () => _navigateToForm(context, clienteId: cliente.id),
            onDelete: () => _showDeleteDialog(context, ref, cliente.id!, cliente.nombre),
          );
        },
      ),
    );
  }

  void _navigateToForm(BuildContext context, {int? clienteId}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ClienteFormScreen(clienteId: clienteId),
      ),
    );
  }

  void _navigateToDetail(BuildContext context, int clienteId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ClienteDetailScreen(clienteId: clienteId),
      ),
    );
  }

  Future<void> _showDeleteDialog(
    BuildContext context,
    WidgetRef ref,
    int id,
    String nombre,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Cliente'),
        content: Text('¿Estás seguro de eliminar a $nombre?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final success = await ref.read(clientesProvider.notifier).deleteCliente(id);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Cliente eliminado exitosamente'
                  : 'Error al eliminar cliente',
            ),
            backgroundColor: success
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}