import 'package:flutter/material.dart';
import 'package:support_sphere/data/models/person.dart';

class PersonChipsRow extends StatelessWidget {
  const PersonChipsRow({
    super.key,
    required this.people,
    required this.label,
    required this.icon,
  });

  final List<Person?> people;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(icon, size: 18, color: Colors.grey[600]),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context)
                      .textTheme
                      .labelSmall
                      ?.copyWith(color: Colors.grey[600]),
                ),
                const SizedBox(height: 6),
                people.isEmpty
                    ? const Text(
                        'Not set',
                        style: TextStyle(
                            color: Colors.grey, fontStyle: FontStyle.italic),
                      )
                    : Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: people.map((person) {
                          final given = person?.givenName ?? '';
                          final family = person?.familyName ?? '';
                          final name = '$given $family'.trim();
                          final chips = person?.initials() ?? '';
                          return Chip(
                            avatar: CircleAvatar(
                              child: Text(
                                chips.isEmpty ? '?' : chips,
                                style: const TextStyle(fontSize: 11),
                              ),
                            ),
                            label: Text(name.isEmpty ? 'Unknown' : name),
                            visualDensity: VisualDensity.compact,
                            padding: const EdgeInsets.all(2),
                          );
                        }).toList(),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
