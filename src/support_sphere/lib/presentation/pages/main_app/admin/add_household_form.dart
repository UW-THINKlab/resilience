import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
//import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
//import 'package:searchfield/searchfield.dart';
import 'package:support_sphere/constants/string_catalog.dart';
import 'package:support_sphere/data/models/households.dart';
import 'package:support_sphere/logic/cubit/manage_cluster_state.dart' show ManageClusterCubit;
import 'package:support_sphere/presentation/components/auth/borders.dart';
import 'package:support_sphere/presentation/pages/main_app/admin/household_filter.dart';
import 'package:uuid/v4.dart';

import 'package:equatable/equatable.dart';

class AddHouseholdFormData extends Equatable {
  const AddHouseholdFormData({
    this.clusterId,
    this.name,
    this.address,
    this.notes,
    this.pets,
    this.accessibilityNeeds
  });

  final String? clusterId;
  final String? name;
  final String? address;
  final String? notes;
  final String? pets;
  final String? accessibilityNeeds;


  @override
  List<Object?> get props => [
        clusterId,
        name,
        address,
        pets,
        notes,
        accessibilityNeeds,
      ];


  AddHouseholdFormData copyWith({
    String? clusterId,
    String? name,
    String? address,
    String? notes,
    String? pets,
    String? accessibilityNeeds,
  }) {
    return AddHouseholdFormData(
      clusterId: clusterId ?? this.clusterId,
      name: name ?? this.name,
      address: address ?? this.address,
      pets: pets ?? this.pets,
      accessibilityNeeds: accessibilityNeeds ?? this.accessibilityNeeds,
      notes: notes ?? this.notes,
    );
  }


  Household toHousehold() {
    return Household(
      id: const UuidV4().generate(),
      clusterId: clusterId!,
      name: name!,
      address: address,
      notes: notes,
      pets: pets!,
      accessibilityNeeds: accessibilityNeeds!,
    );
  }
}

class AddHouseholdForm extends StatefulWidget {
  const AddHouseholdForm(
      {super.key, this.onCancel});

  final VoidCallback? onCancel;

  @override
  State<AddHouseholdForm> createState() => _AddHouseholdFormState();
}

class _AddHouseholdFormState extends State<AddHouseholdForm> {
  final _formKey = GlobalKey<FormState>();
  AddHouseholdFormData _formData = AddHouseholdFormData();

  @override
  Widget build(BuildContext context) {
    // Initialize the form data
    // FIXME _formData = _formData.copyWith(resourceType: widget.resourceTypes!.first);
    return Form(
      key: _formKey,
      child: Column(
        children: [
          const Center(
            child: Text(
              ClusterAdminStrings.addHousehold,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            )),
          // Name of Household and Household Type
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // FIXME broken search form
              // Expanded(
              //   child: SearchField<Household>(
              //     key: const Key('AddHouseholdForm_nameOfHousehold_searchField'),
              //     onSaved: (value) {
              //       _formData = _formData.copyWith(nameOfHousehold: value);
              //     },
              //     autovalidateMode: AutovalidateMode.always,
              //     searchInputDecoration: SearchInputDecoration(
              //         labelText: AddHouseholdFormStrings.nameOfHousehold,
              //         helperText: '',
              //         border: border(context),
              //         enabledBorder: border(context),
              //         focusedBorder: focusBorder(context)),
              //     validator: FormBuilderValidators.compose([
              //       FormBuilderValidators.required(),
              //       FormBuilderValidators.singleLine(),
              //       (value) {
              //         if (value != null) {
              //           bool resourceExists = widget.resources!.any((element) =>
              //               element.name.toLowerCase().trim() ==
              //               value.toLowerCase().trim());
              //           return resourceExists
              //               ? 'Household already exists'
              //               : null;
              //         }

              //         return null;
              //       }
              //     ]),
              //     suggestions: widget.resources!
              //         .map(
              //           (e) => SearchFieldListItem<Household>(
              //             e.name,
              //             item: e,
              //             // Use child to show Custom Widgets in the suggestions
              //             // defaults to Text widget
              //             child: Padding(
              //               padding: const EdgeInsets.all(8.0),
              //               child: Row(
              //                 children: [
              //                   FaIcon(e.resourceType.icon),
              //                   const SizedBox(width: 10),
              //                   Text(e.name),
              //                 ],
              //               ),
              //             ),
              //           ),
              //         )
              //         .toList(),
              //   ),
              // ),
              Expanded(
                child: HouseholdFilter(
                    key: const Key('AddHouseholdForm_resourceTypeFilter'),
                    //resourceTypes: widget.resourceTypes!,
                    onSelected: (value) {
                      // FIXME filter
                      //_formData = _formData.copyWith(
                      //    resourceType: widget.resourceTypes!
                      //        .firstWhere((element) => element.name == value));
                    }),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Total Number Needed and Number Available
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Expanded(
              child: TextFormField(
                initialValue: '0',
                keyboardType: TextInputType.number,
                key: const Key('AddHouseholdForm_totalNumberNeeded_textFormField'),
                // FIXME onSaved: (value) => _formData = _formData.copyWith(totalNumberNeeded: int.tryParse(value ?? '0')),
                autovalidateMode: AutovalidateMode.always,
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                  FormBuilderValidators.numeric(),
                ]),
                decoration: InputDecoration(
                    labelText: "Testin value",
                    helperText: '',
                    border: border(context),
                    enabledBorder: border(context),
                    focusedBorder: focusBorder(context)),
              ),
            ),
            Expanded(
              child: TextFormField(
                initialValue: '0',
                keyboardType: TextInputType.number,
                key: const Key('AddHouseholdForm_numberAvailable_textFormField'),
                //onSaved: (value) => _formData = _formData.copyWith(numberAvailable: int.tryParse(value ?? '0')),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.numeric(),
                ]),
                decoration: InputDecoration(
                    labelText: "AddHouseholdFormStrings.numberAvailable",
                    helperText: '',
                    border: border(context),
                    enabledBorder: border(context),
                    focusedBorder: focusBorder(context)),
              ),
            ),
          ]),
          const SizedBox(height: 10),
          // Household Description (FOR EVERYONE)
          TextFormField(
            key: const Key('AddHouseholdForm_description_textFormField'),
            //onSaved: (value) => _formData = _formData.copyWith(description: value),
            autovalidateMode: AutovalidateMode.onUserInteraction,
            decoration: InputDecoration(
                labelText: 'AddHouseholdFormStrings.description',
                helperText: '',
                border: border(context),
                enabledBorder: border(context),
                focusedBorder: focusBorder(context)),
          ),
          const SizedBox(height: 10),
          // Household Subtype
          // TODO: Update to become tags for subtypes
          // TextFormField(
          //   key: const Key('AddHouseholdForm_subtype_textFormField'),
          //   onSaved: (value) => _formData = _formData.copyWith(subtype: value),
          //   autovalidateMode: AutovalidateMode.onUserInteraction,
          //   decoration: InputDecoration(
          //       labelText: AddHouseholdFormStrings.subtype,
          //       helperText: '',
          //       border: border(context),
          //       enabledBorder: border(context),
          //       focusedBorder: focusBorder(context)),
          // ),
          const SizedBox(height: 10),
          // Household Notes (ONLY FOR Neighborhood Manager)
          TextFormField(
            key: const Key('AddHouseholdForm_notes_textFormField'),
            onSaved: (value) => _formData = _formData.copyWith(notes: value),
            autovalidateMode: AutovalidateMode.onUserInteraction,
            keyboardType: TextInputType.multiline,
            minLines: 1,
            maxLines: 5,
            decoration: InputDecoration(
                labelText: "Notes",
                helperText: '',
                border: border(context),
                enabledBorder: border(context),
                focusedBorder: focusBorder(context)),
          ),
          const SizedBox(height: 10),
          // Buttons to Add Item or Cancel
          Row(children: [
            ElevatedButton(
              onPressed: () {
                _formKey.currentState!.save();
                if (_formKey.currentState!.validate()) {
                  context
                      .read<ManageClusterCubit>()
                      .addHousehold(_formData.toHousehold());
                  widget.onCancel!();
                }
              },
              child: const Text('Add Item'),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: widget.onCancel,
              child: const Text('Cancel'),
            ),
          ]),
        ],
      ),
    );
  }
}
