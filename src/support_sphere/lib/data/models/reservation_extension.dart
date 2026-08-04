import 'package:support_sphere/data/models/generated_classes.dart';

extension ReservationExtension on ResourceReservations {
  bool isExpired() {
    return expiresAt == null ? false : expiresAt!.isBefore(DateTime.now());
  }
}
