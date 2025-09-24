import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../bloc/user_notifier.dart';

class UserPage extends ConsumerWidget {
  const UserPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(userProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('User')),
      body: userState.when(
        data: (user) => Center(child: Text('Hello, ${user?.name}')),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton(onPressed: () => ref.read(userProvider.notifier).fetchUser('1'), child: const Icon(Icons.refresh)),
    );
  }
}
