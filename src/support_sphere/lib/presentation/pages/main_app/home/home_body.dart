import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:ionicons/ionicons.dart';
import 'package:support_sphere/data/models/auth_user.dart';
import 'package:support_sphere/logic/cubit/home_cubit.dart';
import 'package:support_sphere/logic/cubit/home_state.dart';
import 'package:support_sphere/logic/bloc/auth/authentication_bloc.dart';
import 'package:support_sphere/presentation/components/home/home_header.dart';
import 'package:support_sphere/presentation/components/home/home_map.dart';

class HomeBody extends StatefulWidget {
  const HomeBody({super.key});

  @override
  State<HomeBody> createState() => _HomeBodyState();
}

class _HomeBodyState extends State<HomeBody> {
  late final MapController _mapController;
  bool _isMapReady = false;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  @override
  Widget build(BuildContext context) {
    final AuthUser authUser = context.select(
      (AuthenticationBloc bloc) => bloc.state.user,
    );

    return BlocProvider(
      create: (context) => HomeCubit(authUser: authUser),
      child: BlocConsumer<HomeCubit, HomeState>(
        listener: (context, state) {
          if (state.status == HomeStatus.success) {
            _recenterMap(state);
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
                      userLocation: state.userLocation,
                      initMapCentroid: state.initMapCentroid,
                      initZoomLevel: state.initZoomLevel,
                      captainMarkers: state.captainMarkers,
                      onMapReady: () {
                        setState(() => _isMapReady = true);
                      },
                    ),
                  ),
                ],
              ),
              Positioned(
                right: 16,
                bottom: 16,
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
            ],
          );
        },
      ),
    );
  }

  void _recenterMap(HomeState state) {
    if (!_isMapReady) return;

    _mapController.move(state.userLocation ?? state.initMapCentroid, state.initZoomLevel);
  }
}
