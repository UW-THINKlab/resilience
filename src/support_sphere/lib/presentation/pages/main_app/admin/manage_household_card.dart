import 'package:expandable_text/expandable_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:logging/logging.dart' show Logger;
import 'package:support_sphere/constants/color.dart' show ColorConstants;
import 'package:support_sphere/data/models/households.dart';
import 'package:support_sphere/data/models/person.dart' show Person;
import 'package:support_sphere/data/repositories/user.dart' show UserRepository;
import 'package:support_sphere/logic/cubit/manage_cluster_state.dart';

final log = Logger('ManageHouseholdCard');

class ManageHouseholdCard extends StatefulWidget {
  final Household household;

  const ManageHouseholdCard({super.key, required this.household});

  @override
  _HouseholdCardState createState() => _HouseholdCardState();
}

class _HouseholdCardState extends State<ManageHouseholdCard> {
  List<Person> _members = [];

  @override
  void initState() {
    super.initState();
    _fetchMembers();
  }

  Future<void> _fetchMembers() async {
    try {
      final result = await UserRepository()
          .getHouseholdMembersByHouseholdId(widget.household.id);
      if (mounted) {
        setState(() {
          _members = (result?.members ?? []).whereType<Person>().toList();
        });
      }
    } catch (e, st) {
      log.warning(
          'Failed to load members for household ${widget.household.id}: $e\n$st');
    }
  }

  Widget _iconValueRow(Widget icon, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          icon,
          const SizedBox(width: 8),
          Expanded(child: Text(value ?? '')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Icon greyIcon(IconData i) => Icon(i, size: 16, color: Colors.grey[600]);

    return BlocProvider.value(
      value: BlocProvider.of<ManageClusterCubit>(context),
      child: Card(
          color: _members.isEmpty
              ? ColorConstants.warningRed
              : ColorConstants.confirmGreen,
          child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _iconValueRow(greyIcon(Icons.home_outlined), widget.household.name),
            _iconValueRow(greyIcon(Icons.location_searching_outlined),
                widget.household.address),
            _iconValueRow(
              FaIcon(FontAwesomeIcons.peopleRoof,
                  size: 16, color: Colors.grey[600]),
              _members.map((p) => p.name()).join(', '),
            ),
            _iconValueRow(greyIcon(Icons.pets), widget.household.pets),
            _iconValueRow(
                greyIcon(Icons.accessibility), widget.household.accessibilityNeeds),
            (widget.household.notes != null && widget.household.notes!.isNotEmpty)
                ? Container(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(vertical: 5),
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
                : const SizedBox(),
          ],
        ),
      )),
    );
  }
}
