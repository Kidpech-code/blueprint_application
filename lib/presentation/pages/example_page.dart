import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../bloc/example_notifier.dart';

class ExamplePage extends ConsumerWidget {
  const ExamplePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exampleState = ref.watch(exampleProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Example')),
      body: exampleState.when(
        data: (example) => Center(
          child: Text(
            'Hello, {example?.name ?? '
            '}',
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => ref.read(exampleProvider.notifier).fetchExample('1'),
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
