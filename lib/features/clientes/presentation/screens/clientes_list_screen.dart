import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/cliente_provider.dart';
import '../widgets/cliente_card.dart';
import '../widgets/cliente_search_bar.dart';
import 'cliente_form_screen.dart';
import 'cliente_detail_screen.dart';
import '../../../../presentation/widgets/app_drawer.dart';
import '../../../../core/theme/app_theme.dart';

/// Pantalla principal de lista de clientes con diseño inmersivo
class ClientesListScreen extends ConsumerWidget {
  const ClientesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(clientesProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Directorio de Clientes',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              ref.read(clientesProvider.notifier).loadClientes();
            },
            tooltip: 'Refrescar',
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: Stack(
        children: [
          // Header Gradient Background
          Container(
            height: 240,
            decoration: const BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                // Barra de búsqueda integrada en diseño
                ClienteSearchBar(
                  initialQuery: state.searchQuery,
                  onSearch: (query) {
                    ref.read(clientesProvider.notifier).searchClientes(query);
                  },
                  onClear: () {
                    ref.read(clientesProvider.notifier).clearSearch();
                  },
                ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2, end: 0),

                // Contador de clientes y filtros info
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${state.clientes.length} ${state.clientes.length == 1 ? 'cliente' : 'clientes'}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const Spacer(),
                      // Aquí podrían ir botones de filtros rápidos
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Lista de clientes
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark ? theme.scaffoldBackgroundColor : Colors.grey.shade50,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                    ),
                    child: _buildBody(context, ref, state),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToForm(context),
        icon: const Icon(Icons.person_add_rounded),
        label: const Text('NUEVO CLIENTE'),
        backgroundColor: AppTheme.primaryBrand,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
      ).animate().scale(duration: 400.ms, delay: 200.ms, curve: Curves.easeOutBack),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, ClientesState state) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Mostrar loading
    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // Mostrar error
    if (state.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 64,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                state.error!,
                style: theme.textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  ref.read(clientesProvider.notifier).loadClientes();
                },
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Reintentar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBrand,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
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
                  ? Icons.person_search_rounded
                  : Icons.people_outline_rounded,
              size: 80,
              color: isDark ? Colors.white10 : Colors.black12,
            ),
            const SizedBox(height: 16),
            Text(
              state.searchQuery.isNotEmpty
                  ? 'Sin resultados para "${state.searchQuery}"'
                  : 'No hay clientes registrados',
              style: theme.textTheme.titleMedium?.copyWith(
                    color: isDark ? Colors.white38 : Colors.black38,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              state.searchQuery.isNotEmpty
                  ? 'Intenta con otro nombre o documento'
                  : 'Comienza agregando un nuevo cliente',
              style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark ? Colors.white24 : Colors.black26,
                  ),
            ),
          ],
        ),
      );
    }

    // Mostrar lista de clientes
    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(clientesProvider.notifier).loadClientes();
      },
      color: AppTheme.primaryBrand,
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 20, bottom: 100),
        itemCount: state.clientes.length,
        itemBuilder: (context, index) {
          final cliente = state.clientes[index];
          return ClienteCard(
            cliente: cliente,
            onTap: () => _navigateToDetail(context, cliente.id!),
            onEdit: () => _navigateToForm(context, clienteId: cliente.id),
            onDelete: () => _showDeleteDialog(context, ref, cliente.id!, cliente.nombre),
          ).animate().fadeIn(duration: 400.ms, delay: (index % 10 * 50).ms).slideX(begin: 0.1, end: 0);
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
        content: Text('¿Estás seguro de eliminar a $nombre? Esta acción no se puede deshacer.'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCELAR'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('ELIMINAR'),
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
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            backgroundColor: success
                ? Colors.green
                : Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}
