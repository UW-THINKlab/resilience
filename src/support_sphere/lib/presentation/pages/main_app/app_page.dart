import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:support_sphere/constants/string_catalog.dart';
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
      child: BlocBuilder<AppBloc, AppState>(
        buildWhen: (previous, current) =>
            previous.selectedBottomNavIndex != current.selectedBottomNavIndex,
        builder: (context, state) {
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
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
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
              body: AppBodySelect.getBody(state.selectedBottomNavIndex),
              bottomNavigationBar: NavigationBar(
                selectedIndex: state.selectedBottomNavIndex,
                onDestinationSelected: (value) {
                  context
                      .read<AppBloc>()
                      .add(AppOnBottomNavIndexChanged(value));
                },
                destinations: [
                  for (final destination in AppBodySelect.destinations)
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

    Widget iconButton = IconButton(
      onPressed: () => print("Emergency button pressed"),
      icon: Icon(Ionicons.radio_outline),
      color: Colors.white,
    );

    return BlocBuilder<AuthenticationBloc, AuthenticationState>(
        builder: (context, state) {
      switch (state.user.userRole) {
        // TODO: Change key to enums
        case 'MANAGER':
          return iconButton;
        case 'ADMIN':
          return iconButton;
        default:
          return SizedBox();
      }
    });
  }
}
