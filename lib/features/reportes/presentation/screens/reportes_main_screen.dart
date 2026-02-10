import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../presentation/widgets/app_drawer.dart';
import '../widgets/exportar_widget.dart';
import '../widgets/importar_widget.dart';
import '../widgets/reportes_tab.dart';

/// Pantalla principal del módulo de reportes
class ReportesScreen extends ConsumerWidget {
  const ReportesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Reportes y Estadísticas'),
          bottom: const TabBar(
            tabs: [
              Tab(
                icon: Icon(Icons.assessment),
                text: 'Reportes',
              ),
              Tab(
                icon: Icon(Icons.file_download),
                text: 'Exportar',
              ),
              Tab(
                icon: Icon(Icons.file_upload),
                text: 'Importar',
              ),
            ],
          ),
        ),
        drawer: const AppDrawer(),
        body: const TabBarView(
          children: [
            ReportesTab(),
            ExportarWidget(),
            ImportarWidget(),
          ],
        ),
      ),
    );
  }
}
