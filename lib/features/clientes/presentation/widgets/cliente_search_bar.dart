import 'package:flutter/material.dart';
import 'dart:async';
import '../../../../core/theme/app_theme.dart';

/// Widget de barra de búsqueda para clientes con diseño premium
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
    _debounceTimer?.cancel();
    _debounceTimer = Timer(widget.debounceDuration, () {
      if (mounted) {
        widget.onSearch?.call(_controller.text);
        setState(() {}); // For suffix icon visibility
      }
    });
  }

  void _clearSearch() {
    _controller.clear();
    widget.onClear?.call();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? theme.cardColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: !isDark ? [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ] : null,
          border: isDark ? Border.all(color: Colors.white.withOpacity(0.1)) : null,
        ),
        child: TextField(
          controller: _controller,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            hintText: widget.hint ?? 'Buscar por nombre o CI...',
            hintStyle: TextStyle(
              color: isDark ? Colors.white24 : Colors.black26,
              fontWeight: FontWeight.w500,
            ),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: isDark ? Colors.white38 : Colors.black38,
            ),
            suffixIcon: _controller.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: _clearSearch,
                    tooltip: 'Limpiar búsqueda',
                    color: isDark ? Colors.white38 : Colors.black38,
                  )
                : null,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
          ),
        ),
      ),
    );
  }
}

/// Widget simplificado de búsqueda sin debouncing con diseño moderno
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
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? theme.cardColor : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.grey.shade200,
        ),
      ),
      child: TextField(
        controller: controller,
        autofocus: autofocus,
        onChanged: onChanged,
        style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          hintText: hint ?? 'Buscar...',
          hintStyle: TextStyle(color: isDark ? Colors.white24 : Colors.black26),
          prefixIcon: Icon(Icons.search_rounded, size: 20, color: isDark ? Colors.white38 : Colors.black38),
          suffixIcon: controller?.text.isNotEmpty ?? false
              ? IconButton(
                  icon: const Icon(Icons.close_rounded, size: 20),
                  onPressed: () {
                    controller?.clear();
                    onClear?.call();
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }
}
