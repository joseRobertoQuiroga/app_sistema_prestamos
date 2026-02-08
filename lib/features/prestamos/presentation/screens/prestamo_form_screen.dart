import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/prestamo.dart';
import '../../domain/entities/cuota.dart';
import '../providers/prestamo_provider.dart';
import '../widgets/tabla_amortizacion_widget.dart';
import '../../../clientes/presentation/providers/cliente_provider.dart';
import '../../../clientes/domain/entities/cliente.dart';
import '../../../cajas/presentation/providers/caja_provider.dart';
import '../../../cajas/domain/entities/caja.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/validators.dart';
import '../../../../presentation/widgets/custom_text_field.dart';
import '../../../../presentation/widgets/custom_button.dart';
// Import necesario
import 'dart:math';
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
    _montoController.addListener(_calcularVistaPrevia);
    _tasaController.addListener(_calcularVistaPrevia);
    _plazoController.addListener(_calcularVistaPrevia);
  }

  @override
  void dispose() {
    _montoController.dispose();
    _tasaController.dispose();
    _plazoController.dispose();
    _observacionesController.dispose();
    super.dispose();
  }

  Future<void> _calcularVistaPrevia() async {
    // Solo calcular si todos los campos tienen valores válidos
    if (_montoController.text.isEmpty ||
        _tasaController.text.isEmpty ||
        _plazoController.text.isEmpty) {
      setState(() {
        _vistaPrevia = null;
        _totalesCalculados = null;
      });
      return;
    }

    final monto = double.tryParse(_montoController.text);
    final tasa = double.tryParse(_tasaController.text);
    final plazo = int.tryParse(_plazoController.text);

    if (monto == null || tasa == null || plazo == null) {
      return;
    }

    if (monto <= 0 || tasa < 0 || plazo <= 0) {
      return;
    }

    setState(() => _isCalculating = true);

    try {
      // Calcular totales
      final totales = await ref.read(calcularTotalesProvider(
        monto: monto,
        tasaInteres: tasa,
        tipoInteres: _tipoInteres,
        plazoMeses: plazo,
      ).future);

      // Generar tabla de amortización
      final resultado = await ref.read(generarTablaAmortizacionProvider(
        prestamoId: 0, // Temporal
        monto: monto,
        tasaInteres: tasa,
        tipoInteres: _tipoInteres,
        plazoMeses: plazo,
        fechaInicio: _fechaInicio,
      ).future);

      setState(() {
        _totalesCalculados = totales;
        _vistaPrevia = resultado;
        _isCalculating = false;
      });
    } catch (e) {
      setState(() => _isCalculating = false);
    }
  }

  Future<void> _guardarPrestamo() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_clienteSeleccionado == null) {
      _showError('Debe seleccionar un cliente');
      return;
    }

    if (_cajaSeleccionada == null) {
      _showError('Debe seleccionar una caja');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Generar código
      final generarCodigo = ref.read(generarCodigoPrestamoProvider);
      final codigoResult = await generarCodigo();
      
      final codigo = codigoResult.fold(
        (failure) => throw Exception(failure.message),
        (codigo) => codigo,
      );

      // Calcular fecha de vencimiento
      final fechaVencimiento = DateTime(
        _fechaInicio.year,
        _fechaInicio.month + int.parse(_plazoController.text),
        _fechaInicio.day,
      );

      // Crear préstamo
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
        observaciones: _observacionesController.text.isEmpty 
            ? null 
            : _observacionesController.text,
        fechaRegistro: DateTime.now(),
      );

      // Guardar
      final createPrestamo = ref.read(createPrestamoProvider);
      final result = await createPrestamo(prestamo);

      result.fold(
        (failure) {
          setState(() => _isLoading = false);
          _showError(failure.message);
        },
        (prestamoCreado) {
          // Crear cuotas
          _crearCuotas(prestamoCreado.id!);
        },
      );
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Error al crear préstamo: $e');
    }
  }

  Future<void> _crearCuotas(int prestamoId) async {
    if (_vistaPrevia == null) return;

    try {
      // Aquí se deberían crear las cuotas en la BD
      // Por ahora asumimos que se crean automáticamente en el backend
      
      setState(() => _isLoading = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Préstamo creado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Error al crear cuotas: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final clientesAsync = ref.watch(clientesProvider);
    final cajasAsync = ref.watch(cajasActivasProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.prestamoId == null 
            ? 'Nuevo Préstamo' 
            : 'Editar Préstamo'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Selector de Cliente
                  _buildClienteSelector(clientesAsync),
                  
                  const SizedBox(height: 16),
                  
                  // Selector de Caja
                  _buildCajaSelector(cajasAsync),
                  
                  const SizedBox(height: 24),
                  
                  Text(
                    'Datos del Préstamo',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Monto
                  CustomTextField(
                    controller: _montoController,
                    label: 'Monto del Préstamo',
                    keyboardType: TextInputType.number,
                    prefixIcon: Icons.attach_money,
                    validator: Validators.combine([
                      Validators.required('El monto es requerido'),
                      Validators.amount(),
                    ]),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Tasa de Interés
                  CustomTextField(
                    controller: _tasaController,
                    label: 'Tasa de Interés Anual (%)',
                    keyboardType: TextInputType.number,
                    prefixIcon: Icons.percent,
                    validator: Validators.combine([
                      Validators.required('La tasa es requerida'),
                      Validators.interestRate(),
                    ]),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Plazo
                  CustomTextField(
                    controller: _plazoController,
                    label: 'Plazo (meses)',
                    keyboardType: TextInputType.number,
                    prefixIcon: Icons.access_time,
                    validator: Validators.combine([
                      Validators.required('El plazo es requerido'),
                      Validators.termMonths(),
                    ]),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Tipo de Interés
                  _buildTipoInteresSelector(),
                  
                  const SizedBox(height: 16),
                  
                  // Fecha de Inicio
                  _buildFechaInicioSelector(),
                  
                  const SizedBox(height: 16),
                  
                  // Observaciones
                  CustomTextField(
                    controller: _observacionesController,
                    label: 'Observaciones (opcional)',
                    maxLines: 3,
                    prefixIcon: Icons.notes,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Resumen Calculado
                  if (_totalesCalculados != null) _buildResumenCalculado(),
                  
                  const SizedBox(height: 16),
                  
                  // Botón Vista Previa
                  if (_vistaPrevia != null)
                    OutlinedButton.icon(
                      onPressed: () {
                        setState(() {
                          _mostrarVistaPrevia = !_mostrarVistaPrevia;
                        });
                      },
                      icon: Icon(_mostrarVistaPrevia 
                          ? Icons.visibility_off 
                          : Icons.visibility),
                      label: Text(_mostrarVistaPrevia 
                          ? 'Ocultar Tabla de Amortización' 
                          : 'Ver Tabla de Amortización'),
                    ),
                  
                  const SizedBox(height: 16),
                  
                  // Vista Previa de Tabla
                  if (_mostrarVistaPrevia && _vistaPrevia != null)
                    TablaAmortizacionWidget(
                      cuotas: _vistaPrevia!,
                      compact: true,
                    ),
                  
                  const SizedBox(height: 24),
                  
                  // Botones de Acción
                  Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                          text: 'Cancelar',
                          type: ButtonType.outlined,
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: CustomButton(
                          text: 'Guardar Préstamo',
                          onPressed: _guardarPrestamo,
                          isLoading: _isLoading,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  Widget _buildClienteSelector(AsyncValue<ClientesState> clientesAsync) {
    return clientesAsync.when(
      data: (state) {
        final clientesActivos = state.clientes.where((c) => c.activo).toList();
        
        return DropdownButtonFormField<int>(
          value: _clienteSeleccionado,
          decoration: const InputDecoration(
            labelText: 'Cliente',
            prefixIcon: Icon(Icons.person),
            border: OutlineInputBorder(),
          ),
          items: clientesActivos.map((cliente) {
            return DropdownMenuItem(
              value: cliente.id,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(cliente.nombreCompleto),
                  Text(
                    'CI: ${cliente.ci}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() => _clienteSeleccionado = value);
          },
          validator: (value) {
            if (value == null) {
              return 'Debe seleccionar un cliente';
            }
            return null;
          },
        );
      },
      loading: () => const LinearProgressIndicator(),
      error: (error, _) => Text('Error: $error'),
    );
  }

  Widget _buildCajaSelector(AsyncValue<List<Caja>> cajasAsync) {
    return cajasAsync.when(
      data: (cajas) {
        return DropdownButtonFormField<int>(
          value: _cajaSeleccionada,
          decoration: const InputDecoration(
            labelText: 'Caja de Desembolso',
            prefixIcon: Icon(Icons.account_balance_wallet),
            border: OutlineInputBorder(),
          ),
          items: cajas.map((caja) {
            return DropdownMenuItem(
              value: caja.id,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(caja.nombre),
                  Text(
                    'Saldo: ${Formatters.formatCurrency(caja.saldo)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: caja.saldo > 0 ? Colors.green : Colors.red,
                        ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() => _cajaSeleccionada = value);
          },
          validator: (value) {
            if (value == null) {
              return 'Debe seleccionar una caja';
            }
            return null;
          },
        );
      },
      loading: () => const LinearProgressIndicator(),
      error: (error, _) => Text('Error: $error'),
    );
  }

  Widget _buildTipoInteresSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tipo de Interés',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<TipoInteres>(
                    title: const Text('Simple'),
                    subtitle: const Text('Interés fijo'),
                    value: TipoInteres.simple,
                    groupValue: _tipoInteres,
                    onChanged: (value) {
                      setState(() => _tipoInteres = value!);
                      _calcularVistaPrevia();
                    },
                  ),
                ),
                Expanded(
                  child: RadioListTile<TipoInteres>(
                    title: const Text('Compuesto'),
                    subtitle: const Text('Cuota fija'),
                    value: TipoInteres.compuesto,
                    groupValue: _tipoInteres,
                    onChanged: (value) {
                      setState(() => _tipoInteres = value!);
                      _calcularVistaPrevia();
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFechaInicioSelector() {
    return ListTile(
      leading: const Icon(Icons.calendar_today),
      title: const Text('Fecha de Inicio'),
      subtitle: Text(Formatters.formatDate(_fechaInicio)),
      trailing: const Icon(Icons.edit),
      onTap: () async {
        final fecha = await showDatePicker(
          context: context,
          initialDate: _fechaInicio,
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
        );
        
        if (fecha != null) {
          setState(() => _fechaInicio = fecha);
          _calcularVistaPrevia();
        }
      },
    );
  }

  Widget _buildResumenCalculado() {
    return Card(
      color: Theme.of(context).primaryColor.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Resumen del Préstamo',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const Divider(),
            _buildResumenRow(
              'Monto Solicitado:',
              Formatters.formatCurrency(_totalesCalculados!['montoOriginal'] ?? 0),
            ),
            _buildResumenRow(
              'Total Intereses:',
              Formatters.formatCurrency(_totalesCalculados!['interesTotal'] ?? 0),
              color: Colors.orange,
            ),
            _buildResumenRow(
              'Total a Pagar:',
              Formatters.formatCurrency(_totalesCalculados!['montoTotal'] ?? 0),
              bold: true,
            ),
            const Divider(),
            _buildResumenRow(
              'Cuota Mensual:',
              Formatters.formatCurrency(_totalesCalculados!['cuotaMensual'] ?? 0),
              color: Theme.of(context).primaryColor,
              bold: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResumenRow(String label, String value, {Color? color, bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

// Provider para calcular totales
final calcularTotalesProvider = FutureProvider.family<Map<String, double>, ({
  double monto,
  double tasaInteres,
  TipoInteres tipoInteres,
  int plazoMeses,
})>((ref, params) async {
  // Importar el método estático de GenerarTablaAmortizacion
  final totales = {
    'montoOriginal': params.monto,
    'montoTotal': 0.0,
    'interesTotal': 0.0,
    'cuotaMensual': 0.0,
  };
  
  if (params.tipoInteres == TipoInteres.simple) {
    final tasaMensual = params.tasaInteres / 100 / 12;
    final interesTotal = params.monto * tasaMensual * params.plazoMeses;
    final montoTotal = params.monto + interesTotal;
    final cuotaMensual = montoTotal / params.plazoMeses;
    
    totales['montoTotal'] = montoTotal;
    totales['interesTotal'] = interesTotal;
    totales['cuotaMensual'] = cuotaMensual;
  } else {
    final tasaMensual = params.tasaInteres / 100 / 12;
    final cuotaMensual = params.monto *
        (tasaMensual * pow(1 + tasaMensual, params.plazoMeses)) /
        (pow(1 + tasaMensual, params.plazoMeses) - 1);
    final montoTotal = cuotaMensual * params.plazoMeses;
    final interesTotal = montoTotal - params.monto;
    
    totales['montoTotal'] = montoTotal;
    totales['interesTotal'] = interesTotal;
    totales['cuotaMensual'] = cuotaMensual;
  }
  
  return totales;
});

