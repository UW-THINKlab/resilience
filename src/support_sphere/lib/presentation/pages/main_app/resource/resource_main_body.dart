// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:support_sphere/constants/color.dart';
import 'package:support_sphere/constants/string_catalog.dart';
import 'package:support_sphere/constants/text_styles.dart';
import 'package:support_sphere/data/enums/resource_nav.dart';
import 'package:support_sphere/data/models/auth_user.dart';
import 'package:support_sphere/data/models/generated_classes.dart';
import 'package:support_sphere/data/models/resource.dart';
import 'package:support_sphere/data/models/user_resource.dart';
import 'package:support_sphere/logic/bloc/auth/authentication_bloc.dart';
import 'package:support_sphere/logic/cubit/resource_cubit.dart';
import 'package:support_sphere/presentation/components/cancel_button.dart';
import 'package:support_sphere/presentation/components/confirm_button.dart';
import 'package:support_sphere/presentation/components/confirmation_dialog.dart';
import 'package:support_sphere/presentation/components/container_card.dart';
import 'package:support_sphere/presentation/components/manage_resource_card.dart';
import 'package:support_sphere/presentation/components/resource_card.dart';
import 'package:support_sphere/presentation/components/filter_search_bar.dart';
import 'package:support_sphere/presentation/components/resource_type_filter.dart';
import 'package:support_sphere/presentation/components/selection_toolbar.dart';
import 'package:support_sphere/presentation/components/snackbars.dart';
import 'package:support_sphere/data/models/resource_types.dart';
import 'package:support_sphere/presentation/pages/main_app/resource/add_to_inventory_form.dart';
import 'package:support_sphere/presentation/pages/main_app/resource/request_resource_form.dart';

class ResourceBody extends StatelessWidget {
  const ResourceBody({super.key});

  @override
  Widget build(BuildContext context) {
    final MyAuthUser authUser = context.select(
      (AuthenticationBloc bloc) => bloc.state.user,
    );
    return BlocProvider(
      create: (context) => ResourceCubit(authUser),
      child: BlocBuilder<ResourceCubit, ResourceState>(
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
                  FilterSearchBar(
                    labelText: ResourceStrings.searchResources,
                    onQueryChanged: (query) => context
                        .read<ResourceCubit>()
                        .searchQueryChanged(query),
                  ),
                  const SizedBox(height: 8),
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
              return RequestResourceView();
            case ResourceNav.savedRequest:
              //TODO- currently the request form does not have a thank you/confirmation page, so we just go back to the all resources tab
              return AllResourcesTab();
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
        final query = state.searchQuery.trim().toLowerCase();
        final resources = query.isEmpty
            ? state.resources
            : state.resources
                .where((r) => r.name.toLowerCase().contains(query))
                .toList();
        if (resources.isEmpty) {
          return const Center(
            child: Text(ResourceStrings.noResourcesFound),
          );
        }
        return ListView.builder(
          itemCount: resources.length,
          itemBuilder: (context, index) {
            final resource = resources[index];
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
                        Center(
                          child: Text(
                            AddResourceInventoryFormStrings.thankYou,
                            style: const TextStyle(
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
                            child: Text(AddResourceInventoryFormStrings.done))
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

class RequestResourceView extends StatelessWidget {
  const RequestResourceView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ResourceCubit, ResourceState>(
      builder: (context, state) {
        final Resource resource = state.selectedResource!;
        return Column(
          children: [
            Expanded(
              child: Container(
                width: MediaQuery.of(context).size.width,
                margin: const EdgeInsets.all(15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AllResourcesButton(),
                    Expanded(
                      child: ContainerCard(
                        child: RequestResourceForm(
                          resourceCv: resource.resourceCv,
                          resourceType: resource.resourceType,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

Future<bool> _confirmDelete(
  BuildContext context,
  ResourceCubit cubit,
  List<String> ids,
  List<int> itemNumbers,
) async {
  final idsWithReservations =
      await cubit.getUserResourceIdsWithReservations(ids);
  final numbersWithReservations = <int>[
    for (var i = 0; i < ids.length; i++)
      if (idsWithReservations.contains(ids[i])) itemNumbers[i],
  ];
  final message = numbersWithReservations.isEmpty
      ? ResourceStrings.deleteConfirm(itemNumbers)
      : ResourceStrings.deleteConfirmWithReservations(numbersWithReservations);
  if (!context.mounted) return false;
  final confirmed = await ConfirmationDialog(
    actions: [
      CancelButton(
        label: 'Cancel',
        onPressed: () => Navigator.of(context).pop(false),
      ),
      ConfirmButton(
        label: 'Delete',
        color: ColorConstants.dangerRed,
        onPressed: () => Navigator.of(context).pop(true),
      ),
    ],
    content: Text(message),
  ).show<bool>(context);
  return confirmed ?? false;
}

///////////////////////////////////////////////////////////////////////////////
// My Resources Tab
///////////////////////////////////////////////////////////////////////////////
class UserResourcesTab extends StatefulWidget {
  const UserResourcesTab({super.key});

  @override
  State<UserResourcesTab> createState() => _UserResourcesTabState();
}

class _UserResourcesTabState extends State<UserResourcesTab> {
  final Map<String, int> _draftQuantities = {};
  final Map<String, String> _draftNotes = {};
  final Map<String, SHARING_SCOPES> _draftSharingScopes = {};
  final Map<String, SHARING_SCOPES> _draftSharingScopeEmergencies = {};

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ResourceCubit, ResourceState>(
      buildWhen: (previous, current) =>
          previous.userResources != current.userResources ||
          previous.selectionMode != current.selectionMode ||
          previous.selectedUserResourceIds != current.selectedUserResourceIds ||
          previous.searchQuery != current.searchQuery,
      builder: (context, state) {
        final cubit = context.read<ResourceCubit>();
        final query = state.searchQuery.trim().toLowerCase();
        final userResources = query.isEmpty
            ? state.userResources
            : state.userResources
                .where((r) => r.name.toLowerCase().contains(query))
                .toList();
        return Column(
          children: [
            SelectionToolbar(
              selectionMode: state.selectionMode,
              selectedCount: state.selectedUserResourceIds.length,
              allSelected: userResources.isNotEmpty &&
                  userResources.every(
                      (r) => state.selectedUserResourceIds.contains(r.id)),
              onToggleSelectionMode: cubit.toggleSelectionMode,
              onToggleSelectAll: () {
                final allIds = userResources.map((r) => r.id).toSet();
                final allSelected = allIds.isNotEmpty &&
                    allIds.every(state.selectedUserResourceIds.contains);
                cubit.setSelectedUserResourceIds(allSelected ? {} : allIds);
              },
              actions: [
                SelectionAction(
                  icon: Icons.check_circle,
                  label: ResourceStrings.update,
                  onPressed: () async {
                    final edits = userResources
                        .where((r) =>
                            state.selectedUserResourceIds.contains(r.id))
                        .map((r) => (
                              id: r.id,
                              quantity:
                                  _draftQuantities[r.id] ?? r.qtyAvailable,
                              notes: _draftNotes[r.id] ?? r.notes,
                              sharingScope:
                                  _draftSharingScopes[r.id] ?? r.sharingScope,
                              sharingScopeEmergency:
                                  _draftSharingScopeEmergencies[r.id] ??
                                      r.sharingScopeEmergency,
                            ))
                        .toList();
                    await cubit.bulkUpdateUserResources(edits);
                    if (!context.mounted) return;
                    showSuccessSnackBar(context,
                        ResourceStrings.bulkUpdateSuccess(edits.length));
                  },
                ),
                SelectionAction(
                  icon: Icons.delete,
                  label: SelectionToolbarStrings.delete,
                  onPressed: () async {
                    final ids = state.selectedUserResourceIds.toList();
                    final itemNumbers = ids
                        .map((id) =>
                            userResources.indexWhere((r) => r.id == id) + 1)
                        .toList();
                    final confirmed =
                        await _confirmDelete(context, cubit, ids, itemNumbers);
                    if (confirmed) {
                      await cubit.deleteSelected();
                      if (!context.mounted) return;
                      showSuccessSnackBar(context,
                          ResourceStrings.bulkDeleteSuccess(ids.length));
                    }
                  },
                ),
              ],
            ),
            Expanded(
              child: userResources.isEmpty
                  ? const Center(child: Text(ResourceStrings.noUserResources))
                  : ListView.builder(
                      itemCount: userResources.length,
                      itemBuilder: (context, index) {
                        final userResource = userResources[index];
                        return _UserResourceCard(
                          key: ValueKey(userResource.id),
                          userResource: userResource,
                          itemNumber: index + 1,
                          selectionMode: state.selectionMode,
                          selected: state.selectedUserResourceIds
                              .contains(userResource.id),
                          onQuantityChanged: (value) =>
                              _draftQuantities[userResource.id] = value,
                          onNotesChanged: (value) =>
                              _draftNotes[userResource.id] = value,
                          onSharingScopeChanged: (value) =>
                              _draftSharingScopes[userResource.id] = value,
                          onSharingScopeEmergencyChanged: (value) =>
                              _draftSharingScopeEmergencies[userResource.id] =
                                  value,
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}

final List<DropdownMenuItem<SHARING_SCOPES>> _sharingScopeDropdownItems =
    SHARING_SCOPES.values
        .map((scope) => DropdownMenuItem(
              value: scope,
              child: Text(scope.displayName),
            ))
        .toList();

class _UserResourceCard extends StatefulWidget {
  const _UserResourceCard({
    super.key,
    required this.userResource,
    required this.itemNumber,
    required this.selectionMode,
    required this.selected,
    required this.onQuantityChanged,
    required this.onNotesChanged,
    required this.onSharingScopeChanged,
    required this.onSharingScopeEmergencyChanged,
  });

  final UserResource userResource;
  final int itemNumber;
  final bool selectionMode;
  final bool selected;
  final ValueChanged<int> onQuantityChanged;
  final ValueChanged<String> onNotesChanged;
  final ValueChanged<SHARING_SCOPES> onSharingScopeChanged;
  final ValueChanged<SHARING_SCOPES> onSharingScopeEmergencyChanged;

  @override
  State<_UserResourceCard> createState() => _UserResourceCardState();
}

class _UserResourceCardState extends State<_UserResourceCard> {
  late final TextEditingController _quantityController;
  late final TextEditingController _notesController;
  late SHARING_SCOPES _sharingScope;
  late SHARING_SCOPES _sharingScopeEmergency;

  @override
  void initState() {
    super.initState();
    _quantityController = TextEditingController(
        text: widget.userResource.qtyAvailable.toString());
    _notesController =
        TextEditingController(text: widget.userResource.notes ?? '');
    _sharingScope = widget.userResource.sharingScope;
    _sharingScopeEmergency = widget.userResource.sharingScopeEmergency;
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save(ResourceCubit cubit) async {
    final quantity = int.tryParse(_quantityController.text) ??
        widget.userResource.qtyAvailable;
    await cubit.updateUserResource(
      id: widget.userResource.id,
      quantity: quantity,
      notes: _notesController.text,
      sharingScope: _sharingScope,
      sharingScopeEmergency: _sharingScopeEmergency,
    );
    if (!mounted) return;
    showSuccessSnackBar(context, ResourceStrings.updateSuccess);
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ResourceCubit>();
    final userResource = widget.userResource;
    return GestureDetector(
      onTap: widget.selectionMode
          ? () => cubit.toggleUserResourceSelected(userResource.id)
          : null,
      onLongPress: widget.selectionMode
          ? null
          : () => cubit.enterSelectionModeAndSelect(userResource.id),
      child: ContainerCard(
        color: widget.selected
            ? userResource.resourceType.baseColor[200]
            : userResource.resourceType.baseColor[100],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card Header
            Row(
              children: [
                if (widget.selectionMode)
                  Checkbox(
                    value: widget.selected,
                    onChanged: (_) =>
                        cubit.toggleUserResourceSelected(userResource.id),
                  ),
                Text(
                  ResourceStrings.itemLabel(widget.itemNumber),
                  style: TextStyleConstants.cardTitle,
                ),
                const SizedBox(width: 8),
                Text(
                  userResource.name,
                  style: TextStyleConstants.cardTitle,
                ),
              ],
            ),
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
                    Text(ResourceStrings.addedOnDate(userResource.addedDate!)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _quantityController,
              keyboardType: TextInputType.number,
              onChanged: (value) => widget.onQuantityChanged(
                  int.tryParse(value) ?? widget.userResource.qtyAvailable),
              decoration:
                  const InputDecoration(labelText: ResourceStrings.quantity),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _notesController,
              minLines: 1,
              maxLines: 3,
              onChanged: widget.onNotesChanged,
              decoration:
                  const InputDecoration(labelText: ResourceStrings.notes),
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  Text(ResourceStrings.whoCanRequestLabel),
                  const SizedBox(width: 4),
                  DropdownButton<SHARING_SCOPES>(
                    key: ValueKey('sharing_scope_$_sharingScope'),
                    value: _sharingScope,
                    items: _sharingScopeDropdownItems,
                    onChanged: (value) {
                      setState(() => _sharingScope = value!);
                      widget.onSharingScopeChanged(value!);
                      FocusManager.instance.primaryFocus?.unfocus();
                    },
                  ),
                  const SizedBox(width: 16),
                  Text(ResourceStrings.whoCanRequestEmergencyLabel),
                  const SizedBox(width: 4),
                  DropdownButton<SHARING_SCOPES>(
                    key: ValueKey(
                        'sharing_scope_emergency_$_sharingScopeEmergency'),
                    value: _sharingScopeEmergency,
                    items: _sharingScopeDropdownItems,
                    onChanged: (value) {
                      setState(() => _sharingScopeEmergency = value!);
                      widget.onSharingScopeEmergencyChanged(value!);
                      FocusManager.instance.primaryFocus?.unfocus();
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text("Updated: ${userResource.reviewedDate}"),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                    style: ButtonStyle(
                        backgroundColor:
                            WidgetStateProperty.all(Colors.greenAccent)),
                    icon: const FaIcon(FontAwesomeIcons.circleCheck),
                    onPressed: () => _save(cubit),
                    label: const Text(ResourceStrings.update)),
                ElevatedButton.icon(
                    style: ButtonStyle(
                        backgroundColor:
                            WidgetStateProperty.all(Colors.redAccent)),
                    icon: const Icon(Icons.delete, color: Colors.white),
                    onPressed: () async {
                      final confirmed = await _confirmDelete(context, cubit,
                          [userResource.id], [widget.itemNumber]);
                      if (confirmed) {
                        await cubit.deleteUserResource(userResource.id);
                        if (!context.mounted) return;
                        showSuccessSnackBar(
                            context, ResourceStrings.deleteSuccess);
                      }
                    },
                    label: const Text(
                      ResourceStrings.delete,
                      style: TextStyle(color: Colors.white),
                    )),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
