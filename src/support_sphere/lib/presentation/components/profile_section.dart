import 'package:flutter/material.dart';
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
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (displayTitle) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                  if (!readOnly)
                    GestureDetector(
                      onTap: () => _showModalBottomSheet(context),
                      child: Icon(
                        Icons.create,
                        size: 18,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                ],
              ),
            ),
            const Divider(height: 1),
          ],
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
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
