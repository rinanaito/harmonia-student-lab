import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'services/app_state.dart';
import 'screens/login_screen.dart';
import 'screens/gallery_screen.dart';
import 'screens/admin_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState(),
      child: const HarmoniaApp(),
    ),
  );
}

class HarmoniaApp extends StatelessWidget {
  const HarmoniaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Harmonia — Language Lab',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const AuthRouter(),
    );
  }
}

class AuthRouter extends StatelessWidget {
  const AuthRouter({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    if (state.isAdmin) return const AdminScreen();
    if (state.currentStudent != null) return const GalleryScreen();
    return const LoginScreen();
  }
}
