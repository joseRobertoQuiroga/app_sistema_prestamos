import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../pagos/presentation/providers/pago_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';

class PrestamoPagosWidget extends ConsumerWidget {
  final int prestamoId;

  const PrestamoPagosWidget({
    super.key,
    required this.prestamoId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pagosAsync = ref.watch(pagosListProvider(prestamoId));
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        pagosAsync.when(
          data: (pagos) {
            if (pagos.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'No hay pagos registrados',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: pagos.length,
              padding: EdgeInsets.zero,
              itemBuilder: (context, index) {
                final pago = pagos[index];
                final isLast = index == pagos.length - 1;

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? Colors.white10 : Colors.grey[200]!,
                    ),
                  ),
                  child: ExpansionTile(
                    shape: const RoundedRectangleBorder(
                      side: BorderSide.none,
                    ),
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBrand.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.payments_outlined,
                        color: AppTheme.primaryBrand,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      Formatters.formatCurrency(pago.montoTotal),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text(
                      Formatters.formatDate(pago.fechaPago),
                      style: TextStyle(
                        color: isDark ? Colors.white60 : Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                    trailing: const Icon(Icons.expand_more_rounded, size: 20),
                    childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    children: [
                      const Divider(),
                      _buildDetalleRow(
                        'Código',
                        pago.codigo,
                        isDark,
                      ),
                      const SizedBox(height: 8),
                      if (pago.montoMora > 0)
                        _buildDetalleRow(
                          'Mora',
                          Formatters.formatCurrency(pago.montoMora),
                          isDark,
                          valueColor: Colors.red[300],
                        ),
                      if (pago.montoInteres > 0)
                        _buildDetalleRow(
                          'Interés',
                          Formatters.formatCurrency(pago.montoInteres),
                          isDark,
                          valueColor: Colors.orange[300],
                        ),
                      if (pago.montoCapital > 0)
                        _buildDetalleRow(
                          'Capital',
                          Formatters.formatCurrency(pago.montoCapital),
                          isDark,
                          valueColor: Colors.green[300],
                        ),
                      if (pago.metodoPago != null) ...[
                        const SizedBox(height: 8),
                        _buildDetalleRow(
                          'Método',
                          pago.metodoPago!,
                          isDark,
                        ),
                      ],
                      if (pago.referencia != null && pago.referencia!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        _buildDetalleRow(
                          'Referencia',
                          pago.referencia!,
                          isDark,
                        ),
                      ],
                    ],
                  ),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Text('Error al cargar pagos: $error'),
          ),
        ),
      ],
    );
  }

  Widget _buildDetalleRow(String label, String value, bool isDark, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isDark ? Colors.white60 : Colors.grey[600],
            fontSize: 13,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 13,
            color: valueColor ?? (isDark ? Colors.white : Colors.black87),
          ),
        ),
      ],
    );
  }
}
