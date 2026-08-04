import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:support_sphere/constants/string_catalog.dart';
import 'package:support_sphere/data/models/generated_classes.dart';
import 'package:support_sphere/data/repositories/resource.dart';
import 'package:support_sphere/presentation/components/cancel_button.dart';
import 'package:support_sphere/presentation/components/confirm_button.dart';
import 'package:support_sphere/presentation/components/confirmation_dialog.dart';
import 'package:support_sphere/presentation/components/snackbars.dart';
import 'package:support_sphere/data/enums/resource_nav.dart';
import 'package:support_sphere/logic/bloc/app_bloc.dart';
import 'package:support_sphere/logic/cubit/resource_cubit.dart';
import 'package:support_sphere/data/models/resource_types.dart';
import 'package:support_sphere/logic/cubit/location_cubit.dart';
import 'package:support_sphere/presentation/components/auth/borders.dart';
import 'package:uuid/v4.dart';

class RequestResourceFormData extends Equatable {
  const RequestResourceFormData({
    this.resourceId,
    this.quantity,
    this.notes,
    this.requestScope,
    this.currentLatitude,
    this.currentLongitude,
    this.resourceName,
    this.resourceTypeName,
    this.hours,
  });
  final String? resourceId;
  final int? quantity;
  final String? notes;
  final String? requestScope;
  final double? currentLatitude;
  final double? currentLongitude;
  final String? resourceName;
  final String? resourceTypeName;
  final int? hours;

  @override
  List<Object?> get props => [
        resourceId,
        quantity,
        notes,
        requestScope,
        currentLatitude,
        currentLongitude,
        resourceName,
        resourceTypeName,
      ];

  RequestResourceFormData copyWith({
    String? resourceId,
    int? quantity,
    String? notes,
    String? requestScope,
    double? currentLatitude,
    double? currentLongitude,
    String? resourceName,
    String? resourceTypeName,
    int? hours,
  }) {
    return RequestResourceFormData(
      resourceId: resourceId ?? this.resourceId,
      quantity: quantity ?? this.quantity,
      notes: notes ?? this.notes,
      requestScope: requestScope ?? this.requestScope,
      currentLatitude: currentLatitude ?? this.currentLatitude,
      currentLongitude: currentLongitude ?? this.currentLongitude,
      resourceName: resourceName ?? this.resourceName,
      resourceTypeName: resourceTypeName ?? this.resourceTypeName,
      hours: hours ?? this.hours,
    );
  }

  Map<String, dynamic> toJson() {
    String now = DateTime.now().toIso8601String();
    return {
      'id': const UuidV4().generate(),
      'resource_id': resourceId,
      'quantity': quantity,
      'notes': notes,
      'request_scope': requestScope,
      'current_latitude': currentLatitude,
      'current_longitude': currentLongitude,
      'created_at': now,
      'resource_name': resourceName,
      'resource_type_name': resourceTypeName,
    };
  }
}

class RequestResourceForm extends StatefulWidget {
  final ResourcesCv resourceCv;
  final ResourceTypes resourceType;

  const RequestResourceForm({
    super.key,
    required this.resourceCv,
    required this.resourceType,
  });

  @override
  State<RequestResourceForm> createState() => _RequestResourceFormState(
        resourceCv: resourceCv,
        resourceType: resourceType,
      );
}

class _RequestResourceFormState extends State<RequestResourceForm> {
  final _formKey = GlobalKey<FormState>();
  final ResourcesCv resourceCv;
  final ResourceTypes resourceType;
  RequestResourceFormData _formData = RequestResourceFormData();
  bool _isProcessing = false;
  final TextEditingController _expiryDateController = TextEditingController();
  DateTime _expiryDate = DateTime.now().add(Duration(days: 10));

  _RequestResourceFormState({
    required this.resourceCv,
    required this.resourceType,
  });

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    _formKey.currentState!.save();

    _formData = _formData.copyWith(
      resourceId: resourceCv.id,
      resourceName: resourceCv.name,
      resourceTypeName: resourceType.name,
    );

    if (_formData.requestScope == 'nearby') {
      final locationCubit = context.read<LocationCubit>();

      if (locationCubit.state.userLocation == null) {
        await locationCubit.getCurrentLocation();
      }

      final userLocation = locationCubit.state.userLocation;
      if (userLocation == null) {
        if (!mounted) return;
        showErrorSnackBar(
          context,
          'Current location is required for nearby requests.',
        );
        return;
      }

      _formData = _formData.copyWith(
        currentLatitude: userLocation.latitude,
        currentLongitude: userLocation.longitude,
      );
    }
    _submitResourceRequest();
  }

  Future<void> _submitResourceRequest() async {
    setState(() => _isProcessing = true);
    try {
      final mode = context.read<AppBloc>().state.mode;
      final isEmergency =
          mode == AppModes.emergency || mode == AppModes.testEmergency;
      await context.read<ResourceCubit>().submitResourceRequest(
            requestData: _formData.toJson(),
            isEmergency: isEmergency,
            onInsufficientInventory: (totalAvailable, requested) async {
              final res = await ConfirmationDialog(
                actions: [
                  CancelButton(
                    label: 'Cancel',
                    onPressed: () => Navigator.of(context).pop(false),
                  ),
                  ConfirmButton(
                    label: 'Continue',
                    onPressed: () => Navigator.of(context).pop(true),
                  ),
                ],
                content: Text(
                  RequestResourceFormStrings.insufficientInventoryWarning(
                      totalAvailable, requested),
                ),
              ).show<bool>(context);
              return res ?? false;
            },
            confirmation: (SuggestedResourceRequest req) async {
              setState(() => _isProcessing = false);
              final res = await ConfirmationDialog(
                actions: [
                  CancelButton(
                    label: 'Cancel',
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                  ),
                  ConfirmButton(
                    label: 'Yes',
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    },
                  ),
                ],
                content: Text(
                  'Confirming will send a request to ${req.supplierCandidate.givenName} for ${req.requestedQty} unit(s)',
                ),
              ).show<bool>(context);
              if (mounted) setState(() => _isProcessing = true);
              return res ?? false;
            },
            expiresAt: _expiryDate,
          );
      if (!mounted) return;
      showSuccessSnackBar(context, 'Request sent.');
      context.read<ResourceCubit>().currentNavChanged(
            ResourceNav.savedRequest,
          );
    } catch (e) {
      if (!mounted) return;
      if (e is ResourceRequestCancelled) {
        showInfoSnackBar(context, RequestResourceFormStrings.requestCancelled);
        return;
      }
      final message = e.toString().toLowerCase();
      showErrorSnackBar(
        context,
        message.contains('not enough available inventory')
            ? 'Not enough inventory to fulfill this request.'
            : 'Failed to save request: $e',
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _selectDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 1),
      initialDate: _expiryDate,
    );
    if (pickedDate != null) {
      _expiryDate = pickedDate;
      _expiryDateController.text = pickedDate.toString().split(" ")[0];
    }
  }

  Widget _extraField(ResourcesCv resourceCv) {
    switch (resourceCv.unit) {
      case UNIT.People:
        return TextFormField(
          key: const Key('RequestResourceForm_hours_textFormField'),
          initialValue: '1',
          keyboardType: TextInputType.number,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          onSaved: (value) =>
              _formData = _formData.copyWith(hours: int.tryParse(value ?? '0')),
          validator: FormBuilderValidators.compose([
            FormBuilderValidators.required(),
            FormBuilderValidators.numeric(),
            FormBuilderValidators.min(1)
          ]),
          decoration: InputDecoration(
            labelText: 'hours needed',
            helperText: '',
            border: border(context),
            enabledBorder: border(context),
            focusedBorder: focusBorder(context),
          ),
        );
      default:
    }
    return SizedBox(
      height: 0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: BlocProvider.of<ResourceCubit>(context),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Text(RequestResourceFormStrings.reqTitle(resourceCv.name),
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FaIcon(resourceType.icon, size: 15),
                  const SizedBox(width: 4),
                  Text(resourceType.name),
                ],
              ),
              const SizedBox(height: 8),
              Text(resourceCv.description ?? ''),
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
              _extraField(resourceCv),
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
                    Text(RequestResourceFormStrings.requestScope),
                    RadioButtonGroup<RequestScopes>(
                      value: field.value,
                      onChanged: field.didChange,
                      options: RequestScopes.values,
                      labelBuilder: (scope) => scope.displayName,
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              TextFormField(
                controller: _expiryDateController,
                decoration: InputDecoration(
                  labelText: 'Expires at',
                  filled: true,
                  prefixIcon: Icon(Icons.calendar_today),
                  enabledBorder:
                      OutlineInputBorder(borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                ),
                readOnly: true,
                onTap: _selectDate,
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
              if (_isProcessing) ...[
                const Text('Requesting...',
                    style: TextStyle(fontStyle: FontStyle.italic)),
                const SizedBox(height: 8),
              ],
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
                      label: 'Request',
                      onPressed: _isProcessing ? null : () => _handleSubmit()),
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
