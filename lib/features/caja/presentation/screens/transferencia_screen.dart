import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/caja_provider.dart';
import '../../domain/entities/caja.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/validators.dart';
import '../../../../presentation/widgets/custom_text_field.dart';
import '../../../../presentation/widgets/custom_button.dart';

class TransferenciaScreen extends ConsumerStatefulWidget {
  final int? cajaOrigenId;

  const TransferenciaScreen({
    super.key,
    this.cajaOrigenId,
  });

  @override
  ConsumerState<TransferenciaScreen> createState() => _TransferenciaScreenState();
}

class _TransferenciaScreenState extends ConsumerState<TransferenciaScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  late TextEditingController _montoController;
  late TextEditingController _descripcionController;
  late TextEditingController _referenciaController;
  
  // State
  int? _cajaOrigenSeleccionada;
  int? _cajaDestinoSeleccionada;
  DateTime _fecha = DateTime.now();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _montoController = TextEditingController();
    _descripcionController = TextEditingController();
    _referenciaController = TextEditingController();
    _cajaOrigenSeleccionada = widget.cajaOrigenId;
  }

  @override
  void dispose() {
    _montoController.dispose();
    _descripcionController.dispose();
    _referenciaController.dispose();
    super.dispose();
  }

  Future<void> _realizarTransferencia() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_cajaOrigenSeleccionada == null) {
      _showError('Debe seleccionar una caja origen');
      return;
    }

    if (_cajaDestinoSeleccionada == null) {
      _showError('Debe seleccionar una caja destino');
      return;
    }

    if (_cajaOrigenSeleccionada == _cajaDestinoSeleccionada) {
      _showError('La caja origen y destino no pueden ser la misma');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final transferir = ref.read(registrarTransferenciaUseCaseProvider);
      
      final result = await transferir(
        cajaOrigenId: _cajaOrigenSeleccionada!,
        cajaDestinoId: _cajaDestinoSeleccionada!,
        monto: double.parse(_montoController.text),
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
        (movimientos) {
          setState(() => _isLoading = false);
          _showSuccess(
            'Transferencia realizada: ${Formatters.formatCurrency(double.parse(_montoController.text))}'
          );
          Navigator.pop(context, true);
        },
      );
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Error al realizar transferencia: $e');
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
    final cajasAsync = ref.watch(cajasActivasProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transferencia entre Cajas'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Icono y título
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.swap_horiz,
                    size: 64,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Transferir fondos entre cajas',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Caja Origen
            cajasAsync.when(
              data: (cajas) => _buildCajaOrigenSelector(cajas),
              loading: () => const LinearProgressIndicator(),
              error: (error, _) => Text('Error: $error'),
            ),
            
            const SizedBox(height: 16),
            
            // Icono de flecha
            const Center(
              child: Icon(Icons.arrow_downward, size: 32, color: Colors.grey),
            ),
            
            const SizedBox(height: 16),
            
            // Caja Destino
            cajasAsync.when(
              data: (cajas) => _buildCajaDestinoSelector(cajas),
              loading: () => const LinearProgressIndicator(),
              error: (error, _) => Text('Error: $error'),
            ),
            
            const SizedBox(height: 24),
            
            // Monto
            CustomTextField(
              controller: _montoController,
              label: 'Monto a Transferir',
              keyboardType: TextInputType.number,
              prefixIcon: const Icon(Icons.attach_money),
              onChanged: (_) => setState(() {}),
              validator: (value) => Validators.combine([
                (v) => Validators.required(v, fieldName: 'El monto'),
                (v) => Validators.amount(v),
                (value) {
                  if (_cajaOrigenSeleccionada == null) return null;
                  
                  final monto = double.tryParse(value ?? '');
                  if (monto == null) return null;
                  
                  // Validar saldo disponible
                  final cajaOrigen = cajasAsync.value?.firstWhere(
                    (c) => c.id == _cajaOrigenSeleccionada,
                  );
                  
                  if (cajaOrigen != null && monto > cajaOrigen.saldo) {
                    return 'Saldo insuficiente en caja origen';
                  }
                  
                  return null;
                },
              ])(value),
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
              title: const Text('Fecha de Transferencia'),
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
              label: 'Referencia (opcional)',
              prefixIcon: const Icon(Icons.confirmation_number),
            ),
            
            const SizedBox(height: 32),
            
            // Vista Previa
            if (_cajaOrigenSeleccionada != null && 
                _cajaDestinoSeleccionada != null &&
                _montoController.text.isNotEmpty)
              cajasAsync.when(
                data: (cajas) => _buildVistaPrevia(cajas),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
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
                    text: 'Realizar Transferencia',
                    onPressed: _realizarTransferencia,
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

  // ✅ CORREGIDO: Usar Row en lugar de Column para evitar overflow
  Widget _buildCajaOrigenSelector(List<Caja> cajas) {
    return DropdownButtonFormField<int>(
      value: _cajaOrigenSeleccionada,
      decoration: InputDecoration(
        labelText: 'Caja Origen',
        prefixIcon: const Icon(Icons.account_balance_wallet),
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: Colors.red.withOpacity(0.05),
      ),
      items: cajas.map((caja) {
        return DropdownMenuItem(
          value: caja.id,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  caja.nombre,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                Formatters.formatCurrency(caja.saldo),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: caja.saldo > 0 ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
        );
      }).toList(),
      onChanged: widget.cajaOrigenId == null 
          ? (value) {
              setState(() {
                _cajaOrigenSeleccionada = value;
                // Si selecciona la misma que destino, limpiar destino
                if (_cajaDestinoSeleccionada == value) {
                  _cajaDestinoSeleccionada = null;
                }
              });
            }
          : null,
      validator: (value) {
        if (value == null) {
          return 'Debe seleccionar una caja origen';
        }
        return null;
      },
    );
  }

  // ✅ CORREGIDO: Usar Row en lugar de Column para evitar overflow
  Widget _buildCajaDestinoSelector(List<Caja> cajas) {
    // Filtrar para no mostrar la caja origen
    final cajasDisponibles = cajas.where((c) => c.id != _cajaOrigenSeleccionada).toList();

    return DropdownButtonFormField<int>(
      value: _cajaDestinoSeleccionada,
      decoration: InputDecoration(
        labelText: 'Caja Destino',
        prefixIcon: const Icon(Icons.account_balance_wallet),
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: Colors.green.withOpacity(0.05),
      ),
      items: cajasDisponibles.map((caja) {
        return DropdownMenuItem(
          value: caja.id,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  caja.nombre,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                Formatters.formatCurrency(caja.saldo),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        );
      }).toList(),
      onChanged: (value) {
        setState(() => _cajaDestinoSeleccionada = value);
      },
      validator: (value) {
        if (value == null) {
          return 'Debe seleccionar una caja destino';
        }
        return null;
      },
    );
  }

  Widget _buildVistaPrevia(List<Caja> cajas) {
    final monto = double.tryParse(_montoController.text) ?? 0;
    if (monto == 0) return const SizedBox.shrink();

    final cajaOrigen = cajas.firstWhere((c) => c.id == _cajaOrigenSeleccionada);
    final cajaDestino = cajas.firstWhere((c) => c.id == _cajaDestinoSeleccionada);

    final saldoOrigenNuevo = cajaOrigen.saldo - monto;
    final saldoDestinoNuevo = cajaDestino.saldo + monto;

    return Card(
      color: Theme.of(context).primaryColor.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Vista Previa',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const Divider(),
            
            // Caja Origen
            Text(
              cajaOrigen.nombre,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Saldo actual:'),
                Text(
                  Formatters.formatCurrency(cajaOrigen.saldo),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Nuevo saldo:'),
                Text(
                  Formatters.formatCurrency(saldoOrigenNuevo),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: saldoOrigenNuevo >= 0 ? Colors.orange : Colors.red,
                  ),
                ),
              ],
            ),
            
            const Divider(),
            
            // Caja Destino
            Text(
              cajaDestino.nombre,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Saldo actual:'),
                Text(
                  Formatters.formatCurrency(cajaDestino.saldo),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Nuevo saldo:'),
                Text(
                  Formatters.formatCurrency(saldoDestinoNuevo),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}