import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_file/open_file.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../providers/reportes_provider.dart';
import '../../domain/entities/reportes_entities.dart';

/// Widget unificado para gestión de datos (Exportación e Importación)
class GestionDatosWidget extends ConsumerWidget {
  const GestionDatosWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exportando = ref.watch(exportandoDatosProvider);
    final importando = ref.watch(importandoDatosProvider);
    final theme = Theme.of(context);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Gestión de Datos',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Exporte e importe datos del sistema de forma masiva usando archivos Excel.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),

            // Contenido principal en dos columnas
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Columna izquierda: Exportación
                Expanded(
                  child: _buildSeccionExportacion(context, ref, exportando),
                ),
                const SizedBox(width: 24),
                // Columna derecha: Importación
                Expanded(
                  child: _buildSeccionImportacion(context, ref, importando),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeccionExportacion(
    BuildContext context,
    WidgetRef ref,
    bool exportando,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.file_download, color: Colors.blue[700], size: 20),
            const SizedBox(width: 8),
            Text(
              'Exportar Datos',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        if (exportando)
          const SizedBox(
            height: 200,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Exportando...'),
                ],
              ),
            ),
          )
        else
          GridView.count(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildExportCard(
                context,
                ref,
                titulo: 'Clientes',
                icono: Icons.people,
                color: Colors.blue,
                tipo: TipoDatoExportacion.clientes,
              ),
              _buildExportCard(
                context,
                ref,
                titulo: 'Préstamos',
                icono: Icons.account_balance,
                color: Colors.green,
                tipo: TipoDatoExportacion.prestamos,
              ),
              _buildExportCard(
                context,
                ref,
                titulo: 'Pagos',
                icono: Icons.payment,
                color: Colors.orange,
                tipo: TipoDatoExportacion.pagos,
              ),
              _buildExportCard(
                context,
                ref,
                titulo: 'Movimientos',
                icono: Icons.swap_horiz,
                color: Colors.purple,
                tipo: TipoDatoExportacion.movimientos,
              ),
            ],
          ),
      ],
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
            Icon(Icons.file_upload, color: Colors.orange[700], size: 20),
            const SizedBox(width: 8),
            Text(
              'Importar Datos',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Plantillas
        Text(
          'Plantillas',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildPlantillaButton(
                context,
                ref,
                'Clientes',
                Icons.people,
                Colors.blue,
                TipoPlantilla.clientes,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildPlantillaButton(
                context,
                ref,
                'Préstamos',
                Icons.account_balance,
                Colors.green,
                TipoPlantilla.prestamos,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Importar
        Text(
          'Importar Archivos',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),

        if (importando)
          const SizedBox(
            height: 150,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Importando...'),
                ],
              ),
            ),
          )
        else
          Column(
            children: [
              _buildImportButton(
                context,
                ref,
                'Importar Clientes',
                Icons.people,
                Colors.blue,
                esClientes: true,
              ),
              const SizedBox(height: 8),
              _buildImportButton(
                context,
                ref,
                'Importar Préstamos',
                Icons.account_balance,
                Colors.green,
                esClientes: false,
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildExportCard(
    BuildContext context,
    WidgetRef ref, {
    required String titulo,
    required IconData icono,
    required Color color,
    required TipoDatoExportacion tipo,
  }) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () => _exportarDatos(context, ref, tipo),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icono, color: color, size: 32),
              ),
              const SizedBox(height: 8),
              Text(
                titulo,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlantillaButton(
    BuildContext context,
    WidgetRef ref,
    String titulo,
    IconData icono,
    Color color,
    TipoPlantilla tipo,
  ) {
    return ElevatedButton.icon(
      onPressed: () => _descargarPlantilla(context, ref, tipo),
      icon: Icon(icono, size: 18),
      label: Text(titulo, style: const TextStyle(fontSize: 13)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }

  Widget _buildImportButton(
    BuildContext context,
    WidgetRef ref,
    String titulo,
    IconData icono,
    Color color, {
    required bool esClientes,
  }) {
    return OutlinedButton.icon(
      onPressed: () => _seleccionarArchivo(context, ref, esClientes: esClientes),
      icon: Icon(icono, size: 20),
      label: Text(titulo),
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color, width: 2),
        padding: const EdgeInsets.symmetric(vertical: 16),
        minimumSize: const Size(double.infinity, 48),
      ),
    );
  }

  // Métodos de exportación/importación (reutilizados de widgets anteriores)
  Future<void> _exportarDatos(
    BuildContext context,
    WidgetRef ref,
    TipoDatoExportacion tipo,
  ) async {
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

    ref.read(exportandoDatosProvider.notifier).state = true;

    try {
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
    } finally {
      ref.read(exportandoDatosProvider.notifier).state = false;
    }
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
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
        dialogTitle: esClientes
            ? 'Seleccionar archivo de clientes'
            : 'Seleccionar archivo de préstamos',
      );

      if (result == null || result.files.isEmpty) return;

      final rutaArchivo = result.files.single.path;
      if (rutaArchivo == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No se pudo acceder a la ruta del archivo'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      final archivo = File(rutaArchivo);
      if (!archivo.existsSync()) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('El archivo no existe o no es accesible'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

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
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Importación completada: ${resultado.registrosExitosos}/${resultado.totalRegistros} registros',
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
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
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Importación completada: ${resultado.registrosExitosos}/${resultado.totalRegistros} registros',
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
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
}
