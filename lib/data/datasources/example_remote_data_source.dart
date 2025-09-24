import 'package:dio/dio.dart';
import '../models/example_model.dart';

abstract class ExampleRemoteDataSource {
  Future<ExampleModel> fetchExample(String id);
}

class ExampleRemoteDataSourceImpl implements ExampleRemoteDataSource {
  final Dio dio;
  ExampleRemoteDataSourceImpl(this.dio);

  @override
  Future<ExampleModel> fetchExample(String id) async {
    try {
      // ตัวอย่างการใช้ dio (uncomment เพื่อใช้งานจริง)
      // final response = await dio.get('https://api.example.com/example/$id');
      // return ExampleModel.fromJson(response.data);
      // ตัวอย่าง mock
      await Future.delayed(const Duration(milliseconds: 300));
      return ExampleModel(id: id, name: 'Mock Example');
    } catch (e) {
      throw Exception('Failed to fetch example: $e');
    }
  }
}
