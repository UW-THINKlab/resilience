import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';

enum LocationStatus {
  initial,
  loading,
  success,
  failure,
  permissionDenied,
  serviceDisabled,
}

class LocationState extends Equatable {
  const LocationState({
    this.status = LocationStatus.initial,
    this.userLocation,
    this.errorMessage,
  });

  final LocationStatus status;
  final LatLng? userLocation;
  final String? errorMessage;

  LocationState copyWith({
    LocationStatus? status,
    LatLng? userLocation,
    String? errorMessage,
    bool clearError = false,
  }) {
    return LocationState(
      status: status ?? this.status,
      userLocation: userLocation ?? this.userLocation,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [status, userLocation, errorMessage];
}
