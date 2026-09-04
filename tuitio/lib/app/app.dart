import 'package:flutter/material.dart';
import 'router.dart';

class TuitioApp extends StatelessWidget {
  const TuitioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: "Tuitio",
      routerConfig: appRouter,
    );
  }
}