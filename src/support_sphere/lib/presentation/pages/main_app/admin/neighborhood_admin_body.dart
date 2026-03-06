import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:support_sphere/constants/string_catalog.dart';
import 'package:support_sphere/data/models/clusters.dart';
import 'package:support_sphere/logic/cubit/manage_neighborhood_cubit.dart';
import 'package:support_sphere/presentation/pages/main_app/admin/cluster_form.dart';
import 'package:support_sphere/presentation/pages/main_app/admin/manage_cluster_card.dart' show ManageClusterCard;
import 'package:support_sphere/presentation/pages/main_app/admin/neighborhood_filter.dart';


class NeighborhoodAdminBody extends StatelessWidget {
  const NeighborhoodAdminBody({super.key});

  @override
  Widget build(BuildContext context) {
    return ManageNeighborhoodBodyController();
  }
}

class ManageNeighborhoodBodyController extends StatefulWidget {
  const ManageNeighborhoodBodyController({super.key});

  @override
  _ManageNeighborhoodBodyControllerState createState() =>
      _ManageNeighborhoodBodyControllerState();
}

class _ManageNeighborhoodBodyControllerState
    extends State<ManageNeighborhoodBodyController> {
  bool _showingAddNeighborhood = false;

  @override
  Widget build(BuildContext context) {
    void switchPage() {
      setState(() {
        _showingAddNeighborhood = !_showingAddNeighborhood;
      });
    }

    return BlocProvider(
      create: (context) => ManageNeighborhoodCubit(),
      child: (_showingAddNeighborhood)
          ? AddClusterView(onPressed: switchPage)
          : ManageNeighborhoodView(addNeighborhoodOnPressed: switchPage),
    );
  }
}

class ManageNeighborhoodView extends StatelessWidget {
  const ManageNeighborhoodView({super.key, this.addNeighborhoodOnPressed});

  final VoidCallback? addNeighborhoodOnPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(12),
          child: Center(
            child: Text(NeighborhoodStrings.manageNeighborhood,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ),
        ),
        _NeighborhoodsBody(addNeighborhoodOnPressed: addNeighborhoodOnPressed),
      ],
    );
  }
}

class AddClusterView extends StatelessWidget {
  const AddClusterView({super.key, this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ManageNeighborhoodCubit, ManageNeighborhoodState>(
      builder: (context, state) {
        return Column(
          children: [
            Expanded(
                child: Container(
              width: MediaQuery.of(context).size.width,
              margin: const EdgeInsets.all(15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Back button
                  TextButton.icon(
                    icon: const Icon(Icons.arrow_back),
                    label: const Text(
                      NeighborhoodStrings.manageNeighborhood,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    onPressed: onPressed,
                  ),

                  /// Add Neighborhood Form
                  Expanded(
                    child: Card(
                      child: Container(
                        margin: const EdgeInsets.all(15.0),
                        child: AddClusterForm(
                          onCancel: onPressed,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            )),
          ],
        );
      },
    );
  }
}

class _NeighborhoodsBody extends StatefulWidget {
  const _NeighborhoodsBody({this.addNeighborhoodOnPressed});

  final VoidCallback? addNeighborhoodOnPressed;

  @override
  _NeighborhoodsBodyState createState() => _NeighborhoodsBodyState();
}

class _NeighborhoodsBodyState extends State<_NeighborhoodsBody> {
  List<Cluster>? _searchResults;
  String _nameQuery = '';

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ManageNeighborhoodCubit, ManageNeighborhoodState>(
      buildWhen: (previous, current) {
        _searchResults = current.clusters.where((item) {
          return item.name?.toLowerCase().contains(_nameQuery) ?? false;
        }).toList();
        return previous.clusters != current.clusters;
      },
      builder: (context, state) {
        // Search bar query changed
        void onQueryChanged(String query) {
          setState(() {
            _searchResults = state.clusters.where((item) {
              _nameQuery = query;
              return item.name?.toLowerCase().contains(_nameQuery) ?? false;
            }).toList();
          });
        }

        // Filter drowndown onSelected
        void onSelected(String? value) {
          setState(() {
            if (_searchResults != null) {
              // Case to filter with search
              if (value != null && value != 'All clusters') {
                _searchResults = state.clusters.where((item) {
                  return item.name?.toLowerCase().contains(_nameQuery) ?? false;
                }).toList();
              } else {
                _searchResults = state.clusters.where((item) {
                  return item.name?.toLowerCase().contains(_nameQuery) ?? false;
                }).toList();
              }
            } else {
              // Case to filter without search
              _searchResults = state.clusters.where((item) {
                return item.captains!.people!.length > 0;
              }).toList();
            }
          });
        }

        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(width: 16),
                ElevatedButton(
                    onPressed: widget.addNeighborhoodOnPressed,
                    child: Text(NeighborhoodStrings.addCluster)),
                // FIXME Expanded(child: NeighborhoodSearchBar(onQueryChanged: onQueryChanged)),
                Expanded(
                    child: NeighborhoodFilter(
                  onSelected: onSelected,
                )),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: _NeighborhoodViewSection(
                      searchResults: _searchResults ?? state.clusters),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _NeighborhoodViewSection extends StatelessWidget {
  final List<Cluster> searchResults;

  const _NeighborhoodViewSection({required this.searchResults});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ManageNeighborhoodCubit, ManageNeighborhoodState>(
      builder: (context, state) {
        return Container(
            height: MediaQuery.of(context).size.height * 0.65,
            padding: const EdgeInsets.all(16),
            // TODO: Add pagination at some point
            child: (searchResults.isNotEmpty)
                ? ListView.builder(
                    itemCount: searchResults.length,
                    itemBuilder: (context, index) {
                      final cluster = searchResults[index];

                      return ManageClusterCard(cluster: cluster);
                    },
                  )
                : Center(
                    child: Text(NeighborhoodStrings.noClustersFound),
                  ));
      },
    );
  }
}
