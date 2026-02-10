import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/reportes_provider.dart';
import '../../domain/entities/reportes_entities.dart';

/// Widget para exportar datos a Excel
class ExportarWidget extends ConsumerWidget {
  const ExportarWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exportando = ref.watch(exportandoDatosProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Exportar Datos a Excel',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        Text(
          'Exporte todos los datos del sistema a archivos Excel para análisis externo.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
        ),
        const SizedBox(height: 24),

        if (exportando)
          const Expanded(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Exportando datos...'),
                  ],
                ),
              ),
            ),
          )
        else
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.5,
              children: [
                _buildExportCard(
                  context,
                  ref,
                  titulo: 'Clientes',
                  descripcion: 'Exportar todos los clientes',
                  icono: Icons.people,
                  color: Colors.blue,
                  tipo: TipoDatoExportacion.clientes,
                ),
                _buildExportCard(
                  context,
                  ref,
                  titulo: 'Préstamos',
                  descripcion: 'Exportar todos los préstamos',
                  icono: Icons.account_balance,
                  color: Colors.green,
                  tipo: TipoDatoExportacion.prestamos,
                ),
                _buildExportCard(
                  context,
                  ref,
                  titulo: 'Pagos',
                  descripcion: 'Exportar todos los pagos',
                  icono: Icons.payment,
                  color: Colors.orange,
                  tipo: TipoDatoExportacion.pagos,
                ),
                _buildExportCard(
                  context,
                  ref,
                  titulo: 'Movimientos',
                  descripcion: 'Exportar movimientos de caja',
                  icono: Icons.swap_horiz,
                  color: Colors.purple,
                  tipo: TipoDatoExportacion.movimientos,
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildExportCard(
    BuildContext context,
    WidgetRef ref, {
    required String titulo,
    required String descripcion,
    required IconData icono,
    required Color color,
    required TipoDatoExportacion tipo,
  }) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () => _exportarDatos(context, ref, tipo),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icono, color: color, size: 32),
                  const Spacer(),
                  Icon(
                    Icons.file_download,
                    color: Colors.grey[400],
                    size: 20,
                  ),
                ],
              ),
              const Spacer(),
              Text(
                titulo,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                descripcion,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _exportarDatos(
    BuildContext context,
    WidgetRef ref,
    TipoDatoExportacion tipo,
  ) async {
    // Confirmar exportación
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Exportar ${tipo.nombre}'),
        content: Text(
          '¿Desea exportar todos los ${tipo.nombre.toLowerCase()} a Excel?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Exportar'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    // Mostrar loading
    ref.read(exportandoDatosProvider.notifier).state = true;

    try {
      // Exportar
      final exportarDatos = ref.read(exportarDatosUseCaseProvider);
      final result = await exportarDatos(tipo);

      result.fold(
        (failure) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${failure.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        (rutaArchivo) {
          if (context.mounted) {
            final nombreArchivo = rutaArchivo.split('/').last;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Exportado: $nombreArchivo'),
                backgroundColor: Colors.green,
                action: SnackBarAction(
                  label: 'Abrir',
                  textColor: Colors.white,
                  onPressed: () {
                    // TODO: Abrir archivo con open_file
                  },
                ),
                duration: const Duration(seconds: 5),
              ),
            );
          }
        },
      );
    } finally {
      ref.read(exportandoDatosProvider.notifier).state = false;
    }
  }
}