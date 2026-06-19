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

// class PersonList extends StatelessWidget {
//   const PersonList({super.key, required this.people});

//   final List<Person> people;

//   @override
//   Widget build(BuildContext context) {
//     return ListView.builder(
//       padding: const EdgeInsets.all(8),
//       itemCount: people.length,
//       itemBuilder: (BuildContext context, int index) {
//         return PersonListItem(person: people[index]);
//       }
//     );
//   }
// }

// class PersonListItem extends StatelessWidget {
//   const PersonListItem({super.key, required this.person});

//   final Person person;

//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       height: 50,
//       //color: Colors.amber[colorCodes[index]],
//       child: Center(child: Text('Entry $person')),
//     );
//   }
// }

class PersonSelectList extends StatefulWidget {
  const PersonSelectList({super.key, required this.people, required this.onConfirm});

  final List<Person> people;
  final Function(List<Person>) onConfirm;

  @override
  PersonSelectListState createState() => PersonSelectListState();
}

class PersonSelectListState extends State<PersonSelectList> {
  @override
  Widget build(BuildContext context) {
    final items = widget.people.map((person) => MultiSelectItem<Person>(person, person.name())).toList();
    // TODO cluster captains should already be selected and sorted to the top.
    // selecting a new captain puts it in the top part of the list
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.all(20),
      child: Column(
        children: <Widget>[
          SizedBox(height: 40),
          MultiSelectDialogField(
            items: items,
            title: Text("Members"), // FIXME text
            selectedColor: Colors.blue,
            // decoration: BoxDecoration(
            //   color: Colors.blue.shade100,
            //   borderRadius: BorderRadius.all(Radius.circular(40)),
            //   border: Border.all(
            //     color: Colors.blue,
            //     width: 2,
            //   ),
            // ),
            buttonIcon: Icon(
              Icons.person_3_rounded,
              color: Colors.blue,
            ),
            buttonText: Text("Selected", // FIXME text
              style: TextStyle(
                color: Colors.blue.shade800,
                fontSize: 16,
              ),
            ),
            onConfirm: (results) {
              widget.onConfirm(results);
            },
          ),
          SizedBox(height: 40),
        ]
      )
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