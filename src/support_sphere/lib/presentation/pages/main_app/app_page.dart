import 'package:flutter/material.dart';
// TODO: Activate Ionicons package when used
// import 'package:ionicons/ionicons.dart';
import 'package:support_sphere/constants/string_catalog.dart';
import 'package:support_sphere/logic/bloc/app_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:support_sphere/presentation/router/app_body_select.dart';

class AppPage extends StatelessWidget {
  const AppPage({super.key});

  static MaterialPage page() => const MaterialPage(child: AppPage());

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AppBloc(),
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
                  // TODO: Add mode change button
                  // IconButton(
                  //   onPressed: () => showChangeModeAlert(context),
                  //   icon: Icon(Ionicons.radio_outline),
                  //   color: Colors.white,
                  // ),
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
