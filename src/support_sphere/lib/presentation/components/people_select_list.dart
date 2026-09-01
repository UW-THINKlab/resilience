import 'package:flutter/material.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:support_sphere/constants/string_catalog.dart';
import 'package:support_sphere/data/models/person.dart';

class PersonFilter extends StatefulWidget {
  PersonFilter({super.key, this.onSelected});

  final void Function(String?)? onSelected;

  final List<String> peopleFilters = [
    "All",
    "In my cluster",
    "Captains",
  ];

  @override
  State<PersonFilter> createState() => PersonTypeFilterState();
}

class PersonTypeFilterState extends State<PersonFilter> {
  String dropdownValue = '';

  void _defaultOnSelected(String? value) {
    setState(() {
      // This is called when the user selects an item.
      setState(() {
        dropdownValue = value!;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final filters = widget.peopleFilters;
    return Container(
      padding: EdgeInsets.all(16),
      child: DropdownMenu<String>(
        width: 200,
        label: const Text(ClusterAdminStrings.selectFilter),
        initialSelection: filters.first,
        onSelected: widget.onSelected ?? _defaultOnSelected,
        dropdownMenuEntries:
            filters.map<DropdownMenuEntry<String>>((String value) {
          return DropdownMenuEntry<String>(value: value, label: value);
        }).toList(),
      ),
    );
  }
}

class PersonSelectorField extends StatefulWidget {
  const PersonSelectorField({
    super.key,
    required this.people,
    required this.onConfirm,
    this.initialValue = const [],
    this.title,
    this.buttonText,
  });

  final List<Person> people;
  final Function(List<Person>) onConfirm;
  final List<Person> initialValue;
  final Text? title;
  final Text? buttonText;

  @override
  PersonSelectorFieldState createState() => PersonSelectorFieldState();
}

class PersonSelectorFieldState extends State<PersonSelectorField> {
  @override
  Widget build(BuildContext context) {
    final items = widget.people
        .map((person) => MultiSelectItem<Person>(person, person.name()))
        .toList();
    return MultiSelectDialogField<Person>(
      items: items,
      initialValue: widget.initialValue,
      title: widget.title,
      buttonText: widget.buttonText,
      searchable: true,
      searchHint: 'Search people...',
      onConfirm: (results) => widget.onConfirm(results.cast<Person>()),
    );
  }
}
