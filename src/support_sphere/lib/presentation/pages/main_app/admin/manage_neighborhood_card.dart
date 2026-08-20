import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:support_sphere/constants/appconfig.dart';
import 'package:support_sphere/constants/string_catalog.dart'
    show NeighborhoodStrings;
import 'package:support_sphere/logic/cubit/manage_neighborhood_state.dart';
import 'package:support_sphere/presentation/pages/main_app/admin/neighborhood_edit_form.dart'
    show NeighborhoodEditForm;

class ManageNeighborhoodCard extends StatefulWidget {
  const ManageNeighborhoodCard({super.key});

  @override
  _NeighborhoodCardState createState() => _NeighborhoodCardState();
}

class _NeighborhoodCardState extends State<ManageNeighborhoodCard> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: BlocProvider.of<ManageNeighborhoodCubit>(context),
      child: BlocBuilder<ManageNeighborhoodCubit, ManageNeighborhoodState>(
        builder: (context, state) {
          final adminNames = state.admins.map((p) => p.name()).toList();
          final cubit = context.read<ManageNeighborhoodCubit>();
          return GestureDetector(
            onTap: () => showDialog(
              context: context,
              builder: (dialogContext) => Dialog(
                child: NeighborhoodEditForm(
                  admins: state.admins,
                  updateAdmins: (admins) =>
                      cubit.upsertNeighborhoodAdmins(admins),
                ),
              ),
            ),
            child: Card(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // Card Header
                Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      children: [
                        // TODO: Implement Checkbox for selection
                        // Checkbox(
                        //   value: _isSelected,
                        //   onChanged: (value) => _toggleSelection(value),
                        // ),
                        SizedBox(
                          width: 200,
                          child: Text(
                            AppConfig.neighborhood,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      ],
                    )),
                Container(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            // FIXME FaIcon(widget.resource.resourceType.icon, size: 15),
                            const SizedBox(width: 4),
                            // FIXME: Values here need to be determined in ManageNeighborhoodCubit
                            // probably a Neighborhood structure: all clusters, metadata.
                            Text('''
                        Households: 2025
                        Clusters: 100
                        Clusters without captains: 26
                        '''),
                          ],
                        ),
                        // Row(
                        //   children: [
                        //     Badge(
                        //       label: Text(" available"),
                        //       backgroundColor: Colors.blueAccent,
                        //     ),
                        //     const SizedBox(width: 4),
                        //     Badge(
                        //       label: Text("widget.resource.qtyNeeded needed"),
                        //       backgroundColor: Colors.redAccent,
                        //     ),
                        //   ],
                        // )
                      ],
                    )),
                Container(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Admins: ${adminNames.isEmpty ? NeighborhoodStrings.adminNeeded : adminNames.join(', ')}',
                            ),
                          ],
                        ),
                      ],
                    )),
                // Container(
          //   alignment: Alignment.centerLeft,
          //   padding: const EdgeInsets.all(8),
          //   child: Text('resourceDescription'),
          // ),
          // (widget.resource.notes != null && widget.resource.notes!.isNotEmpty)
          //     ? Container(
          //         alignment: Alignment.centerLeft,
          //         padding: const EdgeInsets.all(8),
          //         child: ExpandableText(
          //           widget.resource.notes ?? '',
          //           prefixText: "Notes: ",
          //           expandText: 'show more',
          //           collapseText: 'show less',
          //           expandOnTextTap: true,
          //           collapseOnTextTap: true,
          //           maxLines: 2,
          //           linkColor: Colors.blue,
          //         ),
          //       )
          //     : SizedBox(),
          // Padding(
          //   padding: const EdgeInsets.all(8),
          //   child: Row(
          //     mainAxisAlignment: MainAxisAlignment.end,
          //     children: <Widget>[
          //       // TODO: Implement ElevatedButton for editing
          //       // ElevatedButton(
          //       //   child: const Text('Edit'),
          //       //   onPressed: null,
          //       // ),
          //       const SizedBox(width: 8),
          //       // ElevatedButton(
          //       //   style: ButtonStyle(
          //       //     backgroundColor: WidgetStateProperty.all<Color>(Colors.redAccent),
          //       //   ),
          //       //   onPressed: () {
          //       //   context.read<ManageNeighborhoodCubit>().deleteNeighborhood(widget.cluster.id);
          //       // }, child: Text("Delete", style: TextStyle(color: Colors.white)))
          //     ],
          //   ),
          // ),
              ],
            )),
          );
        },
      ),
    );
  }
}
