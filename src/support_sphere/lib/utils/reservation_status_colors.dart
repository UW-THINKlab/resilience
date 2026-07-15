import 'package:flutter/material.dart';
import 'package:support_sphere/constants/color.dart';
import 'package:support_sphere/data/models/generated_classes.dart';

extension ReservationStatusColor on RESERVATION_STATUS {
  static const Map<RESERVATION_STATUS, Color> _baseColors = {
    RESERVATION_STATUS.tentative: ColorConstants.tentativeLime,
    RESERVATION_STATUS.accepted: ColorConstants.confirmGreen,
    RESERVATION_STATUS.rejected: ColorConstants.rejectedGray,
    RESERVATION_STATUS.released: ColorConstants.cancelGray,
    RESERVATION_STATUS.expired: ColorConstants.cancelGray,
  };

  static const double _lightenAmount = 0.7;

  /// isRequester gets the ColorConstants color as-is (the "normal" level);
  /// the other party gets a lighter tint of that same color, so editing
  /// ColorConstants automatically updates both.
  Color statusColor({required bool isRequester}) {
    final base = _baseColors[this]!;
    if (isRequester) return base;
    return Color.lerp(base, Colors.white, _lightenAmount)!;
  }
}
