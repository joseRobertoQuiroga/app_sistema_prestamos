import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/prestamo.dart';
import '../../domain/entities/cuota.dart';
import '../../domain/usecases/cuota_usecases.dart';
import '../providers/prestamo_provider.dart';
import '../widgets/resumen_prestamo_widget.dart';
import '../widgets/tabla_amortizacion_widget.dart';
import '../../../../presentation/widgets/state_widgets.dart';
import 'prestamo_form_screen.dart';

class PrestamoDetailScreen extends ConsumerWidget {
  final int prestamoId;

  const PrestamoDetailScreen({
    super.key,
    required this.prestamoId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prestamoAsync = ref.watch(prestamoDetailProvider(prestamoId));
    final cuotasAsync = ref.watch(cuotasListProvider(prestamoId));
    final resumenAsync = ref.watch(resumenCuotasProvider(prestamoId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del Préstamo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Editar',
            onPressed: () => _navigateToEdit(context),
          ),
          PopupMenuButton<String>(
            onSelected: (value) => _handleMenuAction(context, ref, value),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'pagar',
                child: ListTile(
                  leading: Icon(Icons.payment),
                  title: Text('Registrar Pago'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'actualizar',
                child: ListTile(
                  leading: Icon(Icons.refresh),
                  title: Text('Actualizar Estados'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'cancelar',
                child: ListTile(
                  leading: Icon(Icons.cancel, color: Colors.red),
                  title: Text('Cancelar Préstamo', style: TextStyle(color: Colors.red)),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      body: prestamoAsync.when(
        data: (prestamo) {
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(prestamoDetailProvider(prestamoId));
              ref.invalidate(cuotasListProvider(prestamoId));
              ref.invalidate(resumenCuotasProvider(prestamoId));
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Resumen del préstamo
                  resumenAsync.when(
                    data: (resumen) => ResumenPrestamoWidget(
                      prestamo: prestamo,
                      cuotasPagadas: resumen.cuotasPagadas,
                      cuotasPendientes: resumen.cuotasPendientes,
                      cuotasVencidas: resumen.cuotasVencidas,
                    ),
                    loading: () => const Card(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    ),
                    error: (error, _) => Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text('Error: $error'),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Tabla de amortización
                  cuotasAsync.when(
                    data: (cuotas) => TablaAmortizacionWidget(
                      cuotas: cuotas,
                      compact: false,
                    ),
                    loading: () => const Card(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    ),
                    error: (error, _) => Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text('Error: $error'),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Observaciones
                  if (prestamo.observaciones != null &&
                      prestamo.observaciones!.isNotEmpty)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Observaciones',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text(prestamo.observaciones!),
                          ],
                        ),
                      ),
                    ),

                  const SizedBox(height: 80),
                ],
              ),
            ),
          );
        },
        loading: () => const LoadingState(message: 'Cargando préstamo...'),
        error: (error, stack) => ErrorState(
          message: error.toString(),
          onRetry: () {
            ref.invalidate(prestamoDetailProvider(prestamoId));
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _registrarPago(context),
        icon: const Icon(Icons.payment),
        label: const Text('Registrar Pago'),
      ),
    );
  }

  void _navigateToEdit(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PrestamoFormScreen(prestamoId: prestamoId),
      ),
    );
  }

  void _handleMenuAction(BuildContext context, WidgetRef ref, String action) {
    switch (action) {
      case 'pagar':
        _registrarPago(context);
        break;
      case 'actualizar':
        _actualizarEstados(context, ref);
        break;
      case 'cancelar':
        _confirmarCancelacion(context, ref);
        break;
    }
  }

  void _registrarPago(BuildContext context) {
    // TODO: Navegar a pantalla de registro de pago
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Módulo de pagos en desarrollo (Fase 4)'),
      ),
    );
  }

  Future<void> _actualizarEstados(BuildContext context, WidgetRef ref) async {
    final actualizarEstados = ref.read(
      Provider((ref) => ref.read(prestamoRepositoryProvider)),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Actualizando estados...')),
    );

    // Actualizar estados de cuotas y préstamo
    await actualizarEstados.actualizarEstadosCuotas(prestamoId);
    await actualizarEstados.actualizarEstadoPrestamo(prestamoId);

    // Refrescar datos
    ref.invalidate(prestamoDetailProvider(prestamoId));
    ref.invalidate(cuotasListProvider(prestamoId));
    ref.invalidate(resumenCuotasProvider(prestamoId));

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Estados actualizados correctamente'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _confirmarCancelacion(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar Préstamo'),
        content: const Text(
          '¿Estás seguro de que deseas cancelar este préstamo?\n\n'
          'Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Sí, Cancelar'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final cancelar = ref.read(cancelarPrestamoProvider);
      final result = await cancelar(prestamoId);

      result.fold(
        (failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${failure.message}'),
              backgroundColor: Colors.red,
            ),
          );
        },
        (_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Préstamo cancelado correctamente'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        },
      );
    }
  }
}