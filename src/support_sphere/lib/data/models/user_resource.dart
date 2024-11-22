import 'package:equatable/equatable.dart';
import 'package:support_sphere/data/models/resource_types.dart';

class UserResource extends Equatable {
  const UserResource({
    required this.id,
    required this.name,
    required this.resourceType,
    required this.qtyAvailable,
    this.notes,
    this.addedDate,
    this.reviewedDate,
  });

  final String id;
  final String name;
  final ResourceTypes resourceType;
  final int qtyAvailable;
  final String? notes;
  final DateTime? addedDate;
  final DateTime? reviewedDate;

  @override
  List<Object?> get props =>
      [id, name, resourceType, qtyAvailable, notes, addedDate, reviewedDate];

  // static UserResource fromJson(Map<String, dynamic> json) {

  // }

  UserResource copyWith({
    String? id,
    String? name,
    ResourceTypes? resourceType,
    int? qtyAvailable,
    String? notes,
    DateTime? addedDate,
    DateTime? reviewedDate,
  }) {
    return UserResource(
      id: id ?? this.id,
      name: name ?? this.name,
      resourceType: resourceType ?? this.resourceType,
      qtyAvailable: qtyAvailable ?? this.qtyAvailable,
      notes: notes ?? this.notes,
      addedDate: addedDate ?? this.addedDate,
      reviewedDate: reviewedDate ?? this.reviewedDate,
    );
  }

  static UserResource fromJson(Map<String, dynamic> json) {
    var resources = json['resources'];
    return UserResource(
      id: json['id'],
      name: resources['resources_cv']['name'],
      resourceType: ResourceTypes.fromJson(resources['resource_types']),
      qtyAvailable: json['quantity'],
      notes: json['notes'],
      addedDate: DateTime.parse(json['created_at']),
      reviewedDate: DateTime.parse(json['updated_at']),
    );
  }
}
