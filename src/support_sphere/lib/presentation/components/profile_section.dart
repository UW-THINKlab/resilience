import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:support_sphere/logic/cubit/profile_cubit.dart';

class ProfileSection extends StatelessWidget {
  const ProfileSection({
    super.key,
    this.title = "Section Header",
    this.children = const [],
    this.modalBody = const SizedBox(),
    this.displayTitle = true,
    this.readOnly = false,
    this.state = const ProfileState(),
  });

  final String title;
  final List<Widget> children;
  final Widget modalBody;
  final bool displayTitle;
  final bool readOnly;
  final ProfileState state;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          _getTitle(context) ?? const SizedBox(),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: children,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget? _getTitle(BuildContext context) {
    if (displayTitle) {
      return ListTile(
        title: Text(title),
        trailing: readOnly
            ? null
            : GestureDetector(
                onTap: () => _showModalBottomSheet(context),
                child: const Icon(Ionicons.create_outline),
              ),
      );
    }
    return null;
  }

  Future<dynamic> _showModalBottomSheet(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: modalBody,
        );
      },
    );
  }
}
