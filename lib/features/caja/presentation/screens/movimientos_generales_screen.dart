import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../presentation/widgets/app_drawer.dart';
import '../../../../core/utils/formatters.dart';
import '../providers/caja_provider.dart';
import '../../../pagos/presentation/providers/pago_provider.dart';
import 'package:open_file/open_file.dart';
import '../../../reportes/presentation/providers/reportes_provider.dart';
import '../../../reportes/data/services/excel_service.dart' as excel_svc;
import '../../domain/entities/movimiento.dart' as entity;

/// Pantalla de Movimientos Generales del sistema (Rediseñada con Estética Premium)
class MovimientosGeneralesScreen extends ConsumerStatefulWidget {
  const MovimientosGeneralesScreen({super.key});

  @override
  ConsumerState<MovimientosGeneralesScreen> createState() => _MovimientosGeneralesScreenState();
}

class _MovimientosGeneralesScreenState extends ConsumerState<MovimientosGeneralesScreen> {
  DateTime _fechaInicio = DateTime.now().subtract(const Duration(days: 30));
  DateTime _fechaFin = DateTime.now();
  int? _cajaSeleccionada;
  String _tipoSeleccionado = 'TODOS'; // TODOS, INGRESO, EGRESO, TRANSFERENCIA
  String? _categoriaSeleccionada;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final movimientosAsync = ref.watch(movimientosGeneralesProvider);
    final cajasAsync = ref.watch(cajasProvider);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F111A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          'Movimientos Generales',
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF1E293B),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: isDark ? const Color(0xFF1E2130) : Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: isDark ? Colors.white : const Color(0xFF1E293B)),
        actions: [
          IconButton(
            icon: const Icon(Icons.table_chart_rounded, color: Colors.green),
            tooltip: 'Exportar a Excel',
            onPressed: () {
              final mAsync = ref.read(movimientosGeneralesProvider);
              final cAsync = ref.read(cajasProvider);
              mAsync.whenData((movimientos) {
                var movimientosFiltrados = movimientos.where((m) {
                  final enRango = m.fecha.isAfter(_fechaInicio.subtract(const Duration(days: 1))) &&
                      m.fecha.isBefore(_fechaFin.add(const Duration(days: 1)));
                  if (!enRango) return false;
                  if (_cajaSeleccionada != null && m.cajaId != _cajaSeleccionada) return false;
                  if (_tipoSeleccionado != 'TODOS') {
                    if (_tipoSeleccionado == 'TRANSFERENCIA') {
                      if (m.categoria != 'TRANSFERENCIA') return false;
                    } else {
                      if (m.tipo != _tipoSeleccionado) return false;
                    }
                  }
                  if (_categoriaSeleccionada != null && m.categoria != _categoriaSeleccionada) return false;
                  return true;
                }).toList();
                movimientosFiltrados.sort((a, b) => b.fecha.compareTo(a.fecha));
                _exportarExcel(movimientosFiltrados, cAsync);
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_rounded, color: Colors.redAccent),
            tooltip: 'Exportar a PDF',
            onPressed: () {
              final mAsync = ref.read(movimientosGeneralesProvider);
              final cAsync = ref.read(cajasProvider);
              mAsync.whenData((movimientos) {
                var movimientosFiltrados = movimientos.where((m) {
                  final enRango = m.fecha.isAfter(_fechaInicio.subtract(const Duration(days: 1))) &&
                      m.fecha.isBefore(_fechaFin.add(const Duration(days: 1)));
                  if (!enRango) return false;
                  if (_cajaSeleccionada != null && m.cajaId != _cajaSeleccionada) return false;
                  if (_tipoSeleccionado != 'TODOS') {
                    if (_tipoSeleccionado == 'TRANSFERENCIA') {
                      if (m.categoria != 'TRANSFERENCIA') return false;
                    } else {
                      if (m.tipo != _tipoSeleccionado) return false;
                    }
                  }
                  if (_categoriaSeleccionada != null && m.categoria != _categoriaSeleccionada) return false;
                  return true;
                }).toList();
                movimientosFiltrados.sort((a, b) => b.fecha.compareTo(a.fecha));
                _exportarPDF(movimientosFiltrados, cAsync);
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(movimientosGeneralesProvider),
          ),
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            onPressed: () => _mostrarFiltros(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: const AppDrawer(),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 900;

          return movimientosAsync.when(
            data: (movimientos) {
              // Aplicar filtros (Lógica original intacta)
              var movimientosFiltrados = movimientos.where((m) {
                final enRango = m.fecha.isAfter(_fechaInicio.subtract(const Duration(days: 1))) &&
                    m.fecha.isBefore(_fechaFin.add(const Duration(days: 1)));
                if (!enRango) return false;
                if (_cajaSeleccionada != null && m.cajaId != _cajaSeleccionada) return false;
                if (_tipoSeleccionado != 'TODOS') {
                  if (_tipoSeleccionado == 'TRANSFERENCIA') {
                    if (m.categoria != 'TRANSFERENCIA') return false;
                  } else {
                    if (m.tipo != _tipoSeleccionado) return false;
                  }
                }
                if (_categoriaSeleccionada != null && m.categoria != _categoriaSeleccionada) return false;
                return true;
              }).toList();

              movimientosFiltrados.sort((a, b) => b.fecha.compareTo(a.fecha));

              final totalIngresos = movimientosFiltrados
                  .where((m) => m.tipo == 'INGRESO')
                  .fold<double>(0, (sum, m) => sum + m.monto);
              final totalEgresos = movimientosFiltrados
                  .where((m) => m.tipo == 'EGRESO')
                  .fold<double>(0, (sum, m) => sum + m.monto);

              if (isMobile) {
                return _buildMobileLayout(movimientosFiltrados, totalIngresos, totalEgresos, cajasAsync);
              } else {
                return _buildDesktopLayout(movimientosFiltrados, totalIngresos, totalEgresos, cajasAsync);
              }
            },
            loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF8B5CF6))),
            error: (error, _) => _buildErrorState(error.toString()),
          );
        },
      ),
    );
  }

  Widget _buildMobileLayout(List<dynamic> movimientos, double ingresos, double egresos, AsyncValue<List<dynamic>> cajasAsync) {
    return Column(
      children: [
        _buildSimplifiedFilterResumen(),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildModernStatsHeader(ingresos, egresos),
              const SizedBox(height: 16),
              ...movimientos.map((m) => _buildModernMovimientoCard(m, cajasAsync)),
              if (movimientos.isEmpty) _buildEmptyState(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopLayout(List<dynamic> movimientos, double ingresos, double egresos, AsyncValue<List<dynamic>> cajasAsync) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Lista principal (70%)
        Expanded(
          flex: 7,
          child: Column(
            children: [
              _buildSimplifiedFilterResumen(),
              Expanded(
                child: movimientos.isEmpty 
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      itemCount: movimientos.length,
                      itemBuilder: (context, index) => _buildModernMovimientoCard(movimientos[index], cajasAsync),
                    ),
              ),
            ],
          ),
        ),
        // Sidebar (30%)
        Expanded(
          flex: 3,
          child: Container(
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E2130) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'RESUMEN FINANCIERO',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 24),
                _buildSidebarStat(
                  'Ingresos Totales',
                  ingresos,
                  const Color(0xFF10B981),
                  Icons.arrow_downward_rounded,
                ),
                const SizedBox(height: 16),
                _buildSidebarStat(
                  'Egresos Totales',
                  egresos,
                  const Color(0xFFEF4444),
                  Icons.arrow_upward_rounded,
                ),
                const Divider(height: 32),
                _buildSidebarBalance(ingresos - egresos),
                const SizedBox(height: 24),
                _buildSidebarQuickActions(),
                const Spacer(),
                _buildSidebarInfo(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModernStatsHeader(double ingresos, double egresos) {
    final balance = ingresos - egresos;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B5CF6).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Balance del Periodo',
            style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          Text(
            Formatters.formatCurrency(balance),
            style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMobileStatItem('Ingresos', ingresos, Icons.add_circle_outline),
              Container(width: 1, height: 30, color: Colors.white24),
              _buildMobileStatItem('Egresos', egresos, Icons.remove_circle_outline),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMobileStatItem(String label, double val, IconData icon) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, size: 12, color: Colors.white70),
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
          ],
        ),
        Text(
          Formatters.formatCurrency(val),
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildSidebarStat(String label, double val, Color color, IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Icon(icon, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 11, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B))),
              Text(Formatters.formatCurrency(val), style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarBalance(double balance) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = balance >= 0 ? const Color(0xFF8B5CF6) : const Color(0xFFEF4444);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('BALANCE NETO', style: TextStyle(fontSize: 11, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B), fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(
          Formatters.formatCurrency(balance),
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }

  Widget _buildModernMovimientoCard(dynamic movimiento, AsyncValue<List<dynamic>> cajasAsync) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final esIngreso = movimiento.tipo == 'INGRESO';
    final isTransfer = movimiento.categoria == 'TRANSFERENCIA';
    
    Color typeColor = esIngreso ? const Color(0xFF10B981) : const Color(0xFFEF4444);
    IconData typeIcon = esIngreso ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded;
    
    if (isTransfer) {
      typeColor = const Color(0xFF3B82F6);
      typeIcon = Icons.swap_horiz_rounded;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2130) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFF1F5F9)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: typeColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(typeIcon, color: typeColor),
        ),
        title: Text(
          movimiento.descripcion,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF1E293B),
            fontSize: 15,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                children: [
                  cajasAsync.when(
                    data: (cajas) {
                      try {
                        final caja = cajas.firstWhere((c) => c.id == movimiento.cajaId);
                        return _buildCardBadge(caja.nombre, isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9));
                      } catch (_) {
                        return _buildCardBadge('Desconocida', Colors.grey.withOpacity(0.2));
                      }
                    },
                    loading: () => const SizedBox(width: 50, height: 10, child: LinearProgressIndicator()),
                    error: (_, __) => _buildCardBadge('N/A', Colors.red.withOpacity(0.1)),
                  ),
                  const SizedBox(width: 8),
                  _buildCardBadge(movimiento.categoria, typeColor.withOpacity(0.1), textColor: typeColor),
                ],
              ),
            ),
            if (movimiento.categoria == 'PAGO' && movimiento.pagoId != null)
              _buildPagoDetalleSub(movimiento.pagoId!),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${esIngreso ? "+" : "-"} ${Formatters.formatCurrency(movimiento.monto)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: typeColor,
                fontSize: 16,
              ),
            ),
            Text(
              DateFormat('dd/MM HH:mm').format(movimiento.fecha),
              style: TextStyle(fontSize: 11, color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPagoDetalleSub(int pagoId) {
    final pagosAsync = ref.watch(allPagosListProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return pagosAsync.when(
      data: (pagos) {
        try {
          final pago = pagos.firstWhere((p) => p.id == pagoId);
          return Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(height: 16),
                Row(
                  children: [
                    _buildDetalleItem('Capital', pago.montoCapital, Colors.blue),
                    const SizedBox(width: 12),
                    _buildDetalleItem('Interés', pago.montoInteres, Colors.amber),
                    if (pago.montoMora > 0) ...[
                      const SizedBox(width: 12),
                      _buildDetalleItem('Mora', pago.montoMora, Colors.red),
                    ],
                  ],
                ),
              ],
            ),
          );
        } catch (_) {
          return const SizedBox.shrink();
        }
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildDetalleItem(String label, double monto, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            color: isDark ? Colors.white54 : Colors.black45,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          Formatters.formatCurrency(monto),
          style: TextStyle(
            fontSize: 11,
            color: color.withOpacity(0.8),
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildCardBadge(String text, Color bgColor, {Color? textColor}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: textColor ?? (isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569)),
        ),
      ),
    );
  }

  Widget _buildSimplifiedFilterResumen() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2130).withOpacity(0.5) : Colors.white,
        border: Border(bottom: BorderSide(color: isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFF1F5F9))),
      ),
      child: Row(
        children: [
          Icon(Icons.calendar_month_rounded, size: 16, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
          const SizedBox(width: 8),
          Text(
            '${DateFormat('dd MMM').format(_fechaInicio)} - ${DateFormat('dd MMM yyyy').format(_fechaFin)}',
            style: TextStyle(fontSize: 13, color: isDark ? Colors.white70 : const Color(0xFF475569), fontWeight: FontWeight.w500),
          ),
          const Spacer(),
          if (_cajaSeleccionada != null || _tipoSeleccionado != 'TODOS' || _categoriaSeleccionada != null)
            _buildActiveFilterChip(
              _categoriaSeleccionada ?? (_tipoSeleccionado == 'TODOS' ? 'Filtrado' : _tipoSeleccionado),
              onClear: () => setState(() {
                _cajaSeleccionada = null;
                _tipoSeleccionado = 'TODOS';
                _categoriaSeleccionada = null;
              }),
            ),
        ],
      ),
    );
  }

  Widget _buildActiveFilterChip(String label, {required VoidCallback onClear}) {
    return Container(
      padding: const EdgeInsets.only(left: 10, right: 4, top: 4, bottom: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF8B5CF6).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF8B5CF6).withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Text(label, style: const TextStyle(color: Color(0xFF8B5CF6), fontSize: 11, fontWeight: FontWeight.bold)),
          const SizedBox(width: 4),
          InkWell(
            onTap: onClear,
            child: const Icon(Icons.close_rounded, size: 14, color: Color(0xFF8B5CF6)),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarQuickActions() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ACCIONES RÁPIDAS',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        _buildQuickActionButton(
          'Hoy',
          Icons.today_rounded,
          () => setState(() {
            _fechaInicio = DateTime.now();
            _fechaFin = DateTime.now();
          }),
        ),
        _buildQuickActionButton(
          'Últimos 7 días',
          Icons.date_range_rounded,
          () => setState(() {
            _fechaInicio = DateTime.now().subtract(const Duration(days: 7));
            _fechaFin = DateTime.now();
          }),
        ),
        _buildQuickActionButton(
          'Reiniciar Filtros',
          Icons.restart_alt_rounded,
          () => setState(() {
            _fechaInicio = DateTime.now().subtract(const Duration(days: 30));
            _fechaFin = DateTime.now();
            _cajaSeleccionada = null;
            _tipoSeleccionado = 'TODOS';
            _categoriaSeleccionada = null;
          }),
        ),
      ],
    );
  }

  Widget _buildQuickActionButton(String label, IconData icon, VoidCallback onTap) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(icon, size: 18, color: const Color(0xFF8B5CF6)),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.white70 : const Color(0xFF475569),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebarInfo() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F111A) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline_rounded, size: 16, color: Color(0xFF94A3B8)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Los movimientos reflejan el flujo real de dinero en las cajas del sistema.',
              style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8), height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 80),
      child: Center(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E2130) : const Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.inbox_rounded, size: 48, color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1)),
            ),
            const SizedBox(height: 16),
            Text(
              'Sin movimientos registrados',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF1E293B)),
            ),
            const SizedBox(height: 8),
            Text(
              'Prueba ajustando los filtros de fecha o categoría.',
              style: TextStyle(color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline_rounded, size: 64, color: Color(0xFFEF4444)),
          const SizedBox(height: 16),
          Text('Ha ocurrido un error', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Text(error, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Future<void> _mostrarFiltros(BuildContext context) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    await showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1E2130) : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final cajasAsync = ref.watch(cajasProvider);

            return Padding(
              padding: EdgeInsets.only(
                left: 24, right: 24, top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Filtrar Movimientos', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF1E293B))),
                      IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Fechas
                  _buildFilterLabel('RANGO DE TIEMPO'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildFilterDateCard(
                          'Inicio', 
                          _fechaInicio, 
                          onTap: () async {
                            final fecha = await showDatePicker(
                              context: context,
                              initialDate: _fechaInicio,
                              firstDate: DateTime(2020),
                              lastDate: DateTime.now(),
                            );
                            if (fecha != null) {
                              setModalState(() => _fechaInicio = fecha);
                              setState(() => _fechaInicio = fecha);
                            }
                          }
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildFilterDateCard(
                          'Fin', 
                          _fechaFin, 
                          onTap: () async {
                            final fecha = await showDatePicker(
                              context: context,
                              initialDate: _fechaFin,
                              firstDate: _fechaInicio,
                              lastDate: DateTime.now(),
                            );
                            if (fecha != null) {
                              setModalState(() => _fechaFin = fecha);
                              setState(() => _fechaFin = fecha);
                            }
                          }
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  _buildFilterLabel('TIPO DE OPERACIÓN'),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildModernChip('Todos', _tipoSeleccionado == 'TODOS', () {
                         setModalState(() => _tipoSeleccionado = 'TODOS');
                         setState(() => _tipoSeleccionado = 'TODOS');
                      }),
                      _buildModernChip('Ingresos', _tipoSeleccionado == 'INGRESO', () {
                         setModalState(() {
                           _tipoSeleccionado = 'INGRESO';
                           _categoriaSeleccionada = null;
                         });
                         setState(() {
                           _tipoSeleccionado = 'INGRESO';
                           _categoriaSeleccionada = null;
                         });
                      }),
                      _buildModernChip('Egresos', _tipoSeleccionado == 'EGRESO', () {
                         setModalState(() {
                           _tipoSeleccionado = 'EGRESO';
                           _categoriaSeleccionada = null;
                         });
                         setState(() {
                           _tipoSeleccionado = 'EGRESO';
                           _categoriaSeleccionada = null;
                         });
                      }),
                      _buildModernChip('Transferencias', _tipoSeleccionado == 'TRANSFERENCIA', () {
                         setModalState(() {
                           _tipoSeleccionado = 'TRANSFERENCIA';
                           _categoriaSeleccionada = null;
                         });
                         setState(() {
                           _tipoSeleccionado = 'TRANSFERENCIA';
                           _categoriaSeleccionada = null;
                         });
                      }),
                    ],
                  ),

                  if (_tipoSeleccionado == 'INGRESO' || _tipoSeleccionado == 'EGRESO') ...[
                    const SizedBox(height: 24),
                    _buildFilterLabel('CATEGORÍA ESPECÍFICA'),
                    const SizedBox(height: 12),
                    ref.watch(categoriasProvider(_tipoSeleccionado)).when(
                      data: (categorias) => Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildModernChip('Todas', _categoriaSeleccionada == null, () {
                            setModalState(() => _categoriaSeleccionada = null);
                            setState(() => _categoriaSeleccionada = null);
                          }),
                          ...categorias.map((cat) => _buildModernChip(cat, _categoriaSeleccionada == cat, () {
                            setModalState(() => _categoriaSeleccionada = cat);
                            setState(() => _categoriaSeleccionada = cat);
                          })),
                        ],
                      ),
                      loading: () => const LinearProgressIndicator(),
                      error: (_, __) => const Text('Error al cargar categorías'),
                    ),
                  ],

                  const SizedBox(height: 24),
                  _buildFilterLabel('CAJA PARTICULAR'),
                  const SizedBox(height: 12),
                  cajasAsync.when(
                    data: (cajas) => Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildModernChip('Todas', _cajaSeleccionada == null, () {
                          setModalState(() => _cajaSeleccionada = null);
                          setState(() => _cajaSeleccionada = null);
                        }),
                        ...cajas.map((c) => _buildModernChip(c.nombre, _cajaSeleccionada == c.id, () {
                          setModalState(() => _cajaSeleccionada = c.id);
                          setState(() => _cajaSeleccionada = c.id);
                        })),
                      ],
                    ),
                    loading: () => const LinearProgressIndicator(),
                    error: (_, __) => const Text('Error al cargar cajas'),
                  ),

                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8B5CF6),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: const Text('Aplicar Filtros', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _exportarPDF(List<dynamic> movimientosFiltrados, AsyncValue<List<dynamic>> cajasAsync) async {
    final pdfService = ref.read(pdfServiceProvider);
    try {
      final headers = ['FECHA', 'DESCRIPCIÓN', 'CATEGORÍA', 'CAJA', 'MONTO'];
      final rows = <List<String>>[];
      
      final cajas = cajasAsync.valueOrNull ?? [];
      
      for (final mov in movimientosFiltrados) {
        String nombreCaja = 'N/A';
        try {
          final caja = cajas.firstWhere((c) => c.id == mov.cajaId);
          nombreCaja = caja.nombre;
        } catch (_) {}
        
        final esIngreso = mov.tipo == 'INGRESO';
        final signo = esIngreso ? '+' : '-';
        
        rows.add([
          DateFormat('dd/MM/yyyy HH:mm').format(mov.fecha),
          mov.descripcion,
          mov.categoria,
          nombreCaja,
          '$signo ${Formatters.formatCurrency(mov.monto)}',
        ]);
      }

      final path = await pdfService.generarPdfTabla(
        titulo: 'Movimientos de Caja',
        subtitulo: 'Del ${DateFormat('dd/MM/yyyy').format(_fechaInicio)} al ${DateFormat('dd/MM/yyyy').format(_fechaFin)} \nFiltros: ${_tipoSeleccionado} | ${_categoriaSeleccionada ?? 'Todas las cat.'}',
        categoria: 'REPORTE FINANCIERO',
        headers: headers,
        rows: rows,
        nombreArchivo: 'Movimientos_${DateFormat('yyyyMMdd').format(DateTime.now())}',
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PDF generado con ${movimientosFiltrados.length} movimientos'),
            backgroundColor: Colors.green,
            action: SnackBarAction(label: 'Abrir', onPressed: () => OpenFile.open(path), textColor: Colors.white),
          )
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al generar PDF: $e')));
      }
    }
  }

  Future<void> _exportarExcel(List<dynamic> movimientosFiltrados, AsyncValue<List<dynamic>> cajasAsync) async {
    final excelService = ref.read(excelServiceProvider);
    try {
      final list = <excel_svc.Movimiento>[];
      final cajas = cajasAsync.valueOrNull ?? [];
      
      for (final mov in movimientosFiltrados) {
        String nombreCaja = 'N/A';
        try {
          final caja = cajas.firstWhere((c) => c.id == mov.cajaId);
          nombreCaja = caja.nombre;
        } catch (_) {}
        
        list.add(excel_svc.Movimiento(
          codigo: mov.codigo ?? '',
          nombreCaja: nombreCaja,
          tipo: mov.tipo,
          categoria: mov.categoria,
          monto: mov.monto,
          saldoAnterior: mov.saldoAnterior ?? 0.0,
          saldoNuevo: mov.saldoNuevo ?? 0.0,
          descripcion: mov.descripcion,
          fecha: mov.fecha,
          fechaRegistro: mov.fechaRegistro,
        ));
      }

      final path = await excelService.exportarMovimientos(list);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Excel generado con ${movimientosFiltrados.length} movimientos'),
            backgroundColor: Colors.green,
            action: SnackBarAction(label: 'Abrir', onPressed: () => OpenFile.open(path), textColor: Colors.white),
          )
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al generar Excel: $e')));
      }
    }
  }

  Widget _buildFilterLabel(String text) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Text(
      text,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
        letterSpacing: 1.1,
      ),
    );
  }

  Widget _buildFilterDateCard(String label, DateTime date, {required VoidCallback onTap}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0F111A) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
            const SizedBox(height: 4),
            Text(DateFormat('dd/MM/yyyy').format(date), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildModernChip(String label, bool isSelected, VoidCallback onTap) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      backgroundColor: isDark ? const Color(0xFF0F111A) : const Color(0xFFF8FAFC),
      selectedColor: const Color(0xFF8B5CF6).withOpacity(0.2),
      labelStyle: TextStyle(
        color: isSelected ? const Color(0xFF8B5CF6) : (isDark ? Colors.white70 : const Color(0xFF64748B)),
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 13,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? const Color(0xFF8B5CF6) : (isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFE2E8F0)),
        ),
      ),
    );
  }
}
