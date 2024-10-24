import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:support_sphere/presentation/pages/main_app/manage_resources/new_resource_skill.dart';

class ManageResourcesBody extends StatelessWidget {
  const ManageResourcesBody({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraint) {
      return Column(
        children: [
          Container(
            height: 50,
            child: const Center(
              // TODO: Add profile picture
              child: Text('Manage Resources',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
          ),
          Expanded(
            child: Container(
                height: MediaQuery.sizeOf(context).height,
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    _ButtonFiltersSection(),
                    _TableViewSection()
                  ],
                )),
          )
        ],
      );
    });
  }
}

class _ButtonFiltersSection extends StatelessWidget {
  const _ButtonFiltersSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Column(
          children: [
            const AddNewResourceSkillButton()
          ],
        ),
      ],
    );
  }
}


class _TableViewSection extends StatelessWidget {
  const _TableViewSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: const Center(child: Text("Table of Resources coming soon!")),
    );
  }
}
