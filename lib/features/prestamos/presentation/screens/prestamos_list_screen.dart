import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../domain/entities/prestamo.dart';
import '../providers/prestamo_provider.dart';
import '../widgets/prestamo_card.dart';
import '../widgets/prestamo_search_bar.dart';
import '../../../../presentation/widgets/state_widgets.dart';
import 'prestamo_form_screen.dart';
import 'prestamo_detail_screen.dart';
import '../../../../presentation/widgets/app_drawer.dart';
import '../../../../core/theme/app_theme.dart';

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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Gestión de Préstamos',
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
            onPressed: () => ref.read(prestamosListProvider.notifier).refresh(),
            tooltip: 'Refrescar',
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: Stack(
        children: [
          // Header Background
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
                // Barra de búsqueda premium
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Prestamo_ModernSearchBar(
                    onSearch: (query) {
                      setState(() => _searchQuery = query);
                      if (query.isEmpty) {
                        ref.read(prestamosListProvider.notifier).refresh();
                      } else {
                        ref.read(prestamosListProvider.notifier).search(query);
                      }
                    },
                  ),
                ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2, end: 0),

                // Filtros de estado (Horizontal Chips)
                _buildFilterChips(ref, estadoFiltro),

                const SizedBox(height: 12),

                // Lista de préstamos
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark ? theme.scaffoldBackgroundColor : Colors.grey.shade50,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                    ),
                    child: prestamosAsync.when(
                      data: (prestamos) {
                        if (prestamos.isEmpty) {
                          return _buildEmptyState(context);
                        }

                        return RefreshIndicator(
                          onRefresh: () async {
                            ref.read(prestamosListProvider.notifier).refresh();
                          },
                          color: AppTheme.primaryBrand,
                          child: ListView.builder(
                            padding: const EdgeInsets.only(top: 20, bottom: 100, left: 16, right: 16),
                            itemCount: prestamos.length,
                            itemBuilder: (context, index) {
                              final prestamo = prestamos[index];
                              return PrestamoCard(
                                prestamo: prestamo,
                                onTap: () => _navigateToDetail(context, prestamo.id!),
                              ).animate().fadeIn(duration: 400.ms, delay: (index % 10 * 50).ms).slideX(begin: 0.1, end: 0);
                            },
                          ),
                        );
                      },
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (error, stack) => ErrorState(
                        message: error.toString(),
                        onRetry: () => ref.read(prestamosListProvider.notifier).refresh(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToForm(context),
        icon: const Icon(Icons.add_card_rounded),
        label: const Text('NUEVO PRÉSTAMO'),
        backgroundColor: AppTheme.primaryBrand,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
      ).animate().scale(duration: 400.ms, delay: 200.ms, curve: Curves.easeOutBack),
    );
  }

  Widget _buildFilterChips(WidgetRef ref, EstadoPrestamo? currentEstado) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          _buildFilterChip(
            ref,
            label: 'Todos',
            isSelected: currentEstado == null,
            onSelected: () => ref.read(estadoFiltroProvider.notifier).state = null,
          ),
          const SizedBox(width: 8),
          ...EstadoPrestamo.values.map((estado) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _buildFilterChip(
                ref,
                label: estado.displayName,
                isSelected: currentEstado == estado,
                color: _getEstadoColor(estado),
                onSelected: () => ref.read(estadoFiltroProvider.notifier).state = estado,
              ),
            );
          }),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms);
  }

  Widget _buildFilterChip(WidgetRef ref, {
    required String label,
    required bool isSelected,
    required VoidCallback onSelected,
    Color? color,
  }) {
    return GestureDetector(
      onTap: onSelected,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected 
            ? (color ?? Colors.white).withOpacity(isSelected ? 0.9 : 0.2)
            : Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? (color ?? Colors.white) : Colors.white.withOpacity(0.2),
            width: 1.5,
          ),
        ),
        child: Text(
          label.toUpperCase(),
          style: TextStyle(
            color: isSelected ? (color != null ? Colors.white : AppTheme.primaryBrand) : Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _searchQuery.isEmpty ? Icons.account_balance_rounded : Icons.search_off_rounded,
            size: 80,
            color: Colors.black12,
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isEmpty ? 'No hay préstamos activos' : 'Sin resultados',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black45),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isEmpty ? 'Crea uno nuevo para comenzar' : 'Intenta con otros términos',
            style: const TextStyle(color: Colors.black26),
          ),
        ],
      ),
    );
  }

  Color _getEstadoColor(EstadoPrestamo estado) {
    switch (estado) {
      case EstadoPrestamo.activo: return Colors.green.shade400;
      case EstadoPrestamo.pagado: return Colors.blue.shade400;
      case EstadoPrestamo.mora: return Colors.red.shade400;
      case EstadoPrestamo.cancelado: return Colors.grey.shade400;
    }
  }

  void _navigateToForm(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PrestamoFormScreen()),
    ).then((_) => ref.read(prestamosListProvider.notifier).refresh());
  }

  void _navigateToDetail(BuildContext context, int id) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PrestamoDetailScreen(prestamoId: id)),
    ).then((_) => ref.read(prestamosListProvider.notifier).refresh());
  }
}

/// Alias para usar el nuevo diseño de barra de búsqueda
class Prestamo_ModernSearchBar extends StatelessWidget {
  final Function(String) onSearch;
  const Prestamo_ModernSearchBar({super.key, required this.onSearch});

  @override
  Widget build(BuildContext context) {
    return PrestamoSearchBar(onSearch: onSearch);
  }
}
