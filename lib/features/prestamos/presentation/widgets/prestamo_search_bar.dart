import 'dart:async';
import 'package:flutter/material.dart';

class PrestamoSearchBar extends StatefulWidget {
  final Function(String) onSearch;
  final int debounceMilliseconds;

  const PrestamoSearchBar({
    super.key,
    required this.onSearch,
    this.debounceMilliseconds = 500,
  });

  @override
  State<PrestamoSearchBar> createState() => _PrestamoSearchBarState();
}

class _PrestamoSearchBarState extends State<PrestamoSearchBar> {
  final TextEditingController _controller = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _controller.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    
    _debounce = Timer(Duration(milliseconds: widget.debounceMilliseconds), () {
      widget.onSearch(query);
    });
  }

  void _clearSearch() {
    _controller.clear();
    widget.onSearch('');
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      onChanged: _onSearchChanged,
      decoration: InputDecoration(
        hintText: 'Buscar por código o cliente...',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _controller.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: _clearSearch,
              )
            : null,
      ),
    );
  }
}