import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/kpi_card.dart';
import '../widgets/alertas_widget.dart';
import '../widgets/proximos_vencimientos_widget.dart';
import '../../../../shared/presentation/widgets/app_drawer.dart';

/// Pantalla principal del Dashboard
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kpisAsync = ref.watch(dashboardKPIsProvider);
    final alertasAsync = ref.watch(dashboardAlertasProvider);
    final vencimientosAsync = ref.watch(proximosVencimientosProvider(30));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),

        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
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
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(dashboardKPIsProvider);
          ref.invalidate(dashboardAlertasProvider);
          ref.invalidate(proximosVencimientosProvider);
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // KPIs Principales
              kpisAsync.when(
                data: (kpis) => _buildKPIs(context, kpis),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Center(
                  child: Text('Error al cargar KPIs: $error'),
                ),
              ),

              const SizedBox(height: 24),

              // Alertas
              Text(
                'Alertas',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              alertasAsync.when(
                data: (alertas) => AlertasWidget(alertas: alertas),
                loading: () => const Card(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ),
                error: (error, _) => Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text('Error: $error'),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Próximos Vencimientos
              Text(
                'Próximos 30 Días',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              vencimientosAsync.when(
                data: (vencimientos) => ProximosVencimientosWidget(
                  vencimientos: vencimientos,
                ),
                loading: () => const Card(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ),
                error: (error, _) => Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text('Error: $error'),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Accesos rápidos
              _buildAccesosRapidos(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKPIs(BuildContext context, kpis) {
    return Column(
      children: [
        // Fila 1: Cartera
        Row(
          children: [
            Expanded(
              child: KPICard.moneda(
                titulo: 'Cartera Total',
                valor: kpis.carteraTotal,
                icono: Icons.account_balance_wallet,
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: KPICard.moneda(
                titulo: 'Por Cobrar',
                valor: kpis.capitalPorCobrar,
                icono: Icons.pending_actions,
                color: Colors.orange,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Fila 2: Ingresos
        Row(
          children: [
            Expanded(
              child: KPICard.moneda(
                titulo: 'Intereses Ganados',
                valor: kpis.interesesGanados,
                icono: Icons.trending_up,
                color: Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: KPICard.moneda(
                titulo: 'Saldo en Cajas',
                valor: kpis.saldoTotalCajas,
                icono: Icons.account_balance,
                color: Colors.purple,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Fila 3: Préstamos
        Row(
          children: [
            Expanded(
              child: KPICard.numero(
                titulo: 'Préstamos Activos',
                valor: kpis.prestamosActivos,
                icono: Icons.description,
                color: Colors.blue,
                subtitulo: 'de ${kpis.totalPrestamos} totales',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: KPICard.numero(
                titulo: 'En Mora',
                valor: kpis.prestamosEnMora,
                icono: Icons.warning_amber,
                color: Colors.red,
                subtitulo: '${kpis.tasaMorosidad.toStringAsFixed(1)}% morosidad',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Salud de cartera
        SaludIndicator(
          titulo: 'Salud de Cartera',
          porcentaje: kpis.saludCartera,
          descripcion: kpis.saludCartera >= 80
              ? 'Excelente estado'
              : kpis.saludCartera >= 60
                  ? 'Requiere atención'
                  : 'Estado crítico',
        ),
      ],
    );
  }

  Widget _buildAccesosRapidos(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Accesos Rápidos',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          children: [
            _AccesoRapidoCard(
              titulo: 'Clientes',
              icono: Icons.people,
              color: Colors.blue,
              onTap: () {
                // TODO: Navegar a clientes
              },
            ),
            _AccesoRapidoCard(
              titulo: 'Préstamos',
              icono: Icons.description,
              color: Colors.green,
              onTap: () {
                // TODO: Navegar a préstamos
              },
            ),
            _AccesoRapidoCard(
              titulo: 'Registrar Pago',
              icono: Icons.payment,
              color: Colors.orange,
              onTap: () {
                // TODO: Navegar a registrar pago
              },
            ),
            _AccesoRapidoCard(
              titulo: 'Cajas',
              icono: Icons.account_balance_wallet,
              color: Colors.purple,
              onTap: () {
                // TODO: Navegar a cajas
              },
            ),
          ],
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
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icono,
                size: 32,
                color: color,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              titulo,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}