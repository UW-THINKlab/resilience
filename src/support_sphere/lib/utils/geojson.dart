import 'package:flutter/material.dart' show WidgetsFlutterBinding;
import 'package:flutter/services.dart' show rootBundle, AssetManifest;
import 'package:logging/logging.dart' show Logger;
import 'package:flutter_map_geojson/flutter_map_geojson.dart';

final log = Logger('GeoJson');

class GeoJson {
  // geojson stored in assets/geojson/*.geojson
  static Future<Map<String, GeoJsonParser>> loadLayers() async {
    // Load everything under assets/geojson
    final assetLocation = "assets/geojson/";
    final assetExt = ".geojson";
    final assetManifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    log.fine("Loaded manifest: ${assetManifest.listAssets()}");

    final geojsonFiles = assetManifest.listAssets()
        .where((key) => key.startsWith(assetLocation))
        .where((key) => key.endsWith(assetExt))
        .toList();

    log.fine("Loading geojson files: $geojsonFiles");

    final Map<String, GeoJsonParser> layers = {};

    for (final fileName in geojsonFiles) {
      // Load geojson
      final String jsonStr = await loadAsset(fileName);
      if (jsonStr.isEmpty) {
        throw Error();
      }
      final layerName = fileName.substring(assetLocation.length, fileName.indexOf(assetExt));
      log.fine("Loaded layer: $layerName");
      //log.finer("XXXXX JSON: $jsonStr");

      // parse
      try {
        log.finer("XXXXX A");
        GeoJsonParser geoJson = GeoJsonParser();
        log.finer("XXXXX B");
        geoJson.parseGeoJsonAsString(jsonStr);
        //log.finer("XXXXX C: $jsonStr");
        log.fine("Parsed geoJson: $geoJson");
        layers[layerName] =  geoJson;
        log.fine("created layer: $layerName");
      } catch (e, s) {
        print('Exception details:\n $e');
        print('Stack trace:\n $s');
      }
    }
    log.fine("Loaded layers: ${layers.keys}");
    return layers;
  }

  static Future<String> loadAsset(String assetPath) async {
    WidgetsFlutterBinding.ensureInitialized();
    return await rootBundle.loadString(assetPath);
  }
}