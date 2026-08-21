import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:uuid/v4.dart';
import 'package:support_sphere/constants/string_catalog.dart';
import 'package:support_sphere/data/models/auth_user.dart';
import 'package:support_sphere/data/models/generated_classes.dart'
    show VISIBILITY_SCOPE;
import 'package:support_sphere/data/models/point_of_interest.dart';
import 'package:support_sphere/data/services/poi_service.dart';
import 'package:support_sphere/presentation/components/auth/borders.dart';
import 'package:support_sphere/presentation/components/cancel_button.dart';
import 'package:support_sphere/presentation/components/confirm_button.dart';

class AddPointOfInterestSheet extends StatefulWidget {
  const AddPointOfInterestSheet({
    super.key,
    required this.authUser,
    required this.availableTypes,
    required this.center,
    required this.onSave,
  });

  final MyAuthUser authUser;
  final List<String> availableTypes;
  final LatLng center;
  final VoidCallback onSave;

  @override
  State<AddPointOfInterestSheet> createState() =>
      _AddPointOfInterestSheetState();
}

class _AddPointOfInterestSheetState extends State<AddPointOfInterestSheet> {
  final _formKey = GlobalKey<FormState>();
  String? _name;
  String? _address;
  String? _type;
  bool _isPublic = false;
  DateTime? _expiresAt;

  Future<void> _pickExpiresAt() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _expiresAt ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_expiresAt ?? DateTime.now()),
    );
    if (time == null) return;

    setState(() {
      _expiresAt = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = widget.authUser.userRole == AppRoles.communityAdmin;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              AddPointOfInterestFormStrings.title,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextFormField(
              onSaved: (value) => _name = value,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (value) => (value == null || value.isEmpty)
                  ? AddPointOfInterestFormStrings.required
                  : null,
              decoration: InputDecoration(
                labelText: AddPointOfInterestFormStrings.name,
                border: border(context),
                enabledBorder: border(context),
                focusedBorder: focusBorder(context),
              ),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              initialValue: _type,
              menuMaxHeight: 300,
              items: widget.availableTypes
                  .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                  .toList(),
              onChanged: (value) => setState(() => _type = value),
              validator: (value) =>
                  value == null ? AddPointOfInterestFormStrings.required : null,
              decoration: InputDecoration(
                labelText: AddPointOfInterestFormStrings.type,
                border: border(context),
                enabledBorder: border(context),
                focusedBorder: focusBorder(context),
              ),
            ),
            const SizedBox(height: 10),
            TextFormField(
              onSaved: (value) => _address = value,
              decoration: InputDecoration(
                labelText: AddPointOfInterestFormStrings.address,
                border: border(context),
                enabledBorder: border(context),
                focusedBorder: focusBorder(context),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  _expiresAt == null
                      ? AddPointOfInterestFormStrings.noExpiration
                      : AddPointOfInterestFormStrings.expiresOn(_expiresAt!),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_calendar),
                  tooltip: AddPointOfInterestFormStrings.setExpiration,
                  onPressed: _pickExpiresAt,
                ),
                if (_expiresAt != null)
                  IconButton(
                    icon: const Icon(Icons.clear),
                    tooltip: AddPointOfInterestFormStrings.clearExpiration,
                    onPressed: () => setState(() => _expiresAt = null),
                  ),
              ],
            ),
            if (isAdmin) ...[
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text(AddPointOfInterestFormStrings.visibleToNeighborhood),
                  Switch(
                    value: _isPublic,
                    onChanged: (value) => setState(() => _isPublic = value),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 10),
            Row(
              children: [
                CancelButton(
                  label: AddPointOfInterestFormStrings.cancel,
                  onPressed: () => Navigator.of(context).pop(),
                ),
                const SizedBox(width: 8),
                ConfirmButton(
                  label: AddPointOfInterestFormStrings.add,
                  onPressed: () async {
                    _formKey.currentState!.save();
                    if (!_formKey.currentState!.validate()) return;

                    final poi = PointOfInterest(
                      id: const UuidV4().generate(),
                      name: _name!,
                      address: _address ?? '',
                      geom: widget.center,
                      type: _type!,
                      userId: widget.authUser.uuid,
                      visibilityScope: isAdmin && _isPublic
                          ? VISIBILITY_SCOPE.neighborhood
                          : VISIBILITY_SCOPE.private,
                      expiresAt: _expiresAt,
                    );
                    await PointOfInterestService().insert(poi);

                    if (context.mounted) Navigator.of(context).pop();
                    widget.onSave();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
