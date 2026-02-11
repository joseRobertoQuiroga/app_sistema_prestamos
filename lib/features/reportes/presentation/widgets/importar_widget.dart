import 'dart:io';
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
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Importar Datos desde Excel',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 4),
              Text(
                'Importe datos masivamente usando las plantillas de Excel.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sección de plantillas
                _buildSeccionPlantillas(context, ref),
                const SizedBox(height: 24),

                // Sección de importación
                _buildSeccionImportacion(context, ref, importando),
              ],
            ),
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
            Icon(Icons.file_download, color: Colors.blue[700], size: 20),
            const SizedBox(width: 8),
            Text(
              'Descargar Plantillas',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 12),

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
      elevation: 1,
      child: InkWell(
        onTap: () => _descargarPlantilla(context, ref, tipo),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(icono, color: color, size: 28),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      titulo,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                descripcion,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              FilledButton.icon(
                onPressed: () => _descargarPlantilla(context, ref, tipo),
                icon: const Icon(Icons.download, size: 16),
                label: const Text('Descargar', style: TextStyle(fontSize: 13)),
                style: FilledButton.styleFrom(
                  backgroundColor: color,
                  minimumSize: const Size(double.infinity, 32),
                  padding: const EdgeInsets.symmetric(vertical: 8),
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
            Icon(Icons.file_upload, color: Colors.orange[700], size: 20),
            const SizedBox(width: 8),
            Text(
              'Importar Archivos',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 12),

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
      elevation: 1,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(icono, color: color, size: 28),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      titulo,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                descripcion,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: onTap,
                icon: const Icon(Icons.upload_file, size: 16),
                label: const Text('Seleccionar', style: TextStyle(fontSize: 13)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: color,
                  side: BorderSide(color: color),
                  minimumSize: const Size(double.infinity, 32),
                  padding: const EdgeInsets.symmetric(vertical: 8),
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
        dialogTitle: esClientes ? 'Seleccionar archivo de clientes' : 'Seleccionar archivo de préstamos',
      );

      if (result == null || result.files.isEmpty) return;

      final rutaArchivo = result.files.single.path;
      if (rutaArchivo == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.white),
                  SizedBox(width: 8),
                  Expanded(child: Text('No se pudo acceder a la ruta del archivo')),
                ],
              ),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 4),
            ),
          );
        }
        return;
      }

      // Validar que el archivo existe y es accesible
      final archivo = File(rutaArchivo);
      if (!archivo.existsSync()) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.white),
                  SizedBox(width: 8),
                  Expanded(child: Text('El archivo seleccionado no existe o no es accesible')),
                ],
              ),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 4),
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
                    content: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.white),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text('Error al importar clientes: ${failure.message}'),
                        ),
                      ],
                    ),
                    backgroundColor: Colors.red,
                    duration: const Duration(seconds: 5),
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
                    content: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.white),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text('Error al importar préstamos: ${failure.message}'),
                        ),
                      ],
                    ),
                    backgroundColor: Colors.red,
                    duration: const Duration(seconds: 5),
                    action: SnackBarAction(
                      label: 'INFO',
                      textColor: Colors.white,
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Row(
                              children: [
                                Icon(Icons.info_outline, color: Colors.blue),
                                SizedBox(width: 8),
                                Text('Información'),
                              ],
                            ),
                            content: const Text(
                              'Asegúrese de que:\n'
                              '• Los clientes referenciados ya estén importados\n'
                              '• Las cajas mencionadas existan en el sistema\n'
                              '• Los datos cumplan con el formato de la plantilla\n'
                              '• Las fechas estén en formato DD/MM/YYYY',
                            ),
                            actions: [
                              FilledButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: const Text('Entendido'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
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
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Error inesperado al procesar el archivo: ${e.toString()}',
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 6),
            ),
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
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text('Error al seleccionar archivo: ${e.toString()}')),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
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
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildResumenCard(resultado),
              if (resultado.errores.isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildErrorSummaryCard(resultado),
              ],
            ],
          ),
        ),
        actions: [
          if (resultado.errores.isNotEmpty)
            OutlinedButton.icon(
              onPressed: () {
                _mostrarDetallesErrores(context, resultado);
              },
              icon: const Icon(Icons.list_alt, size: 18),
              label: const Text('Ver Detalles'),
            ),
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Widget _buildResumenCard(ResultadoImportacion resultado) {
    return Card(
      color: Colors.grey[50],
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total de registros:', style: TextStyle(fontWeight: FontWeight.w500)),
                Text('${resultado.totalRegistros}', style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.check_circle, size: 16, color: Colors.green[700]),
                    const SizedBox(width: 4),
                    const Text('Importados exitosamente:'),
                  ],
                ),
                Text(
                  '${resultado.registrosExitosos}',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green[700]),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.error, size: 16, color: Colors.red[700]),
                    const SizedBox(width: 4),
                    const Text('Con errores:'),
                  ],
                ),
                Text(
                  '${resultado.registrosConError}',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red[700]),
                ),
              ],
            ),
            const Divider(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Porcentaje de éxito:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  '${resultado.porcentajeExito.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: resultado.exitoso ? Colors.green : resultado.parcial ? Colors.orange : Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorSummaryCard(ResultadoImportacion resultado) {
    final agrupados = resultado.getErroresAgrupados();
    
    return Card(
      color: Colors.red[50],
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.error_outline, size: 18, color: Colors.red[700]),
                const SizedBox(width: 6),
                Text(
                  'Resumen de Errores',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red[900]),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...agrupados.entries.map((entry) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      const Text('•', style: TextStyle(fontSize: 16)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          '${entry.key}: ${entry.value} error(es)',
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  void _mostrarDetallesErrores(BuildContext context, ResultadoImportacion resultado) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: SizedBox(
          width: 700,
          height: 600,
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red[700],
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error, color: Colors.white),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Detalles de Errores',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              // Error list
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: resultado.errores.length,
                  itemBuilder: (context, index) {
                    final error = resultado.errores[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.red[100],
                          child: Text(
                            '${error.fila}',
                            style: TextStyle(
                              color: Colors.red[900],
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        title: Text(
                          error.campo,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(error.mensaje, style: const TextStyle(fontSize: 13)),
                            if (error.valorProblematico != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                'Valor: "${error.valorProblematico}"',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ],
                        ),
                        isThreeLine: error.valorProblematico != null,
                      ),
                    );
                  },
                ),
              ),
              // Footer with actions
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  border: Border(top: BorderSide(color: Colors.grey[300]!)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total: ${resultado.errores.length} error(es)',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        OutlinedButton.icon(
                          onPressed: () {
                            _copiarErrores(context, resultado);
                          },
                          icon: const Icon(Icons.copy, size: 16),
                          label: const Text('Copiar'),
                        ),
                        const SizedBox(width: 8),
                        FilledButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cerrar'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _copiarErrores(BuildContext context, ResultadoImportacion resultado) {
    final buffer = StringBuffer();
    buffer.writeln('ERRORES DE IMPORTACIÓN');
    buffer.writeln('=' * 50);
    buffer.writeln('Total de errores: ${resultado.errores.length}');
    buffer.writeln('Fecha: ${resultado.fechaProceso}');
    buffer.writeln('=' * 50);
    buffer.writeln();
    
    for (final error in resultado.errores) {
      buffer.writeln(error.toString());
    }
    
    // Copy to clipboard
    // Note: You'll need to add clipboard package to pubspec.yaml
    // and import 'package:flutter/services.dart';
    // Clipboard.setData(ClipboardData(text: buffer.toString()));
    
    // For now, just show a message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Lista de errores copiada (función pendiente: agregar clipboard)'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}