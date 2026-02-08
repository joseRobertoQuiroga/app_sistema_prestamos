import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/cliente_provider.dart';
import 'cliente_form_screen.dart';
import '../../../../core/utils/formatters.dart';

/// Pantalla de detalle de un cliente
class ClienteDetailScreen extends ConsumerWidget {
  final int clienteId;

  const ClienteDetailScreen({super.key, required this.clienteId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clienteAsync = ref.watch(clienteByIdProvider(clienteId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del Cliente'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ClienteFormScreen(clienteId: clienteId),
                ),
              );
            },
            tooltip: 'Editar',
          ),
        ],
      ),
      body: clienteAsync.when(
        data: (cliente) {
          if (cliente == null) {
            return const Center(
              child: Text('Cliente no encontrado'),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header con avatar y nombre
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: cliente.activo
                            ? Theme.of(context).colorScheme.primaryContainer
                            : Theme.of(context).colorScheme.surfaceContainerHighest,
                        child: Text(
                          cliente.nombre[0].toUpperCase(),
                          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                color: cliente.activo
                                    ? Theme.of(context).colorScheme.onPrimaryContainer
                                    : Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        Formatters.capitalizeWords(cliente.nombre),
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      if (!cliente.activo)
                        Chip(
                          label: const Text('Inactivo'),
                          backgroundColor: Theme.of(context).colorScheme.errorContainer,
                          labelStyle: TextStyle(
                            color: Theme.of(context).colorScheme.onErrorContainer,
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),

                // Información básica
                _buildSectionTitle(context, 'Información Básica'),
                const SizedBox(height: 12),
                _buildInfoRow(
                  context,
                  icon: Icons.badge,
                  label: 'CI',
                  value: Formatters.formatDocument(cliente.ci),
                ),
                _buildInfoRow(
                  context,
                  icon: Icons.calendar_today,
                  label: 'Fecha de registro',
                  value: Formatters.formatDate(cliente.fechaRegistro),
                ),

                const SizedBox(height: 24),

                // Contacto
                if (cliente.telefono != null || cliente.email != null) ...[
                  _buildSectionTitle(context, 'Contacto'),
                  const SizedBox(height: 12),
                  if (cliente.telefono != null)
                    _buildInfoRow(
                      context,
                      icon: Icons.phone,
                      label: 'Teléfono',
                      value: Formatters.formatPhone(cliente.telefono!),
                    ),
                  if (cliente.email != null)
                    _buildInfoRow(
                      context,
                      icon: Icons.email,
                      label: 'Email',
                      value: cliente.email!,
                    ),
                  const SizedBox(height: 24),
                ],

                // Dirección
                if (cliente.direccion != null ||
                    cliente.ciudad != null ||
                    cliente.departamento != null) ...[
                  _buildSectionTitle(context, 'Dirección'),
                  const SizedBox(height: 12),
                  if (cliente.direccion != null)
                    _buildInfoRow(
                      context,
                      icon: Icons.location_on,
                      label: 'Dirección',
                      value: cliente.direccion!,
                    ),
                  if (cliente.ciudad != null)
                    _buildInfoRow(
                      context,
                      icon: Icons.location_city,
                      label: 'Ciudad',
                      value: cliente.ciudad!,
                    ),
                  if (cliente.departamento != null)
                    _buildInfoRow(
                      context,
                      icon: Icons.map,
                      label: 'Departamento',
                      value: cliente.departamento!,
                    ),
                  if (cliente.referencia != null)
                    _buildInfoRow(
                      context,
                      icon: Icons.place,
                      label: 'Referencia',
                      value: cliente.referencia!,
                    ),
                  const SizedBox(height: 24),
                ],

                // Notas
                if (cliente.notas != null && cliente.notas!.isNotEmpty) ...[
                  _buildSectionTitle(context, 'Notas'),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      cliente.notas!,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text('Error: $error'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}