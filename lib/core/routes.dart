import 'package:flutter/material.dart';
import 'package:flutter_application_latn/features/home/presentation/screens/home_screen.dart';
import 'package:flutter_application_latn/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:flutter_application_latn/features/chat/presentation/screens/chat_screen.dart';
class AppRoutes {
  static const String onboarding = '/';
  static const String home = '/home';
  static const String chat = '/chat';

  static Map<String, WidgetBuilder> routes = {
    onboarding: (context) => const OnboardingScreen(),
    home: (context) => const HomeScreen(),
    chat: (context) => const ChatScreen(),
  };
}
