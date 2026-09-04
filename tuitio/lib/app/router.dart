import 'package:go_router/go_router.dart';
import 'package:tuitio/features/students/students_page.dart';
import 'package:tuitio/features/dashboard/dashboard_page.dart';

final appRouter = GoRouter(
  initialLocation: '/',

  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const DashboardPage(),
    ),

    GoRoute(
      path: '/students',
      builder: (context, state) => const StudentsPage(),
    ),
  ]
);