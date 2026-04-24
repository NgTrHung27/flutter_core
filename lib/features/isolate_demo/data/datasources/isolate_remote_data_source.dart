import 'dart:async';
import 'dart:isolate';
import '../../../../core/api/api_helper.dart';
import '../../../../core/api/api_exception.dart';
import '../../../../core/api/api_url.dart';
import '../models/isolate_payload_model.dart';
import '../exceptions/isolate_exceptions.dart';

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
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw IsolateTimeoutException(),
      );

      if (useIsolate) {
        return await Isolate.run(
          () => IsolatePayloadModel.fromJsonSafe(response),
        );
      } else {
        return IsolatePayloadModel.fromJsonSafe(response);
      }
    } on IsolateTimeoutException {
      rethrow;
    } on FetchDataException {
      rethrow;
    } on BadRequestException {
      rethrow;
    } on NotFoundException {
      rethrow;
    } on InternalServerException {
      rethrow;
    } catch (e) {
      throw IsolateParseException(e.toString());
    }
  }
}
