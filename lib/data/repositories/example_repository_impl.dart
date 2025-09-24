import 'package:hive/hive.dart';
import '../../domain/entities/example_entity.dart';
import '../../domain/repositories/example_repository.dart';
import '../datasources/example_remote_data_source.dart';

class ExampleRepositoryImpl implements ExampleRepository {
  final ExampleRemoteDataSource remoteDataSource;
  final Box? cacheBox;
  ExampleRepositoryImpl(this.remoteDataSource, [this.cacheBox]);

  @override
  Future<ExampleEntity> getExample(String id) async {
    // 1. ลองอ่านจาก cache (Hive)
    if (cacheBox != null && cacheBox!.containsKey(id)) {
      final cached = cacheBox!.get(id) as Map?;
      if (cached != null) {
        return ExampleEntity(id: cached['id'], name: cached['name']);
      }
    }
    // 2. ถ้าไม่มีใน cache ให้ดึงจาก remote (Dio)
    final result = await remoteDataSource.fetchExample(id);
    // 3. บันทึกลง cache
    if (cacheBox != null) {
      await cacheBox!.put(id, result.toJson());
    }
    return result;
  }
}
