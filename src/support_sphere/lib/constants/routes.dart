import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:support_sphere/presentation/pages/main_app/profile/profile_body.dart';

class AppRoute extends Equatable {
  const AppRoute({required this.icon, required this.label, this.body});

  final Icon icon;
  final String label;
  final Widget? body;

  @override
  List<Object?> get props => [icon, label, body];
}

class AppNavigation {
  static List<AppRoute> getDestinations(String? role) {
    // TODO: Add body for each route
    List<AppRoute> destinations = [
      const AppRoute(
          icon: Icon(Ionicons.home_sharp), label: 'Home'),
      const AppRoute(
          icon: Icon(Ionicons.person_sharp), label: 'Me', body: ProfileBody()),
      const AppRoute(
          icon: Icon(Ionicons.shield_checkmark_sharp), label: 'Prepare'),
      const AppRoute(icon: Icon(Ionicons.hammer_sharp), label: 'Resources'),
    ];
    if (role == "COM_ADMIN") {
      // TODO: Make this display only for certain screen size
      destinations = destinations + [
        const AppRoute(
            icon: Icon(Ionicons.construct_sharp), label: 'Manage Resources'),
        const AppRoute(
            icon: Icon(Ionicons.list_sharp), label: 'Manage Checklists'),
      ];
    }
    return destinations;
  }
}
