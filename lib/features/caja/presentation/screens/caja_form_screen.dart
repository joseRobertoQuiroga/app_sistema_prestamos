import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/caja.dart';
import '../providers/caja_provider.dart';
import '../../../../core/utils/validators.dart';
import '../../../../presentation/widgets/custom_text_field.dart';
import '../../../../presentation/widgets/custom_button.dart';
import '../../../dashboard/presentation/providers/dashboard_provider.dart';

class CajaFormScreen extends ConsumerStatefulWidget {
  final int? cajaId;

  const CajaFormScreen({
    super.key,
    this.cajaId,
  });

  @override
  ConsumerState<CajaFormScreen> createState() => _CajaFormScreenState();
}

class _CajaFormScreenState extends ConsumerState<CajaFormScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  late TextEditingController _nombreController;
  late TextEditingController _saldoInicialController;
  late TextEditingController _descripcionController;
  late TextEditingController _bancoController;
  late TextEditingController _numeroCuentaController;
  late TextEditingController _titularController;
  
  // State
  String _tipo = 'EFECTIVO';
  bool _activa = true;
  bool _isLoading = false;
  Caja? _cajaExistente;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController();
    _saldoInicialController = TextEditingController(text: '0');
    _descripcionController = TextEditingController();
    _bancoController = TextEditingController();
    _numeroCuentaController = TextEditingController();
    _titularController = TextEditingController();
    
    if (widget.cajaId != null) {
      _cargarCaja();
    }
  }

  Future<void> _cargarCaja() async {
    setState(() => _isLoading = true);
    
    final cajaAsync = await ref.read(cajaByIdProvider(widget.cajaId!).future);
    
    if (cajaAsync != null) {
      setState(() {
        _cajaExistente = cajaAsync;
        _nombreController.text = cajaAsync.nombre;
        _tipo = cajaAsync.tipo;
        _descripcionController.text = cajaAsync.descripcion ?? '';
        _bancoController.text = cajaAsync.banco ?? '';
        _numeroCuentaController.text = cajaAsync.numeroCuenta ?? '';
        _titularController.text = cajaAsync.titular ?? '';
        _activa = cajaAsync.activa;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
      _showError('Caja no encontrada');
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _saldoInicialController.dispose();
    _descripcionController.dispose();
    _bancoController.dispose();
    _numeroCuentaController.dispose();
    _titularController.dispose();
    super.dispose();
  }

  Future<void> _guardarCaja() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validaciones adicionales para bancos
    if (_tipo == 'BANCO') {
      if (_bancoController.text.isEmpty) {
        _showError('Debe ingresar el nombre del banco');
        return;
      }
    }

    setState(() => _isLoading = true);

    try {
      final caja = Caja(
        id: widget.cajaId,
        nombre: _nombreController.text.trim(),
        tipo: _tipo,
        saldo: widget.cajaId == null 
            ? double.parse(_saldoInicialController.text) 
            : _cajaExistente!.saldo, // No modificar saldo en edición
        numeroCuenta: _tipo == 'BANCO' ? _numeroCuentaController.text.trim() : null,
        banco: _tipo == 'BANCO' ? _bancoController.text.trim() : null,
        titular: _tipo == 'BANCO' ? _titularController.text.trim() : null,
        descripcion: _descripcionController.text.isEmpty 
            ? null 
            : _descripcionController.text.trim(),
        activa: _activa,
        fechaCreacion: _cajaExistente?.fechaCreacion ?? DateTime.now(),
        fechaActualizacion: widget.cajaId != null ? DateTime.now() : null,
      );

      if (widget.cajaId == null) {
        // Crear
        final createCaja = ref.read(createCajaUseCaseProvider);
        final result = await createCaja(caja);
        
        result.fold(
          (failure) {
            setState(() => _isLoading = false);
            _showError(failure.message);
          },
          (cajaCreada) {
            // Invalidar providers
            ref.invalidate(cajasListProvider);
            ref.invalidate(cajasActivasProvider);
            ref.invalidate(saldoTotalProvider);
            ref.invalidate(resumenGeneralProvider);
            ref.invalidate(dashboardKPIsProvider);
            
            setState(() => _isLoading = false);
            _showSuccess('Caja creada exitosamente');
            Navigator.pop(context, true);
          },
        );
      } else {
        // Actualizar
        final updateCaja = ref.read(updateCajaUseCaseProvider);
        final result = await updateCaja(caja);
        
        result.fold(
          (failure) {
            setState(() => _isLoading = false);
            _showError(failure.message);
          },
          (cajaActualizada) {
            // Invalidar providers
            ref.invalidate(cajasListProvider);
            ref.invalidate(cajasActivasProvider);
            ref.invalidate(saldoTotalProvider);
            ref.invalidate(resumenGeneralProvider);
            ref.invalidate(dashboardKPIsProvider);
            ref.invalidate(cajaByIdProvider(widget.cajaId!));
            
            setState(() => _isLoading = false);
            _showSuccess('Caja actualizada exitosamente');
            Navigator.pop(context, true);
          },
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Error al guardar caja: $e');
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

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.cajaId == null ? 'Nueva Caja' : 'Editar Caja'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: Column(
                children: [
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        // Nombre
                        CustomTextField(
                          controller: _nombreController,
                          label: 'Nombre de la Caja',
                          prefixIcon: const Icon(Icons.account_balance_wallet),
                          validator: (value) =>
                              Validators.required(value, fieldName: 'El nombre'),
                        ),

                        const SizedBox(height: 16),

                        // Tipo
                        _buildTipoSelector(),

                        const SizedBox(height: 16),

                        // Saldo Inicial (solo en creación)
                        if (widget.cajaId == null)
                          Column(
                            children: [
                              CustomTextField(
                                controller: _saldoInicialController,
                                label: 'Saldo Inicial',
                                keyboardType: TextInputType.number,
                                prefixIcon: const Icon(Icons.attach_money),
                                validator: (value) => Validators.combine([
                                  (v) => Validators.required(v,
                                      fieldName: 'El saldo inicial'),
                                  (v) {
                                    final saldo = double.tryParse(v ?? '');
                                    if (saldo == null || saldo < 0) {
                                      return 'El saldo debe ser mayor o igual a 0';
                                    }
                                    return null;
                                  },
                                ])(value),
                              ),
                              const SizedBox(height: 16),
                            ],
                          ),

                        // Campos específicos para BANCO
                        if (_tipo == 'BANCO') ...[
                          CustomTextField(
                            controller: _bancoController,
                            label: 'Nombre del Banco',
                            prefixIcon: const Icon(Icons.business),
                            validator: (value) => _tipo == 'BANCO'
                                ? Validators.required(value,
                                    fieldName: 'El nombre del banco')
                                : null,
                          ),

                          const SizedBox(height: 16),

                          CustomTextField(
                            controller: _numeroCuentaController,
                            label: 'Número de Cuenta',
                            prefixIcon: const Icon(Icons.confirmation_number),
                          ),

                          const SizedBox(height: 16),

                          CustomTextField(
                            controller: _titularController,
                            label: 'Titular de la Cuenta',
                            prefixIcon: const Icon(Icons.person),
                          ),

                          const SizedBox(height: 16),
                        ],

                        // Descripción
                        CustomTextField(
                          controller: _descripcionController,
                          label: 'Descripción (opcional)',
                          maxLines: 3,
                          prefixIcon: const Icon(Icons.notes),
                        ),

                        const SizedBox(height: 16),

                        // Estado Activa/Inactiva
                        SwitchListTile(
                          title: const Text('Caja Activa'),
                          subtitle: Text(_activa
                              ? 'La caja está habilitada para transacciones'
                              : 'La caja está deshabilitada'),
                          value: _activa,
                          onChanged: (value) {
                            setState(() => _activa = value);
                          },
                        ),
                      ],
                    ),
                  ),

                  // Botones de Acción Fijos
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
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
                            text: 'Cancelar',
                            type: ButtonType.outlined,
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 2,
                          child: CustomButton(
                            text: widget.cajaId == null
                                ? 'Crear Caja'
                                : 'Actualizar Caja',
                            onPressed: _guardarCaja,
                            isLoading: _isLoading,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildTipoSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tipo de Caja',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _tipo,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'EFECTIVO',
                  child: Row(
                    children: [
                      Icon(Icons.money, size: 20),
                      SizedBox(width: 8),
                      Text('Efectivo'),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: 'BANCO',
                  child: Row(
                    children: [
                      Icon(Icons.account_balance, size: 20),
                      SizedBox(width: 8),
                      Text('Cuenta Bancaria'),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: 'OTRO',
                  child: Row(
                    children: [
                      Icon(Icons.wallet, size: 20),
                      SizedBox(width: 8),
                      Text('Otro'),
                    ],
                  ),
                ),
              ],
              onChanged: widget.cajaId == null 
                  ? (value) {
                      setState(() => _tipo = value!);
                    }
                  : null, // No permitir cambiar tipo en edición
            ),
          ],
        ),
      ),
    );
  }
}