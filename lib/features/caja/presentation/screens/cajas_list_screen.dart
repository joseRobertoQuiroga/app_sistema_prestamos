import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/caja_provider.dart';
import '../../domain/entities/caja.dart';
import 'caja_form_screen.dart'; // ✅ IMPORT AGREGADO
import 'caja_detail_screen.dart'; // ✅ IMPORT AGREGADO
import '../../../../core/utils/formatters.dart';
import '../../../../presentation/widgets/app_drawer.dart';
import '../../../../core/theme/app_theme.dart';

/// Pantalla de lista de cajas
class CajasListScreen extends ConsumerWidget {
  const CajasListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cajasAsync = ref.watch(filteredCajasProvider);
    final saldoTotalAsync = ref.watch(saldoTotalProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    const deepDarkBg = Color(0xFF0F111A);

    return Scaffold(
      backgroundColor: isDark ? deepDarkBg : Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black87),
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined),
            onPressed: () {
              // Toggle theme logic placeholder
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              ref.invalidate(cajasListProvider);
              ref.invalidate(saldoTotalProvider);
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADING SECTION
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cajas',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    Text(
                      'Gestione sus cajas y cuentas bancarias',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isDark ? Colors.white38 : Colors.grey,
                      ),
                    ),
                  ],
                ),
                
                // SALDO TOTAL CARD
                saldoTotalAsync.when(
                  data: (saldo) => _buildSaldoTotalCard(context, saldo, isDark),
                  loading: () => const CircularProgressIndicator(),
                  error: (_, __) => const SizedBox.shrink(),
                ),

                // NUEVA CAJA BUTTON
                _buildNewCajaButton(context, ref),
              ],
            ),
            
            const SizedBox(height: 32),

            // SEARCH BAR
            _buildSearchBar(ref, isDark),

            const SizedBox(height: 32),

            // GRID OF CAJAS
            cajasAsync.when(
              data: (cajas) => _buildCajasGrid(context, ref, cajas, isDark),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text('Error: $error')),
            ),
            
            const SizedBox(height: 60),
            
            // FOOTER COPYRIGHT
            Center(
              child: Text(
                '© 2023 Gestión de Préstamos. Todos los derechos reservados.',
                style: TextStyle(
                  color: isDark ? Colors.white12 : Colors.grey.shade400,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSaldoTotalCard(BuildContext context, double saldo, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2130) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade200),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.05) : AppTheme.primaryBrand.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.account_balance_wallet_rounded,
              size: 20,
              color: isDark ? Color(0xFF818CF8) : AppTheme.primaryBrand,
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'SALDO TOTAL',
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              Text(
                '${Formatters.formatCurrency(saldo)} Bs.',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNewCajaButton(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBrand.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: () => _navegarANuevaCaja(context, ref),
        icon: const Icon(Icons.add, color: Colors.white, size: 18),
        label: const Text('Nueva Caja', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        ),
      ),
    );
  }

  Widget _buildSearchBar(WidgetRef ref, bool isDark) {
    return Container(
      width: 350,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2130) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade200),
      ),
      child: TextField(
        style: TextStyle(color: isDark ? Colors.white : Colors.black87),
        decoration: InputDecoration(
          hintText: 'Buscar caja por nombre...',
          hintStyle: TextStyle(color: isDark ? Colors.white24 : Colors.grey),
          prefixIcon: Icon(Icons.search_rounded, color: isDark ? Colors.white24 : Colors.grey, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        ),
        onChanged: (value) {
          ref.read(cajaSearchQueryProvider.notifier).state = value;
        },
      ),
    );
  }

  Widget _buildCajasGrid(BuildContext context, WidgetRef ref, List<Caja> cajas, bool isDark) {
    final double screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount = 4;
    if (screenWidth < 800) crossAxisCount = 1;
    else if (screenWidth < 1100) crossAxisCount = 2;
    else if (screenWidth < 1400) crossAxisCount = 3;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 24,
        mainAxisSpacing: 24,
        childAspectRatio: crossAxisCount == 1 ? 2.5 : 1.4,
      ),
      itemCount: cajas.length + 1, // +1 for the "Add New" card
      itemBuilder: (context, index) {
        if (index < cajas.length) {
          return _CajaIndividualCard(
            caja: cajas[index],
            onTap: () => _navegarADetalle(context, cajas[index]),
          );
        } else {
          return _buildAddCajaCard(context, ref, isDark);
        }
      },
    );
  }

  Widget _buildAddCajaCard(BuildContext context, WidgetRef ref, bool isDark) {
    return InkWell(
      onTap: () => _navegarANuevaCaja(context, ref),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? Colors.white10 : Colors.grey.shade300,
            width: 2,
            style: BorderStyle.none, // We'll use a custom painter if we want dotted, but let's stick to simple for now or use a container with decoration
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: isDark ? Colors.white.withOpacity(0.02) : Colors.grey.withOpacity(0.02),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.add,
                  color: isDark ? Colors.white38 : Colors.grey,
                  size: 24,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Añadir Nueva Caja',
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Crear una nueva cuenta o caja de efectivo',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDark ? Colors.white24 : Colors.grey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
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

class _CajaIndividualCard extends StatelessWidget {
  final Caja caja;
  final VoidCallback onTap;

  const _CajaIndividualCard({
    required this.caja,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E2130) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade200),
          boxShadow: [
            if (!isDark)
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // ICON
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _getIconColor().withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getIcono(),
                    color: _getIconColor(),
                    size: 20,
                  ),
                ),
                
                // STATUS BADGE
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.green.withOpacity(0.3)),
                  ),
                  child: const Text(
                    'Activa',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            
            const Spacer(),
            
            // CAJA NAME & TYPE
            Text(
              caja.nombre,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              caja.esBanco ? 'BANCO - ${caja.banco ?? 'CUENTA'}' : 'EFECTIVO',
              style: theme.textTheme.bodySmall?.copyWith(
                color: isDark ? Colors.white38 : Colors.grey,
                fontWeight: FontWeight.w600,
                fontSize: 10,
                letterSpacing: 0.5,
              ),
            ),
            
            const Divider(height: 32, thickness: 1, color: Colors.white12),

            // BALANCE
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  Formatters.formatCurrency(caja.saldo),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: caja.saldo < 0 ? (isDark ? Color(0xFFF87171) : Colors.red) : (isDark ? Colors.white : Colors.black87),
                  ),
                ),
                const SizedBox(width: 4),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    'Bs.',
                    style: TextStyle(
                      color: isDark ? Colors.white38 : Colors.grey,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getIconColor() {
    switch (caja.tipo) {
      case 'EFECTIVO':
        return const Color(0xFF6366F1); // Indigo
      case 'BANCO':
        return const Color(0xFF818CF8); // Lighter Indigo
      default:
        return Colors.orange;
    }
  }

  IconData _getIcono() {
    switch (caja.tipo) {
      case 'EFECTIVO':
        return Icons.point_of_sale_rounded;
      case 'BANCO':
        return Icons.account_balance_rounded;
      default:
        return Icons.wallet_rounded;
    }
  }
}
