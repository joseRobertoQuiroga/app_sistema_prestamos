import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/utils/formatters.dart';

enum TransactionType { payment, transfer, loan, income, expense }

class CustomTransactionDialog extends StatelessWidget {
  final TransactionType type;
  final String title;
  final Map<String, dynamic> data;
  final VoidCallback? onAccept;

  const CustomTransactionDialog({
    super.key,
    required this.type,
    required this.title,
    required this.data,
    this.onAccept,
  });

  static Future<void> show({
    required BuildContext context,
    required TransactionType type,
    required String title,
    required Map<String, dynamic> data,
    VoidCallback? onAccept,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => CustomTransactionDialog(
        type: type,
        title: title,
        data: data,
        onAccept: onAccept,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = _getStatusColor();

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 320,
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A), // Slate 900
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icono con Animación y Resplandor (Glow)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: primaryColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.3),
                      blurRadius: 24,
                      spreadRadius: 8,
                    ),
                  ],
                ),
                child: Icon(
                  _getStatusIcon(),
                  color: Colors.white,
                  size: 32,
                ),
              ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),
              
              const SizedBox(height: 24),
              
              // Título
              Text(
                title,
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                  color: Colors.white,
                ),
              ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),
              
              const SizedBox(height: 32),
              
              // Contenido Dinámico
              _buildContent().animate().fadeIn(delay: 400.ms),
              
              const SizedBox(height: 32),
              
              // Botón Aceptar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onAccept ?? () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'Entendido',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ).animate().fadeIn(delay: 600.ms).scale(begin: const Offset(0.9, 0.9)),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildContent() {
    switch (type) {
      case TransactionType.payment:
        return _buildPaymentContent();
      case TransactionType.transfer:
        return _buildTransferContent();
      case TransactionType.loan:
        return _buildLoanContent();
      case TransactionType.income:
      case TransactionType.expense:
        return _buildSimpleMovementContent();
    }
  }

  Widget _buildPaymentContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow('Monto Aplicado', Formatters.formatCurrency(data['montoAplicado'] ?? 0), valueColor: _getStatusColor(), isLarge: true),
        _DottedDivider(),
        _buildInfoRow('Mora', Formatters.formatCurrency(data['mora'] ?? 0), valueColor: const Color(0xFFEF4444)),
        _DottedDivider(),
        _buildInfoRow('Interés', Formatters.formatCurrency(data['interes'] ?? 0), valueColor: const Color(0xFFF59E0B)),
        _DottedDivider(),
        _buildInfoRow('Capital', Formatters.formatCurrency(data['capital'] ?? 0), valueColor: const Color(0xFF3B82F6)),
        _DottedDivider(),
        _buildInfoRow('Periodo', data['periodo'] ?? 'N/A', valueColor: Colors.white),
        _DottedDivider(),
        _buildInfoRow('Pagos Totales', '${data['totalPagos'] ?? 0} Pagos', valueColor: Colors.white),
      ],
    );
  }

  Widget _buildTransferContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow('Monto Enviado', Formatters.formatCurrency(data['monto'] ?? 0), valueColor: _getStatusColor(), isLarge: true),
        _DottedDivider(),
        _buildInfoRow('Origen', data['origen'] ?? 'N/A', valueColor: Colors.white),
        _DottedDivider(),
        _buildInfoRow('Destino', data['destino'] ?? 'N/A', valueColor: const Color(0xFFF59E0B)),
        _DottedDivider(),
        _buildDescriptionBlock(data['descripcion'] ?? 'Sin descripción', const Color(0xFF3B82F6)),
      ],
    );
  }

  Widget _buildLoanContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow('Capital', Formatters.formatCurrency(data['monto'] ?? 0), valueColor: _getStatusColor(), isLarge: true),
        _DottedDivider(),
        _buildInfoRow('Cliente', data['cliente'] ?? 'N/A', valueColor: Colors.white),
        _DottedDivider(),
        _buildInfoRow('Caja', data['caja'] ?? 'N/A', valueColor: const Color(0xFFF59E0B)),
        _DottedDivider(),
        _buildInfoRow('1ra Cuota', data['primeraCuota'] ?? 'N/A', valueColor: const Color(0xFF10B981)),
        _DottedDivider(),
        _buildDescriptionBlock(data['codigo'] ?? 'N/A', const Color(0xFF8B5CF6)),
      ],
    );
  }

  Widget _buildSimpleMovementContent() {
    final isIncome = type == TransactionType.income;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow('Monto', Formatters.formatCurrency(data['monto'] ?? 0), valueColor: _getStatusColor(), isLarge: true),
        _DottedDivider(),
        _buildInfoRow('Categoría', data['categoria'] ?? 'N/A', valueColor: isIncome ? const Color(0xFFEF4444) : Colors.white),
        _DottedDivider(),
        _buildInfoRow('Caja', data['caja'] ?? 'N/A', valueColor: const Color(0xFFF59E0B)),
        _DottedDivider(),
        _buildDescriptionBlock(data['descripcion'] ?? 'Sin descripción', const Color(0xFFEF4444)),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor, bool isLarge = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            color: const Color(0xFF94A3B8), // Slate 400
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: isLarge ? 20 : 14,
            fontWeight: FontWeight.bold,
            color: valueColor ?? Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionBlock(String text, Color primaryColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Descripción:',
          style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF94A3B8), fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            text,
            style: GoogleFonts.inter(fontSize: 13, color: primaryColor, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  IconData _getStatusIcon() {
    switch (type) {
      case TransactionType.payment: return Icons.check;
      case TransactionType.transfer: return Icons.compare_arrows;
      case TransactionType.loan: return Icons.description;
      case TransactionType.income: return Icons.add;
      case TransactionType.expense: return Icons.remove;
    }
  }

  Color _getStatusColor() {
    switch (type) {
      case TransactionType.income: return const Color(0xFF10B981); // Emerald 500
      case TransactionType.expense: return const Color(0xFFEF4444); // Red 500
      case TransactionType.payment: return const Color(0xFF6366F1); // Indigo 500
      case TransactionType.transfer: return const Color(0xFF3B82F6); // Blue 500
      case TransactionType.loan: return const Color(0xFF14B8A6); // Teal 500
    }
  }
}

class _DottedDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final boxWidth = constraints.constrainWidth();
          const dashWidth = 4.0;
          const dashHeight = 1.0;
          final dashCount = (boxWidth / (2 * dashWidth)).floor();
          return Flex(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            direction: Axis.horizontal,
            children: List.generate(dashCount, (_) {
              return SizedBox(
                width: dashWidth,
                height: dashHeight,
                child: DecoratedBox(
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.1)),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}
