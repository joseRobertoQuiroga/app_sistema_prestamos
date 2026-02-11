import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../domain/entities/prestamo.dart';
import '../../domain/entities/cuota.dart';
import '../providers/prestamo_provider.dart';
import '../widgets/tabla_amortizacion_widget.dart';
import '../../../clientes/presentation/providers/cliente_provider.dart';
import '../../../clientes/domain/entities/cliente.dart';
import '../../../caja/presentation/providers/caja_provider.dart';
import '../../../caja/domain/entities/caja.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../presentation/widgets/custom_text_field.dart';
import '../../../../presentation/widgets/custom_button.dart';

class PrestamoFormScreen extends ConsumerStatefulWidget {
  final int? prestamoId;

  const PrestamoFormScreen({
    super.key,
    this.prestamoId,
  });

  @override
  ConsumerState<PrestamoFormScreen> createState() => _PrestamoFormScreenState();
}

class _PrestamoFormScreenState extends ConsumerState<PrestamoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  late TextEditingController _montoController;
  late TextEditingController _tasaController;
  late TextEditingController _plazoController;
  late TextEditingController _observacionesController;
  
  // State
  int? _clienteSeleccionado;
  int? _cajaSeleccionada;
  TipoInteres _tipoInteres = TipoInteres.simple;
  DateTime _fechaInicio = DateTime.now();
  bool _mostrarVistaPrevia = false;
  List<Cuota>? _vistaPrevia;
  Map<String, double>? _totalesCalculados;
  bool _isLoading = false;
  bool _isCalculating = false;

  @override
  void initState() {
    super.initState();
    _montoController = TextEditingController();
    _tasaController = TextEditingController();
    _plazoController = TextEditingController();
    _observacionesController = TextEditingController();
    
    // Listeners para recalcular vista previa
    _montoController.addListener(_onFormChanged);
    _tasaController.addListener(_onFormChanged);
    _plazoController.addListener(_onFormChanged);
  }

  @override
  void dispose() {
    _montoController.dispose();
    _tasaController.dispose();
    _plazoController.dispose();
    _observacionesController.dispose();
    super.dispose();
  }

  void _onFormChanged() {
    _calcularVistaPrevia();
  }

  Future<void> _calcularVistaPrevia() async {
    if (_montoController.text.isEmpty ||
        _tasaController.text.isEmpty ||
        _plazoController.text.isEmpty) {
      if (mounted) {
        setState(() {
          _vistaPrevia = null;
          _totalesCalculados = null;
        });
      }
      return;
    }

    final monto = double.tryParse(_montoController.text);
    final tasa = double.tryParse(_tasaController.text);
    final plazo = int.tryParse(_plazoController.text);

    if (monto == null || tasa == null || plazo == null || monto <= 0 || tasa < 0 || plazo <= 0) {
      return;
    }

    if (mounted) setState(() => _isCalculating = true);

    try {
      final totales = await ref.read(calcularTotalesProvider((
        monto: monto,
        tasaInteres: tasa,
        tipoInteres: _tipoInteres,
        plazoMeses: plazo,
      )).future);

      final generarTabla = ref.read(generarTablaAmortizacionProvider);
      final resultadoTabla = await generarTabla(
        prestamoId: 0,
        monto: monto,
        tasaInteres: tasa,
        tipoInteres: _tipoInteres,
        plazoMeses: plazo,
        fechaInicio: _fechaInicio,
      );

      if (mounted) {
        setState(() {
          _totalesCalculados = totales as Map<String, double>?;
          resultadoTabla.fold((_) => _vistaPrevia = null, (cuotas) => _vistaPrevia = cuotas);
          _isCalculating = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isCalculating = false);
    }
  }

  Future<void> _guardarPrestamo() async {
    if (!_formKey.currentState!.validate() || _clienteSeleccionado == null || _cajaSeleccionada == null) {
      _showError(_clienteSeleccionado == null ? 'Seleccione un cliente' : _cajaSeleccionada == null ? 'Seleccione una caja' : 'Revise los campos');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final generarCodigo = ref.read(generarCodigoPrestamoProvider);
      final codigoResult = await generarCodigo();
      final codigo = codigoResult.fold((f) => throw Exception(f.message), (c) => c);

      final fechaVencimiento = DateTime(_fechaInicio.year, _fechaInicio.month + int.parse(_plazoController.text), _fechaInicio.day);

      final prestamo = Prestamo(
        codigo: codigo,
        clienteId: _clienteSeleccionado!,
        cajaId: _cajaSeleccionada!,
        montoOriginal: double.parse(_montoController.text),
        montoTotal: _totalesCalculados!['montoTotal']!,
        saldoPendiente: _totalesCalculados!['montoTotal']!,
        tasaInteres: double.parse(_tasaController.text),
        tipoInteres: _tipoInteres,
        plazoMeses: int.parse(_plazoController.text),
        cuotaMensual: _totalesCalculados!['cuotaMensual']!,
        fechaInicio: _fechaInicio,
        fechaVencimiento: fechaVencimiento,
        estado: EstadoPrestamo.activo,
        observaciones: _observacionesController.text.isEmpty ? null : _observacionesController.text,
        fechaRegistro: DateTime.now(),
      );

      final result = await ref.read(createPrestamoProvider)(prestamo);
      result.fold(
        (f) { setState(() => _isLoading = false); _showError(f.message); },
        (_) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Préstamo creado con éxito'), backgroundColor: Colors.green));
          Navigator.pop(context, true);
        },
      );
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Error al crear préstamo: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final clientesAsync = ref.watch(clientesActivosProvider);
    final cajasAsync = ref.watch(cajasActivasProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.prestamoId == null ? 'Nuevo Préstamo' : 'Editar Préstamo'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: Column(
                children: [
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
                      children: [
                        // SECCIÓN: CLIENTE Y CAJA
                        _buildFormSection(
                          context,
                          title: 'IDENTIFICACIÓN Y ORIGEN',
                          icon: Icons.account_balance_rounded,
                          children: [
                            _buildClienteSelector(clientesAsync),
                            const SizedBox(height: 16),
                            _buildCajaSelector(cajasAsync),
                          ],
                        ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),

                        const SizedBox(height: 24),

                        // SECCIÓN: CONDICIONES
                        _buildFormSection(
                          context,
                          title: 'CONDICIONES DEL PRÉSTAMO',
                          icon: Icons.monetization_on_rounded,
                          children: [
                            CustomTextField(
                              controller: _montoController,
                              label: 'Monto Principal',
                              keyboardType: TextInputType.number,
                              prefixIcon: Icons.attach_money_rounded,
                              validator: (v) => Validators.amount(v),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: CustomTextField(
                                    controller: _tasaController,
                                    label: 'Tasa/Año (%)',
                                    keyboardType: TextInputType.number,
                                    prefixIcon: Icons.percent_rounded,
                                    validator: (v) => Validators.interestRate(v),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: CustomTextField(
                                    controller: _plazoController,
                                    label: 'Plazo (Meses)',
                                    keyboardType: TextInputType.number,
                                    prefixIcon: Icons.calendar_month_rounded,
                                    validator: (v) => Validators.termMonths(v),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _buildTipoInteresSelector(),
                            const SizedBox(height: 16),
                            _buildFechaInicioSelector(),
                          ],
                        ).animate().fadeIn(duration: 400.ms, delay: 100.ms).slideY(begin: 0.1, end: 0),

                        const SizedBox(height: 24),

                        // SECCIÓN: RESULTADOS
                        if (_totalesCalculados != null) ...[
                          _buildFormSection(
                            context,
                            title: 'CÁLCULO ESTIMADO',
                            icon: Icons.calculate_rounded,
                            children: [
                              _buildResumenCalculado(),
                              const SizedBox(height: 16),
                              CustomButton(
                                text: _mostrarVistaPrevia
                                    ? 'OCULTAR TABLA'
                                    : 'VER TABLA DE AMORTIZACIÓN',
                                type: ButtonType.text,
                                onPressed: () => setState(
                                    () => _mostrarVistaPrevia = !_mostrarVistaPrevia),
                              ),
                              if (_mostrarVistaPrevia && _vistaPrevia != null)
                                TablaAmortizacionWidget(
                                    cuotas: _vistaPrevia!, compact: true),
                            ],
                          ).animate().fadeIn(duration: 400.ms, delay: 200.ms),
                          const SizedBox(height: 24),
                        ],

                        // SECCIÓN: NOTAS
                        _buildFormSection(
                          context,
                          title: 'INFORMACIÓN ADICIONAL',
                          icon: Icons.notes_rounded,
                          children: [
                            CustomTextField(
                              controller: _observacionesController,
                              label: 'Observaciones',
                              hintText: 'Cualquier detalle relevante...',
                              maxLines: 3,
                              prefixIcon: Icons.comment_rounded,
                            ),
                          ],
                        ).animate().fadeIn(duration: 400.ms, delay: 300.ms),
                      ],
                    ),
                  ),

                  // BOTONES FIJOS
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                    decoration: BoxDecoration(
                      color: isDark
                          ? theme.scaffoldBackgroundColor
                          : Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, -4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: CustomButton(
                            text: 'CANCELAR',
                            type: ButtonType.outlined,
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 2,
                          child: CustomButton(
                            text: 'CREAR PRÉSTAMO',
                            onPressed: _guardarPrestamo,
                            isLoading: _isLoading,
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 400.ms, delay: 400.ms),
                ],
              ),
            ),
    );
  }

  Widget _buildFormSection(BuildContext context, {required String title, required IconData icon, required List<Widget> children}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Row(
            children: [
              Icon(icon, size: 18, color: AppTheme.primaryBrand),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.2, color: AppTheme.primaryBrand)),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: !isDark ? [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 5))] : null,
            border: isDark ? Border.all(color: Colors.white.withOpacity(0.05)) : null,
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildClienteSelector(AsyncValue<List<Cliente>> clientesAsync) {
    return clientesAsync.when(
      data: (clientes) => DropdownButtonFormField<int>(
        value: _clienteSeleccionado,
        decoration: AppTheme.getInputDecoration(label: 'Seleccionar Cliente', prefixIcon: const Icon(Icons.person_rounded)),
        items: clientes.map((c) => DropdownMenuItem(value: c.id, child: Text(c.nombre))).toList(),
        onChanged: (v) => setState(() => _clienteSeleccionado = v),
        validator: (v) => v == null ? 'Requerido' : null,
      ),
      loading: () => const LinearProgressIndicator(),
      error: (_, __) => const Text('Error al cargar clientes'),
    );
  }

  Widget _buildCajaSelector(AsyncValue<List<Caja>> cajasAsync) {
    return cajasAsync.when(
      data: (cajas) => DropdownButtonFormField<int>(
        value: _cajaSeleccionada,
        decoration: AppTheme.getInputDecoration(label: 'Caja de Origen', prefixIcon: const Icon(Icons.account_balance_wallet_rounded)),
        items: cajas.map((c) => DropdownMenuItem(value: c.id, child: Text(c.nombre))).toList(),
        onChanged: (v) => setState(() => _cajaSeleccionada = v),
        validator: (v) => v == null ? 'Requerido' : null,
      ),
      loading: () => const LinearProgressIndicator(),
      error: (_, __) => const Text('Error al cargar cajas'),
    );
  }

  Widget _buildTipoInteresSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Tipo de Amortización', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildRadioOption('Simple (Interés)', TipoInteres.simple),
            const SizedBox(width: 12),
            _buildRadioOption('Compuesto (Francés)', TipoInteres.compuesto),
          ],
        ),
      ],
    );
  }

  Widget _buildRadioOption(String label, TipoInteres value) {
    bool isSelected = _tipoInteres == value;
    return Expanded(
      child: GestureDetector(
        onTap: () { setState(() => _tipoInteres = value); _calcularVistaPrevia(); },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primaryBrand.withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isSelected ? AppTheme.primaryBrand : Colors.grey.withOpacity(0.3)),
          ),
          alignment: Alignment.center,
          child: Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: isSelected ? AppTheme.primaryBrand : Colors.grey)),
        ),
      ),
    );
  }

  Widget _buildFechaInicioSelector() {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppTheme.primaryBrand.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.calendar_today_rounded, size: 18, color: AppTheme.primaryBrand)),
      title: const Text('Fecha de Desembolso', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
      subtitle: Text(Formatters.formatDate(_fechaInicio)),
      trailing: const Icon(Icons.edit_calendar_rounded),
      onTap: () async {
        final f = await showDatePicker(context: context, initialDate: _fechaInicio, firstDate: DateTime(2020), lastDate: DateTime(2030));
        if (f != null) { setState(() => _fechaInicio = f); _calcularVistaPrevia(); }
      },
    );
  }

  Widget _buildResumenCalculado() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppTheme.primaryBrand.withOpacity(0.05), borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          _buildResumenItem('Monto Original', Formatters.formatCurrency(_totalesCalculados!['montoOriginal'] ?? 0)),
          _buildResumenItem('Interés Total', Formatters.formatCurrency(_totalesCalculados!['interesTotal'] ?? 0), color: Colors.orange),
          const Divider(height: 24),
          _buildResumenItem('TOTAL A PAGAR', Formatters.formatCurrency(_totalesCalculados!['montoTotal'] ?? 0), isBold: true),
          _buildResumenItem('CUOTA MENSUAL', Formatters.formatCurrency(_totalesCalculados!['cuotaMensual'] ?? 0), isBold: true, color: AppTheme.primaryBrand),
        ],
      ),
    );
  }

  Widget _buildResumenItem(String label, String value, {Color? color, bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 11, fontWeight: isBold ? FontWeight.w900 : FontWeight.w500)),
          Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: color)),
        ],
      ),
    );
  }
}

// Provider de cálculo
final calcularTotalesProvider = FutureProvider.family<Map<String, double>, ({double monto, double tasaInteres, TipoInteres tipoInteres, int plazoMeses})>((ref, p) async {
  final tasaMensual = p.tasaInteres / 100 / 12;
  double cuota, total;
  if (p.tipoInteres == TipoInteres.simple) {
    total = p.monto + (p.monto * tasaMensual * p.plazoMeses);
    cuota = total / p.plazoMeses;
  } else {
    cuota = p.monto * (tasaMensual * pow(1 + tasaMensual, p.plazoMeses)) / (pow(1 + tasaMensual, p.plazoMeses) - 1);
    total = cuota * p.plazoMeses;
  }
  return {'montoOriginal': p.monto, 'interesTotal': total - p.monto, 'montoTotal': total, 'cuotaMensual': cuota};
});

