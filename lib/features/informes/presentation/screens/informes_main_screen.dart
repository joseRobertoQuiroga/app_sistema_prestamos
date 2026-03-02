import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../presentation/widgets/app_drawer.dart';
import '../../../clientes/presentation/providers/cliente_provider.dart';
import '../../../prestamos/presentation/providers/prestamo_provider.dart';
import '../../../pagos/presentation/providers/pago_provider.dart';
import '../../../caja/presentation/providers/caja_provider.dart';
import 'historial_cliente_screen.dart';
import 'resumen_prestamo_screen.dart';

/// Pantalla principal del módulo de informes ejecutivos
class InformesMainScreen extends ConsumerWidget {
  const InformesMainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Informes Ejecutivos'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Actualizar datos',
              onPressed: () {
                ref.invalidate(clientesProvider);
                ref.invalidate(clientesActivosProvider);
                ref.invalidate(prestamosListProvider);
                ref.invalidate(allPagosListProvider);
                ref.invalidate(cajasListProvider);
                ref.invalidate(movimientosGeneralesProvider);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✅ Datos actualizados'),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
          ],
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(
                icon: Icon(Icons.person_pin),
                text: 'Historial Cliente',
              ),
              Tab(
                icon: Icon(Icons.description),
                text: 'Resumen Préstamo',
              ),
            ],
          ),
        ),
        drawer: const AppDrawer(),
        body: const TabBarView(
          children: [
            HistorialClienteScreen(),
            ResumenPrestamoScreen(),
          ],
        ),
      ),
    );
  }
}
