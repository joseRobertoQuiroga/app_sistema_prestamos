import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/validators.dart';
import '../../../../presentation/widgets/app_drawer.dart';
import '../../../../presentation/widgets/custom_button.dart';
import '../../../dashboard/presentation/providers/dashboard_provider.dart';
import '../../../prestamos/presentation/providers/prestamo_provider.dart';
import '../../../clientes/presentation/providers/cliente_provider.dart';
import '../../../../presentation/widgets/custom_text_field.dart';

import '../providers/caja_provider.dart';
import '../../domain/entities/caja.dart';
import '../../domain/usecases/caja_usecases.dart';

import '../../../clientes/presentation/providers/cliente_provider.dart';
import '../../../clientes/domain/entities/cliente.dart';

import '../../../prestamos/domain/entities/prestamo.dart';
import '../../../prestamos/presentation/providers/prestamo_provider.dart';

enum TipoMovimiento { ingreso, egreso, transferencia }
enum SubTipoEgreso { simple, prestamo }

class GenerarMovimientoScreen extends ConsumerStatefulWidget {
  const GenerarMovimientoScreen({super.key});

  @override
  ConsumerState<GenerarMovimientoScreen> createState() => _GenerarMovimientoScreenState();
}

class _GenerarMovimientoScreenState extends ConsumerState<GenerarMovimientoScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Estado General
  TipoMovimiento _tipoMovimiento = TipoMovimiento.egreso;
  SubTipoEgreso _subTipoEgreso = SubTipoEgreso.simple;
  DateTime _fecha = DateTime.now();
  bool _isLoading = false;

  // Controladores Generales
  late TextEditingController _montoController;
  late TextEditingController _descripcionController;
  late TextEditingController _motivoController; // Para ingresos/transferencias
  
  // Campos
  int? _cajaOrigenId;
  int? _cajaDestinoId;
  String? _categoria;

  // Campos Préstamo
  int? _clienteId;
  late TextEditingController _tasaController;
  late TextEditingController _plazoController;
  late TextEditingController _observacionesPrestamoController;
  TipoInteres _tipoInteres = TipoInteres.simple;
  // Categorías persistentes (ahora se cargan de DB)
  final Set<String> _categoriasSession = {};
  
  Map<String, double>? _totalesPrestamo;

  @override
  void initState() {
    super.initState();
    _montoController = TextEditingController();
    _descripcionController = TextEditingController();
    _motivoController = TextEditingController();
    
    // Prestamo
    _tasaController = TextEditingController();
    _plazoController = TextEditingController();
    _observacionesPrestamoController = TextEditingController();

    // Listeners para actualizaciones en tiempo real
    _montoController.addListener(() {
      setState(() {}); // Actualizar sidebar e impacto
      _calcularPrestamo();
    });
    _tasaController.addListener(_calcularPrestamo);
    _plazoController.addListener(_calcularPrestamo);
  }

  @override
  void dispose() {
    _montoController.dispose();
    _descripcionController.dispose();
    _motivoController.dispose();
    _tasaController.dispose();
    _plazoController.dispose();
    _observacionesPrestamoController.dispose();
    super.dispose();
  }

  Future<void> _calcularPrestamo() async {
    if (_tipoMovimiento != TipoMovimiento.egreso || 
        _subTipoEgreso != SubTipoEgreso.prestamo) return;

    final monto = double.tryParse(_montoController.text);
    final tasa = double.tryParse(_tasaController.text);
    final plazo = int.tryParse(_plazoController.text);

    if (monto != null && tasa != null && plazo != null && 
        monto > 0 && tasa >= 0 && plazo > 0) {
      try {
        final totales = await ref.read(calcularTotalesProvider((
          monto: monto,
          tasaInteres: tasa,
          tipoInteres: _tipoInteres,
          plazoMeses: plazo,
        )).future);
        
        if (mounted) {
          setState(() {
            _totalesPrestamo = totales;
          });
        }
      } catch (e) {
        // Ignorar errores de cálculo en tiempo real
      }
    } else {
      if (_totalesPrestamo != null) {
        setState(() => _totalesPrestamo = null);
      }
    }
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    
    // Validaciones específicas
    if (_cajaOrigenId == null && _tipoMovimiento != TipoMovimiento.ingreso) {
      _showError('Seleccione la caja de origen');
      return;
    }
    if (_cajaDestinoId == null && (_tipoMovimiento == TipoMovimiento.ingreso || _tipoMovimiento == TipoMovimiento.transferencia)) {
      _showError('Seleccione la caja de destino');
      return;
    }
    if (_tipoMovimiento == TipoMovimiento.transferencia && _cajaOrigenId == _cajaDestinoId) {
      _showError('La caja de destino no puede ser igual a la de origen');
      return;
    }
    if (_tipoMovimiento == TipoMovimiento.egreso && _subTipoEgreso == SubTipoEgreso.prestamo) {
      if (_clienteId == null) {
        _showError('Seleccione un cliente');
        return;
      }
      if (_totalesPrestamo == null) {
        _showError('Verifique los datos del préstamo');
        return;
      }
    }

    setState(() => _isLoading = true);

    try {
      final monto = double.parse(_montoController.text);
      
      switch (_tipoMovimiento) {
        case TipoMovimiento.ingreso:
          await _registrarIngreso(monto);
          break;
        case TipoMovimiento.egreso:
          if (_subTipoEgreso == SubTipoEgreso.simple) {
            await _registrarEgresoSimple(monto);
          } else {
            await _registrarPrestamo(monto);
          }
          break;
        case TipoMovimiento.transferencia:
          await _registrarTransferencia(monto);
          break;
      }

      if (mounted) {
        // Invalidar providers para refrescar datos
        ref.invalidate(cajasListProvider);
        ref.invalidate(cajasActivasProvider);
        ref.invalidate(saldoTotalProvider);
        ref.invalidate(resumenGeneralProvider);
        ref.invalidate(movimientosGeneralesProvider);
        ref.invalidate(dashboardKPIsProvider);
        ref.invalidate(dashboardAlertasProvider);
        
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Movimiento registrado con éxito'), backgroundColor: Colors.green),
        );
        _limpiarFormulario();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showError(e.toString());
      }
    }
  }

  Future<void> _registrarIngreso(double monto) async {
    final registrarIngreso = ref.read(registrarIngresoUseCaseProvider);
    final result = await registrarIngreso(
      cajaId: _cajaDestinoId!,
      monto: monto,
      categoria: _categoria ?? 'INGRESO',
      descripcion: _descripcionController.text.isNotEmpty ? _descripcionController.text : _motivoController.text,
      fecha: _fecha,
    );
    result.fold((l) => throw Exception(l.message), (r) {});
  }

  Future<void> _registrarEgresoSimple(double monto) async {
    final registrarEgreso = ref.read(registrarEgresoUseCaseProvider);
    final result = await registrarEgreso(
      cajaId: _cajaOrigenId!,
      monto: monto,
      categoria: _categoria ?? 'GASTO',
      descripcion: _descripcionController.text,
      fecha: _fecha,
      referencia: _motivoController.text.isNotEmpty ? _motivoController.text : null,
    );
    result.fold((l) => throw Exception(l.message), (r) {});
  }

  Future<void> _registrarTransferencia(double monto) async {
    final registrarTransferencia = ref.read(registrarTransferenciaUseCaseProvider);
    final result = await registrarTransferencia(
      cajaOrigenId: _cajaOrigenId!,
      cajaDestinoId: _cajaDestinoId!,
      monto: monto,
      descripcion: _motivoController.text,
      fecha: _fecha,
    );
    result.fold((l) => throw Exception(l.message), (r) {});
  }

  Future<void> _registrarPrestamo(double monto) async {
    // 1. Crear Préstamo
    final generarCodigo = ref.read(generarCodigoPrestamoProvider);
    final codigoResult = await generarCodigo();
    final codigo = codigoResult.fold((f) => throw Exception(f.message), (c) => c);

    final prestamo = Prestamo(
      codigo: codigo,
      clienteId: _clienteId!,
      cajaId: _cajaOrigenId!,
      montoOriginal: monto,
      montoTotal: _totalesPrestamo!['montoTotal']!,
      saldoPendiente: _totalesPrestamo!['montoTotal']!,
      tasaInteres: double.parse(_tasaController.text),
      tipoInteres: _tipoInteres,
      plazoMeses: int.parse(_plazoController.text),
      cuotaMensual: _totalesPrestamo!['cuotaMensual']!,
      fechaInicio: _fecha,
      fechaVencimiento: DateTime(_fecha.year, _fecha.month + int.parse(_plazoController.text), _fecha.day),
      estado: EstadoPrestamo.activo,
      observaciones: _observacionesPrestamoController.text.isEmpty ? null : _observacionesPrestamoController.text,
      fechaRegistro: DateTime.now(),
    );

    final createPrestamo = ref.read(createPrestamoProvider);
    final prestamoResult = await createPrestamo(prestamo);
    
    // 2. Registrar Desembolso (Egreso de Caja)
    // Asumimos que createPrestamo NO crea el movimiento automáticamente
    
    await prestamoResult.fold(
      (l) => throw Exception('Error al crear préstamo: ${l.message}'),
      (p) async {
        final registrarEgreso = ref.read(registrarEgresoUseCaseProvider);
        final egresoResult = await registrarEgreso(
          cajaId: _cajaOrigenId!,
          monto: monto,
          categoria: 'DESEMBOLSO',
          descripcion: 'Desembolso Préstamo ${p.codigo}',
          fecha: _fecha,
          referencia: p.codigo,
        );
        egresoResult.fold(
          (l) => throw Exception('Préstamo creado pero falló el desembolso: ${l.message}'), 
          (r) {}
        );
      }
    );
  }

  void _limpiarFormulario() {
    _montoController.clear();
    _descripcionController.clear();
    _motivoController.clear();
    _tasaController.clear();
    _plazoController.clear();
    _observacionesPrestamoController.clear();
    setState(() {
      _totalesPrestamo = null;
      _clienteId = null;
      _categoria = null;
    });
  }
  
  Future<void> _agregarNuevaCategoria() async {
    final TextEditingController controller = TextEditingController();
    final isIngreso = _tipoMovimiento == TipoMovimiento.ingreso;
    
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Nueva Categoría (${isIngreso ? 'Ingreso' : 'Egreso'})'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Nombre de la categoría',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCELAR')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text.trim().toUpperCase()),
            child: const Text('AGREGAR'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      setState(() {
        _categoriasSession.add(result);
        _categoria = result;
      });
    } else {
      // Revertir selección si se canceló
      setState(() => _categoria = null);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 900;
        
        final formColumn = SingleChildScrollView(
          padding: EdgeInsets.all(isMobile ? 16 : 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Section 1: Tipo de Operación
                _buildSectionCard(
                  context,
                  title: _tipoMovimiento == TipoMovimiento.egreso ? 'Configuración de Operación' : (_tipoMovimiento == TipoMovimiento.ingreso ? 'Ingreso / Entrada' : 'Transferencia Interna'),
                  icon: Icons.settings_outlined,
                  child: Column(
                    children: [
                      _buildTipoSelector(context),
                      if (_tipoMovimiento == TipoMovimiento.egreso) ...[
                        const SizedBox(height: 20),
                        _buildSubTipoSelector(context),
                      ],
                      if (_subTipoEgreso == SubTipoEgreso.prestamo && _tipoMovimiento == TipoMovimiento.egreso) ...[
                        const SizedBox(height: 24),
                        _buildClienteField(context),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Section 2: Detalles Financieros
                _buildSectionCard(
                  context,
                  title: 'Valores Financieros',
                  icon: Icons.payments_outlined,
                  child: Column(
                    children: [
                      _buildMontoField(context),
                      const SizedBox(height: 24),
                      if (isMobile) ...[
                        _buildCajaField(context, label: _tipoMovimiento == TipoMovimiento.transferencia ? 'CAJA DE ORIGEN' : null),
                        const SizedBox(height: 16),
                        if (_tipoMovimiento == TipoMovimiento.transferencia) ...[
                          _buildCajaDestinoField(context),
                          const SizedBox(height: 16),
                        ],
                        _buildFechaField(context),
                        if (_tipoMovimiento != TipoMovimiento.transferencia) ...[
                          const SizedBox(height: 16),
                          _buildCategoriaField(context),
                        ],
                      ] else
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 3, 
                              child: Column(
                                children: [
                                  _buildCajaField(context, label: _tipoMovimiento == TipoMovimiento.transferencia ? 'CAJA DE ORIGEN' : null),
                                  if (_tipoMovimiento == TipoMovimiento.transferencia) ...[
                                    const SizedBox(height: 16),
                                    _buildCajaDestinoField(context),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              flex: 2, 
                              child: Column(
                                children: [
                                  _buildFechaField(context),
                                  if (_tipoMovimiento != TipoMovimiento.transferencia) ...[
                                    const SizedBox(height: 16),
                                    _buildCategoriaField(context),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Section 3: Concepto y Referencia
                _buildSectionCard(
                  context,
                  title: 'Concepto y Detalles',
                  icon: Icons.description_outlined,
                  child: Column(
                    children: [
                      _buildDescriptionField(context),
                      const SizedBox(height: 24),
                      _buildReferenceField(context),
                    ],
                  ),
                ),
                
                // Prestamo Section (Conditional) - Condiciones
                if (_subTipoEgreso == SubTipoEgreso.prestamo && _tipoMovimiento == TipoMovimiento.egreso) ...[
                   const SizedBox(height: 24),
                   _buildSectionCard(
                     context,
                     title: 'Condiciones del Préstamo',
                     icon: Icons.gavel_outlined,
                     child: _buildPrestamoCondicionesContent(context),
                   ),
                ],
                if (isMobile) ...[
                   const SizedBox(height: 24),
                   _buildMobileImpactCard(context),
                   const SizedBox(height: 80), // Espacio para scroll
                ],
              ],
            ),
          ),
        );

        if (isMobile) return Scaffold(
          backgroundColor: isDark ? const Color(0xFF0F111A) : const Color(0xFFF3F4F6),
          appBar: _buildAppBar(isDark),
          drawer: const AppDrawer(),
          body: formColumn,
        );

        return Scaffold(
          backgroundColor: isDark ? const Color(0xFF0F111A) : const Color(0xFFF3F4F6),
          appBar: _buildAppBar(isDark),
          drawer: const AppDrawer(),
          body: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Main Form Area (70%)
              Expanded(flex: 7, child: formColumn),

              // Impact Sidebar (30%)
              Expanded(
                flex: 3,
                child: Container(
                  margin: const EdgeInsets.only(top: 24, right: 24, bottom: 24),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E2130) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      isDark 
                        ? BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4))
                        : BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: _buildImpactSidebar(context),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Helper para AppBar para reutilizar en Mobile/Desktop
  PreferredSizeWidget _buildAppBar(bool isDark) {
    return AppBar(
      title: Text('Nuevo Movimiento', style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1E293B), fontWeight: FontWeight.bold)),
      backgroundColor: isDark ? const Color(0xFF1E2130) : Colors.white,
      elevation: 0,
      leading: Builder(
        builder: (context) => IconButton(
          icon: Icon(Icons.menu, color: isDark ? Colors.white : const Color(0xFF1E293B)),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.refresh, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF64748B)),
          onPressed: _limpiarFormulario,
        ),
        const Padding(
          padding: EdgeInsets.only(right: 16),
          child: CircleAvatar(
            backgroundColor: Color(0xFF8B5CF6),
            radius: 16,
            child: Text('AD', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileImpactCard(BuildContext context) {
     final isDark = Theme.of(context).brightness == Brightness.dark;
     return Container(
       decoration: BoxDecoration(
         color: isDark ? const Color(0xFF1E2130) : Colors.white,
         borderRadius: BorderRadius.circular(16),
         boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
       ),
       child: _buildImpactSidebar(context, showActions: false),
     );
  }

  Widget _buildSectionCard(BuildContext context, {required String title, required IconData icon, required Widget child}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2130) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          isDark 
            ? BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 2))
            : BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 2)),
        ],
        border: isDark ? Border.all(color: Colors.white.withOpacity(0.05)) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: const Color(0xFF8B5CF6)),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18, 
                  fontWeight: FontWeight.bold, 
                  color: isDark ? Colors.white : const Color(0xFF1E293B)
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          child,
        ],
      ),
    );
  }

  Widget _buildTipoSelector(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F111A) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          _buildSegmentOption(context, 'Ingreso', TipoMovimiento.ingreso),
          _buildSegmentOption(context, 'Gasto / Salida', TipoMovimiento.egreso),
          _buildSegmentOption(context, 'Transferencia', TipoMovimiento.transferencia),
        ],
      ),
    );
  }

  Widget _buildSegmentOption(BuildContext context, String label, TipoMovimiento value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSelected = _tipoMovimiento == value;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() {
          _tipoMovimiento = value;
          _categoria = null; // Reset categoría al cambiar de tipo para evitar crash
          if (value != TipoMovimiento.egreso) _subTipoEgreso = SubTipoEgreso.simple;
        }),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? (isDark ? const Color(0xFF262A40) : Colors.white) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isSelected ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)] : null,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected 
                  ? (isDark ? Colors.white : const Color(0xFF1E293B)) 
                  : (isDark ? const Color(0xFF9CA3AF) : const Color(0xFF64748B)),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFechaField(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('FECHA DEL MOVIMIENTO', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF64748B))),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: _fecha,
              firstDate: DateTime(2020),
              lastDate: DateTime(2030),
            );
            if (date != null) setState(() => _fecha = date);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F111A) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isDark ? Colors.white.withOpacity(0.1) : const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_month_outlined, size: 20, color: Color(0xFF94A3B8)),
                const SizedBox(width: 12),
                Text(DateFormat('dd/MM/yyyy').format(_fecha), style: TextStyle(fontSize: 15, color: isDark ? Colors.white : const Color(0xFF1E293B))),
                const Spacer(),
                const Icon(Icons.calendar_today_outlined, size: 16, color: Color(0xFF94A3B8)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubTipoSelector(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F111A) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          _buildSubTipoOption(context, 'Egreso Simple', SubTipoEgreso.simple),
          _buildSubTipoOption(context, 'Préstamo', SubTipoEgreso.prestamo),
        ],
      ),
    );
  }

  Widget _buildSubTipoOption(BuildContext context, String label, SubTipoEgreso value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSelected = _subTipoEgreso == value;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _subTipoEgreso = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? (isDark ? const Color(0xFF8B5CF6).withOpacity(0.2) : Colors.white) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: isSelected ? Border.all(color: const Color(0xFF8B5CF6).withOpacity(0.5)) : null,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? const Color(0xFF8B5CF6) : (isDark ? const Color(0xFF9CA3AF) : const Color(0xFF64748B)),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoriaField(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isIngreso = _tipoMovimiento == TipoMovimiento.ingreso;
    
    // Ocultar categorías para préstamos (se usa 'DESEMBOLSO' internamente)
    if (_tipoMovimiento == TipoMovimiento.egreso && _subTipoEgreso == SubTipoEgreso.prestamo) {
      return const SizedBox.shrink();
    }
    
    final categoriasAsync = ref.watch(categoriasProvider(isIngreso ? 'INGRESO' : 'EGRESO'));
    
    final defaultCategories = isIngreso 
        ? ['INGRESO GENERAL', 'APORTE DE CAPITAL', 'VENTA DE ACTIVOS']
        : ['GASTO OPERATIVO', 'SERVICIOS', 'PERSONAL', 'MANTENIMIENTO'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('CATEGORÍA', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF64748B))),
        const SizedBox(height: 8),
        categoriasAsync.when(
          data: (categorias) {
            final allCategories = {
              ...defaultCategories, 
              ...categorias,
              ..._categoriasSession,
            }.toList();
            
            return DropdownButtonFormField<String>(
              value: _categoria,
              onChanged: (v) {
                if (v == 'ADD_NEW') {
                  _agregarNuevaCategoria();
                } else {
                  setState(() => _categoria = v);
                }
              },
              dropdownColor: isDark ? const Color(0xFF1E2130) : Colors.white,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.sell_outlined, size: 20, color: Color(0xFF94A3B8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: isDark ? Colors.white.withOpacity(0.1) : const Color(0xFFE2E8F0))),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF8B5CF6))),
                filled: true,
                fillColor: isDark ? const Color(0xFF0F111A) : Colors.white,
              ),
              style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1E293B), fontSize: 15),
              items: [
                ...allCategories.map((c) => DropdownMenuItem(value: c, child: Text(c))),
                const DropdownMenuItem(
                  value: 'ADD_NEW', 
                  child: Row(
                    children: [
                      Icon(Icons.add_circle_outline, size: 18, color: Color(0xFF8B5CF6)),
                      SizedBox(width: 8),
                      Text('Nueva Categoría...', style: TextStyle(color: Color(0xFF8B5CF6), fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            );
          },
          loading: () => const LinearProgressIndicator(),
          error: (_, __) => const Text('Error al cargar categorías'),
        ),
      ],
    );
  }

  Widget _buildCajaField(BuildContext context, {String? label}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cajasAsync = ref.watch(cajasActivasProvider);
    
    // Si es ingreso, mostramos etiqueta de destino y usamos _cajaDestinoId
    final isIngreso = _tipoMovimiento == TipoMovimiento.ingreso;
    final currentId = isIngreso ? _cajaDestinoId : _cajaOrigenId;
    
    // Obtener caja seleccionada para el saldo (solo si no es ingreso o si es transferencia)
    Caja? selectedCaja;
    if (currentId != null && cajasAsync.hasValue) {
      try {
        selectedCaja = cajasAsync.value!.firstWhere((c) => c.id == currentId);
      } catch (_) {
        selectedCaja = null;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label ?? (isIngreso ? 'CAJA DE DESTINO' : 'CAJA DE ORIGEN'), style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF64748B))),
        const SizedBox(height: 8),
        cajasAsync.when(
          data: (cajas) => DropdownButtonFormField<int>(
            value: currentId,
            onChanged: (v) => setState(() {
              if (isIngreso) {
                _cajaDestinoId = v;
              } else {
                _cajaOrigenId = v;
              }
            }),
            dropdownColor: isDark ? const Color(0xFF1E2130) : Colors.white,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.account_balance_outlined, size: 20, color: Color(0xFF94A3B8)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: isDark ? Colors.white.withOpacity(0.1) : const Color(0xFFE2E8F0))),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF8B5CF6))),
              filled: true,
              fillColor: isDark ? const Color(0xFF0F111A) : Colors.white,
            ),
            style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1E293B), fontSize: 15),
            items: cajas.map((c) => DropdownMenuItem(value: c.id, child: Text(c.nombre))).toList(),
          ),
          loading: () => const LinearProgressIndicator(),
          error: (_, __) => const Text('Error al cargar cajas'),
        ),
        if (selectedCaja != null) ...[
          const SizedBox(height: 8),
          Text(
            'Saldo disponible: ${Formatters.formatNumber(selectedCaja.saldo)} Bs.', 
            style: TextStyle(fontSize: 11, color: isDark ? const Color(0xFF34D399) : const Color(0xFF10B981))
          ),
        ],
      ],
    );
  }

  Widget _buildCajaDestinoField(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cajasAsync = ref.watch(cajasActivasProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('CAJA DE DESTINO', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF64748B))),
        const SizedBox(height: 8),
        cajasAsync.when(
          data: (cajas) => DropdownButtonFormField<int>(
            value: _cajaDestinoId,
            onChanged: (v) => setState(() => _cajaDestinoId = v),
            dropdownColor: isDark ? const Color(0xFF1E2130) : Colors.white,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.account_balance_outlined, size: 20, color: Color(0xFF94A3B8)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: isDark ? Colors.white.withOpacity(0.1) : const Color(0xFFE2E8F0))),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF8B5CF6))),
              filled: true,
              fillColor: isDark ? const Color(0xFF0F111A) : Colors.white,
            ),
            style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1E293B), fontSize: 15),
            items: cajas.map((c) => DropdownMenuItem(value: c.id, child: Text(c.nombre))).toList(),
          ),
          loading: () => const LinearProgressIndicator(),
          error: (_, __) => const Text('Error al cargar cajas'),
        ),
      ],
    );
  }

  Widget _buildMontoField(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    String label = 'MONTO A RETIRAR / EGRESO';
    if (_tipoMovimiento == TipoMovimiento.ingreso) label = 'MONTO A INGRESAR';
    if (_tipoMovimiento == TipoMovimiento.transferencia) label = 'MONTO A TRANSFERIR';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF64748B))),
        const SizedBox(height: 8),
        TextFormField(
          controller: _montoController,
          keyboardType: TextInputType.number,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF1E293B)),
          decoration: InputDecoration(
            prefixText: '\$ ',
            prefixStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
            suffix: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF262A40) : const Color(0xFFF1F5F9), 
                borderRadius: BorderRadius.circular(6)
              ),
              child: Text('BS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF64748B))),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: isDark ? Colors.white.withOpacity(0.1) : const Color(0xFFE2E8F0))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF8B5CF6))),
            filled: true,
            fillColor: isDark ? const Color(0xFF0F111A) : const Color(0xFFF8FAFC),
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionField(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('DESCRIPCIÓN / CONCEPTO', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF64748B))),
        const SizedBox(height: 8),
        TextFormField(
          controller: _descripcionController,
          maxLines: 4,
          style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1E293B)),
          decoration: InputDecoration(
            hintText: 'Escriba los detalles de la operación...',
            hintStyle: TextStyle(color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8), fontSize: 14),
            contentPadding: const EdgeInsets.all(16),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: isDark ? Colors.white.withOpacity(0.1) : const Color(0xFFE2E8F0))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF8B5CF6))),
            filled: true,
            fillColor: isDark ? const Color(0xFF0F111A) : const Color(0xFFF8FAFC),
          ),
        ),
      ],
    );
  }

  Widget _buildReferenceField(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('REFERENCIA (OPCIONAL)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF64748B))),
        const SizedBox(height: 8),
        TextFormField(
          controller: _motivoController,
          style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1E293B)),
          decoration: InputDecoration(
            hintText: '# de Recibo / Factura',
            prefixIcon: const Icon(Icons.receipt_long_outlined, size: 20, color: Color(0xFF94A3B8)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: isDark ? Colors.white.withOpacity(0.1) : const Color(0xFFE2E8F0))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF8B5CF6))),
            filled: true,
            fillColor: isDark ? const Color(0xFF0F111A) : const Color(0xFFF8FAFC),
          ),
        ),
      ],
    );
  }

  Widget _buildImpactSidebar(BuildContext context, {bool showActions = true}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cajasAsync = ref.watch(cajasActivasProvider);
    
    // Obtener caja seleccionada y saldo
    final isIncome = _tipoMovimiento == TipoMovimiento.ingreso;
    final targetId = isIncome ? _cajaDestinoId : _cajaOrigenId;

    // Fix: Usar try-catch o find de forma más segura para evitar error de tipo en orElse
    Caja? selectedCaja;
    if (targetId != null && cajasAsync.hasValue) {
      try {
        selectedCaja = cajasAsync.value!.firstWhere((c) => c.id == targetId);
      } catch (_) {
        selectedCaja = null;
      }
    }
    
    final saldoActual = selectedCaja?.saldo ?? 0.0;
    final monto = double.tryParse(_montoController.text) ?? 0.0;
    
    // Calcular delta
    final delta = isIncome ? monto : -monto;
    final nuevoSaldo = isIncome ? (saldoActual + monto) : (saldoActual - monto);
    
    // Validar fondos insuficientes
    final outOfFunds = !isIncome && monto > saldoActual;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('IMPACTO DE OPERACIÓN', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF64748B), letterSpacing: 0.5)),
          const SizedBox(height: 32),
          _buildImpactRow(context, 'Saldo Actual', '${Formatters.formatNumber(saldoActual)} Bs.'),
          const SizedBox(height: 16),
          _buildImpactDelta(context, delta, isIncome),
          const SizedBox(height: 24),
          _buildNewBalance(context, '${Formatters.formatNumber(nuevoSaldo)} Bs.', warning: outOfFunds),
          if (outOfFunds) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.warning_amber_rounded, size: 14, color: Color(0xFFEF4444)),
                const SizedBox(width: 4),
                const Expanded(child: Text('Fondos insuficientes en esta caja', style: TextStyle(color: Color(0xFFEF4444), fontSize: 11, fontWeight: FontWeight.bold))),
              ],
            ),
          ],
          const SizedBox(height: 48),
          _buildImpactInfo(context, 'Caja', selectedCaja?.nombre ?? 'No seleccionada'),
          const SizedBox(height: 12),
          _buildImpactInfo(context, 'Tipo', _tipoMovimiento == TipoMovimiento.egreso ? 'Egreso' : (_tipoMovimiento == TipoMovimiento.ingreso ? 'Ingreso' : 'Transf.')),
          const SizedBox(height: 12),
          _buildImpactInfo(context, 'Fecha', DateFormat('dd/MM/yyyy').format(_fecha)),
          if (showActions) ...[
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: outOfFunds ? null : _guardar, // Deshabilitar si no hay fondos
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B5CF6),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: isDark ? 4 : 0,
                  shadowColor: isDark ? const Color(0xFF8B5CF6).withOpacity(0.3) : null,
                ),
                child: _isLoading 
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_outline, size: 20),
                        SizedBox(width: 8),
                        Text('Confirmar', style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _limpiarFormulario,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  side: BorderSide(color: isDark ? Colors.white.withOpacity(0.1) : const Color(0xFFE2E8F0)),
                ),
                child: Text('Cancelar', style: TextStyle(color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF64748B), fontWeight: FontWeight.bold)),
              ),
            ),
          ],
          const SizedBox(height: 24),
          const Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock_outline, size: 14, color: Color(0xFF94A3B8)),
                SizedBox(width: 4),
                Text('Transacción segura', style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImpactRow(BuildContext context, String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF64748B), fontSize: 13)),
        Text(value, style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1E293B), fontWeight: FontWeight.w500, fontSize: 13)),
      ],
    );
  }

  Widget _buildImpactDelta(BuildContext context, double delta, bool isIncome) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isIncome ? const Color(0xFF10B981) : const Color(0xFFEF4444);
    final icon = isIncome ? Icons.add_circle : Icons.remove_circle;
    
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(height: 1, color: isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFF1F5F9)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          color: isDark ? const Color(0xFF1E2130) : Colors.white,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Text(
                '${isIncome ? "+" : "-"} ${Formatters.formatNumber(delta.abs())}', 
                style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14)
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNewBalance(BuildContext context, String value, {bool warning = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = warning ? const Color(0xFFEF4444) : const Color(0xFF8B5CF6);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: warning 
          ? const Color(0xFFEF4444).withOpacity(0.1) 
          : (isDark ? const Color(0xFF0F111A).withOpacity(0.3) : const Color(0xFFF8FAFC)),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: warning ? const Color(0xFFEF4444).withOpacity(0.5) : (isDark ? Colors.white.withOpacity(0.1) : const Color(0xFFE2E8F0))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Nuevo Saldo', style: TextStyle(color: primaryColor, fontSize: 12, fontWeight: FontWeight.bold)),
          Text(value, style: TextStyle(color: warning ? const Color(0xFFEF4444) : (isDark ? Colors.white : const Color(0xFF1E293B)), fontWeight: FontWeight.bold, fontSize: 18)),
        ],
      ),
    );
  }

  Widget _buildImpactInfo(BuildContext context, String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF64748B), fontSize: 13)),
        Text(value, style: TextStyle(color: label == 'Tipo' ? const Color(0xFFEF4444) : (isDark ? Colors.white : const Color(0xFF1E293B)), fontWeight: FontWeight.bold, fontSize: 13)),
      ],
    );
  }

  Widget _buildClienteField(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final clientesAsync = ref.watch(clientesActivosProvider);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('CLIENTE DEL PRÉSTAMO', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF64748B))),
        const SizedBox(height: 8),
        clientesAsync.when(
          data: (clientes) => DropdownButtonFormField<int>(
            value: _clienteId,
            onChanged: (v) => setState(() => _clienteId = v),
            dropdownColor: isDark ? const Color(0xFF1E2130) : Colors.white,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.person_outline, size: 20, color: Color(0xFF94A3B8)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: isDark ? Colors.white.withOpacity(0.1) : const Color(0xFFE2E8F0))),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF8B5CF6))),
              filled: true,
              fillColor: isDark ? const Color(0xFF0F111A) : Colors.white,
              hintText: 'Seleccionar cliente...',
            ),
            style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1E293B)),
            items: clientes.map((c) => DropdownMenuItem(value: c.id, child: Text(c.nombre))).toList(),
          ),
          loading: () => const LinearProgressIndicator(),
          error: (_, __) => const Text('Error al cargar clientes'),
        ),
      ],
    );
  }

  Widget _buildPrestamoCondicionesContent(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _tasaController,
                style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1E293B)),
                decoration: InputDecoration(
                  labelText: 'Tasa/Año (%)',
                  labelStyle: TextStyle(color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF64748B)),
                  prefixIcon: const Icon(Icons.percent, size: 18),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: isDark ? Colors.white.withOpacity(0.1) : const Color(0xFFE2E8F0))),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF8B5CF6))),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF0F111A) : Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _plazoController,
                style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1E293B)),
                decoration: InputDecoration(
                  labelText: 'Plazo (Meses)',
                  labelStyle: TextStyle(color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF64748B)),
                  prefixIcon: const Icon(Icons.calendar_today_outlined, size: 18),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: isDark ? Colors.white.withOpacity(0.1) : const Color(0xFFE2E8F0))),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF8B5CF6))),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF0F111A) : Colors.white,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildInteresSelector(context),
      ],
    );
  }

  Widget _buildInteresSelector(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F111A) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          _buildInnerSegmentOption(context, 'Interés Simple', TipoInteres.simple),
          _buildInnerSegmentOption(context, 'Capitalización', TipoInteres.compuesto),
        ],
      ),
    );
  }

  Widget _buildInnerSegmentOption(BuildContext context, String label, TipoInteres value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSelected = _tipoInteres == value;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() => _tipoInteres = value);
          _calcularPrestamo();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? (isDark ? const Color(0xFF262A40) : Colors.white) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected 
                  ? (isDark ? Colors.white : const Color(0xFF1E293B)) 
                  : (isDark ? const Color(0xFF9CA3AF) : const Color(0xFF64748B)),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
