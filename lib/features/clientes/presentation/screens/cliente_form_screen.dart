import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../domain/entities/cliente.dart';
import '../providers/cliente_provider.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../presentation/widgets/custom_text_field.dart';

/// Pantalla de formulario para crear o editar un cliente con diseño premium
class ClienteFormScreen extends ConsumerStatefulWidget {
  final int? clienteId;

  const ClienteFormScreen({super.key, this.clienteId});

  @override
  ConsumerState<ClienteFormScreen> createState() => _ClienteFormScreenState();
}

class _ClienteFormScreenState extends ConsumerState<ClienteFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _ciController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _emailController = TextEditingController();
  final _direccionController = TextEditingController();
  final _ciudadController = TextEditingController();
  final _departamentoController = TextEditingController();
  final _referenciaController = TextEditingController();
  final _notasController = TextEditingController();
  
  bool _activo = true;
  bool _isLoading = false;
  bool _isEditMode = false;

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.clienteId != null;
    if (_isEditMode) {
      _loadCliente();
    }
  }

  Future<void> _loadCliente() async {
    final cliente = await ref.read(clienteByIdProvider(widget.clienteId!).future);
    if (cliente != null && mounted) {
      _nombreController.text = cliente.nombre;
      _ciController.text = cliente.ci;
      _telefonoController.text = cliente.telefono ?? '';
      _emailController.text = cliente.email ?? '';
      _direccionController.text = cliente.direccion ?? '';
      _ciudadController.text = cliente.ciudad ?? '';
      _departamentoController.text = cliente.departamento ?? '';
      _referenciaController.text = cliente.referencia ?? '';
      _notasController.text = cliente.notas ?? '';
      setState(() {
        _activo = cliente.activo;
      });
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _ciController.dispose();
    _telefonoController.dispose();
    _emailController.dispose();
    _direccionController.dispose();
    _ciudadController.dispose();
    _departamentoController.dispose();
    _referenciaController.dispose();
    _notasController.dispose();
    super.dispose();
  }

  Future<void> _saveCliente() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final cliente = Cliente(
      id: widget.clienteId,
      nombre: _nombreController.text.trim(),
      ci: _ciController.text.trim(),
      telefono: _telefonoController.text.trim().isEmpty 
          ? null 
          : _telefonoController.text.trim(),
      email: _emailController.text.trim().isEmpty 
          ? null 
          : _emailController.text.trim(),
      direccion: _direccionController.text.trim().isEmpty 
          ? null 
          : _direccionController.text.trim(),
      ciudad: _ciudadController.text.trim().isEmpty 
          ? null 
          : _ciudadController.text.trim(),
      departamento: _departamentoController.text.trim().isEmpty 
          ? null 
          : _departamentoController.text.trim(),
      referencia: _referenciaController.text.trim().isEmpty 
          ? null 
          : _referenciaController.text.trim(),
      fechaRegistro: DateTime.now(),
      activo: _activo,
      notas: _notasController.text.trim().isEmpty 
          ? null 
          : _notasController.text.trim(),
    );

    final success = _isEditMode
        ? await ref.read(clientesProvider.notifier).updateCliente(cliente)
        : await ref.read(clientesProvider.notifier).createCliente(cliente);

    setState(() => _isLoading = false);

    if (mounted) {
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditMode 
                  ? 'Cliente actualizado exitosamente' 
                  : 'Cliente creado exitosamente',
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        final error = ref.read(clientesProvider).error;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error ?? 'Error al guardar cliente'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Editar Perfil' : 'Nuevo Cliente'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: isDark ? Colors.white : Colors.black87,
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Sección: Identificación
                    _buildFormSection(
                      context,
                      title: 'IDENTIFICACIÓN',
                      icon: Icons.person_rounded,
                      children: [
                        CustomTextField(
                          label: 'Nombre completo',
                          controller: _nombreController,
                          hintText: 'Ingresar nombre y apellido',
                          prefixIcon: Icons.account_circle_rounded,
                          textCapitalization: TextCapitalization.words,
                          validator: (value) =>
                              Validators.name(value, fieldName: 'El nombre'),
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          label: 'Documento (CI)',
                          controller: _ciController,
                          hintText: 'Ingresar CI sin puntos ni guiones',
                          prefixIcon: Icons.badge_rounded,
                          keyboardType: TextInputType.number,
                          validator: Validators.document,
                        ),
                      ],
                    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),

                    const SizedBox(height: 24),

                    // Sección: Contacto
                    _buildFormSection(
                      context,
                      title: 'COMUNICACIÓN',
                      icon: Icons.contact_phone_rounded,
                      children: [
                        CustomTextField(
                          label: 'Teléfono de contacto',
                          controller: _telefonoController,
                          hintText: 'Ej: 0981 123 456',
                          prefixIcon: Icons.phone_android_rounded,
                          keyboardType: TextInputType.phone,
                          validator: Validators.phoneOptional,
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          label: 'Correo Electrónico',
                          controller: _emailController,
                          hintText: 'ejemplo@correo.com (Opcional)',
                          prefixIcon: Icons.alternate_email_rounded,
                          keyboardType: TextInputType.emailAddress,
                        ),
                      ],
                    )
                        .animate()
                        .fadeIn(duration: 400.ms, delay: 100.ms)
                        .slideY(begin: 0.1, end: 0),

                    const SizedBox(height: 24),

                    // Sección: Ubicación
                    _buildFormSection(
                      context,
                      title: 'UBICACIÓN',
                      icon: Icons.location_on_rounded,
                      children: [
                        CustomTextField(
                          label: 'Dirección particular',
                          controller: _direccionController,
                          hintText: 'Calle, número de casa, etc.',
                          prefixIcon: Icons.home_rounded,
                          maxLines: 2,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: CustomTextField(
                                label: 'Ciudad',
                                controller: _ciudadController,
                                hintText: 'Localidad',
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: CustomTextField(
                                label: 'Dpto.',
                                controller: _departamentoController,
                                hintText: 'Departamento',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          label: 'Referencia',
                          controller: _referenciaController,
                          hintText: 'Ej: Detrás de la terminal...',
                          prefixIcon: Icons.near_me_rounded,
                        ),
                      ],
                    )
                        .animate()
                        .fadeIn(duration: 400.ms, delay: 200.ms)
                        .slideY(begin: 0.1, end: 0),

                    const SizedBox(height: 24),

                    // Sección: Otros
                    _buildFormSection(
                      context,
                      title: 'OTROS DATOS',
                      icon: Icons.more_horiz_rounded,
                      children: [
                        CustomTextField(
                          label: 'Observaciones / Notas',
                          controller: _notasController,
                          hintText: 'Cualquier detalle relevante...',
                          prefixIcon: Icons.note_rounded,
                          maxLines: 3,
                        ),
                        const SizedBox(height: 16),
                        Container(
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white.withOpacity(0.05)
                                : Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                                color: isDark ? Colors.white10 : Colors.grey.shade200),
                          ),
                          child: SwitchListTile(
                            title: const Text('Cliente Activo',
                                style:
                                    TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            subtitle: const Text('Controla si el cliente puede operar',
                                style: TextStyle(fontSize: 12)),
                            value: _activo,
                            onChanged: (value) => setState(() => _activo = value),
                            activeColor: AppTheme.primaryBrand,
                          ),
                        ),
                      ],
                    )
                        .animate()
                        .fadeIn(duration: 400.ms, delay: 300.ms)
                        .slideY(begin: 0.1, end: 0),
                  ],
                ),
              ),
            ),

            // Botones de acción fijos en la parte inferior
            Container(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              decoration: BoxDecoration(
                color: isDark ? theme.scaffoldBackgroundColor : Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text('CANCELAR',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveCliente,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryBrand,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : Text(_isEditMode ? 'ACTUALIZAR' : 'REGISTRAR',
                              style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 600.ms, delay: 400.ms),
          ],
        ),
      ),
    );
  }

  Widget _buildFormSection(BuildContext context, {
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? theme.cardColor : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: isDark ? Border.all(color: Colors.white.withOpacity(0.05)) : null,
        boxShadow: !isDark ? [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ] : null,
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
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }
}
