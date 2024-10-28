import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:support_sphere/presentation/pages/main_app/profile/profile_body.dart';
import 'package:support_sphere/logic/cubit/profile_cubit.dart';
import 'package:support_sphere/data/models/auth_user.dart';
import 'package:support_sphere/data/models/person.dart';

class ProfileSection extends StatelessWidget {
  const ProfileSection({
    super.key,
    this.title = "Section Header",
    this.children = const [],
    this.displayTitle = true,
    this.readOnly = false,
    this.sectionType = "DEFAULT",
    this.state = const ProfileState(),
  });

  final String title;
  final String sectionType;
  final List<Widget> children;
  final bool displayTitle;
  final bool readOnly;
  final ProfileState state;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          _getTitle(context) ?? const SizedBox(),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: children,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget? _getTitle(BuildContext context) {
    if (displayTitle) {
      return ListTile(
        title: Text(title),
        trailing: readOnly
            ? null
            : GestureDetector(
                onTap: () => _showModalBottomSheet(context),
                child: const Icon(Ionicons.create_outline),
              ),
      );
    }
    return null;
  }

  Future<dynamic> _showModalBottomSheet(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      builder: (context) {
        return _getModalLayout(context);
      },
    );
  }

  Widget _getModalLayout(BuildContext context) {
    Person? userProfile = state.userProfile;
    AuthUser? authUser = state.authUser;
    String givenName = userProfile?.givenName ?? '';
    String familyName = userProfile?.familyName ?? '';
    String fullName = '$givenName $familyName';
    String phoneNumber = authUser?.phone ?? '';

    if (sectionType == ProfileSectionType.personalInfo.type) {
      return Container(
        padding: const EdgeInsets.all(16.0),
        child: FormBuilder(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FormBuilderTextField(
                name: 'name',
                decoration: const InputDecoration(labelText: 'Name'),
                initialValue: fullName,
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                  FormBuilderValidators.minLength(2),
                ]),
              ),
              const SizedBox(height: 4),
              FormBuilderTextField(
                name: 'phone',
                initialValue: phoneNumber,
                decoration: const InputDecoration(labelText: 'Phone'),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                  FormBuilderValidators.phoneNumber(),
                ]),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                onPressed: () {
                  if (FormBuilder.of(context)?.saveAndValidate() ?? false) {
                    // final formData = FormBuilder.of(context)?.value;
                    // Navigator.of(context).pop();
                  }
                  Navigator.of(context).pop();
                },
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      );
    } else if (sectionType == ProfileSectionType.householdInfo.type) {
      return Container();
    } else {
      return Container();
    }
  }
}
