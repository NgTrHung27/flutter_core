import 'dart:isolate';
import '../../../../core/api/api_helper.dart';
import '../../../../core/api/api_url.dart';
import '../models/isolate_payload_model.dart';

abstract class IsolateRemoteDataSource {
  Future<IsolatePayloadModel> fetchHeavyPayload({required bool useIsolate});
}

class IsolateRemoteDataSourceImpl implements IsolateRemoteDataSource {
  final ApiHelper _apiHelper;

  IsolateRemoteDataSourceImpl(this._apiHelper);

  @override
  Future<IsolatePayloadModel> fetchHeavyPayload({
    required bool useIsolate,
  }) async {
    try {
      final response = await _apiHelper.execute(
        method: Method.get,
        url: ApiUrl.isolateHeavyPayload,
      );

      // response ở đây đã được Dio tự parse thành Map<String, dynamic>.
      if (useIsolate) {
        // Đưa công việc mapping cục Model rất nặng này xuống Isolate
        return await Isolate.run(
          () => IsolatePayloadModel.fromJsonSafe(response),
        );
      } else {
        return IsolatePayloadModel.fromJsonSafe(response);
      }
    } on Exception {
      rethrow;
    }
  }
}
