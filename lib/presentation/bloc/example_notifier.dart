import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/example_entity.dart';
import '../../domain/usecases/get_example.dart';

final getExampleUseCaseProvider = Provider<GetExample>((ref) {
  throw UnimplementedError(); // Replace with DI
});

final exampleProvider = AsyncNotifierProvider<ExampleNotifier, ExampleEntity?>(ExampleNotifier.new);

class ExampleNotifier extends AsyncNotifier<ExampleEntity?> {
  @override
  Future<ExampleEntity?> build() async {
    return null;
  }

  Future<void> fetchExample(String id) async {
    state = const AsyncLoading();
    try {
      final getExample = ref.read(getExampleUseCaseProvider);
      final example = await getExample(id);
      state = AsyncData(example);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
