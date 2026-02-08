import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/prestamo.dart';
import '../providers/prestamo_provider.dart';
import '../widgets/prestamo_card.dart';
import '../widgets/prestamo_search_bar.dart';
import '../../../../presentation/widgets/state_widgets.dart';
import 'prestamo_form_screen.dart';
import 'prestamo_detail_screen.dart';
import '../../../../shared/presentation/widgets/app_drawer.dart';

class PrestamosListScreen extends ConsumerStatefulWidget {
  const PrestamosListScreen({super.key});

  @override
  ConsumerState<PrestamosListScreen> createState() => _PrestamosListScreenState();
}

class _PrestamosListScreenState extends ConsumerState<PrestamosListScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final prestamosAsync = ref.watch(prestamosFilteredProvider);
    final estadoFiltro = ref.watch(estadoFiltroProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Préstamos'),
        actions: [
          // Filtro de estado
          PopupMenuButton<EstadoPrestamo?>(
            icon: Icon(
              estadoFiltro != null ? Icons.filter_alt : Icons.filter_alt_outlined,
            ),
            tooltip: 'Filtrar por estado',
            onSelected: (estado) {
              ref.read(estadoFiltroProvider.notifier).state = estado;
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: null,
                child: Text('Todos'),
              ),
              ...EstadoPrestamo.values.map((estado) {
                return PopupMenuItem(
                  value: estado,
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: _getEstadoColor(estado),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(estado.displayName),
                    ],
                  ),
                );
              }),
            ],
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: Column(

        children: [
          // Barra de búsqueda
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: PrestamoSearchBar(
              onSearch: (query) {
                setState(() => _searchQuery = query);
                if (query.isEmpty) {
                  ref.read(prestamosListProvider.notifier).refresh();
                } else {
                  ref.read(prestamosListProvider.notifier).search(query);
                }
              },
            ),
          ),

          // Lista de préstamos
          Expanded(
            child: prestamosAsync.when(
              data: (prestamos) {
                if (prestamos.isEmpty) {
                  return EmptyState(
                    icon: Icons.account_balance,
                    title: _searchQuery.isEmpty
                        ? 'No hay préstamos'
                        : 'No se encontraron préstamos',
                    message: _searchQuery.isEmpty
                        ? 'Crea tu primer préstamo para comenzar'
                        : 'Intenta con otros términos de búsqueda',
                    actionLabel: _searchQuery.isEmpty ? 'Nuevo Préstamo' : null,
                    onAction: _searchQuery.isEmpty
                        ? () => _navigateToForm(context)
                        : null,
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.read(prestamosListProvider.notifier).refresh();
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: prestamos.length,
                    itemBuilder: (context, index) {
                      final prestamo = prestamos[index];
                      return PrestamoCard(
                        prestamo: prestamo,
                        onTap: () => _navigateToDetail(context, prestamo.id!),
                      );
                    },
                  ),
                );
              },
              loading: () => const LoadingState(message: 'Cargando préstamos...'),
              error: (error, stack) => ErrorState(
                message: error.toString(),
                onRetry: () {
                  ref.read(prestamosListProvider.notifier).refresh();
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToForm(context),
        icon: const Icon(Icons.add),
        label: const Text('Nuevo Préstamo'),
      ),
    );
  }

  Color _getEstadoColor(EstadoPrestamo estado) {
    switch (estado) {
      case EstadoPrestamo.activo:
        return Colors.green;
      case EstadoPrestamo.pagado:
        return Colors.blue;
      case EstadoPrestamo.mora:
        return Colors.red;
      case EstadoPrestamo.cancelado:
        return Colors.grey;
    }
  }

  void _navigateToForm(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const PrestamoFormScreen(),
      ),
    ).then((_) {
      ref.read(prestamosListProvider.notifier).refresh();
    });
  }

  void _navigateToDetail(BuildContext context, int id) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PrestamoDetailScreen(prestamoId: id),
      ),
    ).then((_) {
      ref.read(prestamosListProvider.notifier).refresh();
    });
  }
}