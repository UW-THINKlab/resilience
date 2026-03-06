import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:support_sphere/data/models/clusters.dart';
import 'package:support_sphere/logic/cubit/manage_neighborhood_cubit.dart' show ManageNeighborhoodCubit;

// Information about the CLUSTER
class ManageClusterCard extends StatefulWidget {
  final Cluster cluster;

  const ManageClusterCard({super.key, required this.cluster});

  @override
  _ClusterCardState createState() => _ClusterCardState();
}

class _ClusterCardState extends State<ManageClusterCard> {

  @override
  Widget build(BuildContext context) {
    //final resourceDescription = widget.resource.description ?? '';
    //final resourceName = widget.resource.name;
    return BlocProvider.value(
      value: BlocProvider.of<ManageNeighborhoodCubit>(context),
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
                    child: Text(widget.cluster.name ?? "- no name -",
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
                      Text('widget.resource.resourceType.name'),
                    ],
                  ),
                  Row(
                    children: [
                      Badge(
                        label:
                            Text(" available"),
                        backgroundColor: Colors.blueAccent,
                      ),
                      const SizedBox(width: 4),
                      Badge(
                        label: Text("widget.resource.qtyNeeded needed"),
                        backgroundColor: Colors.redAccent,
                      ),
                    ],
                  )
                ],
              )),
          Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.all(8),
            child: Text('resourceDescription'),
          ),
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
                  context.read<ManageNeighborhoodCubit>().deleteCluster(widget.cluster.id);
                }, child: Text("Delete", style: TextStyle(color: Colors.white)))
              ],
            ),
          ),
        ],
      )),
    );
  }
}
