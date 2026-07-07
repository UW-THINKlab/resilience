import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:support_sphere/constants/string_catalog.dart';
import 'package:support_sphere/data/models/generated_classes.dart';
import 'package:support_sphere/data/models/resource.dart';
import 'package:support_sphere/presentation/components/auth/borders.dart';
import 'package:support_sphere/presentation/components/cancel_button.dart';
import 'package:support_sphere/presentation/components/confirm_button.dart';
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
    this.notes,
  });

  final String? nameOfResource;
  final int? totalNumberNeeded;
  final int? numberAvailable;
  final String? description;
  final String? notes;
  final ResourceTypes? resourceType;

  @override
  List<Object?> get props => [
        nameOfResource,
        totalNumberNeeded,
        numberAvailable,
        description,
        notes,
        resourceType,
      ];

  AddResourceFormData copyWith({
    String? nameOfResource,
    int? totalNumberNeeded,
    int? numberAvailable,
    String? description,
    String? notes,
    ResourceTypes? resourceType,
    ResourcesCv? resourceCv,
  }) {
    return AddResourceFormData(
      nameOfResource: nameOfResource ?? this.nameOfResource,
      totalNumberNeeded: totalNumberNeeded ?? this.totalNumberNeeded,
      numberAvailable: numberAvailable ?? this.numberAvailable,
      description: description ?? this.description,
      notes: notes ?? this.notes,
      resourceType: resourceType ?? this.resourceType,
    );
  }

  Resource toResource() {
    if (nameOfResource == null) throw 'resoucrce name is missing';
    if (resourceType == null) throw 'resoucrce type is missing';
    final resourceCv = ResourcesCv(
      id: const UuidV4().generate(),
      name: nameOfResource!,
      unit: UNIT.Unknown,
    );
    return Resource(
      id: resourceCv.id,
      name: nameOfResource!,
      description: description,
      notes: notes,
      qtyNeeded: totalNumberNeeded!,
      qtyAvailable: numberAvailable!,
      resourceType: resourceType!,
      resourceCv: resourceCv,
    );
  }
}

class AddResourceForm extends StatefulWidget {
  const AddResourceForm({
    super.key,
    required this.resourceTypes,
    this.resources,
    this.onCancel,
  });

  final List<ResourceTypes> resourceTypes;
  final List<Resource>? resources;
  final VoidCallback? onCancel;

  @override
  State<AddResourceForm> createState() => _AddResourceFormState(
        resourceTypes: resourceTypes,
      );
}

class _AddResourceFormState extends State<AddResourceForm> {
  final List<ResourceTypes> resourceTypes;
  final _formKey = GlobalKey<FormState>();
  AddResourceFormData _formData;

  _AddResourceFormState({required this.resourceTypes})
      : _formData = AddResourceFormData(
          resourceType: resourceTypes.first,
        );

  @override
  Widget build(BuildContext context) {
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
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: ResourceTypeFilter(
                    key: const Key('AddResourceForm_resourceTypeFilter'),
                    resourceTypes: widget.resourceTypes,
                    onSelected: (value) {
                      _formData = _formData.copyWith(
                          resourceType: widget.resourceTypes
                              .firstWhere((element) => element.name == value));
                    },
                    includeAll: false),
              ),
              Expanded(
                child: TextFormField(
                  decoration: InputDecoration(
                    label: Text('name'),
                    hint: Text('name'),
                  ),
                  onSaved: (newValue) {
                    _formData = _formData.copyWith(nameOfResource: newValue);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
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
          const SizedBox(height: 10),
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
            CancelButton(
              label: 'Cancel',
              onPressed: widget.onCancel,
            ),
            const SizedBox(width: 8),
            ConfirmButton(
              label: 'Add Item',
              onPressed: () {
                _formKey.currentState!.save();
                if (_formKey.currentState!.validate()) {
                  context
                      .read<ManageResourceCubit>()
                      .addNewResource(_formData.toResource());
                  widget.onCancel!();
                }
              },
            ),
          ]),
        ],
      ),
    );
  }
}
