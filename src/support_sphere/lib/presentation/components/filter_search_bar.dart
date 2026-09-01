import 'package:flutter/material.dart';

class FilterSearchBar extends StatefulWidget {
  const FilterSearchBar({
    super.key,
    required this.labelText,
    this.onQueryChanged,
  });

  final String labelText;
  final void Function(String)? onQueryChanged;

  @override
  State<FilterSearchBar> createState() => _FilterSearchBarState();
}

class _FilterSearchBarState extends State<FilterSearchBar> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _clear() {
    _controller.clear();
    widget.onQueryChanged?.call('');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: ValueListenableBuilder<TextEditingValue>(
        valueListenable: _controller,
        builder: (context, value, _) {
          final hasQuery = value.text.isNotEmpty;
          return TextField(
            controller: _controller,
            onChanged: widget.onQueryChanged,
            decoration: InputDecoration(
              labelText: widget.labelText,
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.search),
              suffixIcon: hasQuery
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: _clear,
                    )
                  : null,
              filled: hasQuery,
              fillColor: hasQuery ? Colors.blue[50] : null,
            ),
          );
        },
      ),
    );
  }
}
