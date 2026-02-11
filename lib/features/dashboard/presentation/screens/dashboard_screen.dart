import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:glass_kit/glass_kit.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/kpi_card.dart';
import '../widgets/alertas_widget.dart';
import '../widgets/proximos_vencimientos_widget.dart';
import '../../../../presentation/widgets/app_drawer.dart';
import '../../../../core/theme/app_theme.dart';

/// Pantalla principal del Dashboard con diseño inmersivo y premium
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final kpisAsync = ref.watch(dashboardKPIsProvider);
    final alertasAsync = ref.watch(dashboardAlertasProvider);
    final vencimientosAsync = ref.watch(proximosVencimientosProvider(30));
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Resumen General',
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
              ref.invalidate(dashboardKPIsProvider);
              ref.invalidate(dashboardAlertasProvider);
              ref.invalidate(proximosVencimientosProvider);
            },
            tooltip: 'Actualizar',
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: Stack(
        children: [
          // Background Gradient for the whole screen (Top section focus)
          Container(
            height: MediaQuery.of(context).size.height * 0.45,
            decoration: const BoxDecoration(
              gradient: AppTheme.primaryGradient,
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 10),
                // KPIs Section
                Expanded(
                  flex: 45,
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1200),
                      child: kpisAsync.when(
                        data: (kpis) => RefreshIndicator(
                          onRefresh: () async {
                            ref.invalidate(dashboardKPIsProvider);
                            ref.invalidate(dashboardAlertasProvider);
                            ref.invalidate(proximosVencimientosProvider);
                          },
                          color: AppTheme.primaryBrand,
                          child: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                            child: _buildCompactKPIs(context, kpis),
                          ),
                        ),
                        loading: () => const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        ),
                        error: (error, _) => _buildErrorState(context, error),
                      ),
                    ),
                  ),
                ),

                // Content Section (Tabs)
                Expanded(
                  flex: 55,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: isDark ? theme.scaffoldBackgroundColor : Colors.grey.shade50,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                      boxShadow: !isDark ? [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 20,
                          offset: const Offset(0, -10),
                        ),
                      ] : null,
                    ),
                    child: Column(
                      children: [
                        // Tab Selector
                        Padding(
                          padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
                          child: Row(
                            children: [
                              _buildTabButton(
                                context,
                                index: 0,
                                icon: Icons.notifications_active_rounded,
                                label: 'Alertas',
                                color: const Color(0xFFFF5252),
                                count: alertasAsync.valueOrNull?.length,
                              ),
                              const SizedBox(width: 12),
                              _buildTabButton(
                                context,
                                index: 1,
                                icon: Icons.calendar_month_rounded,
                                label: 'Calendario',
                                color: const Color(0xFF2979FF),
                                count: vencimientosAsync.valueOrNull?.length,
                              ),
                              const SizedBox(width: 12),
                              _buildTabButton(
                                context,
                                index: 2,
                                icon: Icons.grid_view_rounded,
                                label: 'Accesos',
                                color: const Color(0xFF00C853),
                              ),
                            ],
                          ),
                        ),
                        
                        // Tab Content
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: IndexedStack(
                              index: _selectedTabIndex,
                              children: [
                                // Alertas Tab
                                alertasAsync.when(
                                  data: (alertas) => SingleChildScrollView(child: AlertasWidget(alertas: alertas)),
                                  loading: () => const Center(child: CircularProgressIndicator()),
                                  error: (error, _) => Center(child: Text('Error: $error')),
                                ),
                                // Vencimientos Tab
                                vencimientosAsync.when(
                                  data: (vencimientos) => SingleChildScrollView(
                                    child: ProximosVencimientosWidget(vencimientos: vencimientos),
                                  ),
                                  loading: () => const Center(child: CircularProgressIndicator()),
                                  error: (error, _) => Center(child: Text('Error: $error')),
                                ),
                                // Accesos Rápidos Tab
                                SingleChildScrollView(child: _buildAccesosRapidos(context)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(
    BuildContext context, {
    required int index,
    required IconData icon,
    required String label,
    required Color color,
    int? count,
  }) {
    final isSelected = _selectedTabIndex == index;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Expanded(
      child: Material(
        color: isSelected
            ? color.withOpacity(isDark ? 0.2 : 0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () => setState(() => _selectedTabIndex = index),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: isSelected && !isDark ? BoxDecoration(
              border: Border.all(color: color.withOpacity(0.2)),
              borderRadius: BorderRadius.circular(16),
            ) : null,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(
                      icon,
                      size: 22,
                      color: isSelected ? color : (isDark ? Colors.white38 : Colors.black38),
                    ),
                    if (count != null && count > 0)
                      Positioned(
                        right: -6,
                        top: -6,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Color(0xFFFF1744),
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            count.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: isSelected ? FontWeight.w900 : FontWeight.w500,
                    color: isSelected ? (isDark ? Colors.white : Colors.black87) : (isDark ? Colors.white38 : Colors.black38),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, Object error) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, size: 64, color: Colors.white70),
            const SizedBox(height: 24),
            Text(
              'No pudimos cargar los datos',
              style: theme.textTheme.titleLarge?.copyWith(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              error.toString(),
              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white60),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => ref.invalidate(dashboardKPIsProvider),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppTheme.primaryBrand,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactKPIs(BuildContext context, kpis) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Salud de Cartera - High prominence
        SaludIndicator(
          titulo: 'Salud de Cartera',
          porcentaje: kpis.saludCartera,
          descripcion: kpis.saludCartera >= 80
            ? 'Tu cartera se encuentra en excelente estado.'
            : 'Se recomienda revisión de préstamos vencidos.',
        ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.1, end: 0),
        
        const SizedBox(height: 24),
        
        Text(
          'Métricas Clave',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),

        // Grid of KPIs
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.15,
          children: [
            KPICard.moneda(
              titulo: 'Cartera Total',
              valor: kpis.carteraTotal,
              icono: Icons.account_balance_wallet_rounded,
              color: const Color(0xFF64B5F6),
            ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.1, end: 0),
            
            KPICard.moneda(
              titulo: 'Intereses',
              valor: kpis.interesesGanados,
              icono: Icons.trending_up_rounded,
              color: const Color(0xFF81C784),
            ).animate().fadeIn(delay: 200.ms).slideX(begin: 0.1, end: 0),
            
            KPICard.moneda(
              titulo: 'En Cajas',
              valor: kpis.saldoTotalCajas,
              icono: Icons.savings_rounded,
              color: const Color(0xFFFFD54F),
            ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.1, end: 0),
            
            KPICard.numero(
              titulo: 'En Mora',
              valor: kpis.prestamosEnMora,
              icono: Icons.warning_rounded,
              color: const Color(0xFFFF8A65),
              subtitulo: '${kpis.tasaMorosidad.toStringAsFixed(1)}% de mora',
            ).animate().fadeIn(delay: 400.ms).slideX(begin: 0.1, end: 0),
          ],
        ),
      ],
    );
  }

  Widget _buildAccesosRapidos(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.6,
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        _AccesoRapidoCard(
          titulo: 'Clientes',
          icono: Icons.people_alt_rounded,
          color: const Color(0xFF2979FF),
          onTap: () => context.go('/clientes'),
        ),
        _AccesoRapidoCard(
          titulo: 'Préstamos',
          icono: Icons.fact_check_rounded,
          color: const Color(0xFFFFAB00),
          onTap: () => context.go('/prestamos'),
        ),
        _AccesoRapidoCard(
          titulo: 'Registrar Pago',
          icono: Icons.payments_rounded,
          color: const Color(0xFF00C853),
          onTap: () => context.go('/pagos/form'),
        ),
        _AccesoRapidoCard(
          titulo: 'Cajas',
          icono: Icons.account_balance_rounded,
          color: const Color(0xFFD500F9),
          onTap: () => context.go('/cajas'),
        ),
      ],
    );
  }
}

class _AccesoRapidoCard extends StatelessWidget {
  final String titulo;
  final IconData icono;
  final Color color;
  final VoidCallback? onTap;

  const _AccesoRapidoCard({
    required this.titulo,
    required this.icono,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? theme.cardColor : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade100,
        ),
        boxShadow: !isDark ? [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ] : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icono, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    titulo,
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
