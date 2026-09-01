import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:support_sphere/constants/string_catalog.dart';
import 'package:support_sphere/data/enums/resource_nav.dart';
import 'package:support_sphere/data/models/generated_classes.dart';
import 'package:support_sphere/data/models/resource.dart';
import 'package:support_sphere/data/models/resource_types.dart';
import 'package:support_sphere/logic/cubit/resource_cubit.dart';
import 'package:support_sphere/presentation/components/auth/borders.dart';
import 'package:support_sphere/presentation/components/cancel_button.dart';
import 'package:support_sphere/presentation/components/confirm_button.dart';
import 'package:uuid/v4.dart';

class AddToInventoryFormData extends Equatable {
  const AddToInventoryFormData({
    this.resourceId,
    this.quantity,
    this.notes,
    this.sharingScope,
    this.sharingScopeEmergency,
  });
  final String? resourceId;
  final int? quantity;
  final String? notes;
  final SHARING_SCOPES? sharingScope;
  final SHARING_SCOPES? sharingScopeEmergency;

  @override
  List<Object?> get props => [
        resourceId,
        quantity,
        // subtype,
        notes,
        sharingScope,
        sharingScopeEmergency,
      ];

  AddToInventoryFormData copyWith({
    String? resourceId,
    int? quantity,
    String? notes,
    SHARING_SCOPES? sharingScope,
    SHARING_SCOPES? sharingScopeEmergency,
  }) {
    return AddToInventoryFormData(
        resourceId: resourceId ?? this.resourceId,
        quantity: quantity ?? this.quantity,
        notes: notes ?? this.notes,
        sharingScope: sharingScope ?? this.sharingScope,
        sharingScopeEmergency:
            sharingScopeEmergency ?? this.sharingScopeEmergency);
  }

  Map<String, dynamic> toJson() {
    String now = DateTime.now().toIso8601String();
    return {
      'id': const UuidV4().generate(),
      'resource_id': resourceId,
      'quantity': quantity,
      'notes': notes,
      'sharing_scope': sharingScope?.name,
      'sharing_scope_emergency': sharingScopeEmergency?.name,
      'created_at': now,
      'updated_at': now,
    };
  }
}

class AddToInventoryForm extends StatefulWidget {
  const AddToInventoryForm({super.key, required this.resource});

  final Resource resource;

  @override
  State<AddToInventoryForm> createState() => _AddToInventoryFormState();
}

class _AddToInventoryFormState extends State<AddToInventoryForm> {
  final _formKey = GlobalKey<FormState>();
  AddToInventoryFormData _formData = AddToInventoryFormData();

  @override
  Widget build(BuildContext context) {
    final resource = widget.resource;
    return BlocProvider.value(
      value: BlocProvider.of<ResourceCubit>(context),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Text(AddResourceInventoryFormStrings.addTitle(resource.name),
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
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
              if (resource.resourceType.quantifiable)
                TextFormField(
                  key: const Key('AddToInventoryForm_quantity_textFormField'),
                  initialValue: '1',
                  keyboardType: TextInputType.number,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  onSaved: (value) => _formData =
                      _formData.copyWith(quantity: int.tryParse(value ?? '0')),
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
              FormField<SHARING_SCOPES?>(
                initialValue: null,
                validator: (value) => value == null
                    ? 'Please choose who can request this item.'
                    : null,
                onSaved: (value) => _formData = _formData.copyWith(
                  sharingScope: value, // value is guaranteed non-null
                ),
                builder: (field) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (field.hasError)
                      Text(field.errorText!,
                          style: TextStyle(color: Colors.red)),
                    Text(AddResourceInventoryFormStrings.setSharingScopeNormal),
                    RadioButtonGroup<SHARING_SCOPES>(
                      value: field.value,
                      onChanged: field.didChange,
                      options: SHARING_SCOPES.values,
                      labelBuilder: (scope) => scope.displayName,
                    ),
                  ],
                ),
              ),
              FormField<SHARING_SCOPES?>(
                initialValue: null,
                validator: (value) => value == null
                    ? 'Please choose who can request this in an emergency.'
                    : null,
                onSaved: (value) => _formData = _formData.copyWith(
                  sharingScopeEmergency: value, // value is guaranteed non-null
                ),
                builder: (field) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (field.hasError)
                      Text(field.errorText!,
                          style: TextStyle(color: Colors.red)),
                    Text(AddResourceInventoryFormStrings
                        .setSharingScopeEmergency),
                    RadioButtonGroup<SHARING_SCOPES>(
                      value: field.value,
                      onChanged: field.didChange,
                      options: SHARING_SCOPES.values,
                      labelBuilder: (scope) => scope.displayName,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Resource Notes (Only user and cluster captains can see)
              TextFormField(
                key: const Key('AddToInventoryForm_notes_textFormField'),
                onSaved: (value) =>
                    _formData = _formData.copyWith(notes: value),
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
                  CancelButton(
                      label: 'Cancel',
                      onPressed: () {
                        context
                            .read<ResourceCubit>()
                            .currentNavChanged(ResourceNav.showAllResources);
                      }),
                  const SizedBox(width: 4),
                  ConfirmButton(
                      label: 'Save Item',
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          _formData =
                              _formData.copyWith(resourceId: resource.id);
                          context
                              .read<ResourceCubit>()
                              .addToUserInventory(_formData.toJson());
                          context.read<ResourceCubit>().currentNavChanged(
                              ResourceNav.savedResourceInventory);
                        }
                      }),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

extension SharingScopeDisplay on SHARING_SCOPES {
  String get displayName => switch (this) {
        SHARING_SCOPES.cluster => SharingScopeStrings.clusterOnly,
        SHARING_SCOPES.neighborhood => SharingScopeStrings.neighborhood,
        SHARING_SCOPES.everyone => SharingScopeStrings.everyone,
      };
}

class RadioButtonGroup<T> extends StatefulWidget {
  final T? value;
  final ValueChanged<T?> onChanged;
  final VoidCallback? onSaved; // ← new: like TextFormField.onSaved
  final List<T> options;
  final String Function(T) labelBuilder;

  const RadioButtonGroup({
    super.key,
    this.value,
    required this.onChanged,
    this.onSaved, // optional
    required this.options,
    required this.labelBuilder,
  });

  @override
  State<RadioButtonGroup<T>> createState() => _RadioButtonGroupState<T>();
}

class _RadioButtonGroupState<T> extends State<RadioButtonGroup<T>> {
  late T? _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.value;
  }

  @override
  void didUpdateWidget(covariant RadioButtonGroup<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      _selected = widget.value;
    }
  }

  void _handleChanged(T? value) {
    if (value == null) return;
    _selected = value;
    widget.onChanged(value); // your usual state update
    widget.onSaved?.call(); // optional save callback
  }

  @override
  Widget build(BuildContext context) {
    return RadioGroup<T>(
      groupValue: _selected,
      onChanged: _handleChanged,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: widget.options.map(
          (option) {
            final label = widget.labelBuilder(option);
            return RadioListTile<T>(
              title: Text(label),
              value: option,
              // groupValue: _selected,
              onChanged: (value) => _handleChanged(value),
            );
          },
        ).toList(),
      ),
    );
  }
}
