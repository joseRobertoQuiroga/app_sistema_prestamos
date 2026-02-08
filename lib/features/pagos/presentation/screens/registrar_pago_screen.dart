import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/pago_provider.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/utils/formatters.dart';

/// Pantalla para registrar un nuevo pago
class RegistrarPagoScreen extends ConsumerStatefulWidget {
  final int prestamoId;
  final String prestamocodigo;
  final double saldoPendiente;

  const RegistrarPagoScreen({
    super.key,
    required this.prestamoId,
    required this.prestamocodigo,
    required this.saldoPendiente,
  });

  @override
  ConsumerState<RegistrarPagoScreen> createState() => _RegistrarPagoScreenState();
}

class _RegistrarPagoScreenState extends ConsumerState<RegistrarPagoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _montoController = TextEditingController();
  final _referenciaController = TextEditingController();
  final _observacionesController = TextEditingController();
  
  DateTime _fechaPago = DateTime.now();
  String _metodoPago = 'EFECTIVO';
  int? _cajaId;
  bool _isLoading = false;

  @override
  void dispose() {
    _montoController.dispose();
    _referenciaController.dispose();
    _observacionesController.dispose();
    super.dispose();
  }

  Future<void> _registrarPago() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final monto = Formatters.parseCurrency(_montoController.text) ?? 0;
    
    final registrarPago = ref.read(registrarPagoUseCaseProvider);
    final result = await registrarPago(
      prestamoId: widget.prestamoId,
      monto: monto,
      fechaPago: _fechaPago,
      cajaId: _cajaId,
      metodoPago: _metodoPago,
      referencia: _referenciaController.text.trim().isEmpty 
          ? null 
          : _referenciaController.text.trim(),
      observaciones: _observacionesController.text.trim().isEmpty 
          ? null 
          : _observacionesController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (mounted) {
      result.fold(
        (failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(failure.message),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        },
        (resultado) {
          // Mostrar diálogo con resultado
          _mostrarResultado(resultado);
        },
      );
    }
  }

  void _mostrarResultado(dynamic resultado) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Pago Registrado'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Monto aplicado: ${Formatters.formatCurrency(resultado.montoAplicado)}'),
            const SizedBox(height: 8),
            Text('Distribución:', style: Theme.of(context).textTheme.titleSmall),
            Text('• Mora: ${Formatters.formatCurrency(resultado.totalMora)}'),
            Text('• Interés: ${Formatters.formatCurrency(resultado.totalInteres)}'),
            Text('• Capital: ${Formatters.formatCurrency(resultado.totalCapital)}'),
            const SizedBox(height: 8),
            Text('Cuotas afectadas: ${resultado.cuotasAfectadas}'),
            Text('Cuotas pagadas: ${resultado.cuotasPagadas.length}'),
            if (resultado.montoRestante > 0) ...[
              const SizedBox(height: 8),
              Text(
                'Sobrante: ${Formatters.formatCurrency(resultado.montoRestante)}',
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
            ],
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.pop(context); // Cerrar diálogo
              Navigator.pop(context, true); // Volver con resultado
            },
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar Pago'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Info del préstamo
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Préstamo: ${widget.prestamocodigo}'),
                    const SizedBox(height: 4),
                    Text(
                      'Saldo pendiente: ${Formatters.formatCurrency(widget.saldoPendiente)}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Monto
            TextFormField(
              controller: _montoController,
              decoration: InputDecoration(
                labelText: 'Monto del pago *',
                prefixText: 'Bs. ',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              validator: Validators.amount,
            ),
            const SizedBox(height: 16),

            // Fecha de pago
            ListTile(
              title: const Text('Fecha de pago'),
              subtitle: Text(Formatters.formatDate(_fechaPago)),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final fecha = await showDatePicker(
                  context: context,
                  initialDate: _fechaPago,
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                );
                if (fecha != null) {
                  setState(() => _fechaPago = fecha);
                }
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Theme.of(context).colorScheme.outline),
              ),
            ),
            const SizedBox(height: 16),

            // Método de pago
            DropdownButtonFormField<String>(
              value: _metodoPago,
              decoration: const InputDecoration(
                labelText: 'Método de pago',
                border: OutlineInputBorder(),
              ),
              items: ['EFECTIVO', 'TRANSFERENCIA', 'CHEQUE', 'OTRO']
                  .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                  .toList(),
              onChanged: (value) => setState(() => _metodoPago = value!),
            ),
            const SizedBox(height: 16),

            // Referencia
            if (_metodoPago != 'EFECTIVO')
              TextFormField(
                controller: _referenciaController,
                decoration: const InputDecoration(
                  labelText: 'Referencia (Nº cheque, transferencia, etc.)',
                  border: OutlineInputBorder(),
                ),
              ),
            const SizedBox(height: 16),

            // Observaciones
            TextFormField(
              controller: _observacionesController,
              decoration: const InputDecoration(
                labelText: 'Observaciones',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),

            // Botones
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : () => Navigator.pop(context),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: FilledButton(
                    onPressed: _isLoading ? null : _registrarPago,
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Registrar Pago'),
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