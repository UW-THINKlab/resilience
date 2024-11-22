import 'package:expandable_text/expandable_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:support_sphere/data/models/resource.dart';
import 'package:support_sphere/logic/cubit/manage_resource_cubit.dart';

class ResourceCard extends StatefulWidget {
  final Resource resource;

  const ResourceCard({Key? key, required this.resource}) : super(key: key);

  @override
  _ResourceCardState createState() => _ResourceCardState();
}

class _ResourceCardState extends State<ResourceCard> {
  bool? _isSelected = false;

  void _toggleSelection(value) {
    setState(() {
      _isSelected = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final resourceDescription = widget.resource.description ?? '';
    final resourceName = widget.resource.name;
    return BlocProvider.value(
      value: BlocProvider.of<ManageResourceCubit>(context),
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
                  Container(
                    width: 200,
                    child: Text(
                      resourceName,
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
                      FaIcon(widget.resource.resourceType.icon, size: 15),
                      const SizedBox(width: 4),
                      Text(widget.resource.resourceType.name),
                    ],
                  ),
                  Row(
                    children: [
                      Badge(
                        label:
                            Text("${widget.resource.qtyAvailable} available"),
                        backgroundColor: Colors.blueAccent,
                      ),
                      const SizedBox(width: 4),
                      Badge(
                        label: Text("${widget.resource.qtyNeeded} needed"),
                        backgroundColor: Colors.redAccent,
                      ),
                    ],
                  )
                ],
              )),
          Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.all(8),
            child: Text(resourceDescription),
          ),
          (widget.resource.notes != null && widget.resource.notes!.isNotEmpty)
              ? Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.all(8),
                  child: ExpandableText(
                    widget.resource.notes ?? '',
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
                ElevatedButton(onPressed: () {
                  context.read<ManageResourceCubit>().deleteResource(widget.resource.id);
                }, child: Text("Delete"))
              ],
            ),
          ),
        ],
      )),
    );
  }
}
