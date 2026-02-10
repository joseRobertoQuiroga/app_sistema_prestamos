import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:open_file/open_file.dart';
import '../providers/reportes_provider.dart';
import '../../domain/entities/reportes_entities.dart';

/// Widget para importar datos desde Excel
class ImportarWidget extends ConsumerWidget {
  const ImportarWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final importando = ref.watch(importandoDatosProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Importar Datos desde Excel',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        Text(
          'Importe datos masivamente usando las plantillas de Excel.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
        ),
        const SizedBox(height: 24),

        Expanded(
          child: ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              // Sección de plantillas
              _buildSeccionPlantillas(context, ref),
              const SizedBox(height: 32),

              // Sección de importación
              _buildSeccionImportacion(context, ref, importando),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSeccionPlantillas(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.file_download, color: Colors.blue[700]),
            const SizedBox(width: 8),
            Text(
              'Descargar Plantillas',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),
        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: _buildPlantillaCard(
                context,
                ref,
                titulo: 'Plantilla de Clientes',
                descripcion: 'Excel con formato para importar clientes',
                icono: Icons.people,
                color: Colors.blue,
                tipo: TipoPlantilla.clientes,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildPlantillaCard(
                context,
                ref,
                titulo: 'Plantilla de Préstamos',
                descripcion: 'Excel con formato para importar préstamos',
                icono: Icons.account_balance,
                color: Colors.green,
                tipo: TipoPlantilla.prestamos,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPlantillaCard(
    BuildContext context,
    WidgetRef ref, {
    required String titulo,
    required String descripcion,
    required IconData icono,
    required Color color,
    required TipoPlantilla tipo,
  }) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () => _descargarPlantilla(context, ref, tipo),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icono, color: color, size: 40),
              const SizedBox(height: 12),
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
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: () => _descargarPlantilla(context, ref, tipo),
                icon: const Icon(Icons.download, size: 18),
                label: const Text('Descargar'),
                style: FilledButton.styleFrom(
                  backgroundColor: color,
                  minimumSize: const Size(double.infinity, 36),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSeccionImportacion(
    BuildContext context,
    WidgetRef ref,
    bool importando,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.file_upload, color: Colors.orange[700]),
            const SizedBox(width: 8),
            Text(
              'Importar Archivos',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),
        const SizedBox(height: 16),

        if (importando)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Importando datos...'),
                ],
              ),
            ),
          )
        else
          Row(
            children: [
              Expanded(
                child: _buildImportCard(
                  context,
                  ref,
                  titulo: 'Importar Clientes',
                  descripcion: 'Cargar clientes desde plantilla Excel',
                  icono: Icons.people,
                  color: Colors.blue,
                  onTap: () => _seleccionarArchivo(context, ref, esClientes: true),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildImportCard(
                  context,
                  ref,
                  titulo: 'Importar Préstamos',
                  descripcion: 'Cargar préstamos desde plantilla Excel',
                  icono: Icons.account_balance,
                  color: Colors.green,
                  onTap: () => _seleccionarArchivo(context, ref, esClientes: false),
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildImportCard(
    BuildContext context,
    WidgetRef ref, {
    required String titulo,
    required String descripcion,
    required IconData icono,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icono, color: color, size: 40),
              const SizedBox(height: 12),
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
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: onTap,
                icon: const Icon(Icons.upload_file, size: 18),
                label: const Text('Seleccionar Archivo'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: color,
                  side: BorderSide(color: color),
                  minimumSize: const Size(double.infinity, 36),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _descargarPlantilla(
    BuildContext context,
    WidgetRef ref,
    TipoPlantilla tipo,
  ) async {
    try {
      final generarPlantilla = ref.read(generarPlantillaUseCaseProvider);
      final result = await generarPlantilla(tipo);

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
                content: Text('Plantilla descargada: $nombreArchivo'),
                backgroundColor: Colors.green,
                action: SnackBarAction(
                  label: 'Abrir',
                  textColor: Colors.white,
                  onPressed: () async {
                    await OpenFile.open(rutaArchivo);
                  },
                ),
                duration: const Duration(seconds: 5),
              ),
            );
          }
        },
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _seleccionarArchivo(
    BuildContext context,
    WidgetRef ref, {
    required bool esClientes,
  }) async {
    try {
      // Seleccionar archivo
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
      );

      if (result == null || result.files.isEmpty) return;

      final rutaArchivo = result.files.single.path;
      if (rutaArchivo == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No se pudo acceder al archivo'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // Mostrar loading
      ref.read(importandoDatosProvider.notifier).state = true;

      try {
        if (esClientes) {
          final importarClientes = ref.read(importarClientesUseCaseProvider);
          final importResult = await importarClientes(rutaArchivo);

          importResult.fold(
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
            (resultado) {
              if (context.mounted) {
                _mostrarResultadoImportacion(context, resultado);
              }
            },
          );
        } else {
          final importarPrestamos = ref.read(importarPrestamosUseCaseProvider);
          final importResult = await importarPrestamos(rutaArchivo);

          importResult.fold(
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
            (resultado) {
              if (context.mounted) {
                _mostrarResultadoImportacion(context, resultado);
              }
            },
          );
        }
      } finally {
        ref.read(importandoDatosProvider.notifier).state = false;
      }
    } catch (e) {
      ref.read(importandoDatosProvider.notifier).state = false;
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _mostrarResultadoImportacion(
    BuildContext context,
    ResultadoImportacion resultado,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              resultado.exitoso
                  ? Icons.check_circle
                  : resultado.parcial
                      ? Icons.warning
                      : Icons.error,
              color: resultado.exitoso
                  ? Colors.green
                  : resultado.parcial
                      ? Colors.orange
                      : Colors.red,
            ),
            const SizedBox(width: 8),
            const Text('Resultado de Importación'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total de registros: ${resultado.totalRegistros}'),
            Text('Importados exitosamente: ${resultado.registrosExitosos}'),
            Text('Con errores: ${resultado.registrosConError}'),
            const SizedBox(height: 8),
            Text(
              'Porcentaje de éxito: ${resultado.porcentajeExito.toStringAsFixed(1)}%',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          if (resultado.errores.isNotEmpty)
            TextButton(
              onPressed: () {
                // TODO: Mostrar lista de errores
              },
              child: const Text('Ver Errores'),
            ),
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}