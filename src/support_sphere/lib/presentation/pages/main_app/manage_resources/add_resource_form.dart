import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:searchfield/searchfield.dart';
import 'package:support_sphere/constants/string_catalog.dart';
import 'package:support_sphere/data/models/resource.dart';
import 'package:support_sphere/data/models/resource_types.dart';
import 'package:support_sphere/presentation/components/auth/borders.dart';
import 'package:support_sphere/presentation/components/resource_type_filter.dart';
import 'package:support_sphere/logic/cubit/manage_resource_cubit.dart';
import 'package:uuid/v4.dart';

import 'package:equatable/equatable.dart';

class AddResourceFormData extends Equatable {
  const AddResourceFormData({
    this.nameOfResource,
    this.resourceType,
    this.totalNumberNeeded,
    this.numberAvailable,
    this.description,
    // TODO: Implement Subtype
    // this.subtype,
    this.notes,
  });

  final String? nameOfResource;
  final int? totalNumberNeeded;
  final int? numberAvailable;
  final String? description;
  // final String? subtype;
  final String? notes;
  final ResourceTypes? resourceType;

  @override
  List<Object?> get props => [
        nameOfResource,
        totalNumberNeeded,
        numberAvailable,
        description,
        // subtype,
        notes,
        resourceType
      ];

  copyWith({
    String? nameOfResource,
    int? totalNumberNeeded,
    int? numberAvailable,
    String? description,
    // String? subtype,
    String? notes,
    ResourceTypes? resourceType,
  }) {
    return AddResourceFormData(
      nameOfResource: nameOfResource ?? this.nameOfResource,
      totalNumberNeeded: totalNumberNeeded ?? this.totalNumberNeeded,
      numberAvailable: numberAvailable ?? this.numberAvailable,
      description: description ?? this.description,
      // subtype: subtype ?? this.subtype,
      notes: notes ?? this.notes,
      resourceType: resourceType ?? this.resourceType,
    );
  }

  Resource toResource() {
    return Resource(
      id: const UuidV4().generate(),
      name: nameOfResource!,
      description: description,
      notes: notes,
      qtyNeeded: totalNumberNeeded!,
      qtyAvailable: numberAvailable!,
      resourceType: resourceType!,
    );
  }
}

class AddResourceForm extends StatefulWidget {
  AddResourceForm(
      {super.key, this.resourceTypes, this.resources, this.onCancel});

  final List<ResourceTypes>? resourceTypes;
  final List<Resource>? resources;
  final VoidCallback? onCancel;

  @override
  State<AddResourceForm> createState() => _AddResourceFormState();
}

class _AddResourceFormState extends State<AddResourceForm> {
  final _formKey = GlobalKey<FormState>();
  AddResourceFormData _formData = AddResourceFormData();

  @override
  Widget build(BuildContext context) {
    // Initialize the form data
    _formData = _formData.copyWith(resourceType: widget.resourceTypes!.first);
    return Form(
      key: _formKey,
      child: Column(
        children: [
          const Center(
              child: Text(
            ResourceStrings.addResource,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          )),
          // Name of Resource and Resource Type
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: SearchField<Resource>(
                  key: const Key('AddResourceForm_nameOfResource_searchField'),
                  onSaved: (value) {
                    _formData = _formData.copyWith(nameOfResource: value);
                  },
                  autovalidateMode: AutovalidateMode.always,
                  searchInputDecoration: SearchInputDecoration(
                      labelText: AddResourceFormStrings.nameOfResource,
                      helperText: '',
                      border: border(context),
                      enabledBorder: border(context),
                      focusedBorder: focusBorder(context)),
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(),
                    FormBuilderValidators.singleLine(),
                    (value) {
                      if (value != null) {
                        bool resourceExists = widget.resources!.any((element) =>
                            element.name.toLowerCase().trim() ==
                            value.toLowerCase().trim());
                        return resourceExists
                            ? 'Resource already exists'
                            : null;
                      }

                      return null;
                    }
                  ]),
                  suggestions: widget.resources!
                      .map(
                        (e) => SearchFieldListItem<Resource>(
                          e.name,
                          item: e,
                          // Use child to show Custom Widgets in the suggestions
                          // defaults to Text widget
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                FaIcon(e.resourceType.icon),
                                const SizedBox(width: 10),
                                Text(e.name),
                              ],
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
              Expanded(
                child: ResourceTypeFilter(
                    key: const Key('AddResourceForm_resourceTypeFilter'),
                    resourceTypes: widget.resourceTypes!,
                    onSelected: (value) {
                      _formData = _formData.copyWith(
                          resourceType: widget.resourceTypes!
                              .firstWhere((element) => element.name == value));
                    },
                    includeAll: false),
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
                key: const Key(
                    'AddResourceForm_totalNumberNeeded_textFormField'),
                onSaved: (value) => _formData = _formData.copyWith(
                    totalNumberNeeded: int.tryParse(value ?? '0')),
                autovalidateMode: AutovalidateMode.always,
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                  FormBuilderValidators.numeric(),
                ]),
                decoration: InputDecoration(
                    labelText: AddResourceFormStrings.totalNumberNeeded,
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
                key: const Key('AddResourceForm_numberAvailable_textFormField'),
                onSaved: (value) => _formData = _formData.copyWith(
                    numberAvailable: int.tryParse(value ?? '0')),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.numeric(),
                ]),
                decoration: InputDecoration(
                    labelText: AddResourceFormStrings.numberAvailable,
                    helperText: '',
                    border: border(context),
                    enabledBorder: border(context),
                    focusedBorder: focusBorder(context)),
              ),
            ),
          ]),
          const SizedBox(height: 10),
          // Resource Description (FOR EVERYONE)
          TextFormField(
            key: const Key('AddResourceForm_description_textFormField'),
            onSaved: (value) =>
                _formData = _formData.copyWith(description: value),
            autovalidateMode: AutovalidateMode.onUserInteraction,
            decoration: InputDecoration(
                labelText: AddResourceFormStrings.description,
                helperText: '',
                border: border(context),
                enabledBorder: border(context),
                focusedBorder: focusBorder(context)),
          ),
          const SizedBox(height: 10),
          // Resource Subtype
          // TODO: Update to become tags for subtypes
          // TextFormField(
          //   key: const Key('AddResourceForm_subtype_textFormField'),
          //   onSaved: (value) => _formData = _formData.copyWith(subtype: value),
          //   autovalidateMode: AutovalidateMode.onUserInteraction,
          //   decoration: InputDecoration(
          //       labelText: AddResourceFormStrings.subtype,
          //       helperText: '',
          //       border: border(context),
          //       enabledBorder: border(context),
          //       focusedBorder: focusBorder(context)),
          // ),
          const SizedBox(height: 10),
          // Resource Notes (ONLY FOR Neighborhood Manager)
          TextFormField(
            key: const Key('AddResourceForm_notes_textFormField'),
            onSaved: (value) => _formData = _formData.copyWith(notes: value),
            autovalidateMode: AutovalidateMode.onUserInteraction,
            keyboardType: TextInputType.multiline,
            minLines: 1,
            maxLines: 5,
            decoration: InputDecoration(
                labelText: AddResourceFormStrings.notes,
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
                      .read<ManageResourceCubit>()
                      .addNewResource(_formData.toResource());
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
