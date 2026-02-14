import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../presentation/widgets/app_drawer.dart';
import 'historial_cliente_screen.dart';
import 'resumen_prestamo_screen.dart';
import 'resumen_egresos_screen.dart';
import 'resumen_ingresos_screen.dart';

/// Pantalla principal del módulo de informes ejecutivos
class InformesMainScreen extends ConsumerWidget {
  const InformesMainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Informes Ejecutivos'),
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
              Tab(
                icon: Icon(Icons.trending_down),
                text: 'Egresos',
              ),
              Tab(
                icon: Icon(Icons.trending_up),
                text: 'Ingresos',
              ),
            ],
          ),
        ),
        drawer: const AppDrawer(),
        body: const TabBarView(
          children: [
            HistorialClienteScreen(),
            ResumenPrestamoScreen(),
            ResumenEgresosScreen(),
            ResumenIngresosScreen(),
          ],
        ),
      ),
    );
  }
}
