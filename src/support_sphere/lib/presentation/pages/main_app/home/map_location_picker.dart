
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
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
  double? latitude;

  /// the longitude of the picked location
  double? longitude;

  /// the complete address of the picked location
  String? completeAddress;

  /// the location name of the picked location
  String? locationName;

  /// the placemark infomation of the picked location
  Placemark? placemark;

  LocationResult(
      {required this.latitude,
      required this.longitude,
      required this.completeAddress,
      required this.placemark,
      required this.locationName});
}

class MapLocationPicker extends StatefulWidget {
  /// The initial longitude
  final double? initialLongitude;

  /// The initial latitude
  final double? initialLatitude;

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
      required this.initialLatitude,
      required this.initialLongitude,
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
      this.searchBarEnabled = true,
      this.sideWidget,
      this.customButton,
      this.customFooter,
      this.buttonTextStyle,
      this.zoomButtonEnabled = true,
      this.initialZoom,
      this.switchMapTypeEnabled = true,
      this.mapType,
      this.sideButtonsColor,
      this.sideButtonsIconColor,
      this.locationNameTextStyle, this.locale});

  @override
  State<MapLocationPicker> createState() => _MapLocationPickerState();
}

class _MapLocationPickerState extends State<MapLocationPicker> {
  bool _error = false;
  bool _move = false;
  Timer? _timer;
  final MapController _controller = MapController();
  final List<Location> _locationList = [];
  MapType _mapType = MapType.normal;

  LocationResult? _locationResult;

  double _latitude = -6.984072660841485;
  double _longitude = 110.40950678599624;

  @override
  void initState() {
    super.initState();
    _latitude = widget.initialLatitude ?? -6.984072660841485;
    _longitude = widget.initialLongitude ?? 110.40950678599624;

    if (widget.mapType != null) {
      _mapType = widget.mapType!;
    }
    _setupInitalLocation();

  }

  _setupInitalLocation() async{
    if(widget.locale != null){
      await setLocaleIdentifier(widget.locale!);

    }
    _locationResult = LocationResult(
        latitude: _latitude,
        longitude: _longitude,
        completeAddress: null,
        locationName: null,
        placemark: null);
    _getLocationResult();
  }

  _getLocationResult() async {
    _locationResult = await getLocationResult(latitude: _latitude, longitude: _longitude);
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
                    if(value.isNotEmpty){
                      _error = false;
                      setState(() {});
                      try {
                        _locationList.clear();
                        _locationList.addAll(await locationFromAddress(value));

                        if (_locationList.isNotEmpty) {
                        } else {
                          _error = true;
                        }
                      } catch (e) {
                        _error = true;
                      }
                      setState(() {});
                    } else{
                      _locationList.clear();
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
                _locationList.isNotEmpty
                    ? ListView.builder(
                        itemBuilder: (context, index) {
                          return LocationItem(
                            data: _locationList[index],
                            backgroundColor: widget.backgroundColor,
                            locationNameTextStyle:
                                widget.locationNameTextStyle,
                            addressTextStyle: widget.addressTextStyle, onResultClicked: (LocationResult result) {
                            _move = true;
                            _latitude = result.latitude ?? 0;
                            _longitude = result.longitude ?? 0;
                            _controller.move(
                                LatLng(result.latitude ?? 0,
                                    result.longitude ?? 0),
                                16);
                            _locationResult = result;
                            _locationList.clear();
                            setState(() {});
                          },
                          );
                        },
                        itemCount: _locationList.length,
                        shrinkWrap: true,
                  physics: AlwaysScrollableScrollPhysics(),
                      )
                    : Container(),
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
          ? widget.customFooter!(_locationResult ?? LocationResult(latitude: _latitude, longitude: _longitude, completeAddress: null, placemark: null,locationName: null), _controller)
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
                             _locationResult?.locationName ??
                                "Location not found",
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
                      ? widget.customButton!(_locationResult ?? LocationResult(latitude: _latitude, longitude: _longitude, completeAddress: null, placemark: null,locationName: null))
                      : ElevatedButton(
                          onPressed: () {
                            widget.onPicked(_locationResult ?? LocationResult(latitude: _latitude, longitude: _longitude, completeAddress: null, placemark: null,locationName: null));
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
                    _controller.move(LatLng(_latitude, _longitude),
                        _controller.camera.zoom + 1);
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
                    _controller.move(LatLng(_latitude, _longitude),
                        _controller.camera.zoom - 1);
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
                  _latitude = widget.initialLatitude ?? -6.970136294118362;
                  _longitude = widget.initialLongitude ?? 110.40326425161746;
                  setState(() {});
                  _controller.move(LatLng(_latitude, _longitude), 16);
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
              ? widget.sideWidget!(_locationResult ?? LocationResult(latitude: _latitude, longitude: _longitude, completeAddress: null, placemark: null,locationName: null), _controller)
              : Container(),
        ],
      );
    }

    return FlutterMap(
      mapController: _controller,
      options: MapOptions(
        initialCenter: LatLng(_latitude, _longitude),
        initialZoom: 16,
        maxZoom: 18,
        onMapReady: () {
          _controller.mapEventStream.listen((evt) async {
            _timer?.cancel();
            if (!_move) {
              _timer = Timer(const Duration(milliseconds: 200), () {
                _latitude = evt.camera.center.latitude;
                _longitude = evt.camera.center.longitude;
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
                child: widget.centerWidget != null
                    ? widget.centerWidget!
                    : Icon(
                  Icons.location_on_rounded,
                  size: 60,
                  color: widget.indicatorColor != null
                      ? widget.indicatorColor!
                      : Theme.of(context).colorScheme.primary,
                )),
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
  final Location data;

  final Function(LocationResult locationResult) onResultClicked;

  const LocationItem(
      {super.key,
      required this.data,
      this.backgroundColor,
      this.addressTextStyle,
      this.indicatorColor,
      this.locationNameTextStyle, required this.onResultClicked});

  @override
  State<LocationItem> createState() => _LocationItemState();
}

class _LocationItemState extends State<LocationItem> {
  List<Placemark> _placemarks = [];

  _getLocationResult() async {
    _placemarks = await placemarkFromCoordinates(widget.data.latitude, widget.data.longitude);
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _getLocationResult ();
  }

  @override
  Widget build(BuildContext context) {

    if(_placemarks.isEmpty){
      return Container(
        color: widget.backgroundColor ?? Colors.white,
        padding: const EdgeInsets.all(10),
        child: Center(child: SizedBox(width: 20,height: 20,child: CircularProgressIndicator(),)),
      );
    }
    return ListView.builder(itemBuilder: (context,index){
      return GestureDetector(
        onTap: (){
          widget.onResultClicked(LocationResult(latitude: widget.data.latitude, longitude: widget.data.longitude, completeAddress:  getCompleteAdress(placemark: _placemarks[index]), placemark: _placemarks[index], locationName: getLocationName(placemark: _placemarks[index])));
        },
        child: Container(
          color: widget.backgroundColor ?? Colors.white,
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              Icon(
                Icons.location_on_rounded,
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
                        getLocationName(placemark: _placemarks[index]),
                        style: widget.locationNameTextStyle ??
                            Theme.of(context).textTheme.titleMedium,
                      ),              Text(
                        getCompleteAdress(placemark: _placemarks[index]),
                        style: widget.addressTextStyle ??
                            Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ))
            ],
          ),
        ),
      );
    },itemCount: _placemarks.length > 3 ? 3 : _placemarks.length, shrinkWrap: true,physics: NeverScrollableScrollPhysics(),);
  }
}


Future<LocationResult> getLocationResult({required double latitude, required double longitude}) async {
  try {
    List<Placemark> placemarks =
    await placemarkFromCoordinates(latitude, longitude);
    if (placemarks.isNotEmpty) {
      return LocationResult(
          latitude: latitude,
          longitude: longitude,
          locationName: getLocationName(placemark: placemarks.first),
          completeAddress: getCompleteAdress(placemark: placemarks.first),
          placemark: placemarks.first);
    } else {
      return LocationResult(
          latitude: latitude,
          longitude: longitude,
          completeAddress: null,
          placemark: null,locationName: null);
    }
  } catch (e) {
    return LocationResult(
        latitude: latitude,
        longitude: longitude,
        completeAddress: null,
        placemark: null, locationName: null);
  }
}

String getLocationName({required Placemark placemark}){
  /// Returns throughfare or subLocality if name is an unreadable street code
  if(isStreetCode(placemark.name ?? "")){
    if((placemark.thoroughfare ?? "").isEmpty){
      return placemark.subLocality ?? "-";
    } else{
      return placemark.thoroughfare ?? "=";
    }
  }

  /// Returns name if it is same with street
  else if(placemark.name == placemark.street){
    return placemark.name ?? "-";
  }

  /// Returns street if name is part of name (like house number)
  else if(placemark.street?.toLowerCase().contains(placemark.name?.toLowerCase() ?? "") == true){
    return placemark.street ?? "-";
  }
  return placemark.name ?? "-";

}

String getCompleteAdress({required Placemark placemark}){
  /// Returns throughfare or subLocality if name is an unreadable street code
  if(isStreetCode(placemark.name ?? "")){
    if((placemark.thoroughfare ?? "").isEmpty){
      return "${placemark.subLocality},${placemark.locality}, ${placemark.subAdministrativeArea}, ${placemark.administrativeArea}, ${placemark.country}";
    } else{
      return "${placemark.thoroughfare}, ${placemark.subLocality},${placemark.locality}, ${placemark.subAdministrativeArea}, ${placemark.administrativeArea}, ${placemark.country}";
    }
  }

  /// Returns name if it is same with street
  else if(placemark.name == placemark.street){
    return "${placemark.street}, ${placemark.subLocality},${placemark.locality}, ${placemark.subAdministrativeArea}, ${placemark.administrativeArea}, ${placemark.country}";
  }

  /// Returns street if name is part of name (like house number)
  else if(placemark.street?.toLowerCase().contains(placemark.name?.toLowerCase() ?? "") == true){
    return "${placemark.street}, ${placemark.subLocality},${placemark.locality}, ${placemark.subAdministrativeArea}, ${placemark.administrativeArea}, ${placemark.country}";
  }
  return "${placemark.name}, ${placemark.street}, ${placemark.subLocality},${placemark.locality}, ${placemark.subAdministrativeArea}, ${placemark.administrativeArea}, ${placemark.country}";

}

bool isStreetCode(String text) {
  final streetCodeRegex = RegExp(r"^[A-Z0-9\-+]+$"); // Matches all uppercase letters, digits, hyphens, and plus signs
  return streetCodeRegex.hasMatch(text);
}
