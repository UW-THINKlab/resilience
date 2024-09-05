import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

class ModalEdit extends StatelessWidget {
  const ModalEdit(
      {super.key, required this.parentContext, required this.title, this.body});

  final String title;
  final Widget? body;
  final BuildContext parentContext;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
        appBar: AppBar(
          leading: const SizedBox(),
          actions: [
            IconButton(
              icon: const Icon(Ionicons.close_outline),
              onPressed: () => Navigator.pop(parentContext),
            ),
          ],
          title: Center(child: Text(title)),
        ),
        body: Container(
          padding: const EdgeInsets.all(10),
          child: ListView(
            children: [
              _EditField(title: "Given Name", value: "John"),
              _EditField(title: "Family Name", value: "Doe"),
              _EditField(title: "Phone", value: "+15555555555"),
              _EditField(title: "Email", value: "johndoe@example.com"),
            ],
          ),
        ),
      ),
    );
  }
}

class _EditField extends StatelessWidget {
  const _EditField({super.key, required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      subtitle: TextField(
        controller: TextEditingController()..text = value,
      ),
    );
  }
}
