import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:support_sphere/constants/routes.dart';

class AppBodySelect extends Equatable {
  const AppBodySelect({required this.role, this.screenData});

  final String role;
  final MediaQueryData? screenData;

  List<AppRoute> get destinations {
    return AppNavigation.getDestinations(role, screenData?.size.width);
  }

  @override
  List<Object> get props => [destinations];

  Widget getBody(int index) {
    AppRoute collection = destinations[index];
    return collection.body ?? Center(child: Text('${collection.label} Page Coming soon!'));
  }
}
