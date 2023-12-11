import 'package:bookly/Features/home/data/data_sources/home_local_data_source.dart';
import 'package:bookly/Features/home/data/data_sources/home_remote_data_source.dart';
import 'package:bookly/Features/home/data/repos/home_repo_implementation.dart';
import 'package:bookly/core/utils/api_services.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

final getit = GetIt.instance;
void setupServiceLocator() {
  getit.registerSingleton<ApiService>(ApiService(Dio()));
  getit.registerSingleton<HomeRepoImplementaion>(HomeRepoImplementaion(
      homeRemoteDataSource:
          HomeRemoteDataSourceImplementation(getit.get<ApiService>()),
      homeLocalDataSource: HomeLocalDataSourceImplementation()));
}
