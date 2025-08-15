import 'package:flutter/material.dart';
import 'package:geodesy/geodesy.dart';
import 'map_location_picker.dart';

class LocationPickerPage extends StatelessWidget {
  const LocationPickerPage({
    super.key,
    required this.initialLatLong,
    required this.title
  });
  final LatLng initialLatLong;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: MapLocationPicker(
        onPicked: (result) {
          Navigator.pop(context, result);
        },
        initialLatLong: initialLatLong,
      ),
    );
  }
}
