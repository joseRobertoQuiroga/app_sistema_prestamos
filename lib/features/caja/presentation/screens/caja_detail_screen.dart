import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/caja.dart';
import '../../domain/entities/movimiento.dart';
import '../../domain/entities/resumen_caja.dart';
import '../providers/caja_provider.dart';
import '../widgets/movimiento_card.dart';
import 'caja_form_screen.dart';
import 'registrar_ingreso_screen.dart';
import 'registrar_egreso_screen.dart';
import 'transferencia_screen.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../config/theme/app_theme.dart';

class CajaDetailScreen extends ConsumerWidget {
  final int cajaId;

  const CajaDetailScreen({
    super.key,
    required this.cajaId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cajaAsync = ref.watch(cajaByIdProvider(cajaId));
    final resumenAsync = ref.watch(resumenCajaProvider(cajaId));
    final movimientosAsync = ref.watch(movimientosByCajaProvider(cajaId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de Caja'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Editar',
            onPressed: () => _navegarAEditar(context, ref),
          ),
        ],
      ),
      body: cajaAsync.when(
        data: (caja) {
          if (caja == null) {
            return const Center(child: Text('Caja no encontrada'));
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(cajaByIdProvider(cajaId));
              ref.invalidate(resumenCajaProvider(cajaId));
              ref.invalidate(movimientosByCajaProvider(cajaId));
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Información de la Caja
                _buildInfoCard(context, caja),
                
                const SizedBox(height: 16),
                
                // Resumen de Movimientos
                resumenAsync.when(
                  data: (resumen) => _buildResumenCard(context, resumen),
                  loading: () => const Card(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  ),
                  error: (error, _) => Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text('Error: $error'),
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Acciones Rápidas
                _buildAccionesRapidas(context, ref, caja),
                
                const SizedBox(height: 24),
                
                // Título de Historial
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Historial de Movimientos',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.filter_list),
                      tooltip: 'Filtrar',
                      onPressed: () {
                        // TODO: Implementar filtros
                      },
                    ),
                  ],
                ),
                
                const SizedBox(height: 8),
                
                // Historial de Movimientos
                movimientosAsync.when(
                  data: (movimientos) {
                    if (movimientos.isEmpty) {
                      return const Card(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: Center(
                            child: Text('No hay movimientos registrados'),
                          ),
                        ),
                      );
                    }

                    return Column(
                      children: movimientos.map((movimiento) {
                        return MovimientoCard(
                          movimiento: movimiento,
                          onTap: () {
                            // TODO: Ver detalle del movimiento
                          },
                        );
                      }).toList(),
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, _) => Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text('Error: $error'),
                    ),
                  ),
                ),
                
                const SizedBox(height: 80),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error: $error'),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrarMenuAcciones(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, Caja caja) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _getTipoIcon(caja.tipo),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        caja.nombre,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        _getTipoLabel(caja.tipo),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ],
                  ),
                ),
                _buildEstadoBadge(context, caja.activa),
              ],
            ),
            
            const Divider(height: 24),
            
            // Saldo
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    Text(
                      'Saldo Actual',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      Formatters.formatCurrency(caja.saldo),
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: caja.saldo >= 0 ? Colors.green : Colors.red,
                          ),
                    ),
                  ],
                ),
              ],
            ),
            
            // Info adicional para bancos
            if (caja.tipo == 'BANCO') ...[
              const Divider(height: 24),
              _buildInfoRow(Icons.business, 'Banco', caja.banco ?? 'N/A'),
              if (caja.numeroCuenta != null)
                _buildInfoRow(Icons.confirmation_number, 'N° Cuenta', caja.numeroCuenta!),
              if (caja.titular != null)
                _buildInfoRow(Icons.person, 'Titular', caja.titular!),
            ],
            
            // Descripción
            if (caja.descripcion != null) ...[
              const Divider(height: 24),
              Text(
                'Descripción',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 4),
              Text(caja.descripcion!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResumenCard(BuildContext context, ResumenCaja resumen) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Resumen de Movimientos',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildResumenItem(
                    context,
                    'Ingresos',
                    resumen.totalIngresos,
                    Colors.green,
                    Icons.arrow_upward,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildResumenItem(
                    context,
                    'Egresos',
                    resumen.totalEgresos,
                    Colors.red,
                    Icons.arrow_downward,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildResumenItem(
                    context,
                    'Trans. Entrada',
                    resumen.totalTransferenciasEntrada,
                    Colors.blue,
                    Icons.call_received,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildResumenItem(
                    context,
                    'Trans. Salida',
                    resumen.totalTransferenciasSalida,
                    Colors.orange,
                    Icons.call_made,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildResumenRow('Total movimientos:', '${resumen.cantidadMovimientos}'),
            if (resumen.ultimoMovimiento != null)
              _buildResumenRow(
                'Último movimiento:',
                Formatters.formatRelativeDate(resumen.ultimoMovimiento!),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildResumenItem(
    BuildContext context,
    String label,
    double valor,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[700],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            Formatters.formatCurrency(valor),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResumenRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildAccionesRapidas(BuildContext context, WidgetRef ref, Caja caja) {
    if (!caja.activa) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.info, color: Colors.orange[700]),
              const SizedBox(width: 12),
              const Expanded(
                child: Text('Esta caja está inactiva. Active la caja para realizar movimientos.'),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Acciones Rápidas',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    context,
                    'Ingreso',
                    Icons.add_circle,
                    Colors.green,
                    () => _navegarAIngreso(context, ref, caja),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildActionButton(
                    context,
                    'Egreso',
                    Icons.remove_circle,
                    Colors.red,
                    () => _navegarAEgreso(context, ref, caja),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildActionButton(
                    context,
                    'Transferir',
                    Icons.swap_horiz,
                    Colors.blue,
                    () => _navegarATransferencia(context, ref, caja),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.1),
        foregroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
      child: Column(
        children: [
          Icon(icon),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          const SizedBox(width: 8),
          Text('$label: '),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildEstadoBadge(BuildContext context, bool activa) {
    final color = activa ? Colors.green : Colors.grey;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color),
      ),
      child: Text(
        activa ? 'Activa' : 'Inactiva',
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Icon _getTipoIcon(String tipo) {
    switch (tipo) {
      case 'BANCO':
        return const Icon(Icons.account_balance, size: 40);
      case 'EFECTIVO':
        return const Icon(Icons.money, size: 40);
      default:
        return const Icon(Icons.wallet, size: 40);
    }
  }

  String _getTipoLabel(String tipo) {
    switch (tipo) {
      case 'BANCO':
        return 'Cuenta Bancaria';
      case 'EFECTIVO':
        return 'Efectivo';
      default:
        return 'Otro';
    }
  }

  void _mostrarMenuAcciones(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.add_circle, color: Colors.green),
                title: const Text('Registrar Ingreso'),
                onTap: () {
                  Navigator.pop(context);
                  _navegarAIngreso(context, ref, null);
                },
              ),
              ListTile(
                leading: const Icon(Icons.remove_circle, color: Colors.red),
                title: const Text('Registrar Egreso'),
                onTap: () {
                  Navigator.pop(context);
                  _navegarAEgreso(context, ref, null);
                },
              ),
              ListTile(
                leading: const Icon(Icons.swap_horiz, color: Colors.blue),
                title: const Text('Transferir'),
                onTap: () {
                  Navigator.pop(context);
                  _navegarATransferencia(context, ref, null);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _navegarAEditar(BuildContext context, WidgetRef ref) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CajaFormScreen(cajaId: cajaId),
      ),
    ).then((_) {
      ref.invalidate(cajaByIdProvider(cajaId));
    });
  }

  void _navegarAIngreso(BuildContext context, WidgetRef ref, Caja? caja) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RegistrarIngresoScreen(cajaId: caja?.id ?? cajaId),
      ),
    ).then((_) {
      ref.invalidate(cajaByIdProvider(cajaId));
      ref.invalidate(resumenCajaProvider(cajaId));
      ref.invalidate(movimientosByCajaProvider(cajaId));
    });
  }

  void _navegarAEgreso(BuildContext context, WidgetRef ref, Caja? caja) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RegistrarEgresoScreen(cajaId: caja?.id ?? cajaId),
      ),
    ).then((_) {
      ref.invalidate(cajaByIdProvider(cajaId));
      ref.invalidate(resumenCajaProvider(cajaId));
      ref.invalidate(movimientosByCajaProvider(cajaId));
    });
  }

  void _navegarATransferencia(BuildContext context, WidgetRef ref, Caja? caja) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TransferenciaScreen(cajaOrigenId: caja?.id ?? cajaId),
      ),
    ).then((_) {
      ref.invalidate(cajaByIdProvider(cajaId));
      ref.invalidate(resumenCajaProvider(cajaId));
      ref.invalidate(movimientosByCajaProvider(cajaId));
    });
  }
}