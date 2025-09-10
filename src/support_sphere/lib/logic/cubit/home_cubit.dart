import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geodesy/geodesy.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:support_sphere/data/models/auth_user.dart';
import 'package:support_sphere/data/models/clusters.dart';
import 'package:support_sphere/data/repositories/home.dart';
import 'package:support_sphere/logic/cubit/home_state.dart';
import 'dart:math';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit({
    required this.authUser,
  })  : _homeRepository = HomeRepository(),
        super(const HomeState()) {
    _init();
  }

  final MyAuthUser authUser;
  final HomeRepository _homeRepository;

  Future<void> _init() async {
    try {
      await loadHomeData();
      await getCurrentLocation();

      emit(state.copyWith(status: HomeStatus.success));
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

      //var points = homeData?.pointsOfInterest;
      //print(points);

      emit(state.copyWith(
        captainMarkers: homeData!.captainMarkers,
        cluster: homeData.cluster,
        //pointsOfInterest: points,
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
        //initZoomLevel: 17.5,
      ));
    } catch (error) {
      if (error is! PermissionDeniedException) {
        throw Exception(error);
      }
    }
  }

  // emit a new state with all clusters
  Future<void> showAllClusters(bool showAll) async {
    log.fine("starting showAllClusters: $showAll");
    if (showAll) {
      final allClusters = await _homeRepository.getAllClusters();
      log.finer("allClusters: $allClusters");
      emit(state.copyWith(
        status: HomeStatus.allClusters,
        allClusters: allClusters,
      ));
    }
    else {
      emit(state.copyWith(
        status: HomeStatus.success,
        allClusters: [],
      ));
    }
  }

  Future<void> editMeetingPlace() async {
    emit(state.copyWith(
      status: HomeStatus.editMeetingPlace,
      allClusters: [],
    ));
  }

  Future<void> saveMeetingPlace() async {
    if (state.pickedLocation != null) {
      final Cluster cluster = await _homeRepository.updateClusterMeetingPoint(state.cluster!, state.pickedLocation);
      emit(state.copyWith(
        status: HomeStatus.success,
        cluster: cluster,
      ));
    }
  }

  Future<void> cancelMeetingPlace() async {
    emit(state.copyWith(
      status: HomeStatus.success,
    ));
  }

  Future<void> focusCluster() async {
    if (state.cluster != null) {
      // set bounding box vfrom cluster

      emit(state.copyWith(
        status: HomeStatus.success,
      ));
    }
  }

  // Iterator thru all the cluster geometry
  // to build a bounds for all clusters.
  LatLngBounds allClusterBounds(List<Cluster> clusters) {
    double maxLat = 0;
    double maxLng = 0;
    double minLat = 100;
    double minLng = 100;
    for (var cluster in clusters) {
      if (cluster.geom != null) {
        for (var point in cluster.geom!) {
          maxLat = max(maxLat, point.latitude);
          minLat = min(minLat, point.latitude);
          maxLng = max(maxLng, point.longitude);
          minLng = min(minLng, point.longitude);
        }
      }
    }
    LatLng maxPoint = LatLng(maxLat, maxLng);
    LatLng minPoint = LatLng(minLat, minLng);
    return LatLngBounds(minPoint, maxPoint);
  }
}
