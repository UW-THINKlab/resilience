import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:support_sphere/data/models/generated_classes.dart';

export 'package:support_sphere/data/models/generated_classes.dart'
    show ResourceTypes;

enum ResourceTypesEnum {
  durable('Durable'),
  consumable('Consumable'),
  skill('Skill');

  final String value;

  const ResourceTypesEnum(this.value);

  static ResourceTypesEnum fromString(String value) {
    return ResourceTypesEnum.values.firstWhere(
      (e) => e.toString() == 'ResourceTypesEnum.${value.toLowerCase()}',
    );
  }
}

extension ResourceTypeIcon on ResourceTypes {
  bool get quantifiable {
    switch (ResourceTypesEnum.fromString(name)) {
      case ResourceTypesEnum.durable:
        return true;
      case ResourceTypesEnum.consumable:
        return true;
      case ResourceTypesEnum.skill:
        return false;
    }
  }

  FaIconData get icon {
    switch (ResourceTypesEnum.fromString(name)) {
      case ResourceTypesEnum.durable:
        return FontAwesomeIcons.wrench;
      case ResourceTypesEnum.consumable:
        return FontAwesomeIcons.glassWater;
      case ResourceTypesEnum.skill:
        return FontAwesomeIcons.helmetSafety;
    }
  }
}
