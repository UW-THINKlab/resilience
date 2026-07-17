import 'package:flutter/material.dart';
import 'package:support_sphere/constants/string_catalog.dart';

class SelectionToolbar extends StatelessWidget {
  const SelectionToolbar({
    super.key,
    required this.selectionMode,
    required this.selectedCount,
    required this.allSelected,
    required this.onToggleSelectionMode,
    required this.onToggleSelectAll,
    this.actions = const [],
  });

  final bool selectionMode;
  final int selectedCount;
  final bool allSelected;
  final VoidCallback onToggleSelectionMode;
  final VoidCallback onToggleSelectAll;
  final List<SelectionAction> actions;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          if (selectionMode)
            Checkbox(
              value: allSelected,
              onChanged: (_) => onToggleSelectAll(),
            ),
          Expanded(
            child: selectionMode
                ? Text(SelectionToolbarStrings.selectedCount(selectedCount))
                : const SizedBox.shrink(),
          ),
          for (final action in actions)
            TextButton.icon(
              icon: Icon(action.icon),
              label: Text(action.label),
              onPressed: (selectionMode && selectedCount > 0)
                  ? action.onPressed
                  : null,
            ),
          const SizedBox(width: 4),
          if (selectionMode)
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
              ),
              icon: const Icon(Icons.check_box),
              label: const Text(SelectionToolbarStrings.select),
              onPressed: onToggleSelectionMode,
            )
          else
            TextButton.icon(
              icon: const Icon(Icons.check_box_outlined),
              label: const Text(SelectionToolbarStrings.select),
              onPressed: onToggleSelectionMode,
            ),
        ],
      ),
    );
  }
}

/// One action button in a [SelectionToolbar]'s selection-mode row. The
/// toolbar handles disabling it when nothing is selected, so callers just
/// supply the icon/label/callback for what the action actually does.
class SelectionAction {
  const SelectionAction({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;
}
