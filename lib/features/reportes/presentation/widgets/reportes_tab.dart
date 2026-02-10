import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/reportes_provider.dart';
import '../widgets/reporte_card.dart';
import '../../domain/entities/reportes_entities.dart';

/// Tab de generación de reportes optimizada sin scroll
class ReportesTab extends ConsumerWidget {
  const ReportesTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final periodo = ref.watch(periodoSeleccionadoProvider);
    final formato = ref.watch(formatoSeleccionadoProvider);
    final generando = ref.watch(generandoReporteProvider);
    final theme = Theme.of(context);

    return Column(
      children: [
        // Configuración - Fixed at top (~25% of screen)
        Padding(
          padding: const EdgeInsets.all(16),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Configuración',
                    style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),

                  // Período y Formato en Row
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: periodo,
                          decoration: const InputDecoration(
                            labelText: 'Período',
                            prefixIcon: Icon(Icons.calendar_today, size: 20),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            isDense: true,
                          ),
                          items: const [
                            DropdownMenuItem(value: 'hoy', child: Text('Hoy')),
                            DropdownMenuItem(value: 'ultimaSemana', child: Text('Semana')),
                            DropdownMenuItem(value: 'ultimoMes', child: Text('Mes')),
                            DropdownMenuItem(value: 'ultimoTrimestre', child: Text('Trimestre')),
                            DropdownMenuItem(value: 'ultimoAnio', child: Text('Año')),
                            DropdownMenuItem(value: 'todoElTiempo', child: Text('Todo')),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              ref.read(periodoSeleccionadoProvider.notifier).state = value;
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: formato,
                          decoration: const InputDecoration(
                            labelText: 'Formato',
                            prefixIcon: Icon(Icons.picture_as_pdf, size: 20),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            isDense: true,
                          ),
                          items: const [
                            DropdownMenuItem(value: 'pdf', child: Text('PDF')),
                            DropdownMenuItem(value: 'excel', child: Text('Excel')),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              ref.read(formatoSeleccionadoProvider.notifier).state = value;
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.1, end: 0),
        ),

        // Tipos de Reportes - Grid 2x2 in remaining space
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: generando
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 16),
                        Text(
                          'Generando reporte...',
                          style: theme.textTheme.titleMedium,
                        ),
                      ],
                    ),
                  )
                : GridView.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.1,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      ReporteCard(
                        titulo: 'Cartera',
                        descripcion: 'Préstamos activos',
                        icono: Icons.account_balance_wallet,
                        color: Colors.blue,
                        onTap: () => _generarReporte(
                          context,
                          ref,
                          TipoReporte.carteraCompleta,
                        ),
                      ).animate().fadeIn(duration: 300.ms, delay: 0.ms).scale(begin: const Offset(0.8, 0.8)),
                      
                      ReporteCard(
                        titulo: 'Mora',
                        descripcion: 'Pagos vencidos',
                        icono: Icons.warning_amber,
                        color: Colors.orange,
                        onTap: () => _generarReporte(
                          context,
                          ref,
                          TipoReporte.moraDetallada,
                        ),
                      ).animate().fadeIn(duration: 300.ms, delay: 50.ms).scale(begin: const Offset(0.8, 0.8)),
                      
                      ReporteCard(
                        titulo: 'Cajas',
                        descripcion: 'Movimientos',
                        icono: Icons.account_balance,
                        color: Colors.green,
                        onTap: () => _generarReporte(
                          context,
                          ref,
                          TipoReporte.movimientosCaja,
                        ),
                      ).animate().fadeIn(duration: 300.ms, delay: 100.ms).scale(begin: const Offset(0.8, 0.8)),
                      
                      ReporteCard(
                        titulo: 'Pagos',
                        descripcion: 'Historial',
                        icono: Icons.payment,
                        color: Colors.purple,
                        onTap: () => _generarReporte(
                          context,
                          ref,
                          TipoReporte.resumenPagos,
                        ),
                      ).animate().fadeIn(duration: 300.ms, delay: 150.ms).scale(begin: const Offset(0.8, 0.8)),
                    ],
                  ),
          ),
        ),
        
        const SizedBox(height: 16),
      ],
    );
  }

  Future<void> _generarReporte(
    BuildContext context,
    WidgetRef ref,
    TipoReporte tipo,
  ) async {
    try {
      ref.read(generandoReporteProvider.notifier).state = true;

      final generarReporte = ref.read(generarReporteUseCaseProvider);
      final periodo = ref.read(periodoSeleccionadoProvider);
      final formato = ref.read(formatoSeleccionadoProvider);

      final parametros = ConfiguracionReporte(
        tipo: tipo,
        formato: formato == 'pdf' ? FormatoReporte.pdf : FormatoReporte.excel,
        periodo: _getPeriodo(periodo),
      );

      final result = await generarReporte(parametros);

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
        (resultado) {
          if (context.mounted) {
            final nombreArchivo = resultado.rutaArchivo.split(r'\').last.split('/').last;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Reporte generado: $nombreArchivo'),
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
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      ref.read(generandoReporteProvider.notifier).state = false;
    }
  }

  PeriodoReporte _getPeriodo(String periodo) {
    switch (periodo) {
      case 'ultimoMes':
        return PeriodoReporte.ultimoMes;
      case 'ultimoTrimestre':
        return PeriodoReporte.ultimoTrimestre;
      case 'ultimoAnio':
        return PeriodoReporte.ultimoAnio;
      default:
        return PeriodoReporte.ultimoMes;
    }
  }
}
