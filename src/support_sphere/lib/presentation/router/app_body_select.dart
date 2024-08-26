import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:support_sphere/constants/routes.dart';

class AppBodySelect extends Equatable {
  static final destinations = AppNavigation.destinations;

  @override
  List<Object> get props => [destinations];

  static Widget getBody(int index) {
    AppRoute collection = destinations[index];
    return collection.body ?? Center(child: Text('${collection.label} Page Coming soon!'));
  }
}
