import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:support_sphere/constants/string_catalog.dart';
import 'package:support_sphere/data/models/clusters.dart';
import 'package:support_sphere/logic/cubit/manage_neighborhood_state.dart';
import 'package:support_sphere/presentation/pages/main_app/admin/cluster_edit_form.dart';
import 'package:support_sphere/presentation/pages/main_app/admin/cluster_search_bar.dart' show ClusterSearchBar;
import 'package:support_sphere/presentation/pages/main_app/admin/cluster_view_card.dart' show ClusterViewCard;
import 'package:support_sphere/presentation/pages/main_app/admin/manage_neighborhood_card.dart';
import 'package:support_sphere/presentation/components/add_item_button.dart';
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

class _ManageNeighborhoodBodyControllerState extends State<ManageNeighborhoodBodyController> {
  bool _showingAddEdit = false;

  @override
  Widget build(BuildContext context) {
    void switchPage() {
      setState(() {
        _showingAddEdit = !_showingAddEdit;
      });
    }

    void clusterUpdated(Map<String,dynamic> clusterData) {
      final cubit = context.read<ManageNeighborhoodCubit>();
      cubit.upsertCluster(clusterData);
    }

    void addCluster() {
      Navigator.push(context,
        MaterialPageRoute<void>(
              builder: (context) => ClusterEditForm( updateCluster: clusterUpdated ),
            )
      );
    }

    return BlocProvider(
      create: (context) => ManageNeighborhoodCubit(),
      child: (_showingAddEdit)
          ? EditClusterView(onPressed: switchPage)
          : ManageNeighborhoodView(addClusterOnPressed: addCluster),
    );
  }
}

class ManageNeighborhoodView extends StatelessWidget {
  const ManageNeighborhoodView({super.key, this.addClusterOnPressed});

  final VoidCallback? addClusterOnPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ManageNeighborhoodCard(),
        Expanded(child: _NeighborhoodsBody(addClusterOnPressed: addClusterOnPressed)),
      ],
    );
  }
}

class EditClusterView extends StatelessWidget {
  const EditClusterView({super.key, this.onPressed});

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

                  /// Edit Cluster Form
                  Expanded(
                    child: Card(
                      child: Container(
                        margin: const EdgeInsets.all(15.0),
                        child: ClusterEditForm(
                          updateCluster: (clusterData) {
                            final cubit = context.read<ManageNeighborhoodCubit>();
                            cubit.upsertCluster(clusterData);
                          }
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
  const _NeighborhoodsBody({this.addClusterOnPressed});

  final VoidCallback? addClusterOnPressed;

  @override
  _NeighborhoodsBodyState createState() => _NeighborhoodsBodyState();
}

class _NeighborhoodsBodyState extends State<_NeighborhoodsBody> {
  List<Cluster>? _searchResults;
  String _nameQuery = '';
  String _filterValue = '';

  bool matchCluster(Cluster cluster) {
     //   meetingPlace notes
    return (cluster.name?.toLowerCase().contains(_nameQuery) ?? false) ||
      (cluster.meetingPlace?.toLowerCase().contains(_nameQuery) ?? false) ||
      (cluster.notes?.toLowerCase().contains(_nameQuery) ?? false);
  }

  List<Cluster> applySearch(List<Cluster> clusters) {
    switch (_filterValue) {
      case NeighborhoodStrings.clusterFilterParticipate:
        // FIXME: What is participation?
        return clusters.where((item) {
          return (item.notes == null) &&  matchCluster(item);
        }).toList();
      case NeighborhoodStrings.clusterFilterNeedCaptain:
        return clusters.where((item) {
          return (item.captains == null) &&  matchCluster(item);
        }).toList();
      default:
        return clusters.where((item) {
          return matchCluster(item);
        }).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ManageNeighborhoodCubit, ManageNeighborhoodState>(
      buildWhen: (previous, current) {
        _searchResults = applySearch(current.clusters);
        return previous.clusters != current.clusters;
      },
      builder: (context, state) {
        // Search bar query changed
        void onQueryChanged(String query) {
          setState(() {
            _nameQuery = query;
            _searchResults = applySearch(state.clusters);
          });
          log.finer("query: $query, #results: ${_searchResults?.length}");
        }

        // Filter drowndown onSelected
        void onSelected(String? value) {
          setState(() {
            _filterValue = value ?? ClusterAdminStrings.clusterFilterAll;
            _searchResults = applySearch(state.clusters);
          });
          log.fine("filter: $value, #results: ${_searchResults?.length}");

        }

        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(width: 16),
                AddItemButton(
                  label: NeighborhoodStrings.addCluster,
                  onPressed: widget.addClusterOnPressed,
                ),
                Expanded(child: ClusterSearchBar(onQueryChanged: onQueryChanged)),
                Expanded(
                    child: NeighborhoodFilter(
                  onSelected: onSelected,
                )),
              ],
            ),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: _NeighborhoodViewSection(
                        searchResults: _searchResults ?? state.clusters),
                  ),
                ],
              ),
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
            padding: const EdgeInsets.all(16),
            // TODO: Add pagination at some point
            child: (searchResults.isNotEmpty)
                ? ListView.builder(
                    itemCount: searchResults.length,
                    itemBuilder: (context, index) {
                      final cluster = searchResults[index];

                      return ClusterViewCard(
                        cluster: cluster,
                        updateCluster: (clusterData) {
                          final cubit = context.read<ManageNeighborhoodCubit>();
                          cubit.upsertCluster(clusterData);
                        },
                      );
                    },
                  )
                : Center(
                    child: Text(NeighborhoodStrings.noClustersFound),
                  ));
      },
    );
  }
}
