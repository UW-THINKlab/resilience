import 'package:expandable_text/expandable_text.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ionicons/ionicons.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:support_sphere/data/models/resource.dart';
import 'package:support_sphere/presentation/components/resource_card.dart';
import 'package:support_sphere/logic/cubit/manage_resource_cubit.dart';

class ManageResourcesBody extends StatelessWidget {
  const ManageResourcesBody({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ManageResourceCubit(),
      child: Column(
        children: [
          Container(
            height: 50,
            child: const Center(
              // TODO: Add profile picture
              child: Text('Manage Resources',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
          ),
          Container(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [_ButtonFiltersSection(), _ResourceViewSection()],
              )),
        ],
      ),
    );
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
            // TODO: Add new resource button
            // const AddNewResourceSkillButton()
          ],
        ),
      ],
    );
  }
}

class _ResourceViewSection extends StatelessWidget {
  const _ResourceViewSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ManageResourceCubit, ManageResourceState>(
      builder: (context, state) {
        return Container(
            height: MediaQuery.sizeOf(context).height * 0.7,
            child: ListView.builder(
              itemCount: state.resources.length,
              itemBuilder: (context, index) {
                final resource = state.resources[index];
                final resourceDescription = resource.description ?? '';

                return ResourceCard(resource: resource);
              },
            ));
      },
    );
  }
}
