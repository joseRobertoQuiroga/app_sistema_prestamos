import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../prestamos/domain/entities/prestamo.dart';
import '../../../prestamos/presentation/providers/prestamo_provider.dart';
import '../../../clientes/presentation/providers/cliente_provider.dart';
import '../../../pagos/presentation/providers/pago_provider.dart';
import '../widgets/selector_prestamo_widget.dart';
import '../widgets/info_card.dart';

/// Pantalla de Informe: Resumen Ejecutivo de Préstamo
class ResumenPrestamoScreen extends ConsumerStatefulWidget {
  const ResumenPrestamoScreen({super.key});

  @override
  ConsumerState<ResumenPrestamoScreen> createState() =>
      _ResumenPrestamoScreenState();
}

class _ResumenPrestamoScreenState extends ConsumerState<ResumenPrestamoScreen> {
  int? _prestamoSeleccionadoId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_prestamoSeleccionadoId == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.description,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Seleccione un préstamo',
              style: theme.textTheme.titleLarge?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _mostrarSelectorPrestamo(context),
              icon: const Icon(Icons.search),
              label: const Text('Buscar Préstamo'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final prestamosAsync = ref.watch(prestamosListProvider);
    final clientesState = ref.watch(clientesProvider);
    final pagosAsync = ref.watch(allPagosListProvider);
    // Fetch cuotas explicitly
    final cuotasAsync = ref.watch(cuotasListProvider(_prestamoSeleccionadoId!));

    return prestamosAsync.when(
      data: (prestamos) {
        final prestamo = prestamos.cast<Prestamo>().firstWhere(
          (p) => p.id == _prestamoSeleccionadoId,
          orElse: () => prestamos.first,
        );

        if (clientesState.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (clientesState.error != null) {
          return Center(child: Text('Error: ${clientesState.error}'));
        }
        
        if (clientesState.clientes.isEmpty) {
          return const Center(child: Text('No hay clientes disponibles'));
        }

        // Find cliente or use first as fallback
        final cliente = clientesState.clientes.any((c) => c.id == prestamo.clienteId)
            ? clientesState.clientes.firstWhere((c) => c.id == prestamo.clienteId)
            : clientesState.clientes.first;

        return pagosAsync.when(
          data: (todosPagos) {
            final pagosPrestamo = todosPagos
                .where((p) => p.prestamoId == _prestamoSeleccionadoId)
                .toList()
              ..sort((a, b) => b.fechaPago.compareTo(a.fechaPago));

            return cuotasAsync.when(
              data: (cuotas) {
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      // Header con selector
                      Container(
                        color: theme.colorScheme.primaryContainer,
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Resumen Ejecutivo de Préstamo',
                                    style:
                                        theme.textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    prestamo.codigo ?? 'Sin código',
                                    style: theme.textTheme.titleMedium,
                                  ),
                                ],
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: () =>
                                  _mostrarSelectorPrestamo(context),
                              icon: const Icon(Icons.swap_horiz, size: 18),
                              label: const Text('Cambiar'),
                            ),
                          ],
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Card de información del préstamo y cliente
                            _buildInfoPrincipal(prestamo, cliente, theme),
                            const SizedBox(height: 16),

                            // Resumen financiero
                            _buildResumenFinanciero(prestamo, theme),
                            const SizedBox(height: 24),

                            // Plan de Pagos (Amortización)
                            Text(
                              'Plan de Pagos',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _buildTablaAmortizacion(cuotas, theme),
                            const SizedBox(height: 24),

                            // Historial de Pagos
                            if (pagosPrestamo.isNotEmpty) ...[
                              Text(
                                'Pagos Realizados',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              _buildTablaPagos(pagosPrestamo, theme),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, __) => Center(child: Text('Error al cargar cuotas: $e')),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, __) => Center(child: Text('Error: $e')),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, __) => Center(child: Text('Error: $e')),
    );
  }

  Widget _buildInfoPrincipal(
    dynamic prestamo,
    dynamic cliente,
    ThemeData theme,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cliente',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(cliente.nombreCompleto),
                      Text('Cédula: ${cliente.cedula}',
                          style: theme.textTheme.bodySmall),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Detalles del Préstamo',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text('Código: ${prestamo.codigo ?? "N/A"}'),
                      Text(
                        'Tasa: ${prestamo.tasaInteres}% ${prestamo.tipoInteres.toString().split('.').last}',
                      ),
                      Text('Plazo: ${prestamo.plazoMeses} meses'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResumenFinanciero(dynamic prestamo, ThemeData theme) {
    final saldoPendiente = prestamo.saldoPendiente ?? 0.0;
    final porcentajePagado = prestamo.porcentajePagado ?? 0.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Resumen Financiero',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: InfoCard(
                    titulo: 'Monto Original',
                    valor: 'Bs. ${prestamo.montoOriginal.toStringAsFixed(2)}',
                    icono: Icons.monetization_on,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InfoCard(
                    titulo: 'Total a Pagar',
                    valor: 'Bs. ${prestamo.montoTotal.toStringAsFixed(2)}',
                    icono: Icons.account_balance,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InfoCard(
                    titulo: 'Pagado',
                    valor: 'Bs. ${prestamo.montoPagado.toStringAsFixed(2)}',
                    icono: Icons.check_circle,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InfoCard(
                    titulo: 'Saldo Pendiente',
                    valor: 'Bs. ${saldoPendiente.toStringAsFixed(2)}',
                    icono: Icons.pending,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Progreso de Pago',
                      style: theme.textTheme.titleMedium,
                    ),
                    Text(
                      '${porcentajePagado.toStringAsFixed(1)}%',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: porcentajePagado / 100,
                    backgroundColor: Colors.grey[300],
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                    minHeight: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTablaAmortizacion(List<dynamic> cuotas, ThemeData theme) {

    return Card(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: MaterialStateProperty.all(
            theme.colorScheme.primaryContainer,
          ),
          columns: const [
            DataColumn(label: Text('#', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Vencimiento', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Monto', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Capital', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Interés', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Saldo', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Estado', style: TextStyle(fontWeight: FontWeight.bold))),
          ],
          rows: cuotas.asMap().entries.map<DataRow>((entry) {
            final index = entry.key;
            final cuota = entry.value;
            
            Color estadoColor = Colors.grey;
            String estado = 'Pendiente';
            
            if (cuota.pagada) {
              estadoColor = Colors.green;
              estado = 'Pagada';
            } else if (cuota.vencida) {
              estadoColor = Colors.red;
              estado = 'Vencida';
            }

            return DataRow(
              cells: [
                DataCell(Text('${index + 1}')),
                DataCell(Text('${cuota.fechaVencimiento.day}/${cuota.fechaVencimiento.month}/${cuota.fechaVencimiento.year}')),
                DataCell(Text('\$${cuota.montoCuota.toStringAsFixed(2)}')),
                DataCell(Text('\$${cuota.capital.toStringAsFixed(2)}')),
                DataCell(Text('\$${cuota.interes.toStringAsFixed(2)}')),
                DataCell(Text('\$${cuota.saldoPendiente.toStringAsFixed(2)}')),
                DataCell(
                  Chip(
                    label: Text(estado, style: const TextStyle(fontSize: 11)),
                    backgroundColor: estadoColor.withOpacity(0.2),
                    labelPadding: const EdgeInsets.symmetric(horizontal: 4),
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildTablaPagos(List<dynamic> pagos, ThemeData theme) {
    return Card(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: MaterialStateProperty.all(
            theme.colorScheme.primaryContainer,
          ),
          columns: const [
            DataColumn(label: Text('Fecha', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Monto', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Capital', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Interés', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Mora', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Método', style: TextStyle(fontWeight: FontWeight.bold))),
          ],
          rows: pagos.map((pago) {
            return DataRow(cells: [
              DataCell(Text(
                  '${pago.fechaPago.day}/${pago.fechaPago.month}/${pago.fechaPago.year}')),
              DataCell(Text('\$${pago.montoTotal.toStringAsFixed(2)}')),
              DataCell(Text('\$${pago.montoCapital.toStringAsFixed(2)}')),
              DataCell(Text('\$${pago.montoInteres.toStringAsFixed(2)}')),
              DataCell(Text(
                '\$${pago.montoMora.toStringAsFixed(2)}',
                style: TextStyle(
                  color: pago.montoMora > 0 ? Colors.red : null,
                ),
              )),
              DataCell(Text(pago.metodoPago)),
            ]);
          }).toList(),
        ),
      ),
    );
  }

  void _mostrarSelectorPrestamo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => SelectorPrestamoWidget(
        onPrestamoSeleccionado: (prestamoId) {
          setState(() {
            _prestamoSeleccionadoId = prestamoId;
          });
          Navigator.pop(context);
        },
      ),
    );
  }
}
