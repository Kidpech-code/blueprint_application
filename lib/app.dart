import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Core
import 'core/dependency_injection.dart';
import 'core/route_manager.dart';
import 'config.dart';

// ViewModels
import 'features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'features/profile/presentation/viewmodels/profile_viewmodel.dart';
import 'features/blog/presentation/viewmodels/blog_viewmodel.dart';

/// Main application widget that configures the app theme, routing, and state management
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthViewModel>(create: (_) => sl<AuthViewModel>()),
        ChangeNotifierProvider<ProfileViewModel>(create: (_) => sl<ProfileViewModel>()),
        ChangeNotifierProvider<BlogViewModel>(create: (_) => sl<BlogViewModel>()),
      ],
      child: MaterialApp.router(
        title: AppConfig.appName,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue, brightness: Brightness.light),
          appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
          cardTheme: const CardThemeData(elevation: 2, shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12)))),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue, brightness: Brightness.dark),
          appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
        ),
        themeMode: ThemeMode.system,
        routerConfig: AppRouter.router,
      ),
    );
  }
}
