import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:support_sphere/constants/string_catalog.dart';
import 'package:support_sphere/presentation/pages/main_app/manage_resources/manage_resources_body.dart';
import 'package:support_sphere/presentation/pages/main_app/messages/messages_page.dart';
import 'package:support_sphere/presentation/pages/main_app/profile/profile_body.dart';
import 'package:support_sphere/presentation/pages/main_app/checklist/checklist_main_body.dart';
import 'package:support_sphere/presentation/pages/main_app/checklist/checklist_management_main_body.dart';
import 'package:support_sphere/presentation/pages/main_app/resource/resource_main_body.dart';
import 'package:support_sphere/presentation/pages/main_app/home/home_body.dart';

class AppRoute extends Equatable {
  const AppRoute({required this.icon, required this.label, this.body});

  final Icon icon;
  final String label;
  final Widget? body;

  @override
  List<Object?> get props => [icon, label, body];
}

class AppNavigation {
  static List<AppRoute> getDestinations(String? role, [double? minWidth]) {
    List<AppRoute> destinations = [
      const AppRoute(icon: Icon(Ionicons.home_sharp), label: NavRouteLabels.home, body: HomeBody()),
      const AppRoute(icon: Icon(Ionicons.mail), label: NavRouteLabels.messages, body: MessagesPage()),
      const AppRoute(icon: Icon(Ionicons.person_sharp), label: NavRouteLabels.profile, body: ProfileBody()),
      const AppRoute(icon: Icon(Ionicons.shield_checkmark_sharp), label: NavRouteLabels.prepare, body: ChecklistBody()),
      const AppRoute(icon: Icon(Ionicons.hammer_sharp), label: NavRouteLabels.resources, body: ResourceBody()),
    ];
    // Set the minimum width for managing resources and checklists
    // to be displayed in the navigation bar
    // screen size maximum information retrieved from
    // https://learn.microsoft.com/en-us/windows/apps/design/layout/screen-sizes-and-breakpoints-for-responsive-design
    if (role == AppRoles.communityAdmin && minWidth! > 641) {
      destinations = destinations + [
        const AppRoute(
            icon: Icon(Ionicons.construct_sharp), label: NavRouteLabels.manageResources, body: ManageResourcesBody()),
        const AppRoute(
            icon: Icon(Ionicons.list_sharp), label: NavRouteLabels.manageChecklists, body: ChecklistManagementBody()),
      ];
    }
    return destinations;
  }
}
