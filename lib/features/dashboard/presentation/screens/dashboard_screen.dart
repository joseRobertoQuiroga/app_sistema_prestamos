import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui'; // Import dart:ui for ImageFilter
import 'package:glass_kit/glass_kit.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/dashboard_floating_panel.dart'; // Reusing for the right panel content structure, but might refactor use
import '../../../../presentation/widgets/app_drawer.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/dashboard_entities.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final kpisAsync = ref.watch(dashboardKPIsProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    
    // Determine if we are on a "desktop" sized screen where we can enforce no-scroll
    final isDesktop = size.width > 1000;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Panel de Control',
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
          // 1. Fondo Gradiente fijo
          Container(
            decoration: const BoxDecoration(
              gradient: AppTheme.primaryGradient,
            ),
          ),
          
          // 2. Contenido Principal
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: kpisAsync.when(
                data: (kpis) => isDesktop 
                  ? _buildDesktopLayout(context, kpis, theme, isDark)
                  : _buildMobileLayout(context, kpis, theme, isDark),
                loading: () => const Center(child: CircularProgressIndicator(color: Colors.white)),
                error: (error, _) => Center(child: Text('Error: $error', style: const TextStyle(color: Colors.white))),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- DESKTOP LAYOUT (NO SCROLL) ---
  Widget _buildDesktopLayout(BuildContext context, DashboardKPIs kpis, ThemeData theme, bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // COLUMNA IZQUIERDA (Métricas y Acciones) - 70%
        Expanded(
          flex: 7,
          child: Column(
            children: [
              // Fila 1: KPIs Financieros Principales (Cartera, Ganancias, Cajas)
              Expanded(
                flex: 4, // More space for the big numbers
                child: Row(
                  children: [
                    Expanded(child: _buildKpiCard(
                      context, 
                      'Cartera Total', 
                      '${kpis.carteraTotal.toStringAsFixed(2)} Bs', 
                      'Salud: ${kpis.saludCartera.toStringAsFixed(0)}%', 
                      Icons.account_balance_wallet_rounded, 
                      Colors.blue,
                      theme, isDark
                    )),
                    const SizedBox(width: 16),
                    Expanded(child: _buildKpiCard(
                      context, 
                      'Intereses Ganados', 
                      '${kpis.interesesGanados.toStringAsFixed(2)} Bs', 
                      '+${kpis.moraCobrada.toStringAsFixed(2)} Bs Mora', 
                      Icons.trending_up_rounded, 
                      Colors.green,
                      theme, isDark
                    )),
                    const SizedBox(width: 16),
                    Expanded(child: _buildKpiCard(
                      context, 
                      'Saldo en Cajas', 
                      '${kpis.saldoTotalCajas.toStringAsFixed(2)} Bs', 
                      'Mensual: ${kpis.balanceMensual.toStringAsFixed(2)}', 
                      Icons.savings_rounded, 
                      Colors.orange,
                      theme, isDark
                    )),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // Fila 2: Estadísticas Operativas (Clientes, Préstamos)
              Expanded(
                flex: 3,
                child: Row(
                  children: [
                    Expanded(child: _buildStatCard(
                      context, 
                      'Clientes', 
                      kpis.totalClientes.toString(), 
                      '${kpis.clientesActivos} Activos', 
                      Icons.people_alt_rounded, 
                      Colors.purple,
                      theme, isDark
                    )),
                    const SizedBox(width: 16),
                    Expanded(child: _buildStatCard(
                      context, 
                      'Préstamos Activos', 
                      kpis.prestamosActivos.toString(), 
                      '${kpis.porcentajePrestamosActivos.toStringAsFixed(1)}% del total', 
                      Icons.description_rounded, 
                      Colors.indigo,
                      theme, isDark
                    )),
                    const SizedBox(width: 16),
                    Expanded(child: _buildStatCard(
                      context, 
                      'En Mora', 
                      kpis.prestamosEnMora.toString(), 
                      '${kpis.tasaMorosidad.toStringAsFixed(1)}% Tasa', 
                      Icons.warning_amber_rounded, 
                      Colors.red,
                      theme, isDark
                    )),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // Fila 3: Accesos Rápidos (Barra inferior)
              SizedBox(
                height: 80,
                child: _buildQuickActionsBar(context, theme, isDark),
              ),
            ],
          ),
        ),
        
        const SizedBox(width: 16),
        
        // COLUMNA DERECHA (Notificaciones y Calendario) - 30%
        Expanded(
          flex: 3,
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? theme.cardColor.withOpacity(0.5) : Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: const DashboardFloatingPanel(), // Reuse existing widget but constrained
              ),
            ),
          ),
        ),
      ],
    );
  }

  // --- MOBILE LAYOUT (SCROLLABLE) ---
  Widget _buildMobileLayout(BuildContext context, DashboardKPIs kpis, ThemeData theme, bool isDark) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildKpiCard(context, 'Cartera Total', '${kpis.carteraTotal.toStringAsFixed(2)} Bs', 'Salud: ${kpis.saludCartera.toStringAsFixed(0)}%', Icons.account_balance_wallet_rounded, Colors.blue, theme, isDark),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildKpiCard(context, 'Intereses', '${kpis.interesesGanados.toStringAsFixed(0)}', '+Mora', Icons.trending_up_rounded, Colors.green, theme, isDark)),
              const SizedBox(width: 12),
              Expanded(child: _buildKpiCard(context, 'Cajas', '${kpis.saldoTotalCajas.toStringAsFixed(0)}', 'Disponible', Icons.savings_rounded, Colors.orange, theme, isDark)),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 100,
            child: Row(
              children: [
                Expanded(child: _buildStatCard(context, 'Clientes', kpis.totalClientes.toString(), 'Total', Icons.people, Colors.purple, theme, isDark)),
                const SizedBox(width: 8),
                Expanded(child: _buildStatCard(context, 'Mora', kpis.prestamosEnMora.toString(), 'Préstamos', Icons.warning, Colors.red, theme, isDark)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const SizedBox(height: 500, child: DashboardFloatingPanel()), // Fixed height for panel in mobile
        ],
      ),
    );
  }

  // --- WIDGETS ---
  
  Widget _buildKpiCard(BuildContext context, String title, String value, String subtitle, IconData icon, Color color, ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? theme.cardColor.withOpacity(0.8) : Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const Spacer(),
          Text(value, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, fontSize: 24)),
          const SizedBox(height: 4),
          Text(title, style: theme.textTheme.bodyMedium?.copyWith(color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7))),
          const SizedBox(height: 4),
          Text(subtitle, style: theme.textTheme.labelSmall?.copyWith(color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    ).animate().fadeIn().scale();
  }

  Widget _buildStatCard(BuildContext context, String title, String value, String subtitle, IconData icon, Color color, ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? theme.cardColor.withOpacity(0.6) : Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.1),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(value, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                Text(title, style: theme.textTheme.labelMedium),
                Text(subtitle, style: theme.textTheme.labelSmall?.copyWith(color: color)),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms);
  }

  Widget _buildQuickActionsBar(BuildContext context, ThemeData theme, bool isDark) {
    // Lista de acciones rápidas
    final actions = [
      {'icon': Icons.add_circle_rounded, 'label': 'Nuevo Préstamo', 'route': '/prestamos/form', 'color': Colors.blue},
      {'icon': Icons.payments_rounded, 'label': 'Ver Pagos', 'route': '/pagos', 'color': Colors.green},
      {'icon': Icons.person_add_rounded, 'label': 'Nuevo Cliente', 'route': '/clientes/form', 'color': Colors.purple},
      {'icon': Icons.list_alt_rounded, 'label': 'Movimientos', 'route': '/movimientos', 'color': Colors.orange},
    ];

    return Row(
      children: actions.map((action) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Material(
              color: isDark ? theme.cardColor : Colors.white,
              borderRadius: BorderRadius.circular(16),
              elevation: 2,
              shadowColor: Colors.black12,
              child: InkWell(
                onTap: () {
                  context.push(action['route'] as String);
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(action['icon'] as IconData, color: action['color'] as Color),
                      const SizedBox(width: 8),
                      Text(
                        action['label'] as String,
                        style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    ).animate().slideY(begin: 1.0, end: 0.0);
  }
}
