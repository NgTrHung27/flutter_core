import 'package:equatable/equatable.dart';

class IsolatePayloadEntity extends Equatable {
  final int totalRecords;
  final List<dynamic> items;

  const IsolatePayloadEntity({
    required this.totalRecords,
    required this.items,
  });

  @override
  List<Object?> get props => [totalRecords, items];
}
