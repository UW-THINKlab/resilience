import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:support_sphere/data/models/clusters.dart' hide log;
import 'package:support_sphere/data/models/person.dart';
import 'package:support_sphere/data/repositories/cluster.dart' hide log;
import 'package:support_sphere/data/repositories/user.dart';
import 'package:support_sphere/presentation/components/auth/borders.dart';
import 'package:support_sphere/presentation/components/people_select_list.dart'
    show PersonSelectorField;

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

  Map<String, dynamic> toUpsert(Cluster? old) {
    log.fine("UPSERT --- $old");
    // copy over the values from the form
    // TODO: Could check against old for actual changes
    // NOTE: attr names are based on DB column names, and need to be bound to the instance data.
    // There is no way of doing this (currently) other than hard-coded maps
    // Design notes: Sometimes objects/classes get in the way. Nothing supports them in flutter.
    // No ORM, just boilerblate with opportunity for typos.
    final Map<String, dynamic> upsertParams = {
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
  const ClusterEditForm(
      {super.key,
      this.cluster,
      required void Function(Map<String, dynamic>) this.updateCluster});

  final Cluster? cluster;
  final Function(Map<String, dynamic>) updateCluster;

  @override
  State<ClusterEditForm> createState() => ClusterEditFormState();
}

class ClusterEditFormState extends State<ClusterEditForm> {
  final _formKey = GlobalKey<FormState>();
  late EditClusterFormData _formData =
      EditClusterFormData.fromCluster(widget.cluster);
  late String addButtonLabel =
      widget.cluster != null ? "Update Cluster" : "Add Cluster";

  List<Person> _allPeople = [];
  List<Person> _selectedCaptains = [];
  bool _isLoadingPeople = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _initPeopleAndCaptains();
  }

  Future<void> _initPeopleAndCaptains() async {
    try {
      final membersMap = await UserRepository().getAllMembers();
      final allPeople = membersMap.values.toList();

      List<Person> currentCaptains = [];
      if (widget.cluster != null) {
        final rows = await ClusterRepository()
            .getCaptainsViewByClusterId(widget.cluster!.id);
        final captainProfileIds =
            rows.map((r) => r.userProfileId).whereType<String>().toSet();
        currentCaptains = captainProfileIds
            .map((id) => membersMap[id])
            .whereType<Person>()
            .toList();
      }

      if (mounted) {
        setState(() {
          _allPeople = allPeople;
          _selectedCaptains = currentCaptains;
          _isLoadingPeople = false;
        });
      }
    } catch (e, stack) {
      debugPrint('Failed to load people and captains: $e\n$stack');
      if (mounted) setState(() => _isLoadingPeople = false);
    }
  }

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
                      child: Text(
                    addButtonLabel,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  )),
                  // Name of Cluster and Cluster Type
                  const SizedBox(height: 10),
                  TextFormField(
                    initialValue: widget.cluster?.name,
                    key: const Key('ClusterEditForm_name'),
                    onSaved: (value) =>
                        _formData = _formData.copyWith(name: value),
                    decoration: InputDecoration(
                        labelText: "Cluster name", // FIXME strings
                        //helperText: 'Name of the cluster',
                        border: border(context),
                        enabledBorder: border(context),
                        focusedBorder: focusBorder(context)),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    initialValue: widget.cluster?.meetingPlace,
                    key: const Key('ClusterEditForm_meetingPlace'),
                    onSaved: (value) =>
                        _formData = _formData.copyWith(meetingPlace: value),
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
                    onSaved: (value) =>
                        _formData = _formData.copyWith(notes: value),
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
                    const SizedBox(width: 8),
                    _isLoadingPeople
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Expanded(
                            child: PersonSelectorField(
                              people: _allPeople,
                              initialValue: _selectedCaptains,
                              title: const Text('Select Cluster Captains'),
                              buttonText: const Text('Select captains'),
                              onConfirm: (captains) =>
                                  setState(() => _selectedCaptains = captains),
                            ),
                          ),
                  ]),
                  const SizedBox(height: 50),
                  // Buttons to Add Item or Cancel
                  Row(children: [
                    ElevatedButton(
                      onPressed: _isSaving
                          ? null
                          : () async {
                              _formKey.currentState!.save();
                              if (_formKey.currentState!.validate()) {
                                log.finer(
                                    "Original cluster: ${widget.cluster?.name} - ID: ${widget.cluster?.id} - ${widget.cluster?.geom}");
                                final clusterUpsert =
                                    _formData.toUpsert(widget.cluster);
                                clusterUpsert['captains'] = _selectedCaptains;
                                log.finer("Updating cluster: $clusterUpsert");
                                setState(() => _isSaving = true);
                                await widget.updateCluster(clusterUpsert);
                                if (mounted) Navigator.pop(context);
                              }
                            },
                      child: _isSaving
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(addButtonLabel),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Cancel'),
                    ),
                  ]),
                ],
              ),
            )));
  }
}
