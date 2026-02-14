import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../clientes/presentation/providers/cliente_provider.dart';
import '../../../prestamos/presentation/providers/prestamo_provider.dart';
import '../../../prestamos/domain/entities/prestamo.dart';
import '../../../pagos/presentation/providers/pago_provider.dart';
import '../widgets/selector_cliente_widget.dart';
import '../widgets/info_card.dart';
import '../widgets/detalle_credito_widget.dart';

/// Pantalla de Informe: Historial por Cliente
class HistorialClienteScreen extends ConsumerStatefulWidget {
  const HistorialClienteScreen({super.key});

  @override
  ConsumerState<HistorialClienteScreen> createState() =>
      _HistorialClienteScreenState();
}

class _HistorialClienteScreenState
    extends ConsumerState<HistorialClienteScreen> {
  int? _clienteSeleccionadoId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_clienteSeleccionadoId == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_search,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Seleccione un cliente',
              style: theme.textTheme.titleLarge?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _mostrarSelectorCliente(context),
              icon: const Icon(Icons.search),
              label: const Text('Buscar Cliente'),
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

    final clientesState = ref.watch(clientesProvider);
    final prestamosAsync = ref.watch(prestamosListProvider);
    final pagosAsync = ref.watch(allPagosListProvider);

    // Check clientes state
    if (clientesState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (clientesState.error != null) {
      return Center(child: Text('Error: ${clientesState.error}'));
    }

    final cliente = clientesState.clientes.firstWhere(
      (c) => c.id == _clienteSeleccionadoId,
      orElse: () => clientesState.clientes.first,
    );

    return prestamosAsync.when(
      data: (todosLosPrestamos) {
        final prestamosCliente = todosLosPrestamos
            .where((p) => p.clienteId == _clienteSeleccionadoId)
            .toList();

        final prestamosActivos = prestamosCliente
            .where((p) => p.estado != EstadoPrestamo.pagado)
            .toList();
        final prestamosPagados = prestamosCliente
            .where((p) => p.estado == EstadoPrestamo.pagado)
            .toList();

        return pagosAsync.when(
          data: (todosPagos) {
            final pagosCliente = todosPagos
                .where((pago) =>
                    prestamosCliente.any((p) => p.id == pago.prestamoId))
                .toList()
              ..sort((a, b) => b.fechaPago.compareTo(a.fechaPago));

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
                                'Historial de Cliente',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                cliente.nombreCompleto,
                                style: theme.textTheme.titleMedium,
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () => _mostrarSelectorCliente(context),
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
                        // Información básica del cliente
                        _buildInfoBasica(cliente, theme),
                        const SizedBox(height: 24),

                        // Resumen general
                        _buildResumenGeneral(
                          prestamosActivos.length,
                          prestamosPagados.length,
                          prestamosCliente,
                          theme,
                        ),
                        const SizedBox(height: 24),

                        // Créditos Activos
                        if (prestamosActivos.isNotEmpty) ...[
                          Text(
                            'Créditos Activos',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ...prestamosActivos.map(
                            (prestamo) => DetalleCreditoWidget(
                              prestamo: prestamo,
                              esActivo: true,
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],

                        // Créditos Pagados
                        if (prestamosPagados.isNotEmpty) ...[
                          Text(
                            'Créditos Pagados',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ...prestamosPagados.map(
                            (prestamo) => DetalleCreditoWidget(
                              prestamo: prestamo,
                              esActivo: false,
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],

                        // Historial de Pagos
                        if (pagosCliente.isNotEmpty) ...[
                          Text(
                            'Historial de Pagos',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildTablaPagos(
                              pagosCliente, prestamosCliente, theme),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
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

  Widget _buildInfoBasica(dynamic cliente, ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Información del Cliente',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            _buildInfoRow('Cédula:', cliente.cedula, theme),
            _buildInfoRow('Teléfono:', cliente.telefono ?? 'N/A', theme),
            _buildInfoRow('Dirección:', cliente.direccion ?? 'N/A', theme),
            if (cliente.email != null && cliente.email!.isNotEmpty)
              _buildInfoRow('Email:', cliente.email!, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String valor, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              valor,
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResumenGeneral(
    int activos,
    int pagados,
    List<dynamic> todosLosPrestamos,
    ThemeData theme,
  ) {
    final totalPrestado = todosLosPrestamos.fold<double>(
      0,
      (sum, p) => sum + p.montoOriginal,
    );
    final totalPagado = todosLosPrestamos.fold<double>(
      0,
      (sum, p) => sum + p.montoPagado,
    );

    return Row(
      children: [
        Expanded(
          child: InfoCard(
            titulo: 'Activos',
            valor: '$activos',
            icono: Icons.account_balance_wallet,
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: InfoCard(
            titulo: 'Pagados',
            valor: '$pagados',
            icono: Icons.check_circle,
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: InfoCard(
            titulo: 'Total Prestado',
            valor: 'Bs. ${totalPrestado.toStringAsFixed(2)}',
            icono: Icons.monetization_on,
            color: Colors.orange,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: InfoCard(
            titulo: 'Total Pagado',
            valor: 'Bs. ${totalPagado.toStringAsFixed(2)}',
            icono: Icons.payment,
            color: Colors.purple,
          ),
        ),
      ],
    );
  }

  Widget _buildTablaPagos(
    List<dynamic> pagos,
    List<dynamic> prestamos,
    ThemeData theme,
  ) {
    final totalMonto = pagos.fold<double>(0, (sum, p) => sum + p.montoTotal);
    final totalCapital = pagos.fold<double>(0, (sum, p) => sum + p.montoCapital);
    final totalInteres = pagos.fold<double>(0, (sum, p) => sum + p.montoInteres);
    final totalMora = pagos.fold<double>(0, (sum, p) => sum + p.montoMora);

    return Card(
      child: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: MaterialStateProperty.all(
                theme.colorScheme.primaryContainer,
              ),
              columns: const [
                DataColumn(
                    label: Text('Fecha',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(
                    label: Text('Préstamo',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(
                    label: Text('Monto',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(
                    label: Text('Capital',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(
                    label: Text('Interés',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(
                    label: Text('Mora',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(
                    label: Text('Método',
                        style: TextStyle(fontWeight: FontWeight.bold))),
              ],
              rows: [
                ...pagos.take(50).map((pago) {
                  final prestamo = prestamos.firstWhere(
                    (p) => p.id == pago.prestamoId,
                    orElse: () => null,
                  );
                  return DataRow(cells: [
                    DataCell(Text(
                        '${pago.fechaPago.day}/${pago.fechaPago.month}/${pago.fechaPago.year}')),
                    DataCell(Text(prestamo?.codigo ?? 'N/A')),
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
                // Fila de totales
                DataRow(
                  color: MaterialStateProperty.all(Colors.grey[200]),
                  cells: [
                    const DataCell(Text('TOTALES',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                    const DataCell(Text('')),
                    DataCell(Text('\$${totalMonto.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.bold))),
                    DataCell(Text('\$${totalCapital.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.bold))),
                    DataCell(Text('\$${totalInteres.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.bold))),
                    DataCell(Text('\$${totalMora.toStringAsFixed(2)}',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.red))),
                    const DataCell(Text('')),
                  ],
                ),
              ],
            ),
          ),
          if (pagos.length > 50)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Mostrando 50 de ${pagos.length} pagos',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _mostrarSelectorCliente(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => SelectorClienteWidget(
        onClienteSeleccionado: (clienteId) {
          setState(() {
            _clienteSeleccionadoId = clienteId;
          });
          Navigator.pop(context);
        },
      ),
    );
  }
}
