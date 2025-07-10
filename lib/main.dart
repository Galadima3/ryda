// ignore_for_file: use_build_context_synchronously

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ryda/app.dart';
import 'package:ryda/firebase_options.dart';
import 'package:ryda/src/onboarding/service/onboarding_service.dart';

Future<bool> initializeAppResources() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final seen = await LocalStorageService.hasSeenOnboarding();
  return seen;
}

void main() async {
  final binding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: binding);
  final seen = await initializeAppResources();
  FlutterNativeSplash.remove();

  runApp(ProviderScope(child: App(hasSeenOnboarding: seen)));
}

