import 'package:expandable_text/expandable_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:support_sphere/data/models/households.dart';
import 'package:support_sphere/logic/cubit/manage_cluster_state.dart';

class ManageHouseholdCard extends StatefulWidget {
  final Household household;

  const ManageHouseholdCard({super.key, required this.household});

  @override
  _HouseholdCardState createState() => _HouseholdCardState();
}

class _HouseholdCardState extends State<ManageHouseholdCard> {


  @override
  Widget build(BuildContext context) {
    final description = widget.household.address ?? '';
    final name = widget.household.name ?? '';
    return BlocProvider.value(
      value: BlocProvider.of<ManageClusterCubit>(context),
      child: Card(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // Card Header
          Container(
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
                      name,
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
                      FaIcon(FontAwesomeIcons.house, size: 15),
                      const SizedBox(width: 4),
                      Text(description),
                    ],
                  ),
                  Row(
                    children: [
                      Badge(
                        label:
                            Text("${widget.household.pets} available"),
                        backgroundColor: Colors.blueAccent,
                      ),
                      const SizedBox(width: 4),
                      Badge(
                        label: Text("${widget.household.accessibilityNeeds} needed"),
                        backgroundColor: Colors.redAccent,
                      ),
                    ],
                  )
                ],
              )),
          Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.all(8),
            child: Text(description),
          ),
          (widget.household.notes != null && widget.household.notes!.isNotEmpty)
              ? Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.all(8),
                  child: ExpandableText(
                    widget.household.notes ?? '',
                    prefixText: "Notes: ",
                    expandText: 'show more',
                    collapseText: 'show less',
                    expandOnTextTap: true,
                    collapseOnTextTap: true,
                    maxLines: 2,
                    linkColor: Colors.blue,
                  ),
                )
              : SizedBox(),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                // TODO: Implement ElevatedButton for editing
                // ElevatedButton(
                //   child: const Text('Edit'),
                //   onPressed: null,
                // ),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all<Color>(Colors.redAccent),
                  ),
                  onPressed: () {
                  context.read<ManageClusterCubit>().deleteHousehold(widget.household.id);
                }, child: Text("Delete", style: TextStyle(color: Colors.white)))
              ],
            ),
          ),
        ],
      )),
    );
  }
}
