import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'package:tuitio/features/students/student_providers.dart';
import 'package:tuitio/features/students/student_form_modal.dart';

class StudentsPage extends ConsumerWidget {
  const StudentsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ShadTheme.of(context);
    final studentsAsync = ref.watch(studentsProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      // Single Floating Action Button for adding students
      floatingActionButton: FloatingActionButton(
        onPressed: () => showStudentFormModal(context, ref),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(LucideIcons.userPlus, size: 22),
      ),
      body: CustomScrollView(
        slivers: [
          // ── App bar ─────────────────────────────────────────────────────
          SliverAppBar(
            backgroundColor: theme.colorScheme.background,
            surfaceTintColor: Colors.transparent,
            floating: true,
            snap: true,
            titleSpacing: 20,
            title: Text(
              'Students',
              style: theme.textTheme.h3.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
                color: theme.colorScheme.foreground,
              ),
            ),
            // Removed redundant top-right action button to keep ONLY ONE add button (the FAB)
          ),

          // ── Body ────────────────────────────────────────────────────────
          studentsAsync.when(
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => SliverFillRemaining(
              child: Center(child: Text('Error: $e')),
            ),
            data: (students) {
              if (students.isEmpty) {
                return SliverFillRemaining(
                  child: _EmptyStudents(
                    onAdd: () => showStudentFormModal(context, ref),
                  ),
                );
              }

              return SliverPadding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                sliver: SliverList.separated(
                  itemCount: students.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final student = students[i];
                    return _StudentListTile(
                      student: student,
                      onTap: () => context.push('/students/${student.id}'),
                      onEdit: () => showStudentFormModal(
                        context,
                        ref,
                        student: student,
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ── Tile ────────────────────────────────────────────────────────────────────

class _StudentListTile extends StatelessWidget {
  final dynamic student;
  final VoidCallback onTap;
  final VoidCallback onEdit;

  const _StudentListTile({
    required this.student,
    required this.onTap,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    final initials = (student.name as String).trim().isEmpty
        ? '?'
        : (student.name as String)
            .trim()
            .split(' ')
            .map((w) => w[0])
            .take(2)
            .join()
            .toUpperCase();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.colorScheme.border.withValues(alpha: 0.7),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              // Avatar
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(
                  initials,
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student.name as String,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.p.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        if (student.phone != null)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                LucideIcons.phone,
                                size: 11,
                                color: theme.colorScheme.mutedForeground,
                              ),
                              const SizedBox(width: 3),
                              ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 110),
                                child: Text(
                                  student.phone as String,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.muted
                                      .copyWith(fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        if (student.monthlyFee != null)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                LucideIcons.banknote,
                                size: 11,
                                color: theme.colorScheme.mutedForeground,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                '৳${student.monthlyFee}',
                                style: theme.textTheme.muted
                                    .copyWith(fontSize: 12),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              // Action Icons
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: onEdit,
                    icon: Icon(
                      LucideIcons.pencil,
                      size: 16,
                      color: theme.colorScheme.mutedForeground,
                    ),
                    visualDensity: VisualDensity.compact,
                    tooltip: 'Edit',
                  ),
                  IconButton(
                    onPressed: onTap,
                    icon: Icon(
                      LucideIcons.chevronRight,
                      size: 18,
                      color: theme.colorScheme.primary,
                    ),
                    visualDensity: VisualDensity.compact,
                    tooltip: 'Details',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Empty state ──────────────────────────────────────────────────────────────

class _EmptyStudents extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyStudents({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              LucideIcons.users,
              size: 32,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No students yet',
            style: theme.textTheme.h4.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            'Add your first student to get started.',
            style: theme.textTheme.muted,
          ),
          const SizedBox(height: 20),
          IconButton(
            onPressed: onAdd,
            icon: Container(
              padding: const EdgeInsets.all(12),
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
                size: 20,
              ),
            ),
            tooltip: 'Add Student',
          ),
        ],
      ),
    );
  }
}
