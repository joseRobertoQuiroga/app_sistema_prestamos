import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../clientes/presentation/providers/cliente_provider.dart';

/// Widget de diálogo para seleccionar un cliente
class SelectorClienteWidget extends ConsumerStatefulWidget {
  final void Function(int clienteId) onClienteSeleccionado;

  const SelectorClienteWidget({
    super.key,
    required this.onClienteSeleccionado,
  });

  @override
  ConsumerState<SelectorClienteWidget> createState() =>
      _SelectorClienteWidgetState();
}

class _SelectorClienteWidgetState
    extends ConsumerState<SelectorClienteWidget> {
  String _filtro = '';

  @override
  Widget build(BuildContext context) {
    final clientesState = ref.watch(clientesProvider);
    final theme = Theme.of(context);

    return Dialog(
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Seleccionar Cliente',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Buscar por nombre o cédula',
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
              child: clientesState.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : clientesState.error != null
                      ? Center(child: Text('Error: ${clientesState.error}'))
                      : _buildClientesList(clientesState.clientes),
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

  Widget _buildClientesList(List<dynamic> clientes) {
    final clientesFiltrados = clientes.where((cliente) {
      if (_filtro.isEmpty) return true;
      return cliente.nombreCompleto.toLowerCase().contains(_filtro) ||
          cliente.cedula.toLowerCase().contains(_filtro);
    }).toList();

    return ListView.builder(
      shrinkWrap: true,
      itemCount: clientesFiltrados.length,
      itemBuilder: (context, index) {
        final cliente = clientesFiltrados[index];
        return ListTile(
          leading: CircleAvatar(
            child: Text(cliente.nombreCompleto[0].toUpperCase()),
          ),
          title: Text(cliente.nombreCompleto),
          subtitle: Text('Cédula: ${cliente.cedula}'),
          onTap: () {
            widget.onClienteSeleccionado(cliente.id!);
          },
        );
      },
    );
  }
}
