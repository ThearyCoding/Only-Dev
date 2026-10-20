import 'package:only_dev_app/features/home/datasource/home_remote_data_source.dart';
import 'package:only_dev_app/features/home/model/home_screen_data.dart';

abstract class HomeRepository {
  Future<HomeScreenData> getHomeScreenData();
}

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource _remoteDataSource;

  HomeRepositoryImpl(this._remoteDataSource);

  @override
  Future<HomeScreenData> getHomeScreenData() {
    return _remoteDataSource.getHomeScreenData();
  }
}

