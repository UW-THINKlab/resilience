import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:support_sphere/constants/string_catalog.dart';
import 'package:support_sphere/data/models/auth_user.dart';
import 'package:support_sphere/logic/cubit/home_cubit.dart';
import 'package:support_sphere/logic/cubit/home_state.dart';
import 'package:support_sphere/logic/bloc/auth/authentication_bloc.dart';
import 'package:support_sphere/presentation/components/circular_floating_button.dart';
import 'package:support_sphere/presentation/components/home/home_header.dart';
import 'package:support_sphere/presentation/components/home/home_map.dart';
import 'package:support_sphere/presentation/components/snackbars.dart';

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
          if (state.status == HomeStatus.editMeetingPlace) {
            _editMode(state);
          } else if (state.status == HomeStatus.addPointOfInterest) {
            showInfoSnackBar(
              context,
              HomeMapStrings.addPointOfInterestPlacementHint,
            );
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
                child: CircularFloatingButton(
                  icon: Icons.sports_score,
                  tooltip: HomeMapStrings.setMeetingPointTooltip,
                  isActive: state.status == HomeStatus.editMeetingPlace,
                  onPressed: () {
                    final cubit = context.read<HomeCubit>();
                    if (state.status == HomeStatus.editMeetingPlace) {
                      cubit.cancelMeetingPlace();
                    } else {
                      cubit.editMeetingPlace();
                    }
                  },
                ),
              ), // end edit-mode button
              Positioned(
                left: 16,
                bottom: 86,
                child: CircularFloatingButton(
                  icon: Icons.add,
                  tooltip: HomeMapStrings.addPointOfInterestTooltip,
                  isActive: state.status == HomeStatus.addPointOfInterest,
                  onPressed: () {
                    final cubit = context.read<HomeCubit>();
                    if (state.status == HomeStatus.addPointOfInterest) {
                      cubit.cancelAddPointOfInterest();
                    } else {
                      cubit.startAddPointOfInterest();
                    }
                  },
                ),
              ),
              Positioned(
                right: 16,
                bottom: 86,
                child: CircularFloatingButton(
                  icon: Icons.location_searching,
                  tooltip: HomeMapStrings.jumpToLocationTooltip,
                  onPressed: () async {
                    final cubit = context.read<HomeCubit>();
                    await cubit.getCurrentLocation();

                    if (!mounted) return;
                    _recenterMap(cubit.state);
                  },
                ),
              ),
              //
              Positioned(
                right: 16,
                bottom: 16,
                child: CircularFloatingButton(
                  icon: Icons.square_outlined,
                  tooltip: HomeMapStrings.toggleClusterViewTooltip,
                  onPressed: () async {
                    final cubit = context.read<HomeCubit>();
                    // could flip icon! custom icon? mouse pointer?
                    // assume toggle on/off
                    await cubit.showAllClusters(
                        state.status != HomeStatus.allClusters);
                  },
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
