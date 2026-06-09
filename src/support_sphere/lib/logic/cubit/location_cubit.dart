import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'location_state.dart';

class LocationCubit extends Cubit<LocationState> {
  LocationCubit() : super(const LocationState());

  Future<void> getCurrentLocation() async {
    emit(state.copyWith(status: LocationStatus.loading, clearError: true));

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      emit(state.copyWith(
        status: LocationStatus.serviceDisabled,
        errorMessage: 'Location services are disabled.',
      ));
      return;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      emit(state.copyWith(
        status: LocationStatus.permissionDenied,
        errorMessage: 'Location permission denied.',
      ));
      return;
    }

    if (permission == LocationPermission.deniedForever) {
      emit(state.copyWith(
        status: LocationStatus.permissionDenied,
        errorMessage: 'Location permission permanently denied.',
      ));
      return;
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      emit(state.copyWith(
        status: LocationStatus.success,
        userLocation: LatLng(position.latitude, position.longitude),
      ));
    } catch (e) {
      emit(state.copyWith(
        status: LocationStatus.failure,
        errorMessage: 'Failed to get current location.',
      ));
    }
  }
}
