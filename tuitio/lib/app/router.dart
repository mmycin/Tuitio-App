import 'package:go_router/go_router.dart';

import 'package:tuitio/core/widgets/app_shell.dart';
import 'package:tuitio/features/dashboard/dashboard_page.dart';
import 'package:tuitio/features/students/students_page.dart';
import 'package:tuitio/features/students/student_detail_page.dart';
import 'package:tuitio/features/salary/salary_page.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, shell) =>
          AppShell(navigationShell: shell),
      branches: [
        // ── Dashboard branch ────────────────────────────────────────
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => const DashboardPage(),
            ),
          ],
        ),

        // ── Students branch ─────────────────────────────────────────
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/students',
              builder: (context, state) => const StudentsPage(),
              routes: [
                GoRoute(
                  path: ':id',
                  builder: (context, state) {
                    final id = int.parse(state.pathParameters['id']!);
                    return StudentDetailPage(studentId: id);
                  },
                ),
              ],
            ),
          ],
        ),

        // ── Salary branch ───────────────────────────────────────────
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/salary',
              builder: (context, state) => const SalaryPage(),
            ),
          ],
        ),
      ],
    ),
  ],
);