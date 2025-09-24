import '../../domain/entities/example_entity.dart';

class ExampleModel extends ExampleEntity {
  ExampleModel({required super.id, required super.name});

  factory ExampleModel.fromJson(Map<String, dynamic> json) {
    return ExampleModel(id: json['id'] as String, name: json['name'] as String);
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}
