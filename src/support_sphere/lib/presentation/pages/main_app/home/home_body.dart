import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:support_sphere/data/models/auth_user.dart';
import 'package:support_sphere/logic/cubit/home_cubit.dart';
import 'package:support_sphere/logic/cubit/home_state.dart';
import 'package:support_sphere/logic/bloc/auth/authentication_bloc.dart';
import 'package:support_sphere/presentation/components/home/home_header.dart';
import 'package:support_sphere/presentation/components/home/home_map.dart';

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
          } else if (state.status == HomeStatus.editMeetingPlace) {
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
                    child: HomeMap(
                      mapController: _mapController,
                      state: state,
                      cubit: context.read<HomeCubit>(),
                      onMapReady: () {
                        setState(() => _isMapReady = true);
                      },
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
                    Icons.flag,
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
                    Icons.location_searching,
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
                    await cubit.showAllClusters(
                        state.status != HomeStatus.allClusters);
                  },
                  backgroundColor: Colors.white,
                  elevation: 2,
                  child: const Icon(
                    Icons.square_outlined,
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

  // FIXME - move to map?
  void _editMode(HomeState state) {
    if (state.cluster != null && state.cluster!.geom != null) {
      LatLngBounds? bounds = LatLngBounds.fromPoints(state.cluster!.geom!);
      _mapController.fitCamera(CameraFit.bounds(bounds: bounds));
    }
  }
}
