import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:support_sphere/data/models/clusters.dart';
import 'package:support_sphere/logic/cubit/manage_neighborhood_state.dart' show ManageNeighborhoodCubit;
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

  factory EditClusterFormData.fromCluster(Cluster? cluster) {
    if (cluster == null) {
      return EditClusterFormData();
    }
    return EditClusterFormData(
      name: cluster.name,
      meetingPlace: cluster.meetingPlace,
      notes: cluster.notes,
    );
  }


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

  Map<String,dynamic> toUpsert(Cluster? old) {
    // copy over the values from the form
    // TODO: Could check against old for actual changes
    // NOTE: attr names are based on DB column names, and need to be bound to the instance data.
    // There is no way of doing this (currently) other than hard-coded maps
    // Design notes: Sometimes objects/classes get in the way. Nothing supports them in flutter.
    // No ORM, just boilerblate with opportunity for typos.
    final Map<String,dynamic> upsertParams = {
      'name': name,
      'meeting_place': meetingPlace,
      'notes': notes,
    };
    // if updating, insert the existing ID
    if (old != null) {
      upsertParams['id'] = old.id;
    }

    return upsertParams;
  }
}


class ClusterEditForm extends StatefulWidget {
  const ClusterEditForm({super.key, this.cluster, this.cubit});

  final Cluster? cluster;
  final ManageNeighborhoodCubit? cubit;

  @override
  State<ClusterEditForm> createState() => ClusterEditFormState();
}

class ClusterEditFormState extends State<ClusterEditForm> {
  final _formKey = GlobalKey<FormState>();
  late EditClusterFormData _formData = EditClusterFormData.fromCluster(widget.cluster);
  late String addButtonLabel = widget.cluster != null ? "Update Cluster" : "Add Cluster";

  @override
  Widget build(BuildContext context) {
    // Initialize the form data
    //_formData = _formData.copyWith(name: widget.cluster.name);
    // if cluster set, load from
    return Card(
        child: Container(
          margin: const EdgeInsets.all(15.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Center(
                    child: Text(addButtonLabel, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                )),
                // Name of Cluster and Cluster Type
                const SizedBox(height: 10),
                TextFormField(
                  initialValue: widget.cluster?.name,
                  key: const Key('ClusterEditForm_name'),
                  onSaved: (value) => _formData = _formData.copyWith(name: value),
                  decoration: InputDecoration(
                    labelText: "Cluster name", // FIXME strings
                    //helperText: 'Name of the cluster',
                    border: border(context),
                    enabledBorder: border(context),
                    focusedBorder: focusBorder(context)
                  ),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  initialValue: widget.cluster?.meetingPlace,
                  key: const Key('ClusterEditForm_meetingPlace'),
                  onSaved: (value) => _formData = _formData.copyWith(meetingPlace: value),
                  decoration: InputDecoration(
                    labelText: "Meeting place",
                    //helperText: 'Description of the cluster meeting place.',
                    border: border(context),
                    enabledBorder: border(context),
                    focusedBorder: focusBorder(context)),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  key: const Key('ClusterEditForm_notes'),
                  onSaved: (value) => _formData = _formData.copyWith(notes: value),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  decoration: InputDecoration(
                      labelText: "Notes",
                      //helperText: 'Notes about the cluster',
                      border: border(context),
                      enabledBorder: border(context),
                      focusedBorder: focusBorder(context)),
                ),
                // cluster captains
                Row(children: [
                  Text(
                    'Cluster captains:',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${widget.cluster?.captains}',
                    style: TextStyle(
                      fontSize: 15,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // FIXME: Implement user multiselect dialog
                      //final updatedCaptains = [];
                      //widget.cluster!.captains?.people = updatedCaptains;
                    },
                    child: Text('Add cluster captains')
                  ),
                ]),
                const SizedBox(height: 50),
                // Buttons to Add Item or Cancel
                Row(children: [
                  ElevatedButton(
                    onPressed: () {
                      _formKey.currentState!.save();
                      if (_formKey.currentState!.validate()) {
                        log.finer("Original cluster: ${widget.cluster?.name} - ID: ${widget.cluster?.id} - ${widget.cluster?.geom}");

                        final clusterUpsert = _formData.toUpsert(widget.cluster);
                        log.finer("Updating cluster: $clusterUpsert");

                        widget.cubit!.upsertCluster(clusterUpsert);
                        Navigator.pop(context);
                      }
                    },
                    child: Text(addButtonLabel),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () { Navigator.pop(context); },
                    child: const Text('Cancel'),
                  ),
                ]),
              ],
            ),
          )
        )
    );
  }
}
