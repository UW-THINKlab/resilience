import 'package:equatable/equatable.dart';
import 'package:support_sphere/data/models/resource_types.dart';

class Resource extends Equatable {
  const Resource({
    required this.id,
    required this.name,
    required this.resourceType,
    this.notes,
    this.description = '',
    this.qtyNeeded = 0,
    this.qtyAvailable = 0,
  });

  final String id;
  final String name;
  final String? description;
  final String? notes;
  final int qtyNeeded;
  final int qtyAvailable;
  final ResourceTypes resourceType;

  @override
  List<Object?> get props => [id, name, description];

  static Resource fromJson(Map<String, dynamic> json) {
    var resourceTypesJson = json['resource_types'];
    var resourcesCvJson = json['resources_cv'];
    return Resource(
      id: resourcesCvJson['id'],
      name: resourcesCvJson['name'],
      description: resourcesCvJson['description'],
      resourceType: ResourceTypes(
        id: resourceTypesJson['id'],
        name: resourceTypesJson['name'],
        description: resourceTypesJson['description']
      ),
      notes: json['notes'],
      qtyNeeded: json['qty_needed'],
      qtyAvailable: json['qty_available'],
    );
  }

  copyWith({
    String? id,
    String? name,
    String? description,
    String? notes,
    int? qtyNeeded,
    int? qtyAvailable,
    ResourceTypes? resourceType,
  }) {
    return Resource(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      resourceType: resourceType ?? this.resourceType,
      notes: notes ?? this.notes,
      qtyNeeded: qtyNeeded ?? this.qtyNeeded,
      qtyAvailable: qtyAvailable ?? this.qtyAvailable,
    );
  }
}
