class SupplierCandidate {
  final String profileId;
  final String peopleId;
  final String givenName;
  final String householdId;
  final String userResourceId;
  final int availableQuantity;
  final double distanceMeters;

  const SupplierCandidate({
    required this.profileId,
    required this.peopleId,
    required this.givenName,
    required this.householdId,
    required this.userResourceId,
    required this.availableQuantity,
    required this.distanceMeters,
  });

  factory SupplierCandidate.fromJson(Map<String, dynamic> json) {
    return SupplierCandidate(
      profileId: json['profile_id'] as String,
      peopleId: json['people_id'] as String,
      givenName: json.containsKey('given_name')
          ? json['given_name'] as String
          : '[unknown]',
      householdId: json['household_id'] as String,
      userResourceId: json['user_resource_id'] as String,
      availableQuantity: (json['available_quantity'] as num).toInt(),
      distanceMeters: (json['distance_meters'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'profile_id': profileId,
      'people_id': peopleId,
      'household_id': householdId,
      'user_resource_id': userResourceId,
      'available_quantity': availableQuantity,
      'distance_meters': distanceMeters,
    };
  }
}
