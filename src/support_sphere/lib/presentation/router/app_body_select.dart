import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:support_sphere/constants/routes.dart';

class AppBodySelect extends Equatable {
  const AppBodySelect({required this.role});

  final String role;

  List<AppRoute> get destinations {
    return AppNavigation.getDestinations(role);
  }

  @override
  List<Object> get props => [destinations];

  Widget getBody(int index) {
    AppRoute collection = destinations[index];
    return collection.body ?? Center(child: Text('${collection.label} Page Coming soon!'));
  }
}
