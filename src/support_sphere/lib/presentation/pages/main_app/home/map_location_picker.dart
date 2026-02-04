import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
//import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';

/// Change the Map Tiles for OSM
enum MapType { normal, satelite }

/// Location Result contains:
/// * [latitude] as [double]
/// * [longitude] as [double]
/// * [completeAddress] as [String]
/// * [placemark] as [Placemark]
class LocationResult {
  /// the latitude of the picked location
  LatLng? latLng;

  /// the longitude of the picked location
  //double? longitude;

  /// the complete address of the picked location
  String? completeAddress;

  /// the location name of the picked location
  String? locationName;

  /// the placemark infomation of the picked location
  //Placemark? placemark;

  LocationResult(
      {required this.latLng,
      //required this.longitude,
      required this.completeAddress,
      //required this.placemark,
      required this.locationName});
}

class MapLocationPicker extends StatefulWidget {
  /// The initial location
  final LatLng? initialLatLong;
  //final double? initialLongitude;

  /// The initial latitude
  //final double? initialLatitude;

  /// callback when location is picked
  final Function(LocationResult onPicked) onPicked;
  final Color? backgroundColor;

  /// The setLocaleIdentifier with the localeIdentifier parameter can be used to
  /// enforce the results to be formatted (and translated) according to the specified
  /// locale. The localeIdentifier should be formatted using the syntax:
  /// [languageCode]_[countryCode].
  /// Use the ISO 639-1 or ISO 639-2 standard for the language code and the 2 letter
  /// ISO 3166-1 standard for the country code.
  final String? locale;

  final Color? indicatorColor;
  final Color? sideButtonsColor;
  final Color? sideButtonsIconColor;

  final TextStyle? locationNameTextStyle;
  final TextStyle? addressTextStyle;
  final TextStyle? searchTextStyle;
  final TextStyle? buttonTextStyle;
  final Widget? centerWidget;
  final double? initialZoom;
  final Color? buttonColor;
  final String? buttonText;
  final Widget? leadingIcon;
  final InputDecoration? searchBarDecoration;
  final bool myLocationButtonEnabled;
  final bool zoomButtonEnabled;
  final bool searchBarEnabled;
  final bool switchMapTypeEnabled;
  final MapType? mapType;
  final Widget Function(LocationResult locationResult)? customButton;
  final Widget Function(
      LocationResult locationResult, MapController mapController)? customFooter;
  final Widget Function(
      LocationResult locationResult, MapController mapController)? sideWidget;

  /// [onPicked] action on click select Location
  /// [initialLatitude] the latitude of the initial location
  /// [initialLongitude] the longitude of the initial location
  const MapLocationPicker(
      {super.key,
      required this.initialLatLong,
      //required this.initialLongitude,
      required this.onPicked,
      this.backgroundColor,
      this.indicatorColor,
      this.addressTextStyle,
      this.searchTextStyle,
      this.centerWidget,
      this.buttonColor,
      this.buttonText,
      this.leadingIcon,
      this.searchBarDecoration,
      this.myLocationButtonEnabled = true,
      this.searchBarEnabled = false,
      this.sideWidget,
      this.customButton,
      this.customFooter,
      this.buttonTextStyle,
      this.zoomButtonEnabled = false,
      this.initialZoom,
      this.switchMapTypeEnabled = false,
      this.mapType,
      this.sideButtonsColor,
      this.sideButtonsIconColor,
      this.locationNameTextStyle,
      this.locale});

  @override
  State<MapLocationPicker> createState() => _MapLocationPickerState();
}

class _MapLocationPickerState extends State<MapLocationPicker> {
  bool _error = false;
  bool _move = false;
  Timer? _timer;
  final MapController _controller = MapController();
  //final List<Location> _locationList = [];
  MapType _mapType = MapType.normal;

  LocationResult? _locationResult;

  LatLng latLng = LatLng(47.661322762238285, -122.2772993912835);

  @override
  void initState() {
    super.initState();
    latLng = widget.initialLatLong ?? latLng;
    //_latitude = widget.initialLatitude ?? _latitude;
    //_longitude = widget.initialLongitude ?? _longitude;

    if (widget.mapType != null) {
      _mapType = widget.mapType!;
    }
    _setupInitalLocation();
  }

  Future<void> _setupInitalLocation() async {
    if (widget.locale != null) {
      //await setLocaleIdentifier(widget.locale!);
    }
    _locationResult = LocationResult(
        latLng: latLng,
        //longitude: _longitude,
        completeAddress: null,
        locationName: null);
    //placemark: null);
    _getLocationResult();
  }

  Future<void> _getLocationResult() async {
    _locationResult = await getLocationResult(latLng);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    Widget searchBar() {
      return widget.searchBarEnabled
          ? Column(
              children: [
                TextField(
                  style: widget.searchTextStyle,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (value) async {
                    if (value.isNotEmpty) {
                      _error = false;
                      setState(() {});
                      //try {
                      //_locationList.clear();
                      //_locationList.addAll(await locationFromAddress(value));

                      //if (_locationList.isNotEmpty) {
                      //} else {
                      //  _error = true;
                      //}
                      //} catch (e) {
                      //  _error = true;
                      //}
                      setState(() {});
                    } else {
                      //_locationList.clear();
                      _error = false;
                      setState(() {});
                    }
                  },
                  decoration: widget.searchBarDecoration ??
                      InputDecoration(
                        prefixIcon: Icon(
                          Icons.search,
                          color: widget.indicatorColor,
                        ),
                        fillColor: widget.backgroundColor ?? Colors.white,
                        filled: true,
                      ),
                ),
                // _locationList.isNotEmpty
                //     ? ListView.builder(
                //         itemBuilder: (context, index) {
                //           return LocationItem(
                //             data: _locationList[index],
                //             backgroundColor: widget.backgroundColor,
                //             locationNameTextStyle: widget.locationNameTextStyle,
                //             addressTextStyle: widget.addressTextStyle,
                //             onResultClicked: (LocationResult result) {
                //               _move = true;
                //               latLng = result.latLng!;
                //               //_latitude = result.latitude ?? 0;
                //               //_longitude = result.longitude ?? 0;
                //               _controller.move(result.latLng!, 16);
                //               _locationResult = result;
                //               _locationList.clear();
                //               setState(() {});
                //             },
                //           );
                //         },
                //         itemCount: _locationList.length,
                //         shrinkWrap: true,
                //         physics: AlwaysScrollableScrollPhysics(),
                //       )
                //     : Container(),
                _error
                    ? Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        color: widget.backgroundColor ?? Colors.white,
                        child: Text(
                          "Location not found",
                          style: widget.searchTextStyle,
                        ),
                      )
                    : Container()
              ],
            )
          : Container();
    }

    Widget viewLocationName() {
      return widget.customFooter != null
          ? widget.customFooter!(
              _locationResult ??
                  LocationResult(
                      latLng: latLng,
                      completeAddress: null,
                      //placemark: null,
                      locationName: null),
              _controller)
          : Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10)),
                color: widget.backgroundColor ?? Colors.white,
              ),
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  Row(
                    children: [
                      widget.leadingIcon ??
                          Icon(
                            Icons.location_city,
                            color: widget.indicatorColor,
                          ),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                          child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            //"(" + _locationResult?.latitude!.toString() + ", " +  _locationResult?.longitude!.toString() + ")";
                            //_locationResult?.locationName ??

                            "(${_locationResult?.latLng?.latitude}, ${_locationResult?.latLng?.longitude})",

                            style: widget.locationNameTextStyle ??
                                Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(
                            _locationResult?.completeAddress ?? "-",
                            style: widget.addressTextStyle ??
                                Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ))
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  widget.customButton != null
                      ? widget.customButton!(_locationResult ??
                          LocationResult(
                              latLng: latLng,
                              completeAddress: null,
                              //placemark: null,
                              locationName: null))
                      : ElevatedButton(
                          onPressed: () {
                            widget.onPicked(_locationResult ??
                                LocationResult(
                                    latLng: latLng,
                                    completeAddress: null,
                                    //placemark: null,
                                    locationName: null));
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: widget.buttonColor),
                          child: Text(widget.buttonText != null
                              ? widget.buttonText!
                              : "Select Location"),
                        )
                ],
              ),
            );
    }

    Widget sideButton() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Visibility(
            visible: widget.switchMapTypeEnabled,
            child: Padding(
              padding: const EdgeInsets.only(top: 10),
              child: TextButton(
                onPressed: () {
                  if (_mapType == MapType.normal) {
                    _mapType = MapType.satelite;
                  } else {
                    _mapType = MapType.normal;
                  }
                  setState(() {});
                },
                style: TextButton.styleFrom(
                    backgroundColor: widget.sideButtonsColor ??
                        Theme.of(context).primaryColor,
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(10)),
                child: Icon(Icons.layers,
                    color: widget.sideButtonsIconColor ?? Colors.white),
              ),
            ),
          ),
          Visibility(
            visible: widget.zoomButtonEnabled,
            child: Padding(
              padding: const EdgeInsets.only(top: 10),
              child: TextButton(
                onPressed: () {
                  if (_controller.camera.zoom < 17) {
                    _controller.move(latLng, _controller.camera.zoom + 1);
                  }
                },
                style: TextButton.styleFrom(
                    backgroundColor: widget.sideButtonsColor ??
                        Theme.of(context).primaryColor,
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(10)),
                child: Icon(Icons.zoom_in_map,
                    color: widget.sideButtonsIconColor ?? Colors.white),
              ),
            ),
          ),
          Visibility(
            visible: widget.zoomButtonEnabled,
            child: Padding(
              padding: const EdgeInsets.only(top: 10),
              child: TextButton(
                onPressed: () {
                  if (_controller.camera.zoom > 0) {
                    _controller.move(latLng, _controller.camera.zoom - 1);
                  }
                },
                style: TextButton.styleFrom(
                    backgroundColor: widget.sideButtonsColor ??
                        Theme.of(context).primaryColor,
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(10)),
                child: Icon(Icons.zoom_out_map,
                    color: widget.sideButtonsIconColor ?? Colors.white),
              ),
            ),
          ),
          Visibility(
            visible: widget.myLocationButtonEnabled,
            child: Padding(
              padding: const EdgeInsets.only(top: 10),
              child: TextButton(
                onPressed: () {
                  _move = true;
                  latLng = widget.initialLatLong ?? latLng;
                  setState(() {});
                  _controller.move(latLng, 16);
                  _timer?.cancel();
                  _getLocationResult();
                },
                style: TextButton.styleFrom(
                    backgroundColor: widget.sideButtonsColor ??
                        Theme.of(context).primaryColor,
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(10)),
                child: Icon(Icons.my_location,
                    color: widget.sideButtonsIconColor ?? Colors.white),
              ),
            ),
          ),
          widget.sideWidget != null
              ? widget.sideWidget!(
                  _locationResult ??
                      LocationResult(
                          latLng: latLng,
                          completeAddress: null,
                          //placemark: null,
                          locationName: null),
                  _controller)
              : Container(),
        ],
      );
    }

    return FlutterMap(
      mapController: _controller,
      options: MapOptions(
        initialCenter: latLng,
        initialZoom: 17.5,
        maxZoom: 20,
        onPositionChanged: (_, __) => updatePoint(context),
        onMapReady: () {
          _controller.mapEventStream.listen((evt) async {
            _timer?.cancel();
            if (!_move) {
              _timer = Timer(const Duration(milliseconds: 200), () {
                latLng = evt.camera.center;
                _getLocationResult();
              });
            } else {
              _move = false;
            }

            setState(() {});
          });
        },
      ),
      children: [
        TileLayer(
          urlTemplate: _mapType == MapType.normal
              ? "http://tile.openstreetmap.org/{z}/{x}/{y}.png"
              : 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}.jpg',
          userAgentPackageName: 'com.example.app',
        ),
        Stack(
          children: [
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.center_focus_strong_outlined,
                    size: 60,
                    color: widget.indicatorColor != null
                        ? widget.indicatorColor!
                        : Theme.of(context).colorScheme.primary,
                  ),
                  Text(
                    '(${latLng.latitude.toStringAsFixed(3)}, ${latLng.longitude.toStringAsFixed(3)})',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(top: 10, left: 10, right: 10, child: searchBar()),
            Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: sideButton(),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    viewLocationName(),
                  ],
                )),
          ],
        )
      ],
    );
  }

  void updatePoint(BuildContext context) =>
      setState(() => latLng = _controller.camera.center);
  //.screenOffsetToLatLng(Offset(_getPointX(context), _getPointY(context))));
}

/// Widget for showing the picked location address
class LocationItem extends StatefulWidget {
  /// Background color for the container
  final Color? backgroundColor;

  /// Indicator color for the container
  final Color? indicatorColor;

  /// Text Style for the address text
  final TextStyle? addressTextStyle;

  /// Text Style for the location name text
  final TextStyle? locationNameTextStyle;

  /// The location data for the picked location
  final LatLng data;

  final Function(LocationResult locationResult) onResultClicked;

  const LocationItem(
      {super.key,
      required this.data,
      this.backgroundColor,
      this.addressTextStyle,
      this.indicatorColor,
      this.locationNameTextStyle,
      required this.onResultClicked});

  @override
  State<LocationItem> createState() => _LocationItemState();
}

class _LocationItemState extends State<LocationItem> {
  //List<Placemark> _placemarks = [];

  Future<void> _getLocationResult() async {
    //_placemarks = await placemarkFromCoordinates(widget.data);
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _getLocationResult();
  }

  @override
  Widget build(BuildContext context) {
    //if (_placemarks.isEmpty) {
    return Container(
      color: widget.backgroundColor ?? Colors.white,
      padding: const EdgeInsets.all(10),
      child: Center(
          child: SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(),
      )),
    );
    //}
    // return ListView.builder(
    //   itemBuilder: (context, index) {
    //     return GestureDetector(
    //       onTap: () {
    //         widget.onResultClicked(LocationResult(
    //             latLng: LatLng(widget.data.latitude, widget.data.longitude),
    //             completeAddress:
    //                 getCompleteAdress(placemark: _placemarks[index]),
    //             placemark: _placemarks[index],
    //             locationName: getLocationName(placemark: _placemarks[index])));
    //       },
    //       child: Container(
    //         color: widget.backgroundColor ?? Colors.white,
    //         padding: const EdgeInsets.all(10),
    //         child: Row(
    //           children: [
    //             Icon(
    //               Icons.location_on_rounded,
    //               color: widget.indicatorColor,
    //             ),
    //             const SizedBox(
    //               width: 10,
    //             ),
    //             Expanded(
    //                 child: Column(
    //               crossAxisAlignment: CrossAxisAlignment.start,
    //               children: [
    //                 Text(
    //                   getLocationName(placemark: _placemarks[index]),
    //                   style: widget.locationNameTextStyle ??
    //                       Theme.of(context).textTheme.titleMedium,
    //                 ),
    //                 Text(
    //                   getCompleteAdress(placemark: _placemarks[index]),
    //                   style: widget.addressTextStyle ??
    //                       Theme.of(context).textTheme.bodySmall,
    //                 ),
    //               ],
    //             ))
    //           ],
    //         ),
    //       ),
    //     );
    //   },
    //   itemCount: _placemarks.length > 3 ? 3 : _placemarks.length,
    //   shrinkWrap: true,
    //   physics: NeverScrollableScrollPhysics(),
    // );
  }
}

Future<LocationResult> getLocationResult(LatLng latLng) async {
  try {
    //List<Placemark> placemarks =
    //    await placemarkFromCoordinates(latLng);
    //if (placemarks.isNotEmpty) {
    //  return LocationResult(
    //      latLng: latLng,
    //      locationName: getLocationName(placemark: placemarks.first),
    //      completeAddress: getCompleteAdress(placemark: placemarks.first),
    //      placemark: placemarks.first);
    //} else {
    return LocationResult(
        latLng: latLng,
        completeAddress: null,
        //placemark: null,
        locationName: null);
    //}
  } catch (e) {
    return LocationResult(
        latLng: latLng,
        completeAddress: null,
        //placemark: null,
        locationName: null);
  }
}

// String getLocationName({required Placemark placemark}) {
//   /// Returns throughfare or subLocality if name is an unreadable street code
//   if (isStreetCode(placemark.name ?? "")) {
//     if ((placemark.thoroughfare ?? "").isEmpty) {
//       return placemark.subLocality ?? "-";
//     } else {
//       return placemark.thoroughfare ?? "=";
//     }
//   }

//   /// Returns name if it is same with street
//   else if (placemark.name == placemark.street) {
//     return placemark.name ?? "-";
//   }

//   /// Returns street if name is part of name (like house number)
//   else if (placemark.street
//           ?.toLowerCase()
//           .contains(placemark.name?.toLowerCase() ?? "") ==
//       true) {
//     return placemark.street ?? "-";
//   }
//   return placemark.name ?? "-";
// }

// String getCompleteAdress({required Placemark placemark}) {
//   /// Returns throughfare or subLocality if name is an unreadable street code
//   if (isStreetCode(placemark.name ?? "")) {
//     if ((placemark.thoroughfare ?? "").isEmpty) {
//       return "${placemark.subLocality},${placemark.locality}, ${placemark.subAdministrativeArea}, ${placemark.administrativeArea}, ${placemark.country}";
//     } else {
//       return "${placemark.thoroughfare}, ${placemark.subLocality},${placemark.locality}, ${placemark.subAdministrativeArea}, ${placemark.administrativeArea}, ${placemark.country}";
//     }
//   }

//   /// Returns name if it is same with street
//   else if (placemark.name == placemark.street) {
//     return "${placemark.street}, ${placemark.subLocality},${placemark.locality}, ${placemark.subAdministrativeArea}, ${placemark.administrativeArea}, ${placemark.country}";
//   }

//   /// Returns street if name is part of name (like house number)
//   else if (placemark.street
//           ?.toLowerCase()
//           .contains(placemark.name?.toLowerCase() ?? "") ==
//       true) {
//     return "${placemark.street}, ${placemark.subLocality},${placemark.locality}, ${placemark.subAdministrativeArea}, ${placemark.administrativeArea}, ${placemark.country}";
//   }
//   return "${placemark.name}, ${placemark.street}, ${placemark.subLocality},${placemark.locality}, ${placemark.subAdministrativeArea}, ${placemark.administrativeArea}, ${placemark.country}";
// }

bool isStreetCode(String text) {
  final streetCodeRegex = RegExp(
      r"^[A-Z0-9\-+]+$"); // Matches all uppercase letters, digits, hyphens, and plus signs
  return streetCodeRegex.hasMatch(text);
}
