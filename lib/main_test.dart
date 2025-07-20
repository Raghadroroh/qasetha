import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as provider;
import 'screens/profile_screen_new.dart';
import 'services/theme_service.dart';

void main() {
  runApp(
    provider.ChangeNotifierProvider(
      create: (_) => ThemeService(),
      child: const ProviderScope(
        child: MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeService = provider.Provider.of<ThemeService>(context);
    
    return MaterialApp(
      title: 'قسطها',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF667eea),
          brightness: themeService.isDarkMode ? Brightness.dark : Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const ProfileScreen(),
    );
  }
}