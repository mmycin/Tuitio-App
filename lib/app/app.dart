import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'router.dart';

class TuitioApp extends StatelessWidget {
  const TuitioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ShadApp.router(
      title: 'Tuitio',
      debugShowCheckedModeBanner: false,
      routerConfig: appRouter,
      theme: ShadThemeData(
        brightness: Brightness.light,
        colorScheme: const ShadOrangeColorScheme.light(
          primary: Color(0xFFEA580C), // Vibrant Orange
          background: Color(0xFFF8FAFC), // Soft Crisp Slate background
          card: Color(0xFFFFFFFF),
        ),
      ),
    );
  }
}