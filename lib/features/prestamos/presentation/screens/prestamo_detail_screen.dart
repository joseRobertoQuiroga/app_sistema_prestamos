import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../domain/entities/prestamo.dart';
import '../../domain/entities/cuota.dart';
import '../providers/prestamo_provider.dart';
import '../widgets/resumen_prestamo_widget.dart';
import '../widgets/tabla_amortizacion_widget.dart';
import '../../../../presentation/widgets/state_widgets.dart';
import 'prestamo_form_screen.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';

class PrestamoDetailScreen extends ConsumerWidget {
  final int prestamoId;

  const PrestamoDetailScreen({
    super.key,
    required this.prestamoId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prestamoAsync = ref.watch(prestamoDetailProvider(prestamoId));
    final cuotasAsync = ref.watch(cuotasListProvider(prestamoId));
    final resumenAsync = ref.watch(resumenCuotasProvider(prestamoId));
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: prestamoAsync.when(
        data: (prestamo) {
          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Header inmersivo con SliverAppBar
              SliverAppBar(
                expandedHeight: 240,
                pinned: true,
                stretch: true,
                backgroundColor: isDark ? theme.scaffoldBackgroundColor : AppTheme.primaryBrand,
                iconTheme: const IconThemeData(color: Colors.white),
                flexibleSpace: FlexibleSpaceBar(
                  stretchModes: const [StretchMode.zoomBackground, StretchMode.blurBackground],
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Container(
                        decoration: const BoxDecoration(
                          gradient: AppTheme.primaryGradient,
                        ),
                      ),
                      // Efectos visuales de fondo
                      Positioned(
                        top: -50,
                        right: -50,
                        child: CircleAvatar(
                          radius: 100,
                          backgroundColor: Colors.white.withOpacity(0.05),
                        ),
                      ),
                      
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 40),
                            Text(
                              prestamo.codigo,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 2.0,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              Formatters.formatCurrency(prestamo.montoOriginal),
                              style: theme.textTheme.headlineLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -1,
                              ),
                            ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
                            const SizedBox(height: 8),
                            _buildEstadoBadge(prestamo.estado),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.edit_note_rounded, color: Colors.white),
                    onPressed: () => _navigateToEdit(context),
                  ),
                  _buildMenuButton(context, ref),
                ],
              ),

              // Contenido del detalle
              SliverToBoxAdapter(
                child: Container(
                  transform: Matrix4.translationValues(0, -30, 0),
                  decoration: BoxDecoration(
                    color: isDark ? theme.scaffoldBackgroundColor : Colors.white,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                  ),
                  padding: const EdgeInsets.fromLTRB(20, 30, 20, 100),
                  child: Column(
                    children: [
                      // Información del Cliente
                      _buildSectionHeader(context, 'CLIENTE', Icons.person_rounded),
                      _buildInfoCard(
                        context,
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          leading: CircleAvatar(
                            backgroundColor: AppTheme.primaryBrand.withOpacity(0.1),
                            child: const Icon(Icons.person, color: AppTheme.primaryBrand),
                          ),
                          title: Text(
                            prestamo.nombreCliente ?? 'Cliente desconocido',
                            style: const TextStyle(fontWeight: FontWeight.w900),
                          ),
                          subtitle: const Text('Titular del préstamo'),
                          trailing: const Icon(Icons.chevron_right_rounded),
                          onTap: () {
                            // Navegar a detalle cliente si es posible
                          },
                        ),
                      ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1, end: 0),

                      const SizedBox(height: 24),

                      // Resumen de Cuotas
                      _buildSectionHeader(context, 'ESTADO DE CUOTAS', Icons.assessment_rounded),
                      resumenAsync.when(
                        data: (resumen) => ResumenPrestamoWidget(
                          prestamo: prestamo,
                          cuotasPagadas: resumen.cuotasPagadas,
                          cuotasPendientes: resumen.cuotasPendientes,
                          cuotasVencidas: resumen.cuotasVencidas,
                        ),
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (error, _) => Text('Error: $error'),
                      ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0),

                      const SizedBox(height: 24),

                      // Tabla de Amortización
                      _buildSectionHeader(context, 'TABLA DE AMORTIZACIÓN', Icons.calendar_month_rounded),
                      cuotasAsync.when(
                        data: (cuotas) => _buildInfoCard(
                          context,
                          child: TablaAmortizacionWidget(
                            cuotas: cuotas,
                            compact: false,
                          ),
                        ),
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (error, _) => Text('Error: $error'),
                      ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1, end: 0),

                      const SizedBox(height: 24),

                      // Observaciones
                      if (prestamo.observaciones != null && prestamo.observaciones!.isNotEmpty) ...[
                        _buildSectionHeader(context, 'OBSERVACIONES', Icons.notes_rounded),
                        _buildInfoCard(
                          context,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              prestamo.observaciones!,
                              style: TextStyle(
                                color: isDark ? Colors.white70 : Colors.black54,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ).animate().fadeIn(delay: 400.ms),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const LoadingWidget(message: 'Cargando detalle del préstamo...'),
        error: (error, stack) => ErrorState(
          message: error.toString(),
          onRetry: () => ref.invalidate(prestamoDetailProvider(prestamoId)),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _registrarPago(context),
        icon: const Icon(Icons.payments_rounded),
        label: const Text('REGISTRAR PAGO'),
        backgroundColor: AppTheme.primaryBrand,
        foregroundColor: Colors.white,
        elevation: 4,
      ).animate().scale(delay: 600.ms, curve: Curves.easeOutBack),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppTheme.primaryBrand),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
              color: AppTheme.primaryBrand,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, {required Widget child}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: !isDark ? [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ] : null,
        border: isDark ? Border.all(color: Colors.white.withOpacity(0.05)) : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: child,
      ),
    );
  }

  Widget _buildEstadoBadge(EstadoPrestamo estado) {
    Color color;
    switch (estado) {
      case EstadoPrestamo.activo: color = Colors.green; break;
      case EstadoPrestamo.pagado: color = Colors.blue; break;
      case EstadoPrestamo.mora: color = Colors.red; break;
      case EstadoPrestamo.cancelado: color = Colors.grey; break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Text(
        estado.displayName.toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert_rounded, color: Colors.white),
      onSelected: (value) => _handleMenuAction(context, ref, value),
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'pagar',
          child: ListTile(
            leading: Icon(Icons.payment_rounded),
            title: Text('Registrar Pago'),
            contentPadding: EdgeInsets.zero,
          ),
        ),
        const PopupMenuItem(
          value: 'actualizar',
          child: ListTile(
            leading: Icon(Icons.refresh_rounded),
            title: Text('Actualizar Estados'),
            contentPadding: EdgeInsets.zero,
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: 'cancelar',
          child: ListTile(
            leading: Icon(Icons.cancel_outlined, color: Colors.red),
            title: Text('Cancelar Préstamo', style: TextStyle(color: Colors.red)),
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ],
    );
  }

  // Handlers (asumidos iguales que antes pero adaptados si es necesario)
  void _navigateToEdit(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PrestamoFormScreen(prestamoId: prestamoId),
      ),
    );
  }

  void _handleMenuAction(BuildContext context, WidgetRef ref, String action) {
    switch (action) {
      case 'pagar': _registrarPago(context); break;
      case 'actualizar': _actualizarEstados(context, ref); break;
      case 'cancelar': _confirmarCancelacion(context, ref); break;
    }
  }

  void _registrarPago(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Módulo de pagos en desarrollo (Fase 4)')),
    );
  }

  Future<void> _actualizarEstados(BuildContext context, WidgetRef ref) async {
    final repository = ref.read(prestamoRepositoryProvider);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Actualizando estados...')),
    );

    await repository.actualizarEstadosCuotas(prestamoId);
    await repository.actualizarEstadoPrestamo(prestamoId);

    ref.invalidate(prestamoDetailProvider(prestamoId));
    ref.invalidate(cuotasListProvider(prestamoId));
    ref.invalidate(resumenCuotasProvider(prestamoId));

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Estados actualizados correctamente'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _confirmarCancelacion(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar Préstamo'),
        content: const Text('¿Estás seguro de que deseas cancelar este préstamo? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('No')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Sí, Cancelar'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final cancelar = ref.read(cancelarPrestamoProvider);
      final result = await cancelar(prestamoId);

      result.fold(
        (failure) => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${failure.message}'), backgroundColor: Colors.red),
        ),
        (_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Préstamo cancelado correctly'), backgroundColor: Colors.green),
          );
          Navigator.pop(context);
        },
      );
    }
  }
}
