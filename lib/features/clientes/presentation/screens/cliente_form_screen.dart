import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/cliente.dart';
import '../providers/cliente_provider.dart';
import '../../../../core/utils/validators.dart';

/// Pantalla de formulario para crear o editar un cliente
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
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      } else {
        final error = ref.read(clientesProvider).error;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error ?? 'Error al guardar cliente'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Editar Cliente' : 'Nuevo Cliente'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Información básica
            Text(
              'Información Básica',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _nombreController,
              decoration: const InputDecoration(
                labelText: 'Nombre completo *',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (value) => Validators.name(value, fieldName: 'El nombre'),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _ciController,
              decoration: const InputDecoration(
                labelText: 'Cédula de Identidad *',
                prefixIcon: Icon(Icons.badge),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: Validators.document,
            ),
            const SizedBox(height: 24),

            // Contacto
            Text(
              'Contacto',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _telefonoController,
              decoration: const InputDecoration(
                labelText: 'Teléfono',
                prefixIcon: Icon(Icons.phone),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
              validator: Validators.phoneOptional,
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 24),

            // Dirección
            Text(
              'Dirección',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _direccionController,
              decoration: const InputDecoration(
                labelText: 'Dirección',
                prefixIcon: Icon(Icons.location_on),
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _ciudadController,
                    decoration: const InputDecoration(
                      labelText: 'Ciudad',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _departamentoController,
                    decoration: const InputDecoration(
                      labelText: 'Departamento',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _referenciaController,
              decoration: const InputDecoration(
                labelText: 'Referencia',
                hintText: 'Ej: Cerca de...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),

            // Notas
            Text(
              'Notas Adicionales',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _notasController,
              decoration: const InputDecoration(
                labelText: 'Notas',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            // Estado activo
            SwitchListTile(
              title: const Text('Cliente activo'),
              value: _activo,
              onChanged: (value) => setState(() => _activo = value),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
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
                    onPressed: _isLoading ? null : _saveCliente,
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(_isEditMode ? 'Actualizar' : 'Guardar'),
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