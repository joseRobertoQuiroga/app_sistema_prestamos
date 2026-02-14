import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/prestamo_provider.dart';
import '../widgets/prestamo_table_row.dart';
import 'prestamo_form_screen.dart';
import 'prestamo_detail_screen.dart';
import '../../../../presentation/widgets/app_drawer.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/prestamo.dart';

class PrestamosListScreen extends ConsumerWidget {
  const PrestamosListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(prestamosDashboardProvider);
    final estadoFiltro = ref.watch(estadoFiltroProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F111A) : Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryBrand,
        elevation: 0,
        title: const Text('Gestión de Préstamos', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => ref.read(prestamosListProvider.notifier).refresh(),
          ),
          const SizedBox(width: 8),
          const CircleAvatar(
            backgroundColor: Colors.white24,
            child: Text('JD', style: TextStyle(color: Colors.white, fontSize: 12)),
          ),
          const SizedBox(width: 16),
        ],
      ),
      drawer: const AppDrawer(),
      body: dashboardAsync.when(
        data: (data) => Row(
          children: [
            // SIDEBAR
            _buildSidebar(context, ref, data.stats, estadoFiltro, isDark),

            // MAIN CONTENT
            Expanded(
              child: _buildMainContent(context, ref, data.items, isDark),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildSidebar(
    BuildContext context, 
    WidgetRef ref, 
    PrestamosDashboardStats stats, 
    EstadoPrestamo? currentEstado,
    bool isDark,
  ) {
    return Container(
      width: 300,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161925) : Colors.white,
        border: Border(
          right: BorderSide(color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade200),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'RESUMEN GLOBAL',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 24),
                
                // Stat Card 1
                _buildSidebarStatCard(
                  'Total Prestado',
                  stats.totalPrestado,
                  Icons.account_balance_wallet_outlined,
                  '+12% vs mes anterior',
                  Colors.green,
                  isDark,
                ),
                const SizedBox(height: 16),
                
                // Stat Card 2
                _buildSidebarStatCard(
                  'Mora Total',
                  stats.moraTotal,
                  Icons.assignment_late_outlined,
                  '${stats.countMora} préstamos en riesgo',
                  Colors.red,
                  isDark,
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'FILTRAR ESTADO',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 16),
                
                _buildFilterItem(ref, 'Todos', null, stats.countTodos, currentEstado == null, isDark),
                _buildFilterItem(ref, 'Activo', EstadoPrestamo.activo, stats.countActivo, currentEstado == EstadoPrestamo.activo, isDark),
                _buildFilterItem(ref, 'Pagado', EstadoPrestamo.pagado, stats.countPagado, currentEstado == EstadoPrestamo.pagado, isDark),
                _buildFilterItem(ref, 'En Mora', EstadoPrestamo.mora, stats.countMora, currentEstado == EstadoPrestamo.mora, isDark),
              ],
            ),
          ),

          const Spacer(),

          Padding(
            padding: const EdgeInsets.all(24.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _navigateToForm(context, ref),
                icon: const Icon(Icons.add_card_rounded, size: 18),
                label: const Text('Nuevo Préstamo', style: TextStyle(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBrand,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarStatCard(
    String label, 
    double amount, 
    IconData icon, 
    String trend, 
    Color trendColor,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.02) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 4),
                Text(
                  '${Formatters.formatCurrency(amount)} Bs.',
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  trend,
                  style: TextStyle(color: trendColor, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: Colors.indigo.shade300),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterItem(
    WidgetRef ref, 
    String label, 
    EstadoPrestamo? estado, 
    int count, 
    bool isSelected,
    bool isDark,
  ) {
    return InkWell(
      onTap: () => ref.read(estadoFiltroProvider.notifier).state = estado,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Row(
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppTheme.primaryBrand : Colors.grey.shade400,
                  width: isSelected ? 5 : 1,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? (isDark ? Colors.white : Colors.black87) : Colors.grey,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primaryBrand.withOpacity(0.1) : (isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade100),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                count.toString(),
                style: TextStyle(
                  color: isSelected ? AppTheme.primaryBrand : Colors.grey,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent(BuildContext context, WidgetRef ref, List<Prestamo> prestamos, bool isDark) {
    return Column(
      children: [
        // SEARCH HEADER
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppTheme.primaryBrand,
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Buscar por código o cliente...',
                hintStyle: TextStyle(color: Colors.white60),
                prefixIcon: Icon(Icons.search, color: Colors.white60),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 15),
              ),
              onChanged: (query) {
                if (query.isEmpty) {
                  ref.read(prestamosListProvider.notifier).refresh();
                } else {
                  ref.read(prestamosListProvider.notifier).search(query);
                }
              },
            ),
          ),
        ),

        // TABLE
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E2130) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade200),
              boxShadow: [
                if (!isDark)
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
              ],
            ),
            child: Column(
              children: [
                // TABLE HEADER
                _buildTableHeader(isDark),
                const Divider(height: 1),
                
                // TABLE BODY
                Expanded(
                  child: prestamos.isEmpty
                      ? const Center(child: Text('No hay préstamos para mostrar'))
                      : ListView.builder(
                          itemCount: prestamos.length,
                          itemBuilder: (context, index) {
                            final prestamo = prestamos[index];
                            return PrestamoTableRow(
                              prestamo: prestamo,
                              onTap: () {},
                              onDetail: () => _navigateToDetail(context, ref, prestamo.id!),
                            );
                          },
                        ),
                ),

                // TABLE FOOTER
                _buildTableFooter(prestamos.length, isDark),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTableHeader(bool isDark) {
    const headerStyle = TextStyle(
      color: Colors.grey,
      fontSize: 11,
      fontWeight: FontWeight.bold,
      letterSpacing: 0.5,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          const Expanded(flex: 2, child: Text('ID PRÉSTAMO', style: headerStyle)),
          const Expanded(flex: 4, child: Text('CLIENTE', style: headerStyle)),
          const Expanded(flex: 2, child: Text('MONTO', style: headerStyle)),
          const Expanded(flex: 2, child: Text('PENDIENTE', style: headerStyle)),
          const Expanded(flex: 3, child: Text('PROGRESO', style: headerStyle)),
          const Expanded(flex: 2, child: Center(child: Text('ESTADO', style: headerStyle))),
          const Expanded(flex: 1, child: Align(alignment: Alignment.centerRight, child: Text('ACCIÓN', style: headerStyle))),
        ],
      ),
    );
  }

  Widget _buildTableFooter(int count, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.02) : Colors.grey.shade50,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Última actualización: Hoy, 10:45 AM',
            style: TextStyle(color: Colors.grey, fontSize: 11),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Text('10 por página', style: TextStyle(color: Colors.grey, fontSize: 11)),
                Icon(Icons.arrow_drop_down, size: 16, color: Colors.grey),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToForm(BuildContext context, WidgetRef ref) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PrestamoFormScreen()),
    ).then((_) => ref.read(prestamosListProvider.notifier).refresh());
  }

  void _navigateToDetail(BuildContext context, WidgetRef ref, int id) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PrestamoDetailScreen(prestamoId: id)),
    ).then((_) => ref.read(prestamosListProvider.notifier).refresh());
  }
}
