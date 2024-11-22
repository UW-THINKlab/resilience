import 'package:expandable_text/expandable_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:support_sphere/constants/string_catalog.dart';
import 'package:support_sphere/data/enums/resource_nav.dart';
import 'package:support_sphere/data/models/resource.dart';
import 'package:support_sphere/logic/bloc/app_bloc.dart';
import 'package:support_sphere/logic/cubit/resource_cubit.dart';

class ResourceCard extends StatelessWidget {
  const ResourceCard({super.key, required this.resource});

  final Resource resource;

  @override
  Widget build(BuildContext context) {
    final resourceDescription = resource.description ?? '';
    final resourceName = resource.name;
    return Card(
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
                    FaIcon(resource.resourceType.icon, size: 15),
                    const SizedBox(width: 4),
                    Text(resource.resourceType.name),
                  ],
                ),
                Row(
                  children: [
                    Badge(
                      label: Text("${resource.qtyAvailable} available"),
                      backgroundColor: Colors.blueAccent,
                    ),
                    const SizedBox(width: 4),
                    Badge(
                      label: Text("${resource.qtyNeeded} needed"),
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
        Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              _INeedThisButton(),
              const SizedBox(width: 8),
              _IHaveThisButton(resource: resource),
            ],
          ),
        ),
      ],
    ));
  }
}

class _INeedThisButton extends StatelessWidget {
  const _INeedThisButton({Key? key}) : super(key: key);

  final String _buttonText = 'I need this';

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      builder: (context, state) {
        return (state.mode == AppModes.normal)
            ? const SizedBox()
            : ElevatedButton(
                onPressed: () {},
                child: Text(_buttonText),
              );
      },
    );
  }
}

class _IHaveThisButton extends StatelessWidget {
  const _IHaveThisButton({Key? key, required this.resource}) : super(key: key);

  final String _buttonText = 'I have this';
  final Resource resource;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      builder: (context, state) {
        void _onPressed() {
          context.read<ResourceCubit>().selectedResourceChanged(resource);
          context.read<ResourceCubit>().currentNavChanged(ResourceNav.addToResourceInventory);
        }

        return ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent
          ),
          onPressed: (state.mode == AppModes.normal) ? _onPressed : null,
          child: Text(_buttonText, style: const TextStyle(color: Colors.white)),
        );
      },
    );
  }
}
