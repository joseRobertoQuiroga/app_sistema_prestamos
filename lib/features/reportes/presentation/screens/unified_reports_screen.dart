import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import '../../../../presentation/widgets/app_drawer.dart';
import '../providers/reportes_provider.dart';
import '../../domain/entities/reportes_entities.dart';

import '../../../clientes/presentation/providers/cliente_provider.dart';
import '../../../prestamos/presentation/providers/prestamo_provider.dart';
import '../../../prestamos/domain/entities/prestamo.dart';
import '../../../pagos/presentation/providers/pago_provider.dart';
import '../../../caja/presentation/providers/caja_provider.dart';
import '../../../caja/domain/entities/movimiento.dart';
import '../../../informes/presentation/widgets/selector_cliente_widget.dart';
import '../../../informes/presentation/widgets/selector_prestamo_widget.dart';
import '../../../../core/utils/responsive_layout.dart';

class UnifiedReportsScreen extends ConsumerStatefulWidget {
  const UnifiedReportsScreen({super.key});

  @override
  ConsumerState<UnifiedReportsScreen> createState() => _UnifiedReportsScreenState();
}

class _UnifiedReportsScreenState extends ConsumerState<UnifiedReportsScreen> {
  TipoReporte _selectedReport = TipoReporte.carteraCompleta;
  int? _selectedId; // Para reportes específicos (Cliente, Préstamo, Caja)
  String? _selectedEntityName; // Nombre de la entidad seleccionada para UI
  String _searchQuery = '';

  // =========================================================================
  // HELPERS DE FILTRO POR PERÍODO
  // =========================================================================

  DateTimeRange _getRangoPeriodo(String periodo) {
    final ahora = DateTime.now();
    switch (periodo) {
      case 'ultimoTrimestre':
        return DateTimeRange(
          start: DateTime(ahora.year, ahora.month - 3, ahora.day),
          end: ahora,
        );
      case 'ultimoAnio':
        return DateTimeRange(
          start: DateTime(ahora.year - 1, ahora.month, ahora.day),
          end: ahora,
        );
      case 'todoElTiempo':
        return DateTimeRange(start: DateTime(2000), end: ahora);
      case 'ultimoMes':
      default:
        return DateTimeRange(
          start: DateTime(ahora.year, ahora.month - 1, ahora.day),
          end: ahora,
        );
    }
  }

  List<Prestamo> _filterByPeriodoPrestamos(List<Prestamo> list, String periodo) {
    final rango = _getRangoPeriodo(periodo);
    return list.where((p) =>
      !p.fechaRegistro.isBefore(rango.start) && !p.fechaRegistro.isAfter(rango.end)
    ).toList();
  }

  List<Movimiento> _filterByPeriodoMovimientos(List<Movimiento> list, String periodo) {
    final rango = _getRangoPeriodo(periodo);
    return list.where((m) =>
      !m.fecha.isBefore(rango.start) && !m.fecha.isAfter(rango.end)
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return ResponsiveLayout(
      mobile: Scaffold(
        backgroundColor: isDarkMode ? const Color(0xFF0F111A) : theme.scaffoldBackgroundColor,
        appBar: AppBar(
          title: const Text('Reportes'),
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            // Dropdown para cambiar reporte en móvil
            PopupMenuButton<TipoReporte>(
              icon: const Icon(Icons.description_outlined, color: Color(0xFF9333EA)),
              tooltip: 'Cambiar Tipo de Reporte',
              onSelected: (TipoReporte result) {
                setState(() {
                  _selectedReport = result;
                  _selectedId = null;
                  _selectedEntityName = null;
                  _searchQuery = '';
                });
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<TipoReporte>>[
                const PopupMenuDivider(),
                const PopupMenuItem(child: Text('CARTERA', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey))),
                const PopupMenuItem(value: TipoReporte.carteraCompleta, child: Text('Cartera Activa')),
                const PopupMenuItem(value: TipoReporte.moraDetallada, child: Text('Mora Detallada')),
                const PopupMenuItem(value: TipoReporte.prestamosCancelados, child: Text('Préstamos Cancelados')),
                
                const PopupMenuDivider(),
                const PopupMenuItem(child: Text('CLIENTES', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey))),
                const PopupMenuItem(value: TipoReporte.estadoCuentaCliente, child: Text('Historial Cliente')),
                const PopupMenuItem(value: TipoReporte.proyeccionCobros, child: Text('Proyección Cobros')),
                
                const PopupMenuDivider(),
                const PopupMenuItem(child: Text('FINANZAS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey))),
                const PopupMenuItem(value: TipoReporte.movimientosCaja, child: Text('Flujo de Caja')),
                const PopupMenuItem(value: TipoReporte.resumenEgresos, child: Text('Resumen Egresos')),
                const PopupMenuItem(value: TipoReporte.resumenIngresos, child: Text('Resumen Ingresos')),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                ref.invalidate(prestamosListProvider);
                ref.invalidate(clientesProvider);
                ref.invalidate(allPagosListProvider);
                ref.invalidate(movimientosGeneralesProvider);
              },
            ),
          ],
        ),
        drawer: const AppDrawer(),
        endDrawer: Drawer(
          backgroundColor: const Color(0xFF1E2130),
          child: _buildSidebar(context),
        ),
        body: Column(
          children: [
            _buildFilterBar(context, isMobile: true),
            Expanded(child: _buildPreviewArea(context, isMobile: true)),
            _buildFooter(context, isMobile: true),
          ],
        ),
      ),
      desktop: Scaffold(
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
                  _buildFilterBar(context, isMobile: false),
                  Expanded(child: _buildPreviewArea(context, isMobile: false)),
                  _buildFooter(context, isMobile: false),
                ],
              ),
            ),
            // Right Sidebar (Templates)
            _buildSidebar(context),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterBar(BuildContext context, {required bool isMobile}) {
    final periodo = ref.watch(periodoSeleccionadoProvider);
    final formato = ref.watch(formatoSeleccionadoProvider);
    final generando = ref.watch(generandoReporteProvider);

    if (isMobile) {
      return Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E2130),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildDropdown(
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
                    width: double.infinity,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildDropdown(
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
                    width: double.infinity,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildSelectionButton(width: double.infinity),
            const SizedBox(height: 16),
            generando
                ? const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
                      SizedBox(width: 8),
                      Text('Generando...', style: TextStyle(fontSize: 13, color: Colors.grey)),
                    ],
                  )
                : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _generarReporte(context, ref, _selectedReport),
                      icon: Icon(formato == 'pdf' ? Icons.picture_as_pdf : Icons.table_chart, size: 18),
                      label: Text('Exportar ${formato.toUpperCase()}'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: formato == 'pdf' ? const Color(0xFFDC2626) : const Color(0xFF16A34A),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
          ],
        ),
      );
    }

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
          generando
              ? const SizedBox(
                  width: 140,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
                      SizedBox(width: 8),
                      Text('Generando...', style: TextStyle(fontSize: 13, color: Colors.grey)),
                    ],
                  ),
                )
              : ElevatedButton.icon(
                  onPressed: () => _generarReporte(context, ref, _selectedReport),
                  icon: Icon(formato == 'pdf' ? Icons.picture_as_pdf : Icons.table_chart, size: 18),
                  label: Text('Exportar ${formato.toUpperCase()}'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: formato == 'pdf' ? const Color(0xFFDC2626) : const Color(0xFF16A34A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildSelectionButton({double? width}) {
    String label = '';
    IconData icon = Icons.search;
    bool visible = false;

    if (_selectedReport == TipoReporte.estadoCuentaCliente) {
      label = _selectedEntityName ?? 'Seleccionar Cliente';
      icon = Icons.person_search;
      visible = true;
    } else if (_selectedReport == TipoReporte.resumenPrestamo) {
      label = _selectedEntityName ?? 'Seleccionar Préstamo';
      icon = Icons.description;
      visible = true;
    } else if (_selectedReport == TipoReporte.resumenEgresos ||
               _selectedReport == TipoReporte.resumenIngresos ||
               _selectedReport == TipoReporte.movimientosCaja) {
      label = _selectedEntityName ?? 'Caja (Opcional)';
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
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: width ?? 200,
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
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      color: _selectedId != null ? Colors.white : Colors.grey,
                      overflow: TextOverflow.ellipsis,
                      fontWeight: _selectedId != null ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
                if (_selectedId != null)
                  GestureDetector(
                    onTap: () => setState(() { _selectedId = null; _selectedEntityName = null; }),
                    child: const Icon(Icons.close, size: 14, color: Colors.grey),
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
    double? width,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 4),
        Container(
          width: width ?? 200,
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

  Widget _buildPreviewArea(BuildContext context, {required bool isMobile}) {
    final generating = ref.watch(generandoReporteProvider);
    return Container(
      margin: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 16),
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
            child: isMobile
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(_selectedReport.icono, color: Colors.blue, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _selectedReport.nombre,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: _buildSearchField(width: double.infinity)),
                          IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            color: Colors.grey,
                            onPressed: _searchQuery.isNotEmpty ? () => setState(() => _searchQuery = '') : null,
                          ),
                        ],
                      ),
                    ],
                  )
                : Row(
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
                          if (_selectedEntityName != null)
                            Text(
                              'Filtro: $_selectedEntityName',
                              style: const TextStyle(color: Colors.blue, fontSize: 12),
                            ),
                        ],
                      ),
                      const Spacer(),
                      _buildSearchField(),
                      IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        color: Colors.grey,
                        tooltip: 'Limpiar búsqueda',
                        onPressed: _searchQuery.isNotEmpty ? () => setState(() => _searchQuery = '') : null,
                      ),
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
    final periodo = ref.watch(periodoSeleccionadoProvider);

    return prestamosAsync.when(
      data: (prestamos) {
        var filtered = _filterByPeriodoPrestamos(prestamos, periodo);
        filtered = _filterAndSearchPrestamos(filtered);

        List<String> columns;
        if (_selectedReport == TipoReporte.moraDetallada) {
          columns = const ['CLIENTE', 'PRÉSTAMO', 'VENCIMIENTO', 'DÍAS MORA', 'SALDO PEND.', 'TASA', 'CUOTA', 'ESTADO'];
        } else if (_selectedReport == TipoReporte.prestamosCancelados) {
          columns = const ['CLIENTE', 'PRÉSTAMO', 'MONTO ORIG.', 'TOTAL PAGADO', 'FECHA INICIO', 'PLAZO', 'ESTADO'];
        } else {
          columns = const ['CLIENTE', 'ID', 'MONTO', 'SALDO', 'TASA', 'CUOTA', 'ESTADO', 'VENCIMIENTO'];
        }

        return _buildScrollableTable(
          columns: columns,
          totalRows: filtered.length,
          rows: filtered.map((p) {
            List<DataCell> cells;
            if (_selectedReport == TipoReporte.moraDetallada) {
              final diasMora = DateTime.now().difference(p.fechaVencimiento).inDays.clamp(0, 9999);
              cells = [
                DataCell(Text(p.nombreCliente ?? 'N/A')),
                DataCell(Text(p.codigo)),
                DataCell(Text(DateFormat('dd/MM/yyyy').format(p.fechaVencimiento), style: const TextStyle(color: Colors.red))),
                DataCell(Text('$diasMora días', style: TextStyle(color: diasMora > 30 ? Colors.red : Colors.orange, fontWeight: FontWeight.bold))),
                DataCell(Text('Bs. ${p.saldoPendiente.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red))),
                DataCell(Text('${p.tasaInteres}%')),
                DataCell(Text('Bs. ${p.cuotaMensual.toStringAsFixed(2)}')),
                DataCell(_buildStatusBadge(p.estado.displayName)),
              ];
            } else if (_selectedReport == TipoReporte.prestamosCancelados) {
              cells = [
                DataCell(Text(p.nombreCliente ?? 'N/A')),
                DataCell(Text(p.codigo)),
                DataCell(Text('Bs. ${p.montoOriginal.toStringAsFixed(2)}')),
                DataCell(Text('Bs. ${p.montoTotal.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green))),
                DataCell(Text(DateFormat('dd/MM/yyyy').format(p.fechaInicio))),
                DataCell(Text('${p.plazoMeses} meses')),
                DataCell(_buildStatusBadge(p.estado.displayName)),
              ];
            } else {
              cells = [
                DataCell(Text(p.nombreCliente ?? 'N/A')),
                DataCell(Text(p.codigo)),
                DataCell(Text('Bs. ${p.montoOriginal.toStringAsFixed(2)}')),
                DataCell(Text('Bs. ${p.saldoPendiente.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold))),
                DataCell(Text('${p.tasaInteres}%')),
                DataCell(Text('Bs. ${p.cuotaMensual.toStringAsFixed(2)}')),
                DataCell(_buildStatusBadge(p.estado.displayName)),
                DataCell(Text(DateFormat('dd/MM/yyyy').format(p.fechaVencimiento))),
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
    if (_selectedId == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.person_search, size: 48, color: Colors.grey),
            const SizedBox(height: 12),
            const Text('Seleccione un cliente para ver su historial.', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _mostrarSelectorCliente(context),
              icon: const Icon(Icons.person_add, size: 18),
              label: const Text('Seleccionar Cliente'),
            ),
          ],
        ),
      );
    }

    final pagosAsync = ref.watch(allPagosListProvider);
    final prestamosAsync = ref.watch(prestamosListProvider);
    final periodo = ref.watch(periodoSeleccionadoProvider);

    return pagosAsync.when(
      data: (pagos) {
        return prestamosAsync.when(
          data: (prestamos) {
            var pagosCliente = pagos.where((p) => prestamos.any((pr) => pr.id == p.prestamoId && pr.clienteId == _selectedId)).toList();
            final rango = _getRangoPeriodo(periodo);
            pagosCliente = pagosCliente.where((p) =>
              !p.fechaPago.isBefore(rango.start) && !p.fechaPago.isAfter(rango.end)
            ).toList();

            if (_searchQuery.isNotEmpty) {
              pagosCliente = pagosCliente.where((p) {
                final prestamo = prestamos.firstWhere((pr) => pr.id == p.prestamoId, orElse: () => prestamos.first);
                return prestamo.codigo.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                    (p.metodoPago ?? '').toLowerCase().contains(_searchQuery.toLowerCase());
              }).toList();
            }

            return _buildScrollableTable(
              columns: const ['FECHA', 'PRÉSTAMO', 'MONTO TOTAL', 'CAPITAL', 'INTERÉS', 'MÉTODO'],
              totalRows: pagosCliente.length,
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
    if (_selectedId == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.description_outlined, size: 48, color: Colors.grey),
            const SizedBox(height: 12),
            const Text('Seleccione un préstamo para ver su resumen.', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _mostrarSelectorPrestamo(context),
              icon: const Icon(Icons.search, size: 18),
              label: const Text('Seleccionar Préstamo'),
            ),
          ],
        ),
      );
    }

    final prestamoDetailAsync = ref.watch(prestamoDetailProvider(_selectedId!));
    final pagosAsync = ref.watch(allPagosListProvider);

    return prestamoDetailAsync.when(
      data: (prestamo) => pagosAsync.when(
        data: (pagos) {
          var pagosPrestamo = pagos.where((p) => p.prestamoId == _selectedId).toList();

          if (_searchQuery.isNotEmpty) {
            pagosPrestamo = pagosPrestamo.where((p) =>
              p.codigo.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              (p.metodoPago ?? '').toLowerCase().contains(_searchQuery.toLowerCase())
            ).toList();
          }

          return Column(
            children: [
              _buildPrestamoHeader(prestamo),
              Expanded(
                child: _buildScrollableTable(
                  columns: const ['FECHA', 'CÓDIGO', 'MONTO', 'CAPITAL', 'INTERÉS', 'MORA', 'MÉTODO'],
                  totalRows: pagosPrestamo.length,
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
        // Mostrar todos los préstamos activos/mora, ordenados por vencimiento más próximo primero
        var prestamosVivos = prestamos
            .where((p) => p.estado == EstadoPrestamo.activo || p.estado == EstadoPrestamo.mora)
            .toList()
          ..sort((a, b) => a.fechaVencimiento.compareTo(b.fechaVencimiento));

        if (_searchQuery.isNotEmpty) {
          prestamosVivos = prestamosVivos.where((p) =>
            (p.nombreCliente ?? '').toLowerCase().contains(_searchQuery.toLowerCase()) ||
            p.codigo.toLowerCase().contains(_searchQuery.toLowerCase())
          ).toList();
        }

        return _buildScrollableTable(
          columns: const ['CLIENTE', 'PRÉSTAMO', 'CUOTA', 'TASA', 'VENCIMIENTO', 'DÍAS RESTANTES', 'ESTADO'],
          totalRows: prestamosVivos.length,
          rows: prestamosVivos.map((p) {
            final diasRestantes = p.fechaVencimiento.difference(DateTime.now()).inDays;
            final Color diasColor = diasRestantes < 0
                ? Colors.red.shade700
                : diasRestantes < 30
                    ? Colors.red
                    : diasRestantes < 60
                        ? Colors.orange
                        : Colors.green;
            final String diasText = diasRestantes < 0
                ? '${diasRestantes.abs()} días vencido'
                : '$diasRestantes días';

            return DataRow(cells: [
              DataCell(Text(p.nombreCliente ?? 'N/A')),
              DataCell(Text(p.codigo)),
              DataCell(Text('Bs. ${p.cuotaMensual.toStringAsFixed(2)}')),
              DataCell(Text('${p.tasaInteres}%')),
              DataCell(Text(DateFormat('dd/MM/yyyy').format(p.fechaVencimiento))),
              DataCell(Text(diasText, style: TextStyle(color: diasColor, fontWeight: FontWeight.bold))),
              DataCell(_buildStatusBadge(p.estado.displayName)),
            ]);
          }).toList(),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }

  Widget _buildMovimientosTable() {
    final movimientosAsync = ref.watch(movimientosGeneralesProvider);
    final periodo = ref.watch(periodoSeleccionadoProvider);

    return movimientosAsync.when(
      data: (movimientos) {
        var filtered = _filterByPeriodoMovimientos(movimientos, periodo);

        if (_selectedId != null) {
          filtered = filtered.where((m) => m.cajaId == _selectedId).toList();
        }
        if (_selectedReport == TipoReporte.resumenEgresos) {
          filtered = filtered.where((m) => m.esEgreso).toList();
        } else if (_selectedReport == TipoReporte.resumenIngresos) {
          filtered = filtered.where((m) => m.esIngreso).toList();
        }

        if (_searchQuery.isNotEmpty) {
          filtered = filtered.where((m) =>
            m.descripcion.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            m.categoria.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            m.tipo.toLowerCase().contains(_searchQuery.toLowerCase())
          ).toList();
        }

        final totalMonto = filtered.fold<double>(0, (sum, m) => sum + (m.esIngreso ? m.monto : -m.monto));

        return Column(
          children: [
            // Mini resumen
            if (filtered.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: Colors.black.withOpacity(0.15),
                child: Row(
                  children: [
                    Text('${filtered.length} registro(s)', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    const SizedBox(width: 16),
                    Text(
                      'Balance: Bs. ${totalMonto.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: totalMonto >= 0 ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: _buildScrollableTable(
                columns: const ['FECHA', 'TIPO', 'CATEGORÍA', 'MONTO', 'CAJA', 'CONCEPTO'],
                totalRows: filtered.length,
                rows: filtered.map((m) => DataRow(cells: [
                  DataCell(Text(DateFormat('dd/MM/yyyy').format(m.fecha))),
                  DataCell(Text(m.tipo, style: TextStyle(color: m.esIngreso ? Colors.green : Colors.red, fontWeight: FontWeight.bold))),
                  DataCell(Text(m.categoria)),
                  DataCell(Text('Bs. ${m.monto.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold))),
                  DataCell(Text('Caja #${m.cajaId}')),
                  DataCell(Text(m.descripcion)),
                ])).toList(),
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }

  Widget _buildScrollableTable({
    required List<String> columns,
    required List<DataRow> rows,
    int? totalRows,
  }) {
    if (rows.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 48, color: Colors.grey.shade700),
            const SizedBox(height: 12),
            const Text('No hay registros para el filtro seleccionado.', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return Column(
      children: [
        if (totalRows != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            color: Colors.black.withOpacity(0.1),
            alignment: Alignment.centerLeft,
            child: Text('Mostrando $totalRows resultado(s)', style: const TextStyle(color: Colors.grey, fontSize: 11)),
          ),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(Colors.black12),
                columns: columns.map((c) => DataColumn(label: Text(c, style: const TextStyle(fontSize: 12, color: Colors.grey)))).toList(),
                rows: rows,
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<Prestamo> _filterAndSearchPrestamos(List<Prestamo> prestamos) {
    var filtered = prestamos;
    if (_selectedReport == TipoReporte.moraDetallada) {
      filtered = filtered.where((p) => p.enMora).toList();
    } else if (_selectedReport == TipoReporte.prestamosCancelados) {
      filtered = filtered.where((p) => p.estado == EstadoPrestamo.pagado).toList();
    } else {
      // Cartera activa: solo activos y en mora
      filtered = filtered.where((p) => p.estado == EstadoPrestamo.activo || p.estado == EstadoPrestamo.mora).toList();
    }

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((p) => (p.nombreCliente ?? '').toLowerCase().contains(_searchQuery.toLowerCase()) ||
                                     (p.codigo).toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }
    return filtered;
  }

  Widget _buildSearchField({double? width}) {
    return Container(
      width: width ?? 220,
      height: 36,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: TextField(
        onChanged: (val) => setState(() => _searchQuery = val),
        controller: TextEditingController(text: _searchQuery)..selection = TextSelection.fromPosition(TextPosition(offset: _searchQuery.length)),
        style: const TextStyle(fontSize: 13, color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Buscar en resultados...',
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

  Widget _buildFooter(BuildContext context, {required bool isMobile}) {
    final periodo = ref.watch(periodoSeleccionadoProvider);
    final periodoLabel = periodo == 'ultimoMes' ? 'Último mes'
        : periodo == 'ultimoTrimestre' ? 'Último trimestre'
        : periodo == 'ultimoAnio' ? 'Último año'
        : 'Todo el tiempo';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(Icons.filter_alt, size: 14, color: Colors.grey.shade600),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              'Período: $periodoLabel', 
              style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (!isMobile) ...[
            if (_searchQuery.isNotEmpty) ...[
              const SizedBox(width: 12),
              Icon(Icons.search, size: 14, color: Colors.blue.shade300),
              const SizedBox(width: 4),
              Text('Búsqueda: "$_searchQuery"', style: TextStyle(color: Colors.blue.shade300, fontSize: 11)),
            ],
            const Spacer(),
            Text(DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now()),
                style: const TextStyle(color: Colors.grey, fontSize: 11)),
          ],
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
                _buildSidebarItem(TipoReporte.carteraCompleta, 'Cartera Activa', 'Préstamos vigentes con saldos y estados.', Icons.account_balance_wallet, _selectedReport == TipoReporte.carteraCompleta),
                _buildSidebarItem(TipoReporte.moraDetallada, 'Mora Detallada', 'Préstamos con cuotas vencidas y días atraso.', Icons.warning_amber, _selectedReport == TipoReporte.moraDetallada),
                _buildSidebarItem(TipoReporte.prestamosCancelados, 'Préstamos Cancelados', 'Historial de créditos finalizados.', Icons.check_circle, _selectedReport == TipoReporte.prestamosCancelados),
                _buildSidebarItem(TipoReporte.resumenPrestamo, 'Resumen de Préstamo', 'Información completa de un préstamo.', Icons.description, _selectedReport == TipoReporte.resumenPrestamo),

                _buildSidebarCategory('CLIENTES Y COBROS'),
                _buildSidebarItem(TipoReporte.estadoCuentaCliente, 'Historial de Cliente', 'Resumen detallado por cliente.', Icons.person, _selectedReport == TipoReporte.estadoCuentaCliente),
                _buildSidebarItem(TipoReporte.proyeccionCobros, 'Proyección de Cobros', 'Próximos vencimientos de cuotas.', Icons.event_note, _selectedReport == TipoReporte.proyeccionCobros),

                _buildSidebarCategory('FINANZAS Y CAJA'),
                _buildSidebarItem(TipoReporte.movimientosCaja, 'Flujo de Caja', 'Ingresos y egresos detallados.', Icons.trending_up, _selectedReport == TipoReporte.movimientosCaja),
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
            _selectedEntityName = null;
            _searchQuery = '';
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
          // Intentar obtener el nombre del cliente
          final clientesState = ref.read(clientesProvider);
          final cliente = clientesState.clientes.where((c) => c.id == clienteId).firstOrNull;
          final nombre = cliente != null ? cliente.nombre : 'Cliente #$clienteId';
          
          setState(() {
            _selectedId = clienteId;
            _selectedEntityName = nombre;
          });
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
          final prestamosAsync = ref.read(prestamosListProvider);
          String? nombre;
          prestamosAsync.whenData((prestamos) {
            final prestamo = prestamos.where((p) => p.id == prestamoId).firstOrNull;
            nombre = prestamo != null ? '${prestamo.codigo} - ${prestamo.nombreCliente ?? ''}' : 'Préstamo #$prestamoId';
          });
          setState(() {
            _selectedId = prestamoId;
            _selectedEntityName = nombre ?? 'Préstamo #$prestamoId';
          });
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
            data: (cajas) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Opción de "Todas las cajas"
                ListTile(
                  leading: const Icon(Icons.all_inclusive, color: Colors.grey),
                  title: const Text('Todas las cajas', style: TextStyle(color: Colors.grey)),
                  onTap: () {
                    setState(() { _selectedId = null; _selectedEntityName = null; });
                    Navigator.pop(context);
                  },
                ),
                const Divider(color: Colors.white12),
                ...cajas.map((caja) => ListTile(
                  leading: const Icon(Icons.account_balance, color: Colors.blue, size: 18),
                  title: Text(caja.nombre, style: const TextStyle(color: Colors.white)),
                  subtitle: Text('Saldo: Bs. ${caja.saldo.toStringAsFixed(2)}', style: const TextStyle(color: Colors.grey, fontSize: 11)),
                  onTap: () {
                    setState(() { _selectedId = caja.id; _selectedEntityName = caja.nombre; });
                    Navigator.pop(context);
                  },
                )),
              ],
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
        cajaId: (_selectedReport == TipoReporte.resumenEgresos ||
                 _selectedReport == TipoReporte.resumenIngresos ||
                 _selectedReport == TipoReporte.movimientosCaja) ? _selectedId : null,
        prestamoId: (_selectedReport == TipoReporte.resumenPrestamo) ? _selectedId : null,
      );

      final result = await generarReporte(parametros);

      result.fold(
        (failure) => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${failure.message}'),
            backgroundColor: Colors.red,
          ),
        ),
        (resultado) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✓ ${resultado.nombreArchivo}'),
              backgroundColor: Colors.green.shade700,
              action: SnackBarAction(
                label: 'Abrir',
                textColor: Colors.white,
                onPressed: () => OpenFile.open(resultado.rutaArchivo),
              ),
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
      case 'todoElTiempo': return PeriodoReporte.todoElTiempo;
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
