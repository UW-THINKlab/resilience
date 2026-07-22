import 'package:support_sphere/data/models/generated_classes.dart';

class ResourceRequest {
  final String resourceId;
  final String resourceName;
  final String resourceTypeName;
  final int quantity;
  final String requestScope;
  final MESSAGEURGENCY urgency;
  final String? notes;
  final double? lon;
  final double? lat;
  final DateTime expiresAt;

  ResourceRequest({
    required this.resourceId,
    required this.resourceName,
    required this.resourceTypeName,
    required this.quantity,
    required this.requestScope,
    required this.notes,
    required this.lon,
    required this.lat,
    this.urgency = MESSAGEURGENCY.normal,
    required this.expiresAt,
  });
}
