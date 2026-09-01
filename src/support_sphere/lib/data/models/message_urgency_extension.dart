import 'package:flutter/material.dart';
import 'package:support_sphere/data/models/generated_classes.dart';

extension MessageUrgencyExtension on MESSAGEURGENCY {
  Color get color {
    switch (this) {
      case MESSAGEURGENCY.normal:
        return Colors.blue;
      case MESSAGEURGENCY.important:
        return Colors.orange;
      case MESSAGEURGENCY.urgent:
        return Colors.purpleAccent;
      case MESSAGEURGENCY.emergency:
        return Colors.red;
    }
  }
}
