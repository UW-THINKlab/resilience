import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:support_sphere/constants/string_catalog.dart';
import 'package:support_sphere/data/models/households.dart';
import 'package:support_sphere/logic/cubit/manage_cluster_state.dart';
import 'package:support_sphere/presentation/pages/main_app/admin/add_household_form.dart';
import 'package:support_sphere/presentation/pages/main_app/admin/household_filter.dart';
import 'package:support_sphere/presentation/pages/main_app/admin/household_search_bar.dart' show HouseholdSearchBar;
import 'package:support_sphere/presentation/pages/main_app/admin/manage_household_card.dart';

class ClusterAdminBody extends StatelessWidget {
  const ClusterAdminBody({super.key});

  @override
  Widget build(BuildContext context) {
    return ClusterAdminBodyController();
  }
}

class ClusterAdminBodyController extends StatefulWidget {
  const ClusterAdminBodyController({super.key});

  @override
  _ClusterAdminBodyControllerState createState() =>
      _ClusterAdminBodyControllerState();
}

class _ClusterAdminBodyControllerState
    extends State<ClusterAdminBodyController> {
  bool _showingAddHousehold = false;

  @override
  Widget build(BuildContext context) {
    void switchPage() {
      setState(() {
        _showingAddHousehold = !_showingAddHousehold;
      });
    }

    return BlocProvider(
      create: (context) => ManageClusterCubit(),
      child: (_showingAddHousehold)
          ? AddHouseholdView(onPressed: switchPage)
          : ManageClusterView(addHouseholdOnPressed: switchPage),
    );
  }
}

class AddHouseholdView extends StatelessWidget {
  const AddHouseholdView({super.key, this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    // FIXME!!!
    throw UnimplementedError();
  }
}

class HouseholdList extends StatelessWidget {
  const HouseholdList({super.key, required this.households});

  final List<Household> households;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: households.length,
      itemBuilder: (BuildContext context, int index) {
        return HouseholdListItem(household: households[index]);
      }
    );
  }
}

class HouseholdListItem extends StatelessWidget {
  const HouseholdListItem({super.key, required this.household});

  final Household household;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      //color: Colors.amber[colorCodes[index]],
      child: Center(child: Text('Entry $household')),
    );
  }
}

// children: [
//   FaIcon(FontAwesomeIcons.house, size: 15),
//   const SizedBox(width: 4),
//   Text(name),
//   const SizedBox(width: 4),
//   Text(address),
//   const SizedBox(width: 4),
//   Text(widget.household.pets ?? ''),
//   const SizedBox(width: 4),
//   Text(widget.household.accessibilityNeeds ?? ''),
// ],

class ManageClusterView extends StatelessWidget {
  const ManageClusterView({super.key, this.addHouseholdOnPressed});

  final VoidCallback? addHouseholdOnPressed;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ManageClusterCubit, ManageClusterState>(
      builder: (context, state) {
        return Column(
          children: [
            Padding(
              padding: EdgeInsets.all(12),
              child: Center(
                child: Text("Manage Cluster - ${state.cluster?.name}", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ),
            ),
            _ClusterAdminBody(addHouseholdOnPressed: addHouseholdOnPressed),
          ],
        );
      });
  }
}

class AddClusterView extends StatelessWidget {
  const AddClusterView({super.key, this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ManageClusterCubit, ManageClusterState>(
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
                      ResourceStrings.manageResources,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    onPressed: onPressed,
                  ),

                  /// Add Cluster Form
                  Expanded(
                    child: Card(
                      child: Container(
                        margin: const EdgeInsets.all(15.0),
                        child: AddHouseholdForm(
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

class _ClusterAdminBody extends StatefulWidget {
  const _ClusterAdminBody({this.addHouseholdOnPressed});

  final VoidCallback? addHouseholdOnPressed;

  @override
  _ClusterAdminBodyState createState() => _ClusterAdminBodyState();
}

class _ClusterAdminBodyState extends State<_ClusterAdminBody> {
  List<Household>? _searchResults;
  String _nameQuery = '';
  String _householdFilter = '';

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ManageClusterCubit, ManageClusterState>(
      buildWhen: (previous, current) {
        _searchResults = current.households.where((item) {
          if (_nameQuery == '') {
            return true;
          }
          return item.name == null ? false : item.name!.toLowerCase().contains(_nameQuery);
        }).toList();
        return previous.households != current.households;
      },
      builder: (context, state) {
        // Search bar query changed
        void onQueryChanged(String query) {
          setState(() {
            _searchResults = state.households.where((item) {
              _nameQuery = query;
              return item.name!.toLowerCase().contains(_nameQuery);
            }).toList();
          });
        }

        // Filter dropdown onSelected
        void onSelected(String? value) {
          setState(() {
            if (_searchResults != null) {
              // Case to filter with search
              if (value != null && value != ClusterAdminStrings.clusterFilterAll) {
                // value selected
                // "Has resources" or "Low participation";
                // need queries....
                _householdFilter = value;
                switch (_householdFilter) {
                  case ClusterAdminStrings.clusterFilterParticipate:
                    _searchResults = state.households.where((item) {
                      return item.houseHoldMembers!.members.isNotEmpty &&
                        item.name!.toLowerCase().contains(_nameQuery);
                      }).toList();
                      break;
                  case ClusterAdminStrings.clusterFilterAssist:
                    _searchResults = state.households.where((item) {
                      return item.accessibilityNeeds!.isNotEmpty &&
                        item.name!.toLowerCase().contains(_nameQuery);
                      }).toList();
                      break;
                  case ClusterAdminStrings.clusterFilterResources:
                    // FIXME: right now, requires a extra query
                    // this is a place holder that looks for pets
                    _searchResults = state.households.where((item) {
                      return item.pets!.isNotEmpty &&
                        item.name!.toLowerCase().contains(_nameQuery);
                      }).toList();
                      break;
                }
              }
            } else {
              // Case to filter without search
              // FIXME???
              _searchResults = state.households.where((item) {
                _householdFilter = value != 'All' ? value ?? '' : '';
                return item.name!.contains(_householdFilter);
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
                    onPressed: widget.addHouseholdOnPressed,
                    child: Text(ClusterAdminStrings.addHousehold)),
                Expanded(child: HouseholdSearchBar(onQueryChanged: onQueryChanged)),
                Expanded(
                  child: HouseholdFilter(
                    onSelected: onSelected,
                )),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: _ClusterViewSection(
                      searchResults: _searchResults ?? state.households),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _ClusterViewSection extends StatelessWidget {
  final List<Household> searchResults;

  const _ClusterViewSection({required this.searchResults});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ManageClusterCubit, ManageClusterState>(
      builder: (context, state) {
        return Container(
            height: MediaQuery.of(context).size.height * 0.65,
            padding: const EdgeInsets.all(16),
            // TODO: Add pagination at some point
            child: (searchResults.isNotEmpty)
                ? ListView.builder(
                    itemCount: searchResults.length,
                    itemBuilder: (context, index) {
                      return ManageHouseholdCard(household: searchResults[index]);
                    },
                  )
                : Center(
                    child: Text(ClusterAdminStrings.noHouseholdsFound),
                  ));
      },
    );
  }
}
