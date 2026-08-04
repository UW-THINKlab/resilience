import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:support_sphere/data/models/clusters.dart';
import 'package:support_sphere/constants/string_catalog.dart'
    show NeighborhoodStrings;
import 'package:support_sphere/data/models/person.dart' show Person;
import 'package:support_sphere/data/repositories/cluster.dart'
    show ClusterRepository;
import 'package:support_sphere/presentation/pages/main_app/admin/cluster_edit_form.dart'
    show ClusterEditForm;

// Information about the CLUSTER
class ClusterViewCard extends StatefulWidget {
  final Cluster cluster;
  final List<Person> members;
  final Function(Map<String, dynamic>) updateCluster;

  ClusterViewCard(
      {super.key,
      required this.cluster,
      required this.updateCluster,
      List<Person>? members})
      : members = members ?? [];

  @override
  ClusterCardState createState() => ClusterCardState();
}

class ClusterCardState extends State<ClusterViewCard> {
  List<String> _captainNames = [];

  @override
  void initState() {
    super.initState();
    _fetchCaptains();
  }

  Future<void> _fetchCaptains() async {
    try {
      final rows = await ClusterRepository()
          .getCaptainsViewByClusterId(widget.cluster.id);
      if (mounted) {
        setState(() {
          _captainNames = rows.map((r) {
            final nick = r.nickname;
            if (nick != null && nick.isNotEmpty) return nick;
            return '${r.givenName ?? ''} ${r.familyName ?? ''}'.trim();
          }).toList();
        });
      }
    } catch (e, st) {
      log.warning(
          'Failed to load captains for cluster ${widget.cluster.id}: $e\n$st');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        // detect the card has been clicked on, open the
        // details panel
        onTap: () => showDialog(
                context: context,
                builder: (BuildContext context) => Dialog(
                    child: ClusterEditForm(
                        cluster: widget.cluster,
                        updateCluster: widget.updateCluster)))
            .then((_) => _fetchCaptains()),
        child: Card(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Card Header
            Container(
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: [
                    SizedBox(
                      width: 200,
                      child: Row(
                        children: [
                          FaIcon(FontAwesomeIcons.shapes, size: 18),
                          const SizedBox(width: 4),
                          Text(
                            widget.cluster.name ?? "- no name -",
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
                        Text(
                          'Captains: ${_captainNames.isEmpty ? NeighborhoodStrings.captainNeeded : _captainNames.join(', ')}',
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
