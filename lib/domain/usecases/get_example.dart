import '../entities/example_entity.dart';
import '../repositories/example_repository.dart';

class GetExample {
  final ExampleRepository repository;
  GetExample(this.repository);

  Future<ExampleEntity> call(String id) {
    return repository.getExample(id);
  }
}
