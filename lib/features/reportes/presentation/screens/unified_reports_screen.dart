import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import '../../../../presentation/widgets/app_drawer.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/reportes_provider.dart';
import '../../domain/entities/reportes_entities.dart';

import '../../../clientes/presentation/providers/cliente_provider.dart';
import '../../../prestamos/presentation/providers/prestamo_provider.dart';
import '../../../prestamos/domain/entities/prestamo.dart';
import '../../../pagos/presentation/providers/pago_provider.dart';
import '../../../caja/presentation/providers/caja_provider.dart';
import '../../../caja/domain/entities/movimiento.dart';
import '../../../caja/domain/entities/caja.dart';
import '../../../informes/presentation/widgets/selector_cliente_widget.dart';
import '../../../informes/presentation/widgets/selector_prestamo_widget.dart';

class UnifiedReportsScreen extends ConsumerStatefulWidget {
  const UnifiedReportsScreen({super.key});

  @override
  ConsumerState<UnifiedReportsScreen> createState() => _UnifiedReportsScreenState();
}

class _UnifiedReportsScreenState extends ConsumerState<UnifiedReportsScreen> {
  TipoReporte _selectedReport = TipoReporte.carteraCompleta;
  int? _selectedId; // Para reportes específicos (Cliente, Préstamo, Caja)
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF0F111A) : theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Reportes y Estadísticas'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(prestamosListProvider);
              ref.invalidate(clientesProvider);
              ref.invalidate(allPagosListProvider);
              ref.invalidate(movimientosGeneralesProvider);
            },
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: CircleAvatar(
              backgroundColor: Color(0xFF9333EA),
              child: Text('AD', style: TextStyle(color: Colors.white, fontSize: 12)),
            ),
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: Row(
        children: [
          // Main Content Area
          Expanded(
            child: Column(
              children: [
                _buildFilterBar(context),
                Expanded(child: _buildPreviewArea(context)),
                _buildFooter(context),
              ],
            ),
          ),
          // Right Sidebar (Templates)
          _buildSidebar(context),
        ],
      ),
    );
  }

  Widget _buildFilterBar(BuildContext context) {
    final periodo = ref.watch(periodoSeleccionadoProvider);
    final formato = ref.watch(formatoSeleccionadoProvider);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2130),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          _buildDropdown(
            label: 'Período',
            value: periodo,
            items: const [
              DropdownMenuItem(value: 'ultimoMes', child: Text('Este Mes')),
              DropdownMenuItem(value: 'ultimoTrimestre', child: Text('Último Trimestre')),
              DropdownMenuItem(value: 'ultimoAnio', child: Text('Último Año')),
              DropdownMenuItem(value: 'todoElTiempo', child: Text('Todo el Tiempo')),
            ],
            onChanged: (val) {
              if (val != null) ref.read(periodoSeleccionadoProvider.notifier).state = val;
            },
            icon: Icons.calendar_today,
          ),
          const SizedBox(width: 16),
          _buildDropdown(
            label: 'Formato',
            value: formato,
            items: const [
              DropdownMenuItem(value: 'pdf', child: Text('PDF')),
              DropdownMenuItem(value: 'excel', child: Text('Excel')),
            ],
            onChanged: (val) {
              if (val != null) ref.read(formatoSeleccionadoProvider.notifier).state = val;
            },
            icon: Icons.picture_as_pdf,
          ),
          const SizedBox(width: 16),
          _buildSelectionButton(),
          const Spacer(),
          ElevatedButton.icon(
            onPressed: () => _generarReporte(context, ref, _selectedReport),
            icon: const Icon(Icons.file_download),
            label: const Text('Exportar Datos'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionButton() {
    String label = '';
    IconData icon = Icons.search;
    bool visible = false;

    if (_selectedReport == TipoReporte.estadoCuentaCliente) {
      label = _selectedId == null ? 'Seleccionar Cliente' : 'Cambiar Cliente';
      icon = Icons.person_search;
      visible = true;
    } else if (_selectedReport == TipoReporte.resumenPrestamo) {
      label = _selectedId == null ? 'Seleccionar Préstamo' : 'Cambiar Préstamo';
      icon = Icons.description;
      visible = true;
    } else if (_selectedReport == TipoReporte.resumenEgresos || _selectedReport == TipoReporte.resumenIngresos) {
      label = _selectedId == null ? 'Seleccionar Caja (Opcional)' : 'Cambiar Caja';
      icon = Icons.account_balance;
      visible = true;
    }

    if (!visible) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Entidad', style: TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 4),
        InkWell(
          onTap: () {
            if (_selectedReport == TipoReporte.estadoCuentaCliente) {
              _mostrarSelectorCliente(context);
            } else if (_selectedReport == TipoReporte.resumenPrestamo) {
              _mostrarSelectorPrestamo(context);
            } else {
              _mostrarSelectorCaja(context);
            }
          },
          child: Container(
            width: 200,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _selectedId != null ? const Color(0xFF6366F1) : Colors.transparent),
            ),
            child: Row(
              children: [
                Icon(icon, color: _selectedId != null ? const Color(0xFF6366F1) : Colors.grey, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _selectedId == null ? label : 'ID: #$_selectedId',
                    style: const TextStyle(fontSize: 14, color: Colors.white, overflow: TextOverflow.ellipsis),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<DropdownMenuItem<String>> items,
    required void Function(String?) onChanged,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 4),
        Container(
          width: 200,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              items: items,
              onChanged: onChanged,
              icon: Icon(icon, color: Colors.grey, size: 16),
              isExpanded: true,
              dropdownColor: const Color(0xFF1E2130),
              style: const TextStyle(fontSize: 14, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPreviewArea(BuildContext context) {
    final generating = ref.watch(generandoReporteProvider);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2130),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          // Preview Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(_selectedReport.icono, color: Colors.blue),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Vista Previa: ${_selectedReport.nombre}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    if (_selectedId != null)
                      Text('Filtro específico ID: #$_selectedId', style: const TextStyle(color: Colors.blue, fontSize: 12)),
                  ],
                ),
                const Spacer(),
                _buildSearchField(),
                IconButton(icon: const Icon(Icons.filter_list), onPressed: () {}),
                IconButton(icon: const Icon(Icons.view_headline), onPressed: () {}),
              ],
            ),
          ),
          const Divider(height: 1, color: Colors.white12),
          // Dynamic Content
          Expanded(
            child: generating
                ? const Center(child: CircularProgressIndicator())
                : _buildDynamicContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildDynamicContent() {
    switch (_selectedReport) {
      case TipoReporte.carteraCompleta:
      case TipoReporte.moraDetallada:
      case TipoReporte.prestamosCancelados:
        return _buildCarteraTable();
      case TipoReporte.proyeccionCobros:
        return _buildProyeccionTable();
      case TipoReporte.estadoCuentaCliente:
        return _buildHistorialClienteTable();
      case TipoReporte.resumenPrestamo:
        return _buildResumenPrestamoTable();
      case TipoReporte.resumenEgresos:
      case TipoReporte.resumenIngresos:
      case TipoReporte.movimientosCaja:
        return _buildMovimientosTable();
      default:
        return const Center(child: Text('Vista previa para este reporte todavía no implementada.'));
    }
  }

  Widget _buildCarteraTable() {
    final prestamosAsync = ref.watch(prestamosListProvider);
    return prestamosAsync.when(
      data: (prestamos) {
        final filtered = _filterAndSearchPrestamos(prestamos);
        
        List<String> columns;
        if (_selectedReport == TipoReporte.moraDetallada) {
          columns = const ['CLIENTE', 'PRÉSTAMO', 'VENCIMIENTO', 'SALDO PEND.', 'ESTADO'];
        } else if (_selectedReport == TipoReporte.prestamosCancelados) {
          columns = const ['CLIENTE', 'PRÉSTAMO', 'MONTO ORIG.', 'TOTAL PAGADO', 'ESTADO'];
        } else {
          columns = const ['CLIENTE', 'ID', 'MONTO', 'SALDO', 'ESTADO', 'VENCIMIENTO'];
        }

        return _buildScrollableTable(
          columns: columns,
          rows: filtered.map((p) {
            List<DataCell> cells;
            if (_selectedReport == TipoReporte.moraDetallada) {
              cells = [
                DataCell(Text(p.nombreCliente ?? 'N/A')),
                DataCell(Text(p.codigo)),
                DataCell(Text(DateFormat('dd/MM/yyyy').format(p.fechaVencimiento), style: const TextStyle(color: Colors.red))),
                DataCell(Text('Bs. ${p.saldoPendiente.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red))),
                DataCell(_buildStatusBadge(p.estado.displayName)),
              ];
            } else if (_selectedReport == TipoReporte.prestamosCancelados) {
              cells = [
                DataCell(Text(p.nombreCliente ?? 'N/A')),
                DataCell(Text(p.codigo)),
                DataCell(Text('Bs. ${p.montoOriginal.toStringAsFixed(2)}')),
                DataCell(Text('Bs. ${p.montoTotal.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green))),
                DataCell(_buildStatusBadge(p.estado.displayName)),
              ];
            } else {
              cells = [
                DataCell(Text(p.nombreCliente ?? 'N/A')),
                DataCell(Text(p.codigo)),
                DataCell(Text('Bs. ${p.montoOriginal.toStringAsFixed(2)}')),
                DataCell(Text('Bs. ${p.saldoPendiente.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold))),
                DataCell(_buildStatusBadge(p.estado.displayName)),
                DataCell(Text(DateFormat('dd/MM/yyyy').format(p.fechaInicio))),
              ];
            }
            return DataRow(cells: cells);
          }).toList(),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }

  Widget _buildHistorialClienteTable() {
    if (_selectedId == null) return const Center(child: Text('Por favor seleccione un cliente para ver su historial.'));
    
    final pagosAsync = ref.watch(allPagosListProvider);
    final prestamosAsync = ref.watch(prestamosListProvider);
    
    return pagosAsync.when(
      data: (pagos) {
        return prestamosAsync.when(
          data: (prestamos) {
            final pagosCliente = pagos.where((p) => prestamos.any((pr) => pr.id == p.prestamoId && pr.clienteId == _selectedId)).toList();
            return _buildScrollableTable(
              columns: const ['FECHA', 'PRÉSTAMO', 'MONTO TOTAL', 'CAPITAL', 'INTERÉS', 'MÉTODO'],
              rows: pagosCliente.map((p) {
                final prestamo = prestamos.firstWhere((pr) => pr.id == p.prestamoId);
                return DataRow(cells: [
                  DataCell(Text(DateFormat('dd/MM/yyyy').format(p.fechaPago))),
                  DataCell(Text(prestamo.codigo)),
                  DataCell(Text('Bs. ${p.montoTotal.toStringAsFixed(2)}')),
                  DataCell(Text('Bs. ${p.montoCapital.toStringAsFixed(2)}')),
                  DataCell(Text('Bs. ${p.montoInteres.toStringAsFixed(2)}')),
                  DataCell(Text(p.metodoPago ?? 'Efectivo')),
                ]);
              }).toList(),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }

  Widget _buildResumenPrestamoTable() {
    if (_selectedId == null) return const Center(child: Text('Por favor seleccione un préstamo para ver su resumen.'));
    
    final prestamoDetailAsync = ref.watch(prestamoDetailProvider(_selectedId!));
    final pagosAsync = ref.watch(allPagosListProvider);
    
    return prestamoDetailAsync.when(
      data: (prestamo) => pagosAsync.when(
        data: (pagos) {
          final pagosPrestamo = pagos.where((p) => p.prestamoId == _selectedId).toList();
          return Column(
            children: [
              _buildPrestamoHeader(prestamo),
              Expanded(
                child: _buildScrollableTable(
                  columns: const ['FECHA', 'CÓDIGO', 'MONTO', 'CAPITAL', 'INTERÉS', 'MORA', 'MÉTODO'],
                  rows: pagosPrestamo.map((p) => DataRow(cells: [
                    DataCell(Text(DateFormat('dd/MM/yyyy').format(p.fechaPago))),
                    DataCell(Text(p.codigo)),
                    DataCell(Text('Bs. ${p.montoTotal.toStringAsFixed(2)}')),
                    DataCell(Text('Bs. ${p.montoCapital.toStringAsFixed(2)}')),
                    DataCell(Text('Bs. ${p.montoInteres.toStringAsFixed(2)}')),
                    DataCell(Text('Bs. ${p.montoMora.toStringAsFixed(2)}', style: TextStyle(color: p.montoMora > 0 ? Colors.red : null))),
                    DataCell(Text(p.metodoPago ?? 'Efectivo')),
                  ])).toList(),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error al cargar pagos: $e')),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error al cargar préstamo: $e')),
    );
  }

  Widget _buildPrestamoHeader(Prestamo p) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildHeaderItem('Cliente', p.nombreCliente ?? 'N/A'),
          _buildHeaderItem('Código', p.codigo),
          _buildHeaderItem('Monto Original', 'Bs. ${p.montoOriginal.toStringAsFixed(2)}'),
          _buildHeaderItem('Saldo Actual', 'Bs. ${p.saldoPendiente.toStringAsFixed(2)}', isBold: true),
          _buildHeaderItem('Estado', p.estado.displayName),
        ],
      ),
    );
  }

  Widget _buildHeaderItem(String label, String value, {bool isBold = false}) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal, color: isBold ? Colors.blue : Colors.white)),
      ],
    );
  }

  Widget _buildProyeccionTable() {
    final prestamosAsync = ref.watch(prestamosListProvider);
    return prestamosAsync.when(
      data: (prestamos) {
        final prestamosVivos = prestamos.where((p) => p.estado == EstadoPrestamo.activo || p.estado == EstadoPrestamo.mora).toList();
        return _buildScrollableTable(
          columns: const ['CLIENTE', 'PRÉSTAMO', 'CUOTA MENSUAL', 'TASA', 'VENCIMIENTO', 'ACCIONES'],
          rows: prestamosVivos.map((p) => DataRow(cells: [
            DataCell(Text(p.nombreCliente ?? 'N/A')),
            DataCell(Text(p.codigo)),
            DataCell(Text('Bs. ${p.cuotaMensual.toStringAsFixed(2)}')),
            DataCell(Text('${p.tasaInteres}%')),
            DataCell(Text(DateFormat('dd/MM/yyyy').format(p.fechaVencimiento))),
            DataCell(IconButton(icon: const Icon(Icons.info_outline, size: 18), onPressed: () {
              setState(() {
                _selectedReport = TipoReporte.resumenPrestamo;
                _selectedId = p.id;
              });
            })),
          ])).toList(),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }

  Widget _buildMovimientosTable() {
    final movimientosAsync = ref.watch(movimientosGeneralesProvider);
    return movimientosAsync.when(
      data: (movimientos) {
        var filtered = movimientos;
        if (_selectedId != null) {
          filtered = filtered.where((m) => m.cajaId == _selectedId).toList();
        }
        if (_selectedReport == TipoReporte.resumenEgresos) {
          filtered = filtered.where((m) => m.esEgreso).toList();
        } else if (_selectedReport == TipoReporte.resumenIngresos) {
          filtered = filtered.where((m) => m.esIngreso).toList();
        }

        return _buildScrollableTable(
          columns: const ['FECHA', 'TIPO', 'CATEGORÍA', 'MONTO', 'CAJA', 'CONCEPTO'],
          rows: filtered.map((m) => DataRow(cells: [
            DataCell(Text(DateFormat('dd/MM/yyyy').format(m.fecha))),
            DataCell(Text(m.tipo, style: TextStyle(color: m.esIngreso ? Colors.green : Colors.red))),
            DataCell(Text(m.categoria)),
            DataCell(Text('Bs. ${m.monto.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold))),
            DataCell(Text('Caja #${m.cajaId}')),
            DataCell(Text(m.descripcion)),
          ])).toList(),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }

  Widget _buildScrollableTable({required List<String> columns, required List<DataRow> rows}) {
    if (rows.isEmpty) return const Center(child: Text('No hay registros para mostrar.'));
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(Colors.black12),
          columns: columns.map((c) => DataColumn(label: Text(c, style: const TextStyle(fontSize: 12, color: Colors.grey)))).toList(),
          rows: rows,
        ),
      ),
    );
  }

  List<Prestamo> _filterAndSearchPrestamos(List<Prestamo> prestamos) {
    var filtered = prestamos;
    if (_selectedReport == TipoReporte.moraDetallada) {
      filtered = filtered.where((p) => p.enMora).toList();
    } else if (_selectedReport == TipoReporte.prestamosCancelados) {
      filtered = filtered.where((p) => p.estado == EstadoPrestamo.pagado).toList();
    }

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((p) => (p.nombreCliente ?? '').toLowerCase().contains(_searchQuery.toLowerCase()) || 
                                     (p.codigo).toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }
    return filtered;
  }

  Widget _buildSearchField() {
    return Container(
      width: 200,
      height: 36,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: TextField(
        onChanged: (val) => setState(() => _searchQuery = val),
        decoration: InputDecoration(
          hintText: 'Buscar...',
          hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
          prefixIcon: const Icon(Icons.search, size: 18, color: Colors.grey),
          filled: true,
          fillColor: Colors.black.withOpacity(0.2),
          contentPadding: EdgeInsets.zero,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String text) {
    Color color = Colors.blue;
    if (text.toLowerCase().contains('mora')) color = Colors.red;
    else if (text.toLowerCase().contains('pagado')) color = Colors.green;
    else if (text.toLowerCase().contains('pendiente')) color = Colors.orange;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(text, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const Text('Vistas dinámicas habilitadas', style: TextStyle(color: Colors.grey, fontSize: 11)),
          const SizedBox(width: 16),
          IconButton(icon: const Icon(Icons.chevron_left, size: 20), onPressed: () {}),
          IconButton(icon: const Icon(Icons.chevron_right, size: 20), onPressed: () {}),
        ],
      ),
    );
  }

  Widget _buildSidebar(BuildContext context) {
    return Container(
      width: 320,
      decoration: BoxDecoration(
        color: const Color(0xFF1E2130),
        border: Border(left: BorderSide(color: Colors.white.withOpacity(0.05))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.style, color: Colors.purple, size: 20),
                    SizedBox(width: 12),
                    Text('Plantillas de Reporte', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
                SizedBox(height: 8),
                Text('Selecciona un tipo de reporte para visualizar.', style: TextStyle(color: Colors.grey, fontSize: 13)),
              ],
            ),
          ),
          const Divider(height: 1, color: Colors.white12),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 16),
              children: [
                _buildSidebarCategory('CARTERA DE CRÉDITOS'),
                _buildSidebarItem(TipoReporte.carteraCompleta, 'Cartera Activa', 'Listado completo de préstamos vigentes con saldos y estados.', Icons.account_balance_wallet, _selectedReport == TipoReporte.carteraCompleta),
                _buildSidebarItem(TipoReporte.moraDetallada, 'Mora Detallada', 'Préstamos con cuotas vencidas y días de atraso.', Icons.warning_amber, _selectedReport == TipoReporte.moraDetallada),
                _buildSidebarItem(TipoReporte.prestamosCancelados, 'Préstamos Cancelados', 'Historial de créditos finalizados exitosamente.', Icons.check_circle, _selectedReport == TipoReporte.prestamosCancelados),
                _buildSidebarItem(TipoReporte.resumenPrestamo, 'Resumen de Préstamo', 'Información completa y directa de un préstamo.', Icons.description, _selectedReport == TipoReporte.resumenPrestamo),
                
                _buildSidebarCategory('CLIENTES Y COBROS'),
                _buildSidebarItem(TipoReporte.estadoCuentaCliente, 'Historial de Cliente', 'Resumen general o detallado por cada cliente.', Icons.person, _selectedReport == TipoReporte.estadoCuentaCliente),
                _buildSidebarItem(TipoReporte.proyeccionCobros, 'Proyección de Cobros', 'Próximos vencimientos de cuotas.', Icons.event_note, _selectedReport == TipoReporte.proyeccionCobros),

                _buildSidebarCategory('FINANZAS Y CAJA'),
                _buildSidebarItem(TipoReporte.movimientosCaja, 'Flujo de Caja', 'Ingresos y egresos detallados por sucursal.', Icons.trending_up, _selectedReport == TipoReporte.movimientosCaja),
                _buildSidebarItem(TipoReporte.resumenEgresos, 'Resumen de Egresos', 'Detalle general o por caja de salidas.', Icons.file_upload, _selectedReport == TipoReporte.resumenEgresos),
                _buildSidebarItem(TipoReporte.resumenIngresos, 'Resumen de Ingresos', 'Detalle general o por caja de entradas.', Icons.file_download, _selectedReport == TipoReporte.resumenIngresos),
              ],
            ),
          ),
          const Divider(height: 1, color: Colors.white12),
          _buildLastUpdate(),
        ],
      ),
    );
  }

  Widget _buildSidebarCategory(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
      child: Text(
        title,
        style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1.2),
      ),
    );
  }

  Widget _buildSidebarItem(TipoReporte tipo, String title, String subtitle, IconData icon, bool isSelected) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF6366F1).withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: isSelected ? Border.all(color: const Color(0xFF6366F1).withOpacity(0.5)) : null,
      ),
      child: ListTile(
        onTap: () {
          setState(() {
            _selectedReport = tipo;
            _selectedId = null;
          });
        },
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: isSelected ? const Color(0xFF6366F1) : Colors.grey),
        ),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isSelected ? const Color(0xFF6366F1) : Colors.white)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        trailing: isSelected ? const CircleAvatar(radius: 3, backgroundColor: Color(0xFF6366F1)) : null,
      ),
    );
  }

  Widget _buildLastUpdate() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Text('Última actualización de datos:', style: TextStyle(color: Colors.grey, fontSize: 10)),
          const SizedBox(height: 4),
          Text(
            DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.now()),
            style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  void _mostrarSelectorCliente(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => SelectorClienteWidget(
        onClienteSeleccionado: (clienteId) {
          setState(() => _selectedId = clienteId);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _mostrarSelectorPrestamo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => SelectorPrestamoWidget(
        onPrestamoSeleccionado: (prestamoId) {
          setState(() => _selectedId = prestamoId);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _mostrarSelectorCaja(BuildContext context) {
    final cajasAsync = ref.watch(cajasListProvider);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Seleccionar Caja'),
        backgroundColor: const Color(0xFF1E2130),
        titleTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        content: SizedBox(
          width: double.maxFinite,
          child: cajasAsync.when(
            data: (cajas) => ListView.builder(
              shrinkWrap: true,
              itemCount: cajas.length,
              itemBuilder: (context, index) => ListTile(
                title: Text(cajas[index].nombre, style: const TextStyle(color: Colors.white)),
                onTap: () {
                  setState(() => _selectedId = cajas[index].id);
                  Navigator.pop(context);
                },
              ),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('Error: $e', style: const TextStyle(color: Colors.red)),
          ),
        ),
      ),
    );
  }

  Future<void> _generarReporte(BuildContext context, WidgetRef ref, TipoReporte tipo) async {
    try {
      ref.read(generandoReporteProvider.notifier).state = true;
      final generarReporte = ref.read(generarReporteUseCaseProvider);
      final periodoStr = ref.read(periodoSeleccionadoProvider);
      final formatoStr = ref.read(formatoSeleccionadoProvider);

      final parametros = ConfiguracionReporte(
        tipo: tipo,
        formato: formatoStr == 'pdf' ? FormatoReporte.pdf : FormatoReporte.excel,
        periodo: _getPeriodo(periodoStr),
        clienteId: (_selectedReport == TipoReporte.estadoCuentaCliente) ? _selectedId : null,
        cajaId: (_selectedReport == TipoReporte.resumenEgresos || _selectedReport == TipoReporte.resumenIngresos) ? _selectedId : null,
      );

      final result = await generarReporte(parametros);

      result.fold(
        (failure) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${failure.message}'), backgroundColor: Colors.red)),
        (resultado) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Reporte generado: ${resultado.nombreArchivo}'),
              backgroundColor: Colors.green,
              action: SnackBarAction(label: 'Abrir', textColor: Colors.white, onPressed: () => OpenFile.open(resultado.rutaArchivo)),
            ),
          );
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    } finally {
      ref.read(generandoReporteProvider.notifier).state = false;
    }
  }

  PeriodoReporte _getPeriodo(String periodo) {
    switch (periodo) {
      case 'ultimoMes': return PeriodoReporte.ultimoMes;
      case 'ultimoTrimestre': return PeriodoReporte.ultimoTrimestre;
      case 'ultimoAnio': return PeriodoReporte.ultimoAnio;
      default: return PeriodoReporte.ultimoMes;
    }
  }
}

extension TipoReporteIcono on TipoReporte {
  IconData get icono {
    switch (this) {
      case TipoReporte.carteraCompleta: return Icons.account_balance_wallet;
      case TipoReporte.moraDetallada: return Icons.warning_amber;
      case TipoReporte.prestamosCancelados: return Icons.check_circle;
      case TipoReporte.resumenPrestamo: return Icons.description;
      case TipoReporte.estadoCuentaCliente: return Icons.person;
      case TipoReporte.proyeccionCobros: return Icons.event_note;
      default: return Icons.insert_drive_file;
    }
  }
}
