import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:logging/logging.dart' show Logger;
import 'package:support_sphere/constants/color.dart' show ColorConstants;
import 'package:support_sphere/data/models/generated_classes.dart'
    show VISIBILITY_SCOPE, POI_CATEGORY;

final log = Logger('MessagesPage');

const default_icon_size = 48.0;

// Maps a point_of_interest_types.icon slug to its FontAwesome icon.
const Map<String, FaIconData> iconBySlug = {
  'kit-medical': FontAwesomeIcons.kitMedical,
  'graduation-cap': FontAwesomeIcons.graduationCap,
  'book': FontAwesomeIcons.book,
  'hospital': FontAwesomeIcons.hospital,
  'person-praying': FontAwesomeIcons.personPraying,
  'flag-checkered': FontAwesomeIcons.flagCheckered,
  'user-shield': FontAwesomeIcons.userShield,
  'user': FontAwesomeIcons.user,
  'flag': FontAwesomeIcons.flag,
  'hands-praying': FontAwesomeIcons.handsPraying,
  'houzz': FontAwesomeIcons.houzz,
  'shield-halved': FontAwesomeIcons.shieldHalved,
  'house-fire': FontAwesomeIcons.houseFire,
  'store': FontAwesomeIcons.store,
  'gas-pump': FontAwesomeIcons.gasPump,
  'bread-slice': FontAwesomeIcons.breadSlice,
  'person-shelter': FontAwesomeIcons.personShelter,
  'tree': FontAwesomeIcons.tree,
  'water': FontAwesomeIcons.water,
  'envelope': FontAwesomeIcons.envelope,
  'landmark': FontAwesomeIcons.landmark,
  'atom': FontAwesomeIcons.atom,
};

// Maps a point_of_interest_types.category to its display color.
const Map<POI_CATEGORY, Color> colorByCategory = {
  POI_CATEGORY.emergency_safety: ColorConstants.cbVermillion,
  POI_CATEGORY.medical: ColorConstants.cbReddishPurple,
  POI_CATEGORY.education: ColorConstants.cbBlue,
  POI_CATEGORY.community_civic: ColorConstants.cbOrange,
  POI_CATEGORY.nature_outdoor: ColorConstants.cbBluishGreen,
  POI_CATEGORY.utility: ColorConstants.cbSkyBlue,
  POI_CATEGORY.business_economic: ColorConstants.cbYellow,
  POI_CATEGORY.personal_other: ColorConstants.cbBlack,
};

class PointOfInterest extends Equatable {
  final String id;
  final String name;
  final String address;
  final String? notes;
  final LatLng geom;
  final String type;
  final String? userId;
  final VISIBILITY_SCOPE visibilityScope;
  final String? clusterId;
  final String? householdId;
  final DateTime? expiresAt;
  final double size = default_icon_size;

  const PointOfInterest({
    required this.id,
    required this.name,
    this.address = "",
    this.notes,
    required this.geom,
    required this.type,
    this.userId,
    this.visibilityScope = VISIBILITY_SCOPE.neighborhood,
    this.clusterId,
    this.householdId,
    this.expiresAt,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    address,
    notes,
    geom,
    type,
    userId,
    visibilityScope,
    clusterId,
    householdId,
    expiresAt,
  ];

  PointOfInterest copyWith({
    required String id,
    required String name,
    required String address,
    String? notes,
    required LatLng geom,
    required String type,
    required String? userId,
    required VISIBILITY_SCOPE visibilityScope,
    required String? clusterId,
    required String? householdId,
    required DateTime? expiresAt,
  }) {
    return PointOfInterest(
      id: id,
      name: name,
      address: address,
      notes: notes,
      geom: geom,
      type: type,
      userId: userId,
      visibilityScope: visibilityScope,
      clusterId: clusterId,
      householdId: householdId,
      expiresAt: expiresAt,
    );
  }

  static LatLng geometryFromMap(Map geomMap) {
    // "geom" -> Map (2 items)
    //     "type" -> "Point"
    //     "coordinates" -> List (2 items)
    //       47.6591528763917
    //       -122.27787227416428
    // geom:{"type:x", "coordinates":[lat,long]}
    return LatLng(geomMap["coordinates"][1], geomMap["coordinates"][0]);
  }

  static PointOfInterest fromMap(Map poiMap) {
    var geomMap = poiMap['geom'];
    var geom = geometryFromMap(geomMap);
    return PointOfInterest(
      id: poiMap['id'],
      name: poiMap['name'],
      address: poiMap['address'],
      notes: poiMap['notes'],
      geom: geom,
      type: poiMap['point_type_name'],
      userId: poiMap['user_id'],
      visibilityScope: poiMap['visibility_scope'] != null
          ? VISIBILITY_SCOPE.values.byName(
              poiMap['visibility_scope'].toString(),
            )
          : VISIBILITY_SCOPE.neighborhood,
      clusterId: poiMap['cluster_id'],
      householdId: poiMap['household_id'],
      expiresAt: poiMap['expires_at'] != null
          ? DateTime.parse(poiMap['expires_at'])
          : null,
    );
  }

  Map toMap() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'notes': notes,
      'geom': 'POINT(${geom.longitude} ${geom.latitude})',
      'point_type_name': type,
      'user_id': userId,
      'visibility_scope': visibilityScope.name,
      'cluster_id': clusterId,
      'household_id': householdId,
      'expires_at': expiresAt?.toUtc().toIso8601String(),
    };
  }

  static const double _labelWidth = 90.0;
  static const double _labelHeight = 16.0;
  static const double _labelOverlap = 8.0;

  static Widget _pinWidget(
    FaIconData icon,
    Color color,
    double size,
    String label, {
    VoidCallback? onTap,
    bool isPrivate = false,
  }) {
    final iconSize = size * 0.28;
    final holeSize = size * 0.30;

    final content = SizedBox(
      width: _labelWidth,
      height: size + _labelHeight - _labelOverlap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // pin, painted first so the label can paint over it
          Positioned(
            top: _labelHeight - _labelOverlap,
            left: (_labelWidth - size) / 2,
            child: SizedBox(
              width: size,
              height: size,
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  // pin body with a drop shadow so it reads as lifted off the map
                  Icon(
                    Icons.location_on,
                    size: size,
                    color: color,
                    shadows: const [
                      Shadow(
                        color: Colors.black87,
                        offset: Offset(1.5, 2.5),
                        blurRadius: 3,
                      ),
                    ],
                  ),
                  // plug the glyph's hollow center with a solid circle in the
                  // same color, so the outline doesn't show through the hole
                  Positioned(
                    top: size * 0.20,
                    child: Container(
                      width: holeSize,
                      height: holeSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: color,
                      ),
                    ),
                  ),
                  // the type-specific icon, sitting on top of the plug
                  Positioned(
                    top: size * 0.22,
                    child: FaIcon(
                      icon,
                      size: iconSize,
                      color: Colors.white,
                    ),
                  ),
                  // lock badge for private POIs, just below the type icon
                  if (isPrivate)
                    Positioned(
                      top: size * 0.52,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        child: Icon(
                          Icons.lock,
                          size: size * 0.16,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          // label, painted last so it renders on top of the pin
          Positioned(
            top: 0,
            left: 0,
            child: Tooltip(
              message: label,
              child: SizedBox(
                width: _labelWidth,
                height: _labelHeight,
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    shadows: [
                      Shadow(color: Colors.white, blurRadius: 3),
                      Shadow(color: Colors.white, blurRadius: 3),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    return onTap != null
        ? GestureDetector(onTap: onTap, child: content)
        : content;
  }

  Marker marker(
    Map<String, (FaIconData, Color)> styles, {
    VoidCallback? onTap,
  }) {
    FaIconData icon;
    Color color;
    if (styles[type] != null) {
      final (ico, colo) = styles[type]!;
      icon = ico;
      color = colo;
    } else {
      log.warning("Unknown icon type: $name");
      icon = FontAwesomeIcons.atom;
      color = Colors.purple;
    }

    return Marker(
      point: geom,
      width: _labelWidth,
      height: size + _labelHeight - _labelOverlap,
      alignment: Alignment.topCenter,
      child: _pinWidget(
        icon,
        color,
        size,
        name,
        onTap: onTap,
        isPrivate: visibilityScope == VISIBILITY_SCOPE.private,
      ),
    );
  }

  static Marker markerFor(
    LatLng geom,
    name,
    Map<String, (FaIconData, Color)> styles, {
    String? label,
    VoidCallback? onTap,
  }) {
    FaIconData icon;
    Color color;
    const size = default_icon_size;
    if (styles[name] != null) {
      final (ico, colo) = styles[name]!;
      icon = ico;
      color = colo;
    } else {
      log.warning("Unknown icon type: $name");
      icon = FontAwesomeIcons.atom;
      color = Colors.purple;
    }

    final displayLabel =
        (label != null && label.isNotEmpty) ? label : name.toString();

    return Marker(
      point: geom,
      width: _labelWidth,
      height: size + _labelHeight - _labelOverlap,
      alignment: Alignment.topCenter,
      child: _pinWidget(icon, color, size, displayLabel, onTap: onTap),
    );
  }
}
