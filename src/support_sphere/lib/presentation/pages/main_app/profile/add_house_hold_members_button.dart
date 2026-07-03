import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:support_sphere/constants/string_catalog.dart';
import 'package:support_sphere/data/models/person.dart';
import 'package:support_sphere/data/repositories/user.dart';
import 'package:support_sphere/logic/cubit/profile_cubit.dart';
import 'package:support_sphere/presentation/components/discreet_button.dart';
import 'package:support_sphere/presentation/components/people_select_list.dart';

class AddHouseHoldMembersButton extends StatelessWidget {
  final UserRepository _userRepository = UserRepository();
  final List<Person> currentHouseholdMembers;
  final List<Person> selectedPeople = [];
  final String householdId;

  AddHouseHoldMembersButton({
    super.key,
    required this.currentHouseholdMembers,
    required this.householdId,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: DiscreetButton(
        label: 'Add household members',
        onPressed: () {
          final profileCubit = context.read<ProfileCubit>();
          showModalBottomSheet(
            context: context,
            builder: (context) {
              return BlocProvider.value(
                value: profileCubit,
                child: AddMembersForm(
                  userRepository: _userRepository,
                  currentHouseholdMembers: currentHouseholdMembers,
                  selectedPeople: selectedPeople,
                  householdId: householdId,
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class AddMembersForm extends StatelessWidget {
  const AddMembersForm({
    super.key,
    required this.userRepository,
    required this.currentHouseholdMembers,
    required this.selectedPeople,
    required this.householdId,
  });

  final UserRepository userRepository;
  final List<Person> currentHouseholdMembers;
  final List<Person> selectedPeople;
  final String householdId;

  @override
  Widget build(BuildContext context) {
    return FormBuilder(
      child: Column(
        children: [
          SizedBox(
            height: 4,
          ),
          FutureBuilder(
            future: userRepository.getAllMembers(),
            builder: (ctx, snapshot) {
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }
              final result = snapshot.data!;
              return PersonSelectorField(
                people: result.values
                    .where(
                      (p) => !currentHouseholdMembers.contains(p),
                    )
                    .toList(),
                onConfirm: (l) {
                  selectedPeople.clear();
                  selectedPeople.addAll(l);
                },
                title: const Text('Select Members'),
                buttonText: const Text('Edit Selection'),
                initialValue: [],
              );
            },
          ),
          SizedBox(
            height: 4,
          ),
          ElevatedButton(
            onPressed: () async {
              context.read<ProfileCubit>().addPeopleToHousehold(
                    selectedPeople,
                    householdId,
                  );
              Navigator.of(context).pop();
            },
            child: Text(UserProfileStrings.submit),
          ),
          SizedBox(
            height: 4,
          ),
          Text('OR'),
          SizedBox(
            height: 4,
          ),
          DiscreetButton(
            label: 'Add a person without an account',
            onPressed: () {
              final profileCubit = context.read<ProfileCubit>();
              Navigator.of(context).pop();
              showModalBottomSheet(
                context: context,
                builder: (ctx) {
                  return BlocProvider.value(
                    value: profileCubit,
                    child: NewPersonForm(
                      userRepository: userRepository,
                      householdId: householdId,
                    ),
                  );
                },
              );
            },
          ),
          SizedBox(
            height: 4,
          ),
        ],
      ),
    );
  }
}

class NewPersonForm extends StatelessWidget {
  final formKey = GlobalKey<FormBuilderState>();

  final UserRepository userRepository;
  final String householdId;

  NewPersonForm({
    super.key,
    required this.userRepository,
    required this.householdId,
  });

  @override
  Widget build(BuildContext context) {
    return FormBuilder(
      key: formKey,
      child: Column(
        children: [
          const SizedBox(height: 12),
          FormBuilderTextField(
            name: UserProfileStrings.givenName,
            decoration: const InputDecoration(
              labelText: UserProfileStrings.givenName,
            ),
          ),
          const SizedBox(height: 4),
          FormBuilderTextField(
            name: UserProfileStrings.familyName,
            decoration: const InputDecoration(
              labelText: UserProfileStrings.familyName,
            ),
          ),
          const SizedBox(height: 4),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState?.saveAndValidate() ?? false) {
                final formData = formKey.currentState?.value;
                if (formData != null) {
                  context.read<ProfileCubit>().newPersonInHousehold(
                        householdId: householdId,
                        familyName: formData[UserProfileStrings.familyName],
                        givenName: formData[UserProfileStrings.givenName],
                      );
                  Navigator.of(context).pop();
                }
              }
            },
            child: Text(UserProfileStrings.submit),
          ),
        ],
      ),
    );
  }
}
