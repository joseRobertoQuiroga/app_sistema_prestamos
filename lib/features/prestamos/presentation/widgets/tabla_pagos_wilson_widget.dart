import 'package:flutter/material.dart';
import '../../../../core/utils/formatters.dart';

/// Tabla de Pagos Wilson — Vista previa de proyección mensual
/// 
/// Muestra para cada mes: fecha, interés por cobrar, cuota estimada,
/// pago realizado, mora y estado.
/// Esta tabla se muestra ANTES de la tabla de amortización/historial.
class TablaPagosWilsonWidget extends StatelessWidget {
  final double montoOriginal;
  final double saldoPendiente;
  final double tasaInteres; // Tasa mensual directa (ej: 5)
  final int plazoMeses;
  final DateTime fechaInicio;
  final List<Map<String, dynamic>> pagosRealizados; // Historial de pagos

  const TablaPagosWilsonWidget({
    super.key,
    required this.montoOriginal,
    required this.saldoPendiente,
    required this.tasaInteres,
    required this.plazoMeses,
    required this.fechaInicio,
    this.pagosRealizados = const [],
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filas = _generarFilasProyeccion();

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withOpacity(0.3),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.table_chart_outlined,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'TABLA DE PAGOS',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'WILSON',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Tabla
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columnSpacing: 16,
              headingRowHeight: 36,
              dataRowMinHeight: 32,
              dataRowMaxHeight: 40,
              headingTextStyle: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              columns: const [
                DataColumn(label: Text('#')),
                DataColumn(label: Text('Fecha')),
                DataColumn(label: Text('Interés'), numeric: true),
                DataColumn(label: Text('Cuota Est.'), numeric: true),
                DataColumn(label: Text('Pago'), numeric: true),
                DataColumn(label: Text('Mora'), numeric: true),
                DataColumn(label: Text('Estado')),
              ],
              rows: filas.asMap().entries.map((entry) {
                final i = entry.key;
                final fila = entry.value;
                return DataRow(
                  color: WidgetStateProperty.resolveWith<Color?>(
                    (states) => i.isEven
                        ? theme.colorScheme.surfaceContainerHighest.withOpacity(0.3)
                        : null,
                  ),
                  cells: [
                    DataCell(Text('${fila['numero']}')),
                    DataCell(Text(fila['fecha'])),
                    DataCell(Text(Formatters.formatCurrency(fila['interes']))),
                    DataCell(Text(Formatters.formatCurrency(fila['cuotaEstimada']))),
                    DataCell(Text(
                      fila['pago'] > 0 
                          ? Formatters.formatCurrency(fila['pago']) 
                          : '-',
                      style: TextStyle(
                        color: fila['pago'] > 0 
                            ? Colors.green.shade700 
                            : null,
                        fontWeight: fila['pago'] > 0 
                            ? FontWeight.bold 
                            : null,
                      ),
                    )),
                    DataCell(Text(
                      fila['mora'] > 0 
                          ? Formatters.formatCurrency(fila['mora'])
                          : '-',
                      style: TextStyle(
                        color: fila['mora'] > 0 
                            ? Colors.red.shade700 
                            : null,
                      ),
                    )),
                    DataCell(_buildEstadoChip(context, fila['estado'])),
                  ],
                );
              }).toList(),
            ),
          ),

          // Info resumen
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 14, color: theme.colorScheme.outline),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'Interés Wilson: ${tasaInteres.toStringAsFixed(1)}% mensual sobre saldo actual. '
                    'Cuota estimada = interés + (capital ÷ plazo).',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
                      fontStyle: FontStyle.italic,
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

  Widget _buildEstadoChip(BuildContext context, String estado) {
    Color color;
    IconData icon;

    switch (estado) {
      case 'PAGADO':
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      case 'PENDIENTE':
        color = Colors.orange;
        icon = Icons.schedule;
        break;
      case 'MORA':
        color = Colors.red;
        icon = Icons.warning;
        break;
      case 'FUTURO':
        color = Colors.grey;
        icon = Icons.access_time;
        break;
      default:
        color = Colors.grey;
        icon = Icons.help_outline;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 2),
        Text(
          estado,
          style: TextStyle(
            fontSize: 11,
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  /// Genera las filas de proyección mensual
  List<Map<String, dynamic>> _generarFilasProyeccion() {
    final filas = <Map<String, dynamic>>[];
    final tasaMensual = tasaInteres / 100;
    double saldo = montoOriginal;
    final hoy = DateTime.now();

    // Crear un mapa de pagos por mes para buscar rápido
    final pagosPorMes = <String, double>{};
    final moraPorMes = <String, double>{};
    for (final pago in pagosRealizados) {
      final fechaPago = pago['fechaPago'] as DateTime;
      final key = '${fechaPago.year}-${fechaPago.month}';
      pagosPorMes[key] = (pagosPorMes[key] ?? 0) + (pago['montoPago'] as double);
      moraPorMes[key] = (moraPorMes[key] ?? 0) + ((pago['montoMora'] as double?) ?? 0);
    }

    // Recalcular saldo real basado en pagos a capital
    double saldoReal = saldoPendiente;
    
    for (int i = 0; i < plazoMeses; i++) {
      final fechaCuota = DateTime(
        fechaInicio.year + ((fechaInicio.month + i) ~/ 12),
        ((fechaInicio.month + i - 1) % 12) + 1,
        fechaInicio.day,
      );

      final mesKey = '${fechaCuota.year}-${fechaCuota.month}';
      final pagoMes = pagosPorMes[mesKey] ?? 0;
      final moraMes = moraPorMes[mesKey] ?? 0;

      // Para meses pasados con pagos, usar saldo real decreciente
      // Para meses futuros, proyectar desde saldo actual
      final saldoParaCalculo = fechaCuota.isBefore(hoy) || i == 0
          ? (i == 0 ? montoOriginal : saldo)
          : saldoReal;

      final interesMes = saldoParaCalculo * tasaMensual;
      final capitalMes = saldoParaCalculo / (plazoMeses - i > 0 ? plazoMeses - i : 1);
      final cuotaEstimada = interesMes + capitalMes;

      String estado;
      if (pagoMes > 0) {
        estado = 'PAGADO';
        // Reducir saldo para siguiente iteración
        final capitalPagado = pagoMes - moraMes - interesMes;
        if (capitalPagado > 0) saldo = saldo - capitalPagado;
      } else if (fechaCuota.isBefore(hoy)) {
        estado = 'MORA';
      } else if (fechaCuota.month == hoy.month && fechaCuota.year == hoy.year) {
        estado = 'PENDIENTE';
      } else {
        estado = 'FUTURO';
      }

      filas.add({
        'numero': i + 1,
        'fecha': Formatters.formatDate(fechaCuota),
        'interes': interesMes,
        'cuotaEstimada': cuotaEstimada,
        'pago': pagoMes,
        'mora': moraMes,
        'estado': estado,
      });

      // Actualizar saldo para proyección futura
      if (estado != 'PAGADO' && saldo > 0) {
        saldoReal = saldo;
      }
    }

    return filas;
  }
}
