import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:open_file/open_file.dart';
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
                      // 1. Cartera Activa
                      ReporteCard(
                        titulo: 'Cartera Activa',
                        descripcion: 'Listado completo de todos los préstamos activos con montos, saldos pendientes, fechas de vencimiento y estado de cada cuota',
                        icono: Icons.account_balance_wallet,
                        color: Colors.blue,
                        onTap: () => _generarReporte(
                          context,
                          ref,
                          TipoReporte.carteraCompleta,
                        ),
                      ).animate().fadeIn(delay: 0.ms).scale(),
                      
                      // 2. Mora
                      ReporteCard(
                        titulo: 'Mora Detallada',
                        descripcion: 'Préstamos con cuotas vencidas, días de atraso, monto de mora acumulada por cliente y totales de cartera en riesgo',
                        icono: Icons.warning_amber,
                        color: Colors.red,
                        onTap: () => _generarReporte(
                          context,
                          ref,
                          TipoReporte.moraDetallada,
                        ),
                      ).animate().fadeIn(delay: 50.ms).scale(),

                      // 3. Proyección
                      ReporteCard(
                        titulo: 'Proyección de Cobros',
                        descripcion: 'Calendario de vencimientos futuros, cuotas por vencer en los próximos 30 días y proyección de ingresos esperados',
                        icono: Icons.calendar_today,
                        color: Colors.teal,
                        onTap: () => _generarReporte(
                          context,
                          ref,
                          TipoReporte.proyeccionCobros,
                        ),
                      ).animate().fadeIn(delay: 100.ms).scale(),
                      
                      // 4. Pagos
                      ReporteCard(
                        titulo: 'Historial de Pagos',
                        descripcion: 'Registro completo de todos los pagos recibidos con fecha, cliente, monto pagado, aplicación de capital e intereses',
                        icono: Icons.payment,
                        color: Colors.green,
                        onTap: () => _generarReporte(
                          context,
                          ref,
                          TipoReporte.resumenPagos,
                        ),
                      ).animate().fadeIn(delay: 150.ms).scale(),

                      // 5. Cajas
                      ReporteCard(
                        titulo: 'Movimientos de Caja',
                        descripcion: 'Detalle de todos los ingresos y egresos por caja, con totales, saldos y balance de cada punto de operación',
                        icono: Icons.point_of_sale,
                        color: Colors.orange,
                        onTap: () => _generarReporte(
                          context,
                          ref,
                          TipoReporte.movimientosCaja,
                        ),
                      ).animate().fadeIn(delay: 200.ms).scale(),

                      // 6. Cancelados
                      ReporteCard(
                        titulo: 'Préstamos Pagados',
                        descripcion: 'Listado de préstamos completamente liquidados con fechas de inicio, finalización, montos y total de intereses generados',
                        icono: Icons.check_circle_outline,
                        color: Colors.grey,
                        onTap: () => _generarReporte(
                          context,
                          ref,
                          TipoReporte.prestamosCancelados,
                        ),
                      ).animate().fadeIn(delay: 250.ms).scale(),

                      // 8. Estado de Cuenta (Requiere cliente)
                      ReporteCard(
                        titulo: 'Estado de Cuenta',
                        descripcion: 'Resumen detallado por cliente con todos sus préstamos, historial de pagos, saldos y comportamiento crediticio',
                        icono: Icons.person_search,
                        color: Colors.indigo,
                        onTap: () => _seleccionarClienteYGenerar(context, ref),
                      ).animate().fadeIn(delay: 350.ms).scale(),
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
                  onPressed: () async {
                    final result = await OpenFile.open(resultado.rutaArchivo);
                    if (result.type != ResultType.done) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('No se pudo abrir el archivo: ${result.message}'),
                            backgroundColor: Colors.orange,
                          ),
                        );
                      }
                    }
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

  Future<void> _seleccionarClienteYGenerar(BuildContext context, WidgetRef ref) async {
    // Navegar a selección de cliente (reutilizando pantalla de búsqueda o diálogo)
    // Por simplicidad en este paso, pedimos ID o mostramos "Selección pendiente"
    // Idealmente: pushNamed('seleccionar-cliente') y esperar resultado.
    
    // TODO: Implementar selector real. Por ahora usaremos un diálogo simple.
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reporte por Cliente'),
        content: const Text('Para este reporte se necesita seleccionar un cliente específico. \n\n(Funcionalidad de selector en desarrollo)'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          // ElevatedButton(onPressed: () {}, child: Text('Seleccionar')),
        ],
      ),
    );
  }
}
