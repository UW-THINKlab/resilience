import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:support_sphere/data/models/generated_classes.dart';

export 'package:support_sphere/data/models/generated_classes.dart'
    show ResourceTypes;

extension ResourceTypeIcon on ResourceTypes {
  FaIconData get icon {
    switch (name) {
      case 'Durable':
        return FontAwesomeIcons.wrench;
      case 'Consumable':
        return FontAwesomeIcons.glassWater;
      case 'Skill':
        return FontAwesomeIcons.helmetSafety;
      default:
        return FontAwesomeIcons.question;
    }
  }
}
