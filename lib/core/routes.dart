import 'package:flutter/material.dart';
import 'package:flutter_application_latn/features/home/presentation/screens/home_screen.dart';
import 'package:flutter_application_latn/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:flutter_application_latn/features/pineline_main/choose_image/choose_image_screen.dart';
class AppRoutes {
  static const String onboarding = '/';
  static const String home = '/home';
  static const String chat = '/chat';

  static Map<String, WidgetBuilder> routes = {
    onboarding: (context) => const OnboardingScreen(),
    home: (context) => HomeScreen(),
    chat: (context) => const ChooseImageScreen(),
  };
}
