import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:support_sphere/constants/string_catalog.dart';
import 'package:support_sphere/logic/cubit/resource_cubit.dart';
import 'package:support_sphere/presentation/components/manage_resource_card.dart';
import 'package:support_sphere/presentation/components/resource_card.dart';
import 'package:support_sphere/presentation/components/resource_search_bar.dart';
import 'package:support_sphere/presentation/components/resource_type_filter.dart';

class ResourceBody extends StatelessWidget {
  const ResourceBody({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ResourceCubit(),
      child: const Column(
        children: [
          const SizedBox(height: 16),
          const Center(
            child: Text(ResourceStrings.resourcesInventory,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 16),
          // TODO: Implement Search and Filter
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(child: ResourceSearchBar()),
              Expanded(
                  child: ResourceTypeFilter(
                resourceTypes: [],
                // onSelected: onSelected,
              )),
            ],
          ),
          ResourceTabBar(),
        ],
      ),
    );
  }
}

class ResourceTabBar extends StatefulWidget {
  const ResourceTabBar({super.key});

  @override
  State<ResourceTabBar> createState() => _ResourceTabBarState();
}

class _ResourceTabBarState extends State<ResourceTabBar>
    with TickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Container(
            margin: const EdgeInsets.all(12),
            child: Column(
              children: [
                TabBar(
                  controller: _tabController,
                  tabs: const <Widget>[
                    Tab(
                      text: "All Resources",
                    ),
                    Tab(
                      text: "My Resources",
                    ),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: const <Widget>[
                      AllResourcesTab(),
                      Center(
                        child: Text(ResourceStrings.noResourcesFound),
                      ),
                    ],
                  ),
                ),
              ],
            )),
      ),
    );
  }
}

class AllResourcesTab extends StatelessWidget {
  const AllResourcesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ResourceCubit, ResourceState>(
      builder: (context, state) {
        return Expanded(
          child: ListView.builder(
            itemCount: state.resources.length, // Replace with actual resource count
            itemBuilder: (context, index) {
              final resource = state.resources[index]; // Replace with actual resource
              return ResourceCard(resource: resource);
            },
          ),
        );
      },
    );
  }
}
