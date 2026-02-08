import 'package:flutter/material.dart';
import '../../domain/entities/caja.dart';
import '../../../../core/utils/formatters.dart';

class CajaCard extends StatelessWidget {
  final Caja caja;
  final VoidCallback onTap;

  const CajaCard({
    super.key,
    required this.caja,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Tipo, Nombre y Estado
              Row(
                children: [
                  // Icono según tipo
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _getTipoColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getTipoIcon(),
                      color: _getTipoColor(),
                      size: 32,
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // Nombre y tipo
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          caja.nombre,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getTipoLabel(),
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(width: 8),
                  
                  // Badge de estado
                  _buildEstadoBadge(context),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Saldo
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: caja.saldo >= 0
                        ? [
                            Colors.green.withOpacity(0.1),
                            Colors.green.withOpacity(0.05),
                          ]
                        : [
                            Colors.red.withOpacity(0.1),
                            Colors.red.withOpacity(0.05),
                          ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: caja.saldo >= 0 
                        ? Colors.green.withOpacity(0.3)
                        : Colors.red.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Saldo Actual',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      Formatters.formatCurrency(caja.saldo),
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: caja.saldo >= 0 ? Colors.green : Colors.red,
                          ),
                    ),
                  ],
                ),
              ),
              
              // Información adicional para bancos
              if (caja.tipo == 'BANCO') ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      if (caja.banco != null)
                        _buildInfoRow(
                          Icons.business,
                          'Banco',
                          caja.banco!,
                        ),
                      if (caja.numeroCuenta != null) ...[
                        const SizedBox(height: 4),
                        _buildInfoRow(
                          Icons.confirmation_number,
                          'N° Cuenta',
                          caja.numeroCuenta!,
                        ),
                      ],
                      if (caja.titular != null) ...[
                        const SizedBox(height: 4),
                        _buildInfoRow(
                          Icons.person,
                          'Titular',
                          caja.titular!,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
              
              // Descripción (si existe)
              if (caja.descripcion != null && caja.descripcion!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.notes, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        caja.descripcion!,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[700],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
              
              // Footer: Fecha de creación
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 14,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Creada: ${Formatters.formatDate(caja.fechaCreacion)}',
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
      ),
    );
  }

  Widget _buildEstadoBadge(BuildContext context) {
    final color = caja.activa ? Colors.green : Colors.grey;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            caja.activa ? Icons.check_circle : Icons.cancel,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            caja.activa ? 'Activa' : 'Inactiva',
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[700],
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Color _getTipoColor() {
    switch (caja.tipo) {
      case 'BANCO':
        return Colors.blue;
      case 'EFECTIVO':
        return Colors.green;
      default:
        return Colors.purple;
    }
  }

  IconData _getTipoIcon() {
    switch (caja.tipo) {
      case 'BANCO':
        return Icons.account_balance;
      case 'EFECTIVO':
        return Icons.money;
      default:
        return Icons.wallet;
    }
  }

  String _getTipoLabel() {
    switch (caja.tipo) {
      case 'BANCO':
        return 'Cuenta Bancaria';
      case 'EFECTIVO':
        return 'Efectivo';
      default:
        return 'Otro';
    }
  }
}