import 'package:equatable/equatable.dart';

class Frequency extends Equatable {
  final String id;
  final String? name;
  final int? numDays;

  const Frequency({
    required this.id,
    this.name,
    this.numDays,
  });

  @override
  List<Object?> get props => [id, name, numDays];
}