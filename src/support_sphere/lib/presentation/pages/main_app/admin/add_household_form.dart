import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:support_sphere/constants/string_catalog.dart';
import 'package:support_sphere/data/models/households.dart';
import 'package:support_sphere/logic/cubit/manage_cluster_state.dart' show ManageClusterCubit;
import 'package:support_sphere/presentation/components/auth/borders.dart';
import 'package:support_sphere/presentation/components/cancel_button.dart';
import 'package:support_sphere/presentation/components/confirm_button.dart';
import 'package:uuid/v4.dart';

import 'package:equatable/equatable.dart';

class AddHouseholdFormData extends Equatable {
  const AddHouseholdFormData({
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


  AddHouseholdFormData copyWith({
    String? name,
    String? address,
    String? notes,
    String? pets,
    String? accessibilityNeeds,
  }) {
    return AddHouseholdFormData(
      name: name ?? this.name,
      address: address ?? this.address,
      pets: pets ?? this.pets,
      accessibilityNeeds: accessibilityNeeds ?? this.accessibilityNeeds,
      notes: notes ?? this.notes,
    );
  }


  Household toHousehold(String clusterId) {
    return Household(
      id: const UuidV4().generate(),
      clusterId: clusterId,
      name: name,
      address: address,
      notes: notes,
      pets: pets,
      accessibilityNeeds: accessibilityNeeds,
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
    return Form(
      key: _formKey,
      child: Column(
        children: [
          const Center(
            child: Text(
              ClusterAdminStrings.addHousehold,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            )),
          const SizedBox(height: 10),
          TextFormField(
            key: const Key('AddHouseholdForm_name_textFormField'),
            onSaved: (value) => _formData = _formData.copyWith(name: value),
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: FormBuilderValidators.required(),
            decoration: InputDecoration(
                labelText: 'Household name',
                helperText: '',
                border: border(context),
                enabledBorder: border(context),
                focusedBorder: focusBorder(context)),
          ),
          const SizedBox(height: 10),
          TextFormField(
            key: const Key('AddHouseholdForm_address_textFormField'),
            onSaved: (value) => _formData = _formData.copyWith(address: value),
            decoration: InputDecoration(
                labelText: 'Address',
                helperText: '',
                border: border(context),
                enabledBorder: border(context),
                focusedBorder: focusBorder(context)),
          ),
          const SizedBox(height: 10),
          TextFormField(
            key: const Key('AddHouseholdForm_pets_textFormField'),
            onSaved: (value) => _formData = _formData.copyWith(pets: value),
            decoration: InputDecoration(
                labelText: 'Pets',
                helperText: '',
                border: border(context),
                enabledBorder: border(context),
                focusedBorder: focusBorder(context)),
          ),
          const SizedBox(height: 10),
          TextFormField(
            key: const Key('AddHouseholdForm_accessibilityNeeds_textFormField'),
            onSaved: (value) =>
                _formData = _formData.copyWith(accessibilityNeeds: value),
            decoration: InputDecoration(
                labelText: 'Accessibility needs',
                helperText: '',
                border: border(context),
                enabledBorder: border(context),
                focusedBorder: focusBorder(context)),
          ),
          const SizedBox(height: 10),
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
            CancelButton(
              label: 'Cancel',
              onPressed: widget.onCancel,
            ),
            const SizedBox(width: 8),
            ConfirmButton(
              label: 'Add Household',
              onPressed: () {
                _formKey.currentState!.save();
                if (_formKey.currentState!.validate()) {
                  final cubit = context.read<ManageClusterCubit>();
                  cubit.addHousehold(_formData.toHousehold(cubit.state.cluster!.id));
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
