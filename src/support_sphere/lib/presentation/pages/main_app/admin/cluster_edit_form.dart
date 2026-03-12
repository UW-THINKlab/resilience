import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:support_sphere/data/models/clusters.dart';
import 'package:support_sphere/logic/cubit/manage_neighborhood_cubit.dart';
import 'package:support_sphere/presentation/components/auth/borders.dart';
import 'package:uuid/v4.dart';

// FORMZ: derive from col/attr list, props from entity...
class EditClusterFormData extends Equatable {
  const EditClusterFormData({
    this.name,
    this.meetingPlace,
    this.notes,
  });

  final String? name;
  final String? meetingPlace;
  final String? notes;


  @override
  List<Object?> get props => [
        name,
        meetingPlace,
        notes,
      ];


  EditClusterFormData copyWith({
    String? name,
    String? meetingPlace,
    String? notes,
  }) {
    return EditClusterFormData(
      name: name ?? this.name,
      meetingPlace: meetingPlace ?? this.meetingPlace,
      notes: notes ?? this.notes,
    );
  }

  // FIXME: edit case, ID known.
  // derive geometry?
  // add geometry from
  Cluster toCluster() {
    return Cluster(
      id: const UuidV4().generate(),
      name: name ?? this.name,
      meetingPlace: meetingPlace ?? this.meetingPlace,
      notes: notes ?? this.notes,
    );
  }
}

class ClusterEditForm extends StatefulWidget {
  const ClusterEditForm(
      {super.key, this.onCancel});

  final VoidCallback? onCancel;

  @override
  State<ClusterEditForm> createState() => _ClusterEditFormState();

  static Route<void> route() {
    return MaterialPageRoute(
      builder: (context) => const ClusterEditForm(),
    );
  }
}

class _ClusterEditFormState extends State<ClusterEditForm> {
  final _formKey = GlobalKey<FormState>();
  EditClusterFormData _formData = EditClusterFormData();

  @override
  Widget build(BuildContext context) {
    // Initialize the form data
    // FIXME _formData = _formData.copyWith(resourceType: widget.resourceTypes!.first);
    // if cluster set, load from
    return Form(
      key: _formKey,
      child: Column(
        children: [
          const Center(
              // FIXME if cluster set, title="Edit ${cluster.name}", if not, "AddCluster" const
              child: Text('ClusterStrings.addCluster', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          )),
          // Name of Cluster and Cluster Type
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
