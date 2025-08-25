import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'src/core/app_initializer.dart';
import 'src/core/app.dart';

void main() async {
  await AppInitializer.initialize();
  AppInitializer.setupErrorHandling();
  
  runApp(
    const ProviderScope(
      child: K53App(),
    ),
  );
}
