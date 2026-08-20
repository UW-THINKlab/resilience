import 'package:flutter/material.dart';
import 'package:logging/logging.dart' show Logger;
import 'package:support_sphere/constants/appconfig.dart';
import 'package:support_sphere/data/models/person.dart';
import 'package:support_sphere/data/repositories/user.dart';
import 'package:support_sphere/presentation/components/auth/borders.dart';
import 'package:support_sphere/presentation/components/people_select_list.dart'
    show PersonSelectorField;
import 'package:support_sphere/presentation/components/update_entity_form.dart'
    show UpdateEntityForm;

final log = Logger('NeighborhoodEditForm');

class NeighborhoodEditForm extends StatefulWidget {
  const NeighborhoodEditForm(
      {super.key, required this.admins, required this.updateAdmins});

  final List<Person> admins;
  final Future<void> Function(List<Person>) updateAdmins;

  @override
  State<NeighborhoodEditForm> createState() => NeighborhoodEditFormState();
}

class NeighborhoodEditFormState extends State<NeighborhoodEditForm> {
  List<Person> _allPeople = [];
  late List<Person> _selectedAdmins = widget.admins;
  bool _isLoadingPeople = true;

  @override
  void initState() {
    super.initState();
    _initPeople();
  }

  Future<void> _initPeople() async {
    try {
      final membersMap = await UserRepository().getAllMembers();
      if (mounted) {
        setState(() {
          _allPeople = membersMap.values.toList();
          _isLoadingPeople = false;
        });
      }
    } catch (e, stack) {
      log.warning('Failed to load people: $e\n$stack');
      if (mounted) setState(() => _isLoadingPeople = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return UpdateEntityForm(
      title: 'Update Neighborhood',
      confirmLabel: 'Update Neighborhood',
      onConfirm: () async {
        await widget.updateAdmins(_selectedAdmins);
        return true;
      },
      fields: [
        TextFormField(
          initialValue: AppConfig.neighborhood,
          readOnly: true,
          decoration: InputDecoration(
              labelText: "Neighborhood name",
              border: border(context),
              enabledBorder: border(context),
              focusedBorder: focusBorder(context)),
        ),
        const SizedBox(height: 10),
        // neighborhood admins
        Row(children: [
          Text(
            'Neighborhood admins:',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          _isLoadingPeople
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Expanded(
                  child: PersonSelectorField(
                    people: _allPeople,
                    initialValue: _selectedAdmins,
                    title: const Text('Select Neighborhood Admins'),
                    buttonText: const Text('Select admins'),
                    onConfirm: (admins) =>
                        setState(() => _selectedAdmins = admins),
                  ),
                ),
        ]),
      ],
    );
  }
}
