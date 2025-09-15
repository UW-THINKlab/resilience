import 'dart:ui';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geodesy/geodesy.dart';
import 'package:geolocator/geolocator.dart';
import 'package:logging/logging.dart' show Logger;
import 'package:support_sphere/data/models/auth_user.dart';
import 'package:support_sphere/data/models/clusters.dart';
import 'package:support_sphere/data/repositories/cluster.dart';
import 'package:support_sphere/data/repositories/home.dart';
import 'package:support_sphere/logic/cubit/home_state.dart';

final log = Logger('HomeCubit');

class HomeCubit extends Cubit<HomeState> {
  HomeCubit({
    required this.authUser,
  })  :
        _homeRepository = HomeRepository(),
        clusterRepo = ClusterRepository(),
        super(const HomeState()) {
    _init();
  }

  final MyAuthUser authUser;
  final HomeRepository _homeRepository;
  final ClusterRepository clusterRepo;

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
      final points = homeData?.pointsOfInterest;
      final allClusters = await clusterRepo.getAllClusters();

      emit(state.copyWith(
        captainMarkers: homeData!.captainMarkers,
        cluster: homeData.cluster,
        pointsOfInterest: points,
        allClusters: allClusters,
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
    //log.fine("starting showAllClusters: $showAll");
    if (showAll) {
      final allClusters = await clusterRepo.getAllClusters();
      //log.finer("allClusters: $allClusters");
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

  // state flow: set location, -> description/cancel -> notify/cancel -> (end)

  Future<void> setMeetingPlace(LatLng point, Offset offset) async {
    emit(state.copyWith(
      //status: HomeStatus.editMeetingPlace, NEXT state?
      pickedLocation: point,
      pickedOffset: offset,
    ));
  }

  Future<void> editMeetingPlace() async {
    emit(state.copyWith(
      status: HomeStatus.editMeetingPlace,
    ));
  }

  Future<void> saveMeetingPlace() async {
    if (state.pickedLocation != null) {
      final Cluster cluster = await clusterRepo.updateClusterMeetingPoint(state.cluster!, state.pickedLocation, state.meetingPlace);
      log.fine("Updated cluster: ${cluster.meetingPoint}");

      emit(state.copyWith(
        status: HomeStatus.success,
        cluster: cluster,
        pickedLocation: null,
        pickedOffset: null,
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
        //status: HomeStatus.success,
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
