import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../prestamos/presentation/providers/prestamo_provider.dart';
import '../../../prestamos/domain/entities/prestamo.dart';
import '../../../clientes/presentation/providers/cliente_provider.dart';

/// Widget de diálogo para seleccionar un préstamo
class SelectorPrestamoWidget extends ConsumerStatefulWidget {
  final void Function(int prestamoId) onPrestamoSeleccionado;

  const SelectorPrestamoWidget({
    super.key,
    required this.onPrestamoSeleccionado,
  });

  @override
  ConsumerState<SelectorPrestamoWidget> createState() =>
      _SelectorPrestamoWidgetState();
}

class _SelectorPrestamoWidgetState
    extends ConsumerState<SelectorPrestamoWidget> {
  String _filtro = '';

  @override
  Widget build(BuildContext context) {
    final prestamosAsync = ref.watch(prestamosListProvider);
    final clientesState = ref.watch(clientesProvider);
    final theme = Theme.of(context);

    return Dialog(
      child: Container(
        width: 600,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Seleccionar Préstamo',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Buscar por código, cliente o cédula',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _filtro = value.toLowerCase();
                });
              },
            ),
            const SizedBox(height: 16),
            Flexible(
              child: prestamosAsync.when(
                data: (prestamos) {
                  if (clientesState.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  
                  final clientes = clientesState.clientes;
                  
                  final prestamosCompletos = prestamos.map((prestamo) {
                    final cliente = clientes.any((c) => c.id == prestamo.clienteId)
                        ? clientes.firstWhere((c) => c.id == prestamo.clienteId)
                        : null;
                    return {
                      'prestamo': prestamo,
                      'cliente': cliente,
                    };
                  }).toList();

                  final prestamosFiltrados = prestamosCompletos.where((item) {
                    if (_filtro.isEmpty) return true;
                    final prestamo = item['prestamo'] as dynamic;
                    final cliente = item['cliente'] as dynamic;
                    if (cliente == null) return false;
                    return (prestamo.codigo ?? '')
                            .toLowerCase()
                            .contains(_filtro) ||
                        cliente.nombreCompleto.toLowerCase().contains(_filtro) ||
                        cliente.cedula.toLowerCase().contains(_filtro);
                  }).toList();

                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: prestamosFiltrados.length,
                    itemBuilder: (context, index) {
                      final item = prestamosFiltrados[index];
                      final prestamo = item['prestamo'] as dynamic;
                      final cliente = item['cliente'] as dynamic;

                      Color estadoColor = Colors.grey;
                      String estado = 'Activo';

                      if (prestamo.estado == EstadoPrestamo.pagado) {
                        estadoColor = Colors.green;
                        estado = 'Pagado';
                      } else if (prestamo.estado == EstadoPrestamo.mora) {
                        estadoColor = Colors.red;
                        estado = 'En Mora';
                      } else if (prestamo.estado == EstadoPrestamo.activo) {
                        estadoColor = Colors.blue;
                        estado = 'Activo';
                      }

                      return ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: estadoColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.account_balance_wallet,
                            color: estadoColor,
                          ),
                        ),
                        title: Text(
                          prestamo.codigo ?? 'Sin código',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (cliente != null) Text(cliente.nombreCompleto),
                            Text(
                                'Bs. ${prestamo.montoOriginal.toStringAsFixed(2)} - $estado'),
                          ],
                        ),
                        isThreeLine: true,
                        onTap: () {
                          widget.onPrestamoSeleccionado(prestamo.id!);
                        },
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, __) => Center(child: Text('Error: $e')),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
