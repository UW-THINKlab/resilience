import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show SystemMouseCursor;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:ionicons/ionicons.dart';
import 'package:support_sphere/data/models/auth_user.dart';
import 'package:support_sphere/logic/cubit/home_cubit.dart';
import 'package:support_sphere/logic/cubit/home_state.dart';
import 'package:support_sphere/logic/bloc/auth/authentication_bloc.dart';
import 'package:support_sphere/presentation/components/home/home_header.dart';
import 'package:support_sphere/presentation/components/home/home_map.dart';
import 'package:geodesy/geodesy.dart';


class HomeBody extends StatefulWidget {
  const HomeBody({super.key});

  @override
  State<HomeBody> createState() => HomeBodyState();
}

class HomeBodyState extends State<HomeBody> {
  late final MapController _mapController;
  bool _isMapReady = false;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  @override
  Widget build(BuildContext context) {
    final MyAuthUser authUser = context.select(
      (AuthenticationBloc bloc) => bloc.state.user,
    );

    return BlocProvider(
      create: (context) => HomeCubit(authUser: authUser),
      child: BlocConsumer<HomeCubit, HomeState>(
        listener: (context, state) {
          if (state.status == HomeStatus.success) {
            _recenterMap(state);
          }
          else if (state.status == HomeStatus.editMeetingPlace) {
            _editMode(state);
          }
        },
        builder: (context, state) {
          if (state.status == HomeStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Stack(
            children: [
              Column(
                children: [
                  if (state.cluster != null)
                    HomeHeader(cluster: state.cluster!),
                  Expanded(
                    child: MouseRegion(
                      cursor: _cursorFor(state.status),
                      child: HomeMap(
                        mapController: _mapController,
                        state: state,
                        cubit: context.read<HomeCubit>(),
                        onMapReady: () {
                          setState(() => _isMapReady = true);
                        },
                      ),
                    ),
                  ),
                ],
              ),
              Positioned(
                // start edit-mode button
                left: 16,
                bottom: 16,
                child: FloatingActionButton(
                  onPressed: () {
                    final cubit = context.read<HomeCubit>();
                    cubit.editMeetingPlace();
                  },

                  backgroundColor: Colors.white,
                  elevation: 2,
                  child: const Icon(
                    Ionicons.flag,
                    color: Colors.black,
                  ),
                ),
              ), // end edit-mode button
              Positioned(
                right: 16,
                bottom: 86,
                child: FloatingActionButton(
                  onPressed: () async {
                    final cubit = context.read<HomeCubit>();
                    await cubit.getCurrentLocation();

                    if (!mounted) return;
                    _recenterMap(cubit.state);
                  },
                  backgroundColor: Colors.white,
                  elevation: 2,
                  child: const Icon(
                    Ionicons.locate,
                    color: Colors.black,
                  ),
                ),
              ),
              //
              Positioned(
                right: 16,
                bottom: 16,
                child: FloatingActionButton(
                  onPressed: () async {
                    final cubit = context.read<HomeCubit>();
                    // could flip icon! custom icon? mouse pointer?
                    // assume toggle on/off
                    await cubit.showAllClusters(state.status != HomeStatus.allClusters);
                  },
                  backgroundColor: Colors.white,
                  elevation: 2,
                  child: const Icon(
                    Ionicons.square_outline,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _recenterMap(HomeState state) {
    if (!_isMapReady) return;

    _mapController.move(
        state.userLocation ?? state.initMapCentroid, state.initZoomLevel);
  }

  void _editMode(HomeState state) {
    // change icon
    if (state.cluster != null && state.cluster!.geom != null ) {
      LatLngBounds? bounds = LatLngBounds.fromPoints(state.cluster!.geom!);
      _mapController.fitCamera(CameraFit.bounds(bounds: bounds));
    }
  }

  LatLng _initMapCentroid(HomeState state) {
    // first, check user location
    if (state.userLocation != null) {
      return state.userLocation!;
    }
    if (state.cluster != null) {
      LatLng? centroid = state.cluster!.centroid();
      if (centroid != null) {
        return centroid;
      }
    }
    return LatLng(47.661322762238285, -122.2772993912835);
  }
}

// Noting to self, and for posteriety:
// These state-to-visual mappings could be stored
// in a DB or simple lookup table.
SystemMouseCursor _cursorFor(HomeStatus status) {
  switch (status) {
    case HomeStatus.initial:
    case HomeStatus.loading:
      return SystemMouseCursors.wait;
    case HomeStatus.editMeetingPlace:
      return SystemMouseCursors.grabbing;
    case HomeStatus.success:
    case HomeStatus.allClusters:
      return SystemMouseCursors.basic;
    case HomeStatus.failure:
      return SystemMouseCursors.forbidden;
  }
}