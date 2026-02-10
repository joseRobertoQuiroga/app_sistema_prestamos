import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:glass_kit/glass_kit.dart';
import '../providers/cliente_provider.dart';
import 'cliente_form_screen.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/theme/app_theme.dart';

/// Pantalla de detalle de un cliente con diseño inmersivo y premium
class ClienteDetailScreen extends ConsumerWidget {
  final int clienteId;

  const ClienteDetailScreen({super.key, required this.clienteId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clienteAsync = ref.watch(clienteByIdProvider(clienteId));
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: clienteAsync.when(
        data: (cliente) {
          if (cliente == null) {
            return const Center(child: Text('Cliente no encontrado'));
          }

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Header inmersivo con SliverAppBar
              SliverAppBar(
                expandedHeight: 280,
                pinned: true,
                stretch: true,
                backgroundColor: isDark ? theme.scaffoldBackgroundColor : AppTheme.primaryBrand,
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
                      // Efectos visuales de fondo (círculos sutiles)
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
                            // Avatar Premium
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  cliente.nombre[0].toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 40,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
                            const SizedBox(height: 16),
                            Text(
                              Formatters.capitalizeWords(cliente.nombre),
                              style: theme.textTheme.headlineSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.5,
                              ),
                              textAlign: TextAlign.center,
                            ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: cliente.activo 
                                  ? Colors.green.withOpacity(0.2) 
                                  : Colors.red.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: (cliente.activo ? Colors.green : Colors.red).withOpacity(0.3)
                                ),
                              ),
                              child: Text(
                                cliente.activo ? 'ACTIVO' : 'INACTIVO',
                                style: TextStyle(
                                  color: cliente.activo ? Colors.green.shade100 : Colors.red.shade100,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ).animate().fadeIn(delay: 400.ms),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.edit_note_rounded, color: Colors.white),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ClienteFormScreen(clienteId: clienteId),
                        ),
                      );
                    },
                  ),
                ],
              ),

              // Contenido del Detalle
              SliverToBoxAdapter(
                child: Container(
                  transform: Matrix4.translationValues(0, -30, 0),
                  decoration: BoxDecoration(
                    color: isDark ? theme.scaffoldBackgroundColor : Colors.white,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                  ),
                  padding: const EdgeInsets.fromLTRB(20, 30, 20, 40),
                  child: Column(
                    children: [
                      // Sección: Información Personal
                      _buildInfoSection(
                        context,
                        title: 'INFORMACIÓN PERSONAL',
                        icon: Icons.person_outline_rounded,
                        items: [
                          _buildInfoTile(context, Icons.badge_outlined, 'Documento (CI)', Formatters.formatDocument(cliente.ci)),
                          _buildInfoTile(context, Icons.calendar_month_outlined, 'Registrado el', Formatters.formatDate(cliente.fechaRegistro)),
                        ],
                      ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1, end: 0),
                      
                      const SizedBox(height: 24),
                      
                      // Sección: Contacto
                      _buildInfoSection(
                        context,
                        title: 'CONTACTO',
                        icon: Icons.contact_phone_outlined,
                        items: [
                          _buildInfoTile(context, Icons.phone_android_rounded, 'Teléfono', Formatters.formatPhone(cliente.telefono ?? 'No registrado')),
                          _buildInfoTile(context, Icons.alternate_email_rounded, 'Correo Electrónico', cliente.email ?? 'Sin correo'),
                        ],
                      ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0),

                      const SizedBox(height: 24),

                      // Sección: Localización
                      _buildInfoSection(
                        context,
                        title: 'UBICACIÓN',
                        icon: Icons.map_outlined,
                        items: [
                          _buildInfoTile(context, Icons.location_on_outlined, 'Dirección', cliente.direccion ?? 'Sin especificar'),
                          _buildInfoTile(context, Icons.location_city_rounded, 'Ciudad / Depto', '${cliente.ciudad ?? 'N/A'}, ${cliente.departamento ?? 'N/A'}'),
                          if (cliente.referencia != null)
                            _buildInfoTile(context, Icons.near_me_outlined, 'Referencia', cliente.referencia!),
                        ],
                      ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1, end: 0),

                      if (cliente.notas != null && cliente.notas!.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        _buildInfoSection(
                          context,
                          title: 'NOTAS ADICIONALES',
                          icon: Icons.note_alt_outlined,
                          items: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Text(
                                cliente.notas!,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: isDark ? Colors.white70 : Colors.black87,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1, end: 0),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildErrorState(context, error),
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context, {
    required String title,
    required IconData icon,
    required List<Widget> items,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.02) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppTheme.primaryBrand),
              const SizedBox(width: 10),
              Text(
                title,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: AppTheme.primaryBrand,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...items,
        ],
      ),
    );
  }

  Widget _buildInfoTile(BuildContext context, IconData icon, String label, String value) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryBrand.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 16, color: AppTheme.primaryBrand),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark ? Colors.white38 : Colors.black38,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error: $error', textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Volver'),
            ),
          ],
        ),
      ),
    );
  }
}
