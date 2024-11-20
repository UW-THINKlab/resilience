import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ResourceTypes extends Equatable {
  const ResourceTypes({
    required this.id,
    required this.name,
    this.description = '',
  });

  final String id;
  final String name;
  final String? description;

  @override
  List<Object?> get props => [id, name, description];

  IconData get icon {
    // Get the icon based on the resource type
    switch (name) {
      case 'Durable':
        return FontAwesomeIcons.wrench;
      case 'Consumable':
        return FontAwesomeIcons.glassWater;
      case 'Skill':
        return FontAwesomeIcons.helmetSafety;
      default:
        return FontAwesomeIcons.question;
    }
  }

  static ResourceTypes fromJson(Map<String, dynamic> json) {
    return ResourceTypes(
      id: json['id'],
      name: json['name'],
      description: json['description'],
    );
  }

  copyWith({
    String? id,
    String? name,
    String? description,
  }) {
    return ResourceTypes(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
    );
  }
}
