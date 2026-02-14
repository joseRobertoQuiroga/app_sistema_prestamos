import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/cliente_provider.dart';
import '../widgets/cliente_table_row.dart';
import 'cliente_form_screen.dart';
import 'cliente_detail_screen.dart';
import '../../../../presentation/widgets/app_drawer.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';

class ClientesListScreen extends ConsumerWidget {
  const ClientesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(clientesDashboardProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // El mockup usa un fondo oscuro muy específico
    const deepDarkBg = Color(0xFF1E2130);

    return Scaffold(
      backgroundColor: isDark ? deepDarkBg : Colors.grey[100],
      appBar: AppBar(
        title: Text(
          'Directorio de Clientes',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black87),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              ref.read(clientesProvider.notifier).loadClientes();
            },
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: AppTheme.primaryBrand,
            child: const Text('A', style: TextStyle(color: Colors.white, fontSize: 12)),
          ),
          const SizedBox(width: 16),
        ],
      ),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          // Barra de Búsqueda y Filtros
          _buildFilterBar(context, ref, isDark),

          // Cuerpo con la tabla
          Expanded(
            child: _buildDashboardBody(context, ref, dashboardAsync, isDark),
          ),

          // Footer / Paginación
          _buildFooter(context, ref, dashboardAsync, isDark),
        ],
      ),
    );
  }

  Widget _buildFilterBar(BuildContext context, WidgetRef ref, bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        children: [
          // Buscador
          Expanded(
            flex: 2,
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF262A40) : Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade300),
              ),
              child: TextField(
                onChanged: (value) {
                  ref.read(clientesProvider.notifier).searchClientes(value);
                },
                style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Buscar por nombre, CI o teléfono...',
                  hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.grey),
                  prefixIcon: Icon(Icons.search, color: isDark ? Colors.white38 : Colors.grey),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Dropdown Estados
          Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF262A40) : Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade300),
            ),
            child: DropdownButton<String>(
              value: 'Todos los Estados',
              dropdownColor: isDark ? const Color(0xFF262A40) : Colors.white,
              underline: const SizedBox(),
              style: TextStyle(color: isDark ? Colors.white : Colors.black87),
              items: ['Todos los Estados', 'Mora', 'Activo', 'Inactivo']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (_) {},
            ),
          ),
          const Spacer(),

          // Botón Nuevo Cliente
          ElevatedButton.icon(
            onPressed: () => _navigateToForm(context),
            icon: const Icon(Icons.person_add_outlined, size: 20),
            label: const Text('Nuevo Cliente'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF818CF8),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardBody(
    BuildContext context, 
    WidgetRef ref, 
    AsyncValue<({List<ClienteDashboardModel> items, int totalItems, int totalPages, int currentPage})> dashboardAsync,
    bool isDark,
  ) {
    return dashboardAsync.when(
      data: (data) {
        if (data.items.isEmpty) {
          return const Center(child: Text('No hay clientes vinculados'));
        }

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF262A40).withOpacity(0.5) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade200),
          ),
          child: Column(
            children: [
              // Encabezado de Tabla
              _buildTableHeader(isDark),
              
              const Divider(height: 1, thickness: 1, color: Colors.white12),

              // Filas
              Expanded(
                child: ListView.builder(
                  itemCount: data.items.length,
                  itemBuilder: (context, index) {
                    final item = data.items[index];
                    return ClienteTableRow(
                      item: item,
                      onTap: () => _navigateToDetail(context, item.cliente.id!),
                      onEdit: () => _navigateToForm(context, clienteId: item.cliente.id),
                      onDelete: () => _showDeleteDialog(context, ref, item.cliente.id!, item.cliente.nombre),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text('Error: $e')),
    );
  }

  Widget _buildTableHeader(bool isDark) {
    final style = TextStyle(
      color: isDark ? Colors.white38 : Colors.grey,
      fontSize: 12,
      fontWeight: FontWeight.bold,
      letterSpacing: 0.5,
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          const SizedBox(width: 42), // Checkbox area
          SizedBox(width: 100, child: Text('ESTADO', style: style)),
          Expanded(flex: 3, child: Text('CLIENTE / CI', style: style)),
          Expanded(flex: 2, child: Text('CONTACTO', style: style)),
          Expanded(flex: 3, child: Text('DIRECCIÓN', style: style)),
          SizedBox(width: 120, child: Text('SALDO', textAlign: TextAlign.right, style: style)),
          SizedBox(
            width: 60, 
            child: Align(
              alignment: Alignment.centerRight,
              child: Icon(Icons.settings_suggest_outlined, size: 16, color: isDark ? Colors.white38 : Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(
    BuildContext context, 
    WidgetRef ref,
    AsyncValue<({List<ClienteDashboardModel> items, int totalItems, int totalPages, int currentPage})> dashboardAsync, 
    bool isDark,
  ) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: dashboardAsync.when(
        data: (data) {
          final startItem = data.totalItems == 0 ? 0 : (data.currentPage - 1) * 15 + 1;
          final endItem = data.currentPage * 15 > data.totalItems ? data.totalItems : data.currentPage * 15;

          return Row(
            children: [
              Text(
                'Mostrando $startItem a $endItem de ${data.totalItems} resultados',
                style: TextStyle(color: isDark ? Colors.white24 : Colors.grey, fontSize: 12),
              ),
              const Spacer(),
              
              // Botones de página
              Row(
                children: List.generate(data.totalPages, (index) {
                  final pageNum = index + 1;
                  // Si hay muchas páginas, podríamos truncar, pero por ahora mostramos todas si son pocas
                  if (data.totalPages > 7) {
                    if (pageNum > 3 && pageNum < data.totalPages - 2 && (pageNum - data.currentPage).abs() > 1) {
                      if (pageNum == 4 || pageNum == data.totalPages - 3) {
                         return const Text('...', style: TextStyle(color: Colors.white24));
                      }
                      return const SizedBox();
                    }
                  }
                  
                  return _buildPaginationButton(
                    pageNum.toString(), 
                    active: data.currentPage == pageNum,
                    onTap: () => ref.read(clientesProvider.notifier).setPage(pageNum),
                  );
                }),
              ),
              
              const SizedBox(width: 8),
              
              IconButton(
                icon: Icon(Icons.chevron_left, color: data.currentPage > 1 ? (isDark ? Colors.white70 : Colors.black87) : Colors.white24, size: 18),
                onPressed: data.currentPage > 1 ? () => ref.read(clientesProvider.notifier).setPage(data.currentPage - 1) : null,
              ),
              IconButton(
                icon: Icon(Icons.chevron_right, color: data.currentPage < data.totalPages ? (isDark ? Colors.white70 : Colors.black87) : Colors.white24, size: 18),
                onPressed: data.currentPage < data.totalPages ? () => ref.read(clientesProvider.notifier).setPage(data.currentPage + 1) : null,
              ),
            ],
          );
        },
        loading: () => const SizedBox(),
        error: (_, __) => const SizedBox(),
      ),
    );
  }

  Widget _buildPaginationButton(String label, {bool active = false, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: active ? const Color(0xFF6366F1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: !active ? Border.all(color: Colors.white10) : null,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: active ? Colors.white : Colors.white70,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
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
