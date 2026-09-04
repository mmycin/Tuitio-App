import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'package:tuitio/features/dashboard/dashboard_providers.dart';
import 'package:tuitio/core/widgets/student_class_card.dart';
import 'package:tuitio/features/students/student_form_modal.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ShadTheme.of(context);
    final data = ref.watch(dashboardStudentsProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      floatingActionButton: FloatingActionButton(
        onPressed: () => showStudentFormModal(context, ref),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(LucideIcons.plus, size: 24),
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(dashboardStudentsProvider),
        child: CustomScrollView(
          slivers: [
            // ── Header bar ───────────────────────────────────────────────
            SliverAppBar(
              backgroundColor: theme.colorScheme.background,
              surfaceTintColor: Colors.transparent,
              floating: true,
              snap: true,
              titleSpacing: 20,
              toolbarHeight: 64,
              title: Row(
                children: [
                  // Modern App Icon Badge
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFEA580C), Color(0xFFFB923C)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFEA580C).withValues(alpha: 0.35),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      LucideIcons.graduationCap,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Gradient Typography for Tuitio
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [Color(0xFFEA580C), Color(0xFFF97316)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ).createShader(bounds),
                        child: const Text(
                          'Tuitio',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.8,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Text(
                        'Class & Payment Tracker',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.mutedForeground,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Full-width vertically stacked student cards list ──────────
            data.when(
              loading: () => const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (err, stack) => SliverFillRemaining(
                child: Center(
                  child: Text(
                    'Error loading dashboard: $err',
                    style: TextStyle(color: theme.colorScheme.destructive),
                  ),
                ),
              ),
              data: (models) {
                if (models.isEmpty) {
                  return SliverFillRemaining(
                    child: _EmptyState(
                      onAddStudent: () => showStudentFormModal(context, ref),
                    ),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                  sliver: SliverList.separated(
                    itemCount: models.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final model = models[index];
                      return StudentClassCard(
                        model: model,
                        onTap: () =>
                            context.push('/students/${model.student.id}'),
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ── Empty state widget ───────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final VoidCallback onAddStudent;
  const _EmptyState({required this.onAddStudent});

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(24),
              ),
              alignment: Alignment.center,
              child: Icon(
                LucideIcons.graduationCap,
                size: 40,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No Students Added Yet',
              style: theme.textTheme.h4.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add a student to start tracking their classes and billing cycles.',
              textAlign: TextAlign.center,
              style: theme.textTheme.muted,
            ),
            const SizedBox(height: 24),
            IconButton(
              onPressed: onAddStudent,
              icon: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  LucideIcons.userPlus,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              tooltip: 'Add Student',
            ),
          ],
        ),
      ),
    );
  }
}