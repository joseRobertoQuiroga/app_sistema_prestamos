import 'package:flutter/material.dart';
import '../../../../presentation/widgets/app_drawer.dart';
import '../widgets/gestion_datos_widget.dart';

class GestionDatosScreen extends StatelessWidget {
  const GestionDatosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Datos'),
      ),
      drawer: const AppDrawer(),
      body: const GestionDatosWidget(),
    );
  }
}
