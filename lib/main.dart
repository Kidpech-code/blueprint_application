import 'package:flutter/material.dart';

// Core
import 'core/dependency_injection.dart';

// App
import 'app.dart';

/// Application entry point
///
/// This file is responsible for:
/// - Initializing Flutter framework
/// - Setting up dependency injection
/// - Starting the application
void main() async {
  // Ensure Flutter framework is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize all dependencies (repositories, use cases, view models)
  await initializeDependencies();

  // Start the application
  runApp(const MyApp());
}
