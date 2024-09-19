import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:ionicons/ionicons.dart';
import 'package:flutter/material.dart';
import 'package:formz/formz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:support_sphere/constants/string_catalog.dart';
import 'package:support_sphere/logic/cubit/login_cubit.dart';
import 'package:support_sphere/presentation/components/auth/borders.dart';

class LoginForm extends StatelessWidget {
  const LoginForm({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginCubit, LoginState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.status.isFailure) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              const SnackBar(
                content: Text('Authentication Failure'),
              ),
            );
        }
      },
      child: Form(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _EmailInput(),
            const SizedBox(height: 8),
            _PasswordInput(),
            const SizedBox(height: 8),
            _LoginButton(),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

String? validateValue(List<FormFieldValidator<String?>> validators,
    String? value, BuildContext context) {
  Function validate = FormBuilderValidators.compose(validators);
  String? validateResult = validate(value);
  if (validateResult != null) {
    context.read<LoginCubit>().setInvalid();
    return validateResult;
  }
  context.read<LoginCubit>().setValid();
  return null;
}

class _EmailInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginCubit, LoginState>(
      buildWhen: (previous, current) =>
          previous.email != current.email || previous.status != current.status,
      builder: (context, state) {
        return TextFormField(
          enabled: !state.status.isInProgress,
          key: const Key('loginForm_emailInput_textFormField'),
          onChanged: (email) => context.read<LoginCubit>().emailChanged(email),
          keyboardType: TextInputType.emailAddress,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: (value) => validateValue([
            FormBuilderValidators.required(),
            FormBuilderValidators.email(),
          ], value, context),
          decoration: InputDecoration(
            labelText: LoginStrings.email,
            helperText: '',
            border: border(context),
            enabledBorder: border(context),
            focusedBorder: focusBorder(context),
            prefixIcon: Icon(
              Ionicons.mail_outline,
              size: 15.0,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
        );
      },
    );
  }
}

class _PasswordInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginCubit, LoginState>(
      buildWhen: (previous, current) =>
          previous.password != current.password ||
          previous.showPassword != current.showPassword ||
          previous.status != current.status,
      builder: (context, state) {
        return TextFormField(
          enabled: !state.status.isInProgress,
          key: const Key('loginForm_passwordInput_textFormField'),
          onChanged: (password) =>
              context.read<LoginCubit>().passwordChanged(password),
          obscureText: !state.showPassword,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: (value) => validateValue([
            FormBuilderValidators.required(),
            FormBuilderValidators.password(),
          ], value, context),
          decoration: InputDecoration(
            labelText: LoginStrings.password,
            helperText: '',
            border: border(context),
            enabledBorder: border(context),
            focusedBorder: focusBorder(context),
            prefixIcon: Icon(
              Ionicons.lock_closed_outline,
              size: 15.0,
              color: Theme.of(context).colorScheme.secondary,
            ),
            suffixIcon: GestureDetector(
              onTap: () {
                context.read<LoginCubit>().toggleShowPassword();
              },
              child: Icon(
                state.showPassword
                    ? Ionicons.eye_off_outline
                    : Ionicons.eye_outline,
                size: 15.0,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _LoginButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginCubit, LoginState>(
      builder: (context, state) {
        return state.status.isInProgress
            ? const CircularProgressIndicator()
            : ElevatedButton(
                onPressed: state.isValid
                    ? () => context.read<LoginCubit>().logInWithCredentials()
                    : null,
                style: ButtonStyle(
                  shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40.0),
                    ),
                  ),
                  backgroundColor: WidgetStateProperty.all<Color>(
                    Theme.of(context).colorScheme.primary,
                  ),
                ),
                // highlightElevation: 4.0,
                child: const Text(
                  LoginStrings.login,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
      },
    );
  }
}
