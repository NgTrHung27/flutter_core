import '../../domain/entities/isolate_payload_entity.dart';

class IsolatePayloadModel extends IsolatePayloadEntity {
  const IsolatePayloadModel({
    required super.totalRecords,
    required super.items,
  });

  factory IsolatePayloadModel.fromJson(Map<String, dynamic> json) {
    return IsolatePayloadModel(
      totalRecords: json['data']?['totalRecords'] ?? 0,
      items: json['data']?['items'] ?? [],
    );
  }

  // Hàm tĩnh (Static function) nhận json Map để mapping.
  // Hàm này an toàn khi truyền qua Isolate.
  static IsolatePayloadModel fromJsonSafe(Map<String, dynamic> json) {
    return IsolatePayloadModel.fromJson(json);
  }
}
