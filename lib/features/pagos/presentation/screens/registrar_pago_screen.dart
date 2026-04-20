import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/pago_provider.dart';
import '../../../caja/presentation/providers/caja_provider.dart';
import '../../../dashboard/presentation/providers/dashboard_provider.dart';
import '../../../prestamos/presentation/providers/prestamo_provider.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../presentation/widgets/custom_transaction_dialog.dart';

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
  bool _esAbonoCapital = false; // Estado para el nuevo switch
  bool _esCobroInteres = false; // Estado para Cobro de Interés anticipado

  @override
  void initState() {
    super.initState();
    // Forzar recarga de cajas activas para que el dropdown de caja destino siempre esté actualizado
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(cajasActivasProvider);
    });
  }

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
      esAbonoCapital: _esAbonoCapital, // Pasar valor del switch
      esCobroInteres: _esCobroInteres, // Pasar valor del cobro interés
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
          // Invalidar providers globales
          ref.invalidate(saldoTotalProvider);
          ref.invalidate(dashboardKPIsProvider);
          ref.invalidate(resumenGeneralProvider);
          ref.invalidate(movimientosGeneralesProvider);
          ref.invalidate(cajasListProvider);
          ref.invalidate(cajasActivasProvider);
          // Invalidar providers del préstamo para refrescar su detalle y pagos
          ref.invalidate(pagosListProvider(widget.prestamoId));
          ref.invalidate(resumenPagosProvider(widget.prestamoId));
          ref.invalidate(prestamoDetailProvider(widget.prestamoId));
          ref.invalidate(cuotasListProvider(widget.prestamoId));
          ref.invalidate(resumenCuotasProvider(widget.prestamoId));
          ref.invalidate(prestamosListProvider);
          
          // Mostrar diálogo con resultado
          _mostrarResultado(resultado);
        },
      );
    }
  }

  void _mostrarResultado(dynamic resultado) {
    CustomTransactionDialog.show(
      context: context,
      type: TransactionType.payment,
      title: 'Pago Registrado',
      data: {
        'montoAplicado': resultado.montoAplicado,
        'mora': resultado.totalMora,
        'interes': resultado.totalInteres,
        'capital': resultado.totalCapital,
        'periodo': resultado.periodoAfectado ?? 'No definido',
        'totalPagos': resultado.totalPagosRealizados,
        'restante': resultado.montoRestante,
      },
      onAccept: () {
        Navigator.pop(context); // Cerrar diálogo
        Navigator.pop(context, true); // Volver con resultado
      },
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
            
            // Selector de Caja Destino Obligatorio
            Consumer(
              builder: (context, ref, child) {
                final cajasAsync = ref.watch(cajasActivasProvider);
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Caja Destino (donde ingresa el dinero) *',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    cajasAsync.when(
                      data: (cajas) {
                        if (cajas.isEmpty) return const Text('No hay cajas activas');
                        // Asignar primera caja por defecto si es nulo
                        if (_cajaId == null && cajas.isNotEmpty) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (mounted) setState(() => _cajaId = cajas.first.id);
                          });
                        }
                        return DropdownButtonFormField<int>(
                          value: _cajaId ?? (cajas.isNotEmpty ? cajas.first.id : null),
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.account_balance_outlined),
                          ),
                          items: cajas.map((c) => DropdownMenuItem(
                            value: c.id, 
                            child: Text(c.nombre)
                          )).toList(),
                          onChanged: (v) => setState(() => _cajaId = v),
                          validator: (v) => v == null ? 'Seleccione una caja' : null,
                        );
                      },
                      loading: () => const LinearProgressIndicator(),
                      error: (err, _) => Text('Error al cargar cajas: $err'),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            
            // Switch Abono a Capital (Nuevo)
            SwitchListTile(
              title: const Text('Abono directo a Capital'),
              subtitle: const Text('No cobra interés en este pago, reduce saldo directamente.'),
              value: _esAbonoCapital,
              onChanged: (val) {
                setState(() {
                  _esAbonoCapital = val;
                  if (val) _esCobroInteres = false;
                });
              },
              secondary: const Icon(Icons.savings_outlined),
            ),
            const Divider(),
            // Switch Cobro a Interés (Nuevo)
            SwitchListTile(
              title: const Text('Cobrar Interés (Anticipado / Manual)'),
              subtitle: const Text('Omite el capital. Todo el dinero ingresado cubre solo la porción de intereses.'),
              value: _esCobroInteres,
              onChanged: (val) {
                setState(() {
                  _esCobroInteres = val;
                  if (val) _esAbonoCapital = false;
                });
              },
              secondary: const Icon(Icons.percent_outlined),
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
            LayoutBuilder(
              builder: (context, constraints) {
                final isNarrow = constraints.maxWidth < 400;
                
                final buttons = [
                  Expanded(
                    flex: isNarrow ? 0 : 1,
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  SizedBox(
                    width: isNarrow ? 0 : 16,
                    height: isNarrow ? 12 : 0,
                  ),
                  Expanded(
                    flex: isNarrow ? 0 : 1,
                    child: FilledButton(
                      onPressed: _isLoading ? null : _registrarPago,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Text('Registrar Pago'),
                    ),
                  ),
                ];

                return isNarrow 
                    ? Column(children: buttons) 
                    : Row(children: buttons);
              },
            ),
          ],
        ),
      ),
    );
  }
}