import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:support_sphere/constants/string_catalog.dart';
import 'package:support_sphere/data/enums/resource_nav.dart';
import 'package:support_sphere/data/models/resource.dart';
import 'package:support_sphere/logic/cubit/resource_cubit.dart';
import 'package:support_sphere/presentation/components/auth/borders.dart';
import 'package:uuid/v4.dart';

class RequestResourceFormData extends Equatable {
  const RequestResourceFormData({
    this.resourceId,
    this.quantity,
    // TODO: Implement Subtype
    // this.subtype,
    this.notes,
    this.requestScope,
  });
  final String? resourceId;
  final int? quantity;
  // final String? subtype;
  final String? notes;
  final String? requestScope;

  @override
  List<Object?> get props => [
        resourceId,
        quantity,
        // subtype,
        notes,
        requestScope,
      ];

  RequestResourceFormData copyWith({
    String? resourceId,
    int? quantity,
    // String? subtype,
    String? notes,
    String? requestScope,
  }) {
    return RequestResourceFormData(
        resourceId: resourceId ?? this.resourceId,
        quantity: quantity ?? this.quantity,
        // subtype: subtype ?? this.subtype,
        notes: notes ?? this.notes,
        requestScope: requestScope ?? this.requestScope);
  }

  Map<String, dynamic> toJson() {
    String now = DateTime.now().toIso8601String();
    return {
      'id': const UuidV4().generate(),
      'resource_id': resourceId,
      'quantity': quantity,
      // 'subtype': subtype,
      'notes': notes,
      'request_scope': requestScope,
      'created_at': now,
      // 'updated_at': now,
    };
  }
}

class RequestResourceForm extends StatefulWidget {
  const RequestResourceForm({super.key, required this.resource});

  final Resource resource;

  @override
  State<RequestResourceForm> createState() => _RequestResourceFormState();
}

class _RequestResourceFormState extends State<RequestResourceForm> {
  final _formKey = GlobalKey<FormState>();
  RequestResourceFormData _formData = RequestResourceFormData();
  // state variables for sharing scopes radio buttons
  RequestScopes? _requestScope;

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
              Text(RequestResourceFormStrings.reqTitle(resource.name),
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
              TextFormField(
                key: const Key('RequestResourceForm_quantity_textFormField'),
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
                    labelText: RequestResourceFormStrings.numberNeeded,
                    helperText: '',
                    border: border(context),
                    enabledBorder: border(context),
                    focusedBorder: focusBorder(context)),
              ),
              FormField<RequestScopes?>(
                initialValue: null,
                validator: (value) => value == null
                    ? 'Please choose who to ask for this item.'
                    : null,
                onSaved: (value) => _formData = _formData.copyWith(
                  requestScope: value!.dbValue, // value is guaranteed non-null
                ),
                builder: (field) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (field.hasError)
                      Text(field.errorText!,
                          style: TextStyle(color: Colors.red)),
                    Text(RequestResourceFormStrings.requestScope ?? ''),
                    RadioButtonGroup<RequestScopes>(
                      value: field.value,
                      onChanged: field.didChange,
                      options: RequestScopes.values,
                      labelBuilder: (scope) => scope.displayName,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Resource Notes (Only user and cluster captains can see)
              TextFormField(
                key: const Key('RequestResourceForm_notes_textFormField'),
                onSaved: (value) =>
                    _formData = _formData.copyWith(notes: value),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                keyboardType: TextInputType.multiline,
                minLines: 1,
                maxLines: 5,
                decoration: InputDecoration(
                    labelText: RequestResourceFormStrings.notes,
                    helperMaxLines: 3,
                    border: border(context),
                    enabledBorder: border(context),
                    focusedBorder: focusBorder(context)),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent),
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          _formData =
                              _formData.copyWith(resourceId: resource.id);

                          try {
                            // await context
                            //     .read<ResourceCubit>()
                            //     .requestResource(_formData.toJson());
                            await context
                                .read<ResourceCubit>()
                                .submitResourceRequest(
                                  requestData: _formData.toJson(),
                                  recipientUserId: //currently hardcoded to a test chat for testing
                                      '256d26ab-5154-47ec-a08a-d854d6ce0ae6',
                                );
                            if (!context.mounted) return;
                            context
                                .read<ResourceCubit>()
                                .currentNavChanged(ResourceNav.savedRequest);
                          } catch (e) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text('Failed to save request: $e')),
                            );
                          }
                        }
                      },
                      child: Text("Request",
                          style: const TextStyle(color: Colors.white))),
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
      ),
    );
  }
}

enum RequestScopes { nearby, neighbors }

extension RequestScopesExtension on RequestScopes {
  String get displayName => switch (this) {
        RequestScopes.nearby => 'Near Current Location',
        RequestScopes.neighbors => 'Near Home',
      };
  String get dbValue => switch (this) {
        RequestScopes.nearby => 'nearby',
        RequestScopes.neighbors => 'neighbors',
      };
}

class RadioButtonGroup<T> extends StatefulWidget {
  final T? value;
  final ValueChanged<T?> onChanged;
  final VoidCallback? onSaved;
  final List<T> options;
  final String Function(T) labelBuilder;

  const RadioButtonGroup({
    super.key,
    this.value,
    required this.onChanged,
    this.onSaved,
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
