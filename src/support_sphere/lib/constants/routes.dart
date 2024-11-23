import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:support_sphere/constants/string_catalog.dart';
import 'package:support_sphere/presentation/pages/main_app/profile/profile_body.dart';
import 'package:support_sphere/presentation/pages/main_app/checklist/checklist_main_body.dart';
import 'package:support_sphere/presentation/pages/main_app/checklist/checklist_management_main_body.dart';

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
          icon: Icon(Ionicons.home_sharp), label: NavRouteLabels.home),
      const AppRoute(
          icon: Icon(Ionicons.person_sharp), label: NavRouteLabels.profile, body: ProfileBody()),
      const AppRoute(
          icon: Icon(Ionicons.shield_checkmark_sharp), label: NavRouteLabels.prepare, body: ChecklistBody()),
      const AppRoute(icon: Icon(Ionicons.hammer_sharp), label: NavRouteLabels.resources),
    ];
    if (role == AppRoles.communityAdmin) {
      // TODO: Make this display only for certain screen size
      destinations = destinations + [
        const AppRoute(
            icon: Icon(Ionicons.construct_sharp), label: NavRouteLabels.manageResources),
        const AppRoute(
            icon: Icon(Ionicons.list_sharp), label: NavRouteLabels.manageChecklists, body: ChecklistManagementBody()),
      ];
    }
    return destinations;
  }
}
