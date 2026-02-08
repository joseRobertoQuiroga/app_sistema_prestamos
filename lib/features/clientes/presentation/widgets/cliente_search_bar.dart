import 'package:flutter/material.dart';
import 'dart:async';

/// Widget de barra de búsqueda para clientes
/// 
/// Incluye debouncing para evitar búsquedas excesivas mientras el usuario escribe
class ClienteSearchBar extends StatefulWidget {
  final String? initialQuery;
  final ValueChanged<String>? onSearch;
  final VoidCallback? onClear;
  final String? hint;
  final Duration debounceDuration;

  const ClienteSearchBar({
    super.key,
    this.initialQuery,
    this.onSearch,
    this.onClear,
    this.hint,
    this.debounceDuration = const Duration(milliseconds: 500),
  });

  @override
  State<ClienteSearchBar> createState() => _ClienteSearchBarState();
}

class _ClienteSearchBarState extends State<ClienteSearchBar> {
  late TextEditingController _controller;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialQuery);
    _controller.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onSearchChanged);
    _controller.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    // Cancelar el timer anterior si existe
    _debounceTimer?.cancel();

    // Crear un nuevo timer para debouncing
    _debounceTimer = Timer(widget.debounceDuration, () {
      widget.onSearch?.call(_controller.text);
    });
  }

  void _clearSearch() {
    _controller.clear();
    widget.onClear?.call();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _controller,
        decoration: InputDecoration(
          hintText: widget.hint ?? 'Buscar por nombre o CI...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: _clearSearch,
                  tooltip: 'Limpiar búsqueda',
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: theme.colorScheme.outline,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: theme.colorScheme.outline.withOpacity(0.5),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: theme.colorScheme.primary,
              width: 2,
            ),
          ),
          filled: true,
          fillColor: theme.colorScheme.surface,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        style: theme.textTheme.bodyLarge,
      ),
    );
  }
}

/// Widget simplificado de búsqueda sin debouncing
class SimpleSearchBar extends StatelessWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final String? hint;
  final bool autofocus;

  const SimpleSearchBar({
    super.key,
    this.controller,
    this.onChanged,
    this.onClear,
    this.hint,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TextField(
      controller: controller,
      autofocus: autofocus,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint ?? 'Buscar...',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: controller?.text.isNotEmpty ?? false
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  controller?.clear();
                  onClear?.call();
                },
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: theme.colorScheme.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    );
  }
}