import 'package:flutter/material.dart';
import '../../../../core/route_manager.dart';

class NotFoundView extends StatelessWidget {
  const NotFoundView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Page Not Found'), backgroundColor: Colors.red[400], foregroundColor: Colors.white),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top - kToolbarHeight - 48),
            child: IntrinsicHeight(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 1),
                  Icon(Icons.error_outline, size: 80, color: Colors.red[400]),
                  const SizedBox(height: 24),
                  Text(
                    '404',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(color: Colors.red[400], fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Text('Page Not Found', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.grey[600])),
                  const SizedBox(height: 16),
                  Text(
                    'The page you are looking for does not exist.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: () {
                      // Use AppRouter.go when using go_router
                      AppRouter.go('/');
                    },
                    icon: const Icon(Icons.home),
                    label: const Text('Go Home'),
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
                  ),
                  const Spacer(flex: 1),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
