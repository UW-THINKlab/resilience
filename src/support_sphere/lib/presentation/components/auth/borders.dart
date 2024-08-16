import 'package:flutter/material.dart';

border(BuildContext context) {
  return const OutlineInputBorder(
    borderRadius: BorderRadius.all(
      Radius.circular(30.0),
    ),
    borderSide: BorderSide(
      color: Colors.white,
      width: 0.0,
    ),
  );
}

focusBorder(BuildContext context) {
  return OutlineInputBorder(
    borderRadius: const BorderRadius.all(
      Radius.circular(30.0),
    ),
    borderSide: BorderSide(
      color: Theme.of(context).colorScheme.secondary,
      width: 1.0,
    ),
  );
}