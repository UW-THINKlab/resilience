import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:support_sphere/constants/string_catalog.dart';
import 'package:support_sphere/data/enums/resource_nav.dart';
import 'package:support_sphere/data/models/auth_user.dart';
import 'package:support_sphere/data/models/resource.dart';
import 'package:support_sphere/logic/bloc/auth/authentication_bloc.dart';
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
    final AuthUser authUser = context.select(
      (AuthenticationBloc bloc) => bloc.state.user,
    );
    return BlocProvider(
      create: (context) => ResourceCubit(authUser),
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
                    UserResourcesTab(),
                  ],
                ),
              ),
            ],
          )),
    );
  }
}

// All Resources Tab
class AllResourcesTab extends StatelessWidget {
  const AllResourcesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ResourceCubit, ResourceState>(
      builder: (context, state) {
        if (state.resources.isEmpty) {
          return const Center(
            child: Text("No resources found"),
          );
        }
        return ListView.builder(
          itemCount: state.resources.length,
          itemBuilder: (context, index) {
            final resource = state.resources[index];
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

// My Resources Tab
class UserResourcesTab extends StatelessWidget {
  const UserResourcesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ResourceCubit, ResourceState>(
      builder: (context, state) {
        if (state.userResources.isEmpty) {
          return const Center(
            child: Text(ResourceStrings.noUserResources),
          );
        }
        return ListView.builder(
          itemCount:
              state.userResources.length, // Replace with actual resource count
          itemBuilder: (context, index) {
            final userResource =
                state.userResources[index]; // Replace with actual resource
            return ContainerCard(
              color: Colors.grey[300],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Card Header
                  Center(
                      child: Text(
                    userResource.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  )),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Row(children: [
                        FaIcon(userResource.resourceType.icon, size: 15),
                        const SizedBox(width: 4),
                        Text(userResource.resourceType.name),
                      ]),
                      const SizedBox(width: 8),
                      Row(
                        children: [
                          FaIcon(FontAwesomeIcons.calendar, size: 15),
                          const SizedBox(width: 4),
                          Text(
                              "Added on ${DateFormat.yMMMd('en').format(userResource.addedDate!)}"),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text("Quantity: ${userResource.qtyAvailable}"),
                  const SizedBox(height: 8),
                  // TODO: Implement Subtype
                  Text("Subtype: None"),
                  const SizedBox(height: 8),
                  Text("Notes: ${userResource.notes}"),
                  const SizedBox(height: 8),
                  Text("Reviewed by: ${userResource.reviewedDate}"),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                      style: ButtonStyle(
                          backgroundColor:
                              WidgetStateProperty.all(Colors.greenAccent)),
                      icon: const FaIcon(FontAwesomeIcons.circleCheck),
                      iconAlignment: IconAlignment.end,
                      onPressed: () {},
                      label: Text("Mark as up to date")),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                      style: ButtonStyle(
                          backgroundColor:
                              WidgetStateProperty.all(Colors.redAccent)),
                      onPressed: () {},
                      label: const Text(
                        "Delete Item",
                        style: TextStyle(color: Colors.white),
                      ))
                ],
              ),
            );
          },
        );
      },
    );
  }
}
