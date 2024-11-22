import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:support_sphere/constants/string_catalog.dart';
import 'package:support_sphere/data/enums/resource_nav.dart';
import 'package:support_sphere/data/models/resource.dart';
import 'package:support_sphere/logic/cubit/resource_cubit.dart';
import 'package:support_sphere/presentation/components/container_card.dart';
import 'package:support_sphere/presentation/components/manage_resource_card.dart';
import 'package:support_sphere/presentation/components/resource_card.dart';
import 'package:support_sphere/presentation/components/resource_search_bar.dart';
import 'package:support_sphere/presentation/components/resource_type_filter.dart';
import 'package:support_sphere/presentation/pages/main_app/resource/add_to_inventory_form.dart';

class ResourceBody extends StatelessWidget {
  const ResourceBody({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ResourceCubit(),
      child: BlocBuilder<ResourceCubit, ResourceState>(
        buildWhen: (previous, current) =>
            previous.currentNav != current.currentNav,
        builder: (context, state) {
          switch (state.currentNav) {
            case ResourceNav.showAllResources:
              return Column(
                children: [
                  const SizedBox(height: 16),
                  const Center(
                    child: Text(ResourceStrings.resourcesInventory,
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
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
                  Expanded(
                      child: ResourceTabBar(
                          initialTabIndex: state.initialTabIndex)),
                ],
              );
            case ResourceNav.addToResourceInventory:
              return AddToResourceView();
            case ResourceNav.savedResourceInventory:
              return AddToResourceThankYou();
            case ResourceNav.requestResource:
              // TODO: Handle this case.
              return const SizedBox();
          }
        },
      ),
    );
  }
}

class ResourceTabBar extends StatefulWidget {
  const ResourceTabBar({super.key, this.initialTabIndex = 0});

  final int initialTabIndex;

  @override
  State<ResourceTabBar> createState() => _ResourceTabBarState();
}

class _ResourceTabBarState extends State<ResourceTabBar>
    with TickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
        initialIndex: widget.initialTabIndex, length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
          margin: const EdgeInsets.all(12),
          child: Column(
            children: [
              TabBar(
                controller: _tabController,
                onTap: (index) {
                  context.read<ResourceCubit>().initialTabIndexChanged(index);
                },
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
    );
  }
}

class AllResourcesTab extends StatelessWidget {
  const AllResourcesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ResourceCubit, ResourceState>(
      builder: (context, state) {
        return ListView.builder(
          itemCount:
              state.resources.length, // Replace with actual resource count
          itemBuilder: (context, index) {
            final resource =
                state.resources[index]; // Replace with actual resource
            return ResourceCard(resource: resource);
          },
        );
      },
    );
  }
}

class AddToResourceView extends StatelessWidget {
  const AddToResourceView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ResourceCubit, ResourceState>(
      builder: (context, state) {
        Resource resource = state.selectedResource!;
        return Column(children: [
          Expanded(
              child: Container(
            width: MediaQuery.of(context).size.width,
            margin: const EdgeInsets.all(15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Back button
                AllResourcesButton(),

                /// Form card
                Expanded(
                    child: ContainerCard(
                  child: AddToInventoryForm(resource: resource),
                )),
              ],
            ),
          ))
        ]);
      },
    );
  }
}

class AddToResourceThankYou extends StatelessWidget {
  const AddToResourceThankYou({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ResourceCubit, ResourceState>(
      builder: (context, state) {
        Resource resource = state.selectedResource!;
        return Column(children: [
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
                    ResourceStrings.allResources,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onPressed: () {
                    context
                        .read<ResourceCubit>()
                        .currentNavChanged((ResourceNav.showAllResources));
                  },
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ContainerCard(
                    child: Column(
                      children: [
                        const Center(
                          child: Text(
                            "Thank You",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          children: [
                            Text(AddResourceInventoryFormStrings.thankYouText(
                                resource.name))
                          ],
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                            onPressed: () {
                              context.read<ResourceCubit>().currentNavChanged(
                                  (ResourceNav.showAllResources));
                            },
                            child: Text("Done"))
                      ],
                    ),
                  ),
                )
              ],
            ),
          ))
        ]);
      },
    );
  }
}

class AllResourcesButton extends StatelessWidget {
  const AllResourcesButton({super.key});

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      icon: const Icon(Icons.arrow_back),
      label: const Text(
        ResourceStrings.allResources,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      onPressed: () {
        context
            .read<ResourceCubit>()
            .currentNavChanged((ResourceNav.showAllResources));
      },
    );
  }
}
