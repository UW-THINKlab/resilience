import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:support_sphere/data/models/auth_user.dart';
import 'package:support_sphere/data/repositories/home.dart';
import 'package:support_sphere/logic/cubit/home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit({
    required this.authUser,
  })  : _homeRepository = HomeRepository(),
        super(const HomeState()) {
    _init();
  }

  final AuthUser authUser;
  final HomeRepository _homeRepository;

  Future<void> _init() async {
    try {
      await loadHomeData();
      await getCurrentLocation();

      emit(state.copyWith(
        status: HomeStatus.success,
      ));
    } catch (error) {
      /// TODO: Handle error when getting current location
      emit(state.copyWith(
        status: HomeStatus.failure,
      ));
    }
  }

  Future<void> loadHomeData() async {
    emit(state.copyWith(status: HomeStatus.loading));

    try {
      final homeData = await _homeRepository.getHomeData(authUser.uuid);

      emit(state.copyWith(
        captainMarkers: homeData!.captainMarkers,
        cluster: homeData.cluster,
      ));
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<void> getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition();

      emit(state.copyWith(
        userLocation: LatLng(position.latitude, position.longitude),
        initMapCentroid: LatLng(position.latitude, position.longitude),
        // TODO: adjust zoom level based on user location and cluster size
        initZoomLevel: 17.5,
      ));
    } catch (error) {
      if (error is! PermissionDeniedException) {
        throw Exception(error);
      }
    }
  }
}
