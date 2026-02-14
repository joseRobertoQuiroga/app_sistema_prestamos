import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/caja_provider.dart';
import '../../domain/entities/caja.dart';
import '../../../../core/utils/formatters.dart';
import '../../../dashboard/presentation/providers/dashboard_provider.dart';
import '../../../../core/utils/validators.dart';
import '../../../../presentation/widgets/custom_text_field.dart';
import '../../../../presentation/widgets/custom_button.dart';

class RegistrarEgresoScreen extends ConsumerStatefulWidget {
  final int cajaId;

  const RegistrarEgresoScreen({
    super.key,
    required this.cajaId,
  });

  @override
  ConsumerState<RegistrarEgresoScreen> createState() => _RegistrarEgresoScreenState();
}

class _RegistrarEgresoScreenState extends ConsumerState<RegistrarEgresoScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  late TextEditingController _montoController;
  late TextEditingController _descripcionController;
  late TextEditingController _referenciaController;
  
  // State
  String _categoria = 'GASTO';
  DateTime _fecha = DateTime.now();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _montoController = TextEditingController();
    _descripcionController = TextEditingController();
    _referenciaController = TextEditingController();
  }

  @override
  void dispose() {
    _montoController.dispose();
    _descripcionController.dispose();
    _referenciaController.dispose();
    super.dispose();
  }

  Future<void> _registrarEgreso() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final registrarEgreso = ref.read(registrarEgresoUseCaseProvider);
      
      final result = await registrarEgreso(
        cajaId: widget.cajaId,
        monto: double.parse(_montoController.text),
        categoria: _categoria,
        descripcion: _descripcionController.text.trim(),
        fecha: _fecha,
        referencia: _referenciaController.text.isEmpty 
            ? null 
            : _referenciaController.text.trim(),
      );

      result.fold(
        (failure) {
          setState(() => _isLoading = false);
          _showError(failure.message);
        },
        (movimiento) {
          // Invalidar providers
          ref.invalidate(saldoTotalProvider);
          ref.invalidate(dashboardKPIsProvider);
          ref.invalidate(resumenGeneralProvider);
          ref.invalidate(movimientosGeneralesProvider);
          ref.invalidate(cajasListProvider);
          ref.invalidate(cajasActivasProvider);
          
          setState(() => _isLoading = false);
          _showSuccess(
            'Egreso registrado: ${Formatters.formatCurrency(movimiento.monto)}'
          );
          Navigator.pop(context, true);
        },
      );
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Error al registrar egreso: $e');
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
    final cajaAsync = ref.watch(cajaByIdProvider(widget.cajaId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar Egreso'),
      ),
      body: cajaAsync.when(
        data: (caja) {
          if (caja == null) {
            return const Center(child: Text('Caja no encontrada'));
          }

          final monto = double.tryParse(_montoController.text) ?? 0;
          final saldoInsuficiente = monto > caja.saldo;

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Info de la Caja
                Card(
                  color: Colors.red.withOpacity(0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.account_balance_wallet, color: Colors.red),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    caja.nombre,
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  Text(
                                    'Saldo disponible: ${Formatters.formatCurrency(caja.saldo)}',
                                    style: TextStyle(
                                      color: Colors.grey[700],
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (saldoInsuficiente && monto > 0) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.red),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.warning, color: Colors.red, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Saldo insuficiente. Faltan: ${Formatters.formatCurrency(monto - caja.saldo)}',
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Monto
                CustomTextField(
                  controller: _montoController,
                  label: 'Monto del Egreso',
                  keyboardType: TextInputType.number,
                  prefixIcon: const Icon(Icons.remove_circle),
                  onChanged: (_) => setState(() {}), // Para actualizar validación
                  validator: (value) => Validators.combine([
                    (v) => Validators.required(v, fieldName: 'El monto'),
                    (v) => Validators.amount(v),
                    (value) {
                      final monto = double.tryParse(value ?? '');
                      if (monto != null && monto > caja.saldo) {
                        return 'Saldo insuficiente en la caja';
                      }
                      return null;
                    },
                  ])(value),
                ),
                
                const SizedBox(height: 16),
                
                // Categoría
                DropdownButtonFormField<String>(
                  value: _categoria,
                  decoration: const InputDecoration(
                    labelText: 'Categoría',
                    prefixIcon: Icon(Icons.category),
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'GASTO', child: Text('Gasto Operativo')),
                    DropdownMenuItem(value: 'DESEMBOLSO', child: Text('Desembolso Préstamo')),
                    DropdownMenuItem(value: 'RETIRO', child: Text('Retiro')),
                    DropdownMenuItem(value: 'OTRO', child: Text('Otro')),
                  ],
                  onChanged: (value) {
                    setState(() => _categoria = value!);
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Descripción
                CustomTextField(
                  controller: _descripcionController,
                  label: 'Descripción / Concepto',
                  maxLines: 3,
                  prefixIcon: const Icon(Icons.description),
                  validator: (value) => Validators.required(value, fieldName: 'La descripción'),
                ),
                
                const SizedBox(height: 16),
                
                // Fecha
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.calendar_today),
                  title: const Text('Fecha del Egreso'),
                  subtitle: Text(Formatters.formatDate(_fecha)),
                  trailing: const Icon(Icons.edit),
                  onTap: () async {
                    final fecha = await showDatePicker(
                      context: context,
                      initialDate: _fecha,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    
                    if (fecha != null) {
                      setState(() => _fecha = fecha);
                    }
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Referencia (opcional)
                CustomTextField(
                  controller: _referenciaController,
                  label: 'Referencia / N° Comprobante (opcional)',
                  prefixIcon: const Icon(Icons.confirmation_number),
                ),
                
                const SizedBox(height: 32),
                
                // Resumen
                Card(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Resumen',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const Divider(),
                        _buildResumenRow('Saldo actual:', Formatters.formatCurrency(caja.saldo)),
                        if (_montoController.text.isNotEmpty)
                          _buildResumenRow(
                            'Nuevo saldo:',
                            Formatters.formatCurrency(
                              caja.saldo - (double.tryParse(_montoController.text) ?? 0),
                            ),
                            bold: true,
                            color: saldoInsuficiente ? Colors.red : Colors.orange,
                          ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Botones
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
                        text: 'Registrar Egreso',
                        onPressed: saldoInsuficiente ? null : _registrarEgreso,
                        isLoading: _isLoading,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildResumenRow(String label, String value, {bool bold = false, Color? color}) {
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
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}