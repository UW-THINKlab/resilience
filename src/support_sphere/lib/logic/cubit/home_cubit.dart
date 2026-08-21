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
import 'package:support_sphere/utils/geojson.dart' show GeoJson;

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
      await loadGeojson();
      log.fine("### ${state.geojson}");

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
      log.fine('loadHomeData: fetching home data for ${authUser.uuid}');
      final homeData = await _homeRepository.getHomeData(authUser.uuid);
      log.fine(
        'loadHomeData: got homeData, '
        'poiCount=${homeData?.pointsOfInterest?.length}, '
        'poiTypeStylesCount=${homeData?.poiTypeStyles.length}',
      );
      final points = homeData?.pointsOfInterest;
      final allClusters = await clusterRepo.getAllClusters();
      log.fine('loadHomeData: got allClusters, count=${allClusters.length}');

      emit(state.copyWith(
        captainMarkers: homeData!.captainMarkers,
        cluster: homeData.cluster,
        pointsOfInterest: points,
        poiTypeStyles: homeData.poiTypeStyles,
        allClusters: allClusters,
      ));
      log.fine('loadHomeData: emitted updated state');
    } catch (error, stackTrace) {
      log.severe('loadHomeData failed', error, stackTrace);
      emit(state.copyWith(status: HomeStatus.failure));
    }
  }

  Future<void> refreshPointsOfInterest() async {
    try {
      final points = await _homeRepository.getPointsOfInterest(authUser.uuid);
      final poiTypeStyles = await _homeRepository.getPointOfInterestTypes();
      emit(state.copyWith(
        pointsOfInterest: points,
        poiTypeStyles: poiTypeStyles,
      ));
    } catch (error, stackTrace) {
      log.severe('refreshPointsOfInterest failed', error, stackTrace);
    }
  }

  Future<void> getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition();

      emit(state.copyWith(
        userLocation: LatLng(position.latitude, position.longitude),
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
      pickedLocation: point,
      pickedOffset: offset,
    ));
  }

  Future<void> editMeetingPlace() async {
    emit(state.copyWith(
      status: HomeStatus.editMeetingPlace,
    ));
  }

  Future<void> startAddPointOfInterest() async {
    emit(state.copyWith(status: HomeStatus.addPointOfInterest));
  }

  Future<void> cancelAddPointOfInterest() async {
    emit(state.copyWith(status: HomeStatus.success));
  }

  Future<void> saveMeetingPlace(String? description) async {
    if (state.pickedLocation != null) {
      final Cluster cluster = await clusterRepo.updateClusterMeetingPoint(state.cluster!, state.pickedLocation, description);
      log.fine("Updated cluster: ${cluster.meetingPoint}");

      emit(state.copyWith(
        status: HomeStatus.success,
        cluster: cluster,
        meetingPlace: description,
        pickedLocation: null,
        pickedOffset: null,
      ));
    }
  }

  Future<void> cancelMeetingPlace() async {
    emit(state.copyWith(
      status: HomeStatus.success,
      pickedLocation: null,
      pickedOffset: null,
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

  // emit a new state with the geojson assets loaded
  Future<void> loadGeojson() async {
    final layers = await GeoJson.loadLayers();
    emit(state.copyWith(
      geojson: layers,
    ));
  }
}
