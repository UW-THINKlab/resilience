class SupplierCandidate {
  const SupplierCandidate({
    required this.profileId,
    required this.peopleId,
    required this.givenName,
    required this.householdId,
    required this.availableQuantity,
    required this.distanceMeters,
  });

  final String profileId;
  final String peopleId;
  final String givenName;
  final String householdId;
  final int availableQuantity;
  final double distanceMeters;

  factory SupplierCandidate.fromJson(Map<String, dynamic> json) {
    return SupplierCandidate(
      profileId: json['profile_id'] as String,
      peopleId: json['people_id'] as String,
      givenName: json['given_name'] as String? ?? 'Neighbor',
      householdId: json['household_id'] as String,
      availableQuantity: (json['available_quantity'] as num).toInt(),
      distanceMeters: (json['distance_meters'] as num).toDouble(),
    );
  }
}
