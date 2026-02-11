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
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Exportar Datos a Excel',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 4),
              Text(
                'Exporte todos los datos del sistema a archivos Excel para análisis externo.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),

        if (exportando)
          const Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Exportando datos...'),
                ],
              ),
            ),
          )
        else
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.3,
                physics: const NeverScrollableScrollPhysics(),
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
      elevation: 1,
      child: InkWell(
        onTap: () => _exportarDatos(context, ref, tipo),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icono, color: color, size: 24),
                  ),
                  Icon(
                    Icons.file_download,
                    color: Colors.grey[400],
                    size: 18,
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    descripcion,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
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