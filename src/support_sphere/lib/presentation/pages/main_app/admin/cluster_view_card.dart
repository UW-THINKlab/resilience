import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:support_sphere/data/models/clusters.dart';
import 'package:support_sphere/data/models/person.dart' show Person;
import 'package:support_sphere/presentation/components/people_select_list.dart' show PersonSelectList;
import 'package:support_sphere/presentation/pages/main_app/admin/cluster_edit_form.dart' show ClusterEditForm;

// Information about the CLUSTER
class ClusterViewCard extends StatefulWidget {
  final Cluster cluster;
  final List<Person> members;
  final Function(Map<String,dynamic>) updateCluster;

  ClusterViewCard({super.key,
    required this.cluster,
    required this.updateCluster,
    List<Person>? members
  }): members = members ?? [];


  @override
  ClusterCardState createState() => ClusterCardState();
}

class ClusterCardState extends State<ClusterViewCard> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // detect the card has been clicked on, open the
      // details panel
      onTap: () => showDialog(
        context: context,
        builder: (BuildContext context) => Dialog(
          child: ClusterEditForm(cluster: widget.cluster, updateCluster: widget.updateCluster)
        )
      ),
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
                  child: Row(
                    children: [
                      FaIcon(FontAwesomeIcons.shapes, size: 18),
                      const SizedBox(width: 4),
                      Text(widget.cluster.name ?? "- no name -",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
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
                    Text('Meeting place: ${widget.cluster.meetingPlace}'),
                  ],
                ),
              ],
            )),
            Container(
            padding: const EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text('Notes: ${widget.cluster.notes}'),
                  ],
                ),
              ],
            )),
            Container(
            padding: const EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text('Captains: ${widget.cluster.captains}'),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                      onPressed: () => showDialog<String>(
                        context: context,
                        builder: (BuildContext context) => Dialog.fullscreen(
                          child: PersonSelectList(
                            people: widget.members,
                            onConfirm: (List<Person> updatedCaptains) {
                              widget.updateCluster({'captains': updatedCaptains});
                            })
                        ),
                      ),
                      child: Text("Manage Captains", style: const TextStyle(color: Colors.white)),
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
        //       ElevatedButton(
        //         style: ButtonStyle(
        //           backgroundColor: WidgetStateProperty.all<Color>(Colors.redAccent),
        //         ),
        //         onPressed: () {
        //         context.read<ManageNeighborhoodCubit>().deleteCluster(widget.cluster.id);
        //       }, child: Text("Delete", style: TextStyle(color: Colors.white)))
        //     ],
        //   ),
        // ),
      ],
    )));
  }
}