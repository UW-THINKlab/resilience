import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';

import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

class NewResourceSkillPage extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  String resourceType = 'Durable'; // Default resource type

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add New Resource or Skill')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Name of Resource*'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter the resource name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              Text('Resource Type*'),
              DropdownSearch<String>(
                selectedItem: 'Durable',
                items: (f, cs) => ['Durable', 'Consumable', 'Skill'].toList(),
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Total number needed*'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter the total number needed';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration:
                    InputDecoration(labelText: 'Number currently available'),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                decoration: InputDecoration(
                    labelText: 'Description (visible to all users)'),
              ),
              TextFormField(
                decoration: InputDecoration(
                    labelText:
                        'Subtypes, if applicable (e.g., cordless vs. electric chainsaws)'),
              ),
              TextFormField(
                decoration: InputDecoration(
                    labelText:
                        'Note (visible only to LEAP steering committee)'),
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        // Perform save operation
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Saving Resource')));
                      }
                    },
                    child: Text('Save'),
                  ),
                  SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: () {
                      // Cancel operation
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(),
                    child: Text('Cancel'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AddNewResourceSkillButton extends StatelessWidget {
  const AddNewResourceSkillButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => NewResourceSkillPage()),
        );
      },
      label: Text("New Resource"),
      icon: const Icon(Ionicons.add_sharp),
    );
  }
}
