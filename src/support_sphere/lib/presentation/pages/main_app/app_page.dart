import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ionicons/ionicons.dart';
import 'package:support_sphere/constants/string_catalog.dart';
import 'package:support_sphere/data/models/auth_user.dart';
import 'package:support_sphere/logic/bloc/app_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:support_sphere/logic/bloc/auth/authentication_bloc.dart';
import 'package:support_sphere/presentation/router/app_body_select.dart';
import 'package:support_sphere/data/repositories/app.dart';

class AppPage extends StatelessWidget {
  const AppPage({super.key});

  static MaterialPage page() => const MaterialPage(child: AppPage());

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AppBloc(appRepository: AppRepository()),
      child: BlocListener<AppBloc, AppState>(
        listener: (context, state) {
          /// Show a banner if the app is in test emergency mode
          /// This is to help users understand that the emergency
          /// is not real and is only a test

          // TODO: Fix this... still buggy
          if (state.mode == AppModes.testEmergency) {
            ScaffoldMessenger.of(context).showMaterialBanner(
              const MaterialBanner(
                padding: EdgeInsets.all(5),
                content: Text(AppStrings.testEmergencyBannerText),
                leading: Icon(Ionicons.warning_sharp),
                backgroundColor: Colors.yellow,
                actions: [SizedBox()],
              ),
            );
          } else {
            ScaffoldMessenger.of(context).removeCurrentMaterialBanner();
          }
        },
        child: BlocBuilder<AppBloc, AppState>(
          buildWhen: (previous, current) =>
              previous.selectedBottomNavIndex !=
                  current.selectedBottomNavIndex ||
              previous.mode != current.mode,
          builder: (context, state) {
            final AuthUser authUser = context.select(
              (AuthenticationBloc bloc) => bloc.state.user,
            );
            MediaQueryData screenData = MediaQuery.of(context);
            AppBodySelect bodySelector = AppBodySelect(role: authUser.userRole, screenData: screenData);
            return SafeArea(
              child: Scaffold(
                appBar: AppBar(
                  // TODO: Add hamburger menu
                  // leading: Builder(
                  //   builder: (context) {
                  //     return IconButton(
                  //       icon: const Icon(color: Colors.white, Ionicons.menu_outline),
                  //       onPressed: () {
                  //         Scaffold.of(context).openDrawer();
                  //       },
                  //     );
                  //   },
                  // ),
                  // TODO: Change color to red during emergency mode
                  backgroundColor: state.mode == AppModes.normal
                      ? Theme.of(context).colorScheme.primaryContainer
                      : Colors.red,
                  // TODO: Add "Emergency Declared" title during emergency mode
                  title: const Text(
                    AppStrings.appName,
                    style: TextStyle(color: Colors.white),
                  ),
                  actions: const [
                    _DeclareEmergencyButton(),
                    // TODO: Add notifications badge
                    // IconButton(
                    //   icon: const Badge(
                    //       label: Text('2'),
                    //       child: Icon(Ionicons.notifications_sharp)),
                    //   color: Colors.white,
                    //   onPressed: () {},
                    // ),
                  ],
                ),
                // TODO: Add hamburger menu navigation
                // drawer: const Drawer(
                //   child: null,
                // ),
                body: bodySelector.getBody(state.selectedBottomNavIndex),
                bottomNavigationBar: NavigationBar(
                  selectedIndex: state.selectedBottomNavIndex,
                  onDestinationSelected: (value) {
                    context
                        .read<AppBloc>()
                        .add(AppOnBottomNavIndexChanged(value));
                  },
                  destinations: [
                    for (final destination in bodySelector.destinations)
                      NavigationDestination(
                        icon: destination.icon,
                        label: destination.label,
                      )
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Button to declare an emergency
/// Only visible to users that have a role
/// of community admin and above
class _DeclareEmergencyButton extends StatelessWidget {
  const _DeclareEmergencyButton({super.key});

  @override
  Widget build(BuildContext context) {
    Future<void> showChangeModeAlert(BuildContext parentContext) async {
      print(parentContext);
      return showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return _AppModeChangeDialog(parentContext: parentContext);
        },
      );
    }

    return BlocBuilder<AuthenticationBloc, AuthenticationState>(
        builder: (context, state) {
      final String appMode = context.select(
        (AppBloc bloc) => bloc.state.mode,
      );

      Widget iconButton;

      if (appMode == AppModes.normal) {
        iconButton = IconButton(
          onPressed: () => showChangeModeAlert(context),
          icon: FaIcon(
            FontAwesomeIcons.houseCrack,
          ),
          color: const Color.fromARGB(255, 255, 0, 0),
        );
      } else {
        iconButton = IconButton(
          onPressed: () => showChangeModeAlert(context),
          icon: FaIcon(
            FontAwesomeIcons.houseCircleCheck,
          ),
          color: const Color.fromARGB(255, 0, 255, 98),
        );
      }
      switch (state.user.userRole) {
        // TODO: Change key to enums
        case AppRoles.admin:
          return iconButton;
        case AppRoles.communityAdmin:
          return iconButton;
        default:
          return SizedBox();
      }
    });
  }
}

class _AppModeChangeDialog extends StatelessWidget {
  const _AppModeChangeDialog({super.key, required this.parentContext});

  final BuildContext parentContext;

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: parentContext.read<AppBloc>(),
      child: BlocBuilder<AppBloc, AppState>(
        builder: (context, state) {
          // Show different alert dialog based on the current mode
          switch (state.mode) {
            case AppModes.normal:
              return _NormalAlertDialog(parentContext: parentContext);
            case AppModes.emergency:
              return _EmergencyAlertDialog(parentContext: parentContext);
            case AppModes.testEmergency:
              return _EmergencyAlertDialog(parentContext: parentContext);
            default:
              return const SizedBox();
          }
        },
      ),
    );
  }
}

/// Emergency mode alert dialog
/// This dialog will ask the user if they want to return to normal mode.
///
/// If the user selects "Yes", the app will switch to normal mode.
/// If the user selects "No", the dialog will close.
class _EmergencyAlertDialog extends StatelessWidget {
  const _EmergencyAlertDialog({super.key, required this.parentContext});

  final BuildContext parentContext;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(EmergencyAlertDialogStrings.title),
      content: const SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            Text(EmergencyAlertDialogStrings.message),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text(EmergencyAlertDialogStrings.buttonYes),
          onPressed: () {
            Navigator.of(context).pop();
            parentContext
                .read<AppBloc>()
                .add(AppOnStatusChangeRequested(AppModes.normal));
          },
        ),
        TextButton(
          child: const Text(EmergencyAlertDialogStrings.buttonNo),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}

/// Normal mode alert dialog
/// This dialog will ask the user if they want to declare an emergency
/// or a test emergency.
///
/// If the user selects "Emergency", the app will switch to emergency mode.
/// If the user selects "Test", the app will switch to test emergency mode.
/// If the user selects "Cancel", the dialog will close.
class _NormalAlertDialog extends StatelessWidget {
  const _NormalAlertDialog({super.key, required this.parentContext});

  final BuildContext parentContext;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(NormalAlertDialogStrings.title),
      content: const SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            Text(NormalAlertDialogStrings.message),
          ],
        ),
      ),
      actions: <Widget>[
        // Cancel button
        TextButton(
          child: const Text(NormalAlertDialogStrings.buttonCancel),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        // Test button
        TextButton(
          child: const Text(NormalAlertDialogStrings.buttonTest),
          onPressed: () {
            Navigator.of(context).pop();
            parentContext
                .read<AppBloc>()
                .add(AppOnStatusChangeRequested(AppModes.testEmergency));
          },
        ),
        // Emergency button
        TextButton(
          child: const Text(NormalAlertDialogStrings.buttonEmergency),
          onPressed: () {
            Navigator.of(context).pop();
            parentContext
                .read<AppBloc>()
                .add(AppOnStatusChangeRequested(AppModes.emergency));
          },
        ),
      ],
    );
  }
}
