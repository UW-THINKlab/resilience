import 'package:equatable/equatable.dart';
import 'package:support_sphere/data/models/generated_classes.dart';

class UserResource extends Equatable {
  const UserResource({
    required this.id,
    required this.name,
    required this.resourceType,
    required this.qtyAvailable,
    required this.sharingScope,
    required this.sharingScopeEmergency,
    this.notes,
    this.addedDate,
    this.reviewedDate,
  });

  final String id;
  final String name;
  final ResourceTypes resourceType;
  final int qtyAvailable;
  final SHARING_SCOPES sharingScope;
  final SHARING_SCOPES sharingScopeEmergency;
  final String? notes;
  final DateTime? addedDate;
  final DateTime? reviewedDate;

  @override
  List<Object?> get props => [
        id,
        name,
        resourceType,
        qtyAvailable,
        sharingScope,
        sharingScopeEmergency,
        notes,
        addedDate,
        reviewedDate,
      ];

  UserResource copyWith({
    String? id,
    String? name,
    ResourceTypes? resourceType,
    int? qtyAvailable,
    SHARING_SCOPES? sharingScope,
    SHARING_SCOPES? sharingScopeEmergency,
    String? notes,
    DateTime? addedDate,
    DateTime? reviewedDate,
  }) {
    return UserResource(
      id: id ?? this.id,
      name: name ?? this.name,
      resourceType: resourceType ?? this.resourceType,
      qtyAvailable: qtyAvailable ?? this.qtyAvailable,
      sharingScope: sharingScope ?? this.sharingScope,
      sharingScopeEmergency:
          sharingScopeEmergency ?? this.sharingScopeEmergency,
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
      sharingScope: SHARING_SCOPES.values.byName(json['sharing_scope']),
      sharingScopeEmergency:
          SHARING_SCOPES.values.byName(json['sharing_scope_emergency']),
      notes: json['notes'],
      addedDate: DateTime.parse(json['created_at']),
      reviewedDate: DateTime.parse(json['updated_at']),
    );
  }
}
