import 'package:flutter/material.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:support_sphere/logic/cubit/utils.dart';

/// Function to validate the form fields
///
/// Takes in a list of [validators], the input [value],
/// as well as [context] for error management.
/// It will return the error message if the value is invalid
/// and null if the value is valid.
/// Also, it will set the [isValid] flag in the provided cubit
/// based on the validity of the value.
String? validateValue<T extends ValidatableCubit>(
    List<FormFieldValidator<String?>> validators,
    String? value,
    BuildContext context,
) {
  final cubit = context.read<T>();
  Function validate = FormBuilderValidators.compose(validators);
  String? validateResult = validate(value);

  if (validateResult != null) {
    cubit.setInvalid();
    return validateResult;
  }

  return null;
}
