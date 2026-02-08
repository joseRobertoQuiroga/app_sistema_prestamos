import 'package:flutter/material.dart';
import '../../domain/entities/movimiento.dart';
import '../../../../core/utils/formatters.dart';

class MovimientoCard extends StatelessWidget {
  final Movimiento movimiento;
  final VoidCallback? onTap;

  const MovimientoCard({
    super.key,
    required this.movimiento,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isIngreso = movimiento.tipo == 'INGRESO';
    final isTransferencia = movimiento.tipo == 'TRANSFERENCIA';
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Tipo y Monto
              Row(
                children: [
                  // Icono según tipo
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getTipoColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getTipoIcon(),
                      color: _getTipoColor(),
                      size: 24,
                    ),
                  ),
                  
                  const SizedBox(width: 12),
                  
                  // Descripción
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          movimiento.descripcion,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.label,
                              size: 14,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _getCategoriaLabel(),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(width: 12),
                  
                  // Monto
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${movimiento.simbolo} ${Formatters.formatCurrency(movimiento.monto)}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: _getTipoColor(),
                            ),
                      ),
                      Text(
                        _getTipoLabel(),
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Información adicional
              Row(
                children: [
                  // Fecha
                  Expanded(
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          Formatters.formatDate(movimiento.fecha),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Referencia (si existe)
                  if (movimiento.referencia != null) ...[
                    const SizedBox(width: 16),
                    Expanded(
                      child: Row(
                        children: [
                          Icon(
                            Icons.confirmation_number,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              movimiento.referencia!,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[700],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
              
              // Saldos (si no es compacto)
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildSaldoInfo(
                      'Anterior',
                      movimiento.saldoAnterior,
                      Icons.trending_flat,
                    ),
                    Container(
                      height: 30,
                      width: 1,
                      color: Colors.grey[300],
                    ),
                    _buildSaldoInfo(
                      'Nuevo',
                      movimiento.saldoNuevo,
                      isIngreso ? Icons.trending_up : Icons.trending_down,
                      color: isIngreso ? Colors.green : Colors.red,
                    ),
                  ],
                ),
              ),
              
              // Info de transferencia (si aplica)
              if (isTransferencia && movimiento.cajaDestinoId != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.swap_horiz, size: 16, color: Colors.blue),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Transferencia a otra caja',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue[700],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              
              // Info de préstamo/pago (si aplica)
              if (movimiento.prestamoId != null || movimiento.pagoId != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.purple.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        movimiento.categoria == 'DESEMBOLSO' 
                            ? Icons.money_off 
                            : Icons.payment,
                        size: 16,
                        color: Colors.purple,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        movimiento.categoria == 'DESEMBOLSO'
                            ? 'Vinculado a desembolso de préstamo'
                            : 'Vinculado a pago de préstamo',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.purple[700],
                          fontWeight: FontWeight.w600,
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
    );
  }

  Widget _buildSaldoInfo(String label, double saldo, IconData icon, {Color? color}) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color ?? Colors.grey[600]),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          Formatters.formatCurrency(saldo),
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: color ?? Colors.grey[800],
          ),
        ),
      ],
    );
  }

  Color _getTipoColor() {
    switch (movimiento.tipo) {
      case 'INGRESO':
        return Colors.green;
      case 'EGRESO':
        return Colors.red;
      case 'TRANSFERENCIA':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _getTipoIcon() {
    switch (movimiento.tipo) {
      case 'INGRESO':
        return Icons.add_circle;
      case 'EGRESO':
        return Icons.remove_circle;
      case 'TRANSFERENCIA':
        return Icons.swap_horiz;
      default:
        return Icons.help;
    }
  }

  String _getTipoLabel() {
    switch (movimiento.tipo) {
      case 'INGRESO':
        return 'Ingreso';
      case 'EGRESO':
        return 'Egreso';
      case 'TRANSFERENCIA':
        return 'Transferencia';
      default:
        return movimiento.tipo;
    }
  }

  String _getCategoriaLabel() {
    switch (movimiento.categoria) {
      case 'DESEMBOLSO':
        return 'Desembolso Préstamo';
      case 'PAGO':
        return 'Pago Préstamo';
      case 'GASTO':
        return 'Gasto Operativo';
      case 'DEPOSITO':
        return 'Depósito';
      case 'RETIRO':
        return 'Retiro';
      case 'TRANSFERENCIA':
        return 'Transferencia';
      default:
        return movimiento.categoria;
    }
  }
}