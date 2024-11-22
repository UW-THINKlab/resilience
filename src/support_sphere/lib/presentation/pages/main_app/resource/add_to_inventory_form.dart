import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:support_sphere/constants/string_catalog.dart';
import 'package:support_sphere/data/enums/resource_nav.dart';
import 'package:support_sphere/data/models/resource.dart';
import 'package:support_sphere/logic/cubit/resource_cubit.dart';
import 'package:support_sphere/presentation/components/auth/borders.dart';

class AddToInventoryForm extends StatefulWidget {
  const AddToInventoryForm({super.key, required this.resource});

  final Resource resource;

  @override
  State<AddToInventoryForm> createState() => _AddToInventoryFormState();
}

class _AddToInventoryFormState extends State<AddToInventoryForm> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final resource = widget.resource;
    return BlocProvider.value(
      value: BlocProvider.of<ResourceCubit>(context),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            Text(AddResourceInventoryFormStrings.addTitle(resource.name),
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FaIcon(resource.resourceType.icon, size: 15),
                const SizedBox(width: 4),
                Text(resource.resourceType.name),
              ],
            ),
            const SizedBox(height: 8),
            Text(resource.description ?? ''),
            const SizedBox(height: 16),
            TextFormField(
              key: const Key('AddToInventoryForm_quantity_textFormField'),
              initialValue: '1',
              keyboardType: TextInputType.number,
              // onSaved: (value) => _formData = _formData.copyWith(subtype: value),
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(),
                FormBuilderValidators.numeric(),
                FormBuilderValidators.min(1)
              ]),
              decoration: InputDecoration(
                  labelText: AddResourceInventoryFormStrings.howManyAdding,
                  helperText: '',
                  border: border(context),
                  enabledBorder: border(context),
                  focusedBorder: focusBorder(context)),
            ),
            const SizedBox(height: 16),
            TextFormField(
              key:
                  const Key('AddToInventoryForm_resourceSubtype_textFormField'),
              // onSaved: (value) => _formData = _formData.copyWith(subtype: value),
              autovalidateMode: AutovalidateMode.onUserInteraction,
              decoration: InputDecoration(
                  labelText:
                      AddResourceInventoryFormStrings.askSubtype(resource.name),
                  helperText: '',
                  border: border(context),
                  enabledBorder: border(context),
                  focusedBorder: focusBorder(context)),
            ),
            const SizedBox(height: 16),
            // Resource Notes (Only user and cluster captains can see)
            TextFormField(
              key: const Key('AddToInventoryForm_notes_textFormField'),
              // onSaved: (value) => _formData = _formData.copyWith(notes: value),
              autovalidateMode: AutovalidateMode.onUserInteraction,
              keyboardType: TextInputType.multiline,
              minLines: 1,
              maxLines: 5,
              decoration: InputDecoration(
                  labelText: AddResourceInventoryFormStrings.notes,
                  helperText: AddResourceInventoryFormStrings.notesHelperText,
                  helperMaxLines: 3,
                  border: border(context),
                  enabledBorder: border(context),
                  focusedBorder: focusBorder(context)),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // TODO: Implement Save Item for User Invetory
                ElevatedButton(onPressed: () {
                  _formKey.currentState!.save();
                  if (_formKey.currentState!.validate()) {
                    context
                        .read<ResourceCubit>()
                        .currentNavChanged(ResourceNav.savedResourceInventory);
                  }
                }, child: Text("Save Item")),
                const SizedBox(width: 4),
                ElevatedButton(
                    onPressed: () {
                      context
                          .read<ResourceCubit>()
                          .currentNavChanged((ResourceNav.showAllResources));
                    },
                    child: Text("Cancel")),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
