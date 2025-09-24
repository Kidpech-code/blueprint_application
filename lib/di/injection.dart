import 'package:hive/hive.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/datasources/example_remote_data_source.dart';
import '../data/repositories/example_repository_impl.dart';
import '../domain/repositories/example_repository.dart';
import '../domain/usecases/get_example.dart';
import '../data/datasources/user_remote_data_source.dart';
import '../data/repositories/user_repository_impl.dart';
import '../domain/repositories/user_repository.dart';
import '../domain/usecases/get_user.dart';

// Hive Provider (async)
final hiveBoxProvider = FutureProvider<Box>((ref) async {
  // ตัวอย่างเปิด box ชื่อ 'exampleBox'
  return await Hive.openBox('exampleBox');
});

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio();
  // สามารถตั้งค่า baseUrl, interceptors ฯลฯ ได้ที่นี่
  return dio;
});

// Example DataSource Provider
final exampleRemoteDataSourceProvider = Provider<ExampleRemoteDataSource>((ref) {
  final dio = ref.watch(dioProvider);
  return ExampleRemoteDataSourceImpl(dio);
});

// Example Repository Provider
final exampleRepositoryProvider = Provider<ExampleRepository>((ref) {
  final dataSource = ref.watch(exampleRemoteDataSourceProvider);
  return ExampleRepositoryImpl(dataSource);
});

// Example UseCase Provider
final getExampleUseCaseProvider = Provider<GetExample>((ref) {
  final repo = ref.watch(exampleRepositoryProvider);
  return GetExample(repo);
});

// User DataSource Provider
final userRemoteDataSourceProvider = Provider<UserRemoteDataSource>((ref) {
  return UserRemoteDataSourceImpl();
});

// User Repository Provider
final userRepositoryProvider = Provider<UserRepository>((ref) {
  final dataSource = ref.watch(userRemoteDataSourceProvider);
  return UserRepositoryImpl(dataSource);
});

// User UseCase Provider
final getUserUseCaseProvider = Provider<GetUser>((ref) {
  final repo = ref.watch(userRepositoryProvider);
  return GetUser(repo);
});

class Injection {
  // static final getIt = GetIt.instance;
  // static void init() {
  //   // Register repositories, datasources, usecases, etc.
  //   // getIt.registerLazySingleton<ExampleRepository>(() => ExampleRepositoryImpl(...));
  // }
}
