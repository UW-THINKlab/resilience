import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
//import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:support_sphere/data/models/clusters.dart';
import 'package:support_sphere/logic/cubit/manage_neighborhood_cubit.dart';
import 'package:support_sphere/presentation/components/auth/borders.dart';
import 'package:support_sphere/presentation/pages/main_app/admin/neighborhood_filter.dart';
import 'package:uuid/v4.dart';

class AddClusterFormData extends Equatable {
  const AddClusterFormData({
    this.name,
    this.address,
    this.notes,
    this.pets,
    this.accessibilityNeeds
  });

  final String? name;
  final String? address;
  final String? notes;
  final String? pets;
  final String? accessibilityNeeds;


  @override
  List<Object?> get props => [
        name,
        address,
        pets,
        notes,
        accessibilityNeeds,
      ];


  AddClusterFormData copyWith({
    String? clusterId,
    String? name,
    String? address,
    String? notes,
    String? pets,
    String? accessibilityNeeds,
  }) {
    return AddClusterFormData(
      name: name ?? this.name,
      address: address ?? this.address,
      pets: pets ?? this.pets,
      accessibilityNeeds: accessibilityNeeds ?? this.accessibilityNeeds,
      notes: notes ?? this.notes,
    );
  }

  Cluster toCluster() {
    return Cluster(
      id: const UuidV4().generate(),
      name: name!,
      notes: notes,
    );
  }
}

class AddClusterForm extends StatefulWidget {
  const AddClusterForm(
      {super.key, this.onCancel});

  final VoidCallback? onCancel;

  @override
  State<AddClusterForm> createState() => _AddClusterFormState();
}

class _AddClusterFormState extends State<AddClusterForm> {
  final _formKey = GlobalKey<FormState>();
  AddClusterFormData _formData = AddClusterFormData();

  @override
  Widget build(BuildContext context) {
    // Initialize the form data
    // FIXME _formData = _formData.copyWith(resourceType: widget.resourceTypes!.first);
    return Form(
      key: _formKey,
      child: Column(
        children: [
          const Center(
              child: Text('ClusterStrings.addCluster', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          )),
          // Name of Cluster and Cluster Type
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // FIXME broken search form
              // Expanded(
              //   child: SearchField<Cluster>(
              //     key: const Key('AddClusterForm_nameOfCluster_searchField'),
              //     onSaved: (value) {
              //       _formData = _formData.copyWith(nameOfCluster: value);
              //     },
              //     autovalidateMode: AutovalidateMode.always,
              //     searchInputDecoration: SearchInputDecoration(
              //         labelText: AddClusterFormStrings.nameOfCluster,
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
              //               ? 'Cluster already exists'
              //               : null;
              //         }

              //         return null;
              //       }
              //     ]),
              //     suggestions: widget.resources!
              //         .map(
              //           (e) => SearchFieldListItem<Cluster>(
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
                child: NeighborhoodFilter(
                    key: const Key('AddClusterForm_resourceTypeFilter'),
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
                key: const Key('AddClusterForm_totalNumberNeeded_textFormField'),
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
                key: const Key('AddClusterForm_numberAvailable_textFormField'),
                //onSaved: (value) => _formData = _formData.copyWith(numberAvailable: int.tryParse(value ?? '0')),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.numeric(),
                ]),
                decoration: InputDecoration(
                    labelText: "AddClusterFormStrings.numberAvailable",
                    helperText: '',
                    border: border(context),
                    enabledBorder: border(context),
                    focusedBorder: focusBorder(context)),
              ),
            ),
          ]),
          const SizedBox(height: 10),
          // Cluster Description (FOR EVERYONE)
          TextFormField(
            key: const Key('AddClusterForm_description_textFormField'),
            //onSaved: (value) => _formData = _formData.copyWith(description: value),
            autovalidateMode: AutovalidateMode.onUserInteraction,
            decoration: InputDecoration(
                labelText: 'AddClusterFormStrings.description',
                helperText: '',
                border: border(context),
                enabledBorder: border(context),
                focusedBorder: focusBorder(context)),
          ),
          const SizedBox(height: 10),
          // Cluster Subtype
          // TODO: Update to become tags for subtypes
          // TextFormField(
          //   key: const Key('AddClusterForm_subtype_textFormField'),
          //   onSaved: (value) => _formData = _formData.copyWith(subtype: value),
          //   autovalidateMode: AutovalidateMode.onUserInteraction,
          //   decoration: InputDecoration(
          //       labelText: AddClusterFormStrings.subtype,
          //       helperText: '',
          //       border: border(context),
          //       enabledBorder: border(context),
          //       focusedBorder: focusBorder(context)),
          // ),
          const SizedBox(height: 10),
          // Cluster Notes (ONLY FOR Neighborhood Manager)
          TextFormField(
            key: const Key('AddClusterForm_notes_textFormField'),
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
                  context.read<ManageNeighborhoodCubit>().addCluster(_formData.toCluster());
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
