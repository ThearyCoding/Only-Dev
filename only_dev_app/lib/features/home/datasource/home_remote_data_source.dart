import 'package:only_dev_app/features/home/model/home_screen_data.dart';
import 'package:only_dev_app/service/api/api_endpoints.dart';
import 'package:only_dev_app/service/api/dio_client.dart';

abstract class HomeRemoteDataSource {
  Future<HomeScreenData> getHomeScreenData();
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final DioClient _dioClient;

  HomeRemoteDataSourceImpl(this._dioClient);

  @override
  Future<HomeScreenData> getHomeScreenData() async {
    final response = await _dioClient.get(ApiEndpoints.home);

    if (response.data != null && response.data['data'] != null) {
      return HomeScreenData.fromJson(
        response.data['data'] as Map<String, dynamic>,
      );
    }

    throw Exception('Failed to load home screen data');
  }
}

