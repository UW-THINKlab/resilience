import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

class AppRoute extends Equatable {
  const AppRoute({required this.icon, required this.label, this.body});

  final Icon icon;
  final String label;
  final Widget? body;

  @override
  List<Object?> get props => [icon, label, body];
}

class AppNavigation {
  // TODO: Add body for each route
  static List<AppRoute> destinations = [
    const AppRoute(
        icon: Icon(Ionicons.home_sharp), label: 'Home'),
    const AppRoute(
        icon: Icon(Ionicons.person_sharp), label: 'Me'),
    const AppRoute(
        icon: Icon(Ionicons.shield_checkmark_sharp), label: 'Prepare'),
    const AppRoute(icon: Icon(Ionicons.hammer_sharp), label: 'Resources'),
  ];
}
