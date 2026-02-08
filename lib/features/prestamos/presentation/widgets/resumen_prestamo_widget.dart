import 'package:flutter/material.dart';
import '../../domain/entities/prestamo.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../config/theme/app_theme.dart';

class ResumenPrestamoWidget extends StatelessWidget {
  final Prestamo prestamo;
  final int cuotasPagadas;
  final int cuotasPendientes;
  final int cuotasVencidas;

  const ResumenPrestamoWidget({
    super.key,
    required this.prestamo,
    required this.cuotasPagadas,
    required this.cuotasPendientes,
    required this.cuotasVencidas,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título
            Text(
              'Resumen del Préstamo',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),

            // Información básica
            _buildInfoSection(context, 'Información General', [
              _InfoItem(
                icon: Icons.code,
                label: 'Código',
                value: prestamo.codigo,
              ),
              _InfoItem(
                icon: Icons.person,
                label: 'Cliente',
                value: prestamo.nombreCliente ?? 'N/A',
              ),
              _InfoItem(
                icon: Icons.account_balance_wallet,
                label: 'Caja',
                value: prestamo.nombreCaja ?? 'N/A',
              ),
              _InfoItem(
                icon: Icons.calendar_today,
                label: 'Fecha Inicio',
                value: Formatters.formatDate(prestamo.fechaInicio),
              ),
              _InfoItem(
                icon: Icons.event,
                label: 'Fecha Vencimiento',
                value: Formatters.formatDate(prestamo.fechaVencimiento),
              ),
            ]),

            const Divider(height: 32),

            // Montos
            _buildInfoSection(context, 'Montos', [
              _InfoItem(
                icon: Icons.attach_money,
                label: 'Monto Original',
                value: Formatters.formatCurrency(prestamo.montoOriginal),
                valueColor: Colors.blue,
              ),
              _InfoItem(
                icon: Icons.trending_up,
                label: 'Monto Total (con intereses)',
                value: Formatters.formatCurrency(prestamo.montoTotal),
                valueColor: Colors.orange,
              ),
              _InfoItem(
                icon: Icons.check_circle,
                label: 'Monto Pagado',
                value: Formatters.formatCurrency(prestamo.montoPagado),
                valueColor: Colors.green,
              ),
              _InfoItem(
                icon: Icons.pending,
                label: 'Saldo Pendiente',
                value: Formatters.formatCurrency(prestamo.saldoPendiente),
                valueColor: prestamo.saldoPendiente > 0 ? Colors.red : Colors.green,
              ),
            ]),

            const Divider(height: 32),

            // Términos
            _buildInfoSection(context, 'Términos del Préstamo', [
              _InfoItem(
                icon: Icons.percent,
                label: 'Tasa de Interés',
                value: Formatters.formatPercentage(prestamo.tasaInteres),
              ),
              _InfoItem(
                icon: Icons.category,
                label: 'Tipo de Interés',
                value: prestamo.tipoInteres.displayName,
              ),
              _InfoItem(
                icon: Icons.access_time,
                label: 'Plazo',
                value: Formatters.formatDuration(prestamo.plazoMeses),
              ),
              _InfoItem(
                icon: Icons.payment,
                label: 'Cuota Mensual',
                value: Formatters.formatCurrency(prestamo.cuotaMensual),
                valueColor: Theme.of(context).primaryColor,
              ),
            ]),

            const Divider(height: 32),

            // Estado y progreso
            _buildEstadoSection(context),

            const SizedBox(height: 16),

            // Cuotas
            _buildCuotasSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(
    BuildContext context,
    String title,
    List<_InfoItem> items,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 12),
        ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Icon(item.icon, size: 20, color: Colors.grey[600]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item.label,
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ),
                  Text(
                    item.value,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: item.valueColor,
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  Widget _buildEstadoSection(BuildContext context) {
    final color = AppTheme.getEstadoColor(prestamo.estado.toStorageString());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Estado y Progreso',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: color),
                ),
                child: Center(
                  child: Text(
                    prestamo.estado.displayName,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Progreso de Pago'),
            Text(
              '${prestamo.porcentajePagado.toStringAsFixed(1)}%',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: prestamo.porcentajePagado / 100,
            minHeight: 12,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(
              _getProgressColor(prestamo.porcentajePagado),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCuotasSection(BuildContext context) {
    final totalCuotas = cuotasPagadas + cuotasPendientes;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Estado de Cuotas',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildCuotaCard(
                context,
                'Pagadas',
                cuotasPagadas,
                totalCuotas,
                Colors.green,
                Icons.check_circle,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildCuotaCard(
                context,
                'Pendientes',
                cuotasPendientes,
                totalCuotas,
                Colors.orange,
                Icons.pending,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildCuotaCard(
                context,
                'Vencidas',
                cuotasVencidas,
                totalCuotas,
                Colors.red,
                Icons.warning,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCuotaCard(
    BuildContext context,
    String label,
    int count,
    int total,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[700],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Color _getProgressColor(double progress) {
    if (progress >= 75) return Colors.green;
    if (progress >= 50) return Colors.blue;
    if (progress >= 25) return Colors.orange;
    return Colors.red;
  }
}

class _InfoItem {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });
}