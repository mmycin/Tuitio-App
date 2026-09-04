import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'package:tuitio/core/database/database_provider.dart';
import 'package:tuitio/features/students/student_providers.dart';
import 'package:tuitio/features/dashboard/add_class_modal.dart';
import 'package:tuitio/features/salary/salary_providers.dart';

/// Full-width student card for the dashboard vertical list layout.
class StudentClassCard extends ConsumerStatefulWidget {
  final DashboardStudentModel model;
  final VoidCallback? onTap;

  const StudentClassCard({
    super.key,
    required this.model,
    this.onTap,
  });

  @override
  ConsumerState<StudentClassCard> createState() => _StudentClassCardState();
}

class _StudentClassCardState extends ConsumerState<StudentClassCard> {
  bool _togglingPaid = false;

  Future<void> _togglePaid() async {
    final cycle = widget.model.activeCycle;
    if (cycle == null || _togglingPaid) return;

    setState(() => _togglingPaid = true);
    try {
      final db = ref.read(databaseProvider);
      final cyclesDao = db.paymentCyclesDao;

      if (cycle.isPaid) {
        await cyclesDao.markUnpaid(cycle.id);
      } else {
        final totalClasses = await cyclesDao.markPaid(cycle.id);
        final student =
            await db.studentDao.getStudentById(cycle.studentId);
        if (student != null) {
          final carryover =
              (totalClasses - student.classesPerMonth).clamp(0, totalClasses);
          await cyclesDao.createCycle(
            studentId: cycle.studentId,
            startingCount: carryover,
          );
        }
      }
      // Re-evaluate providers across dashboard & salary tabs
      ref.invalidate(dashboardStudentsProvider);
      ref.invalidate(salaryRecordsProvider);
    } finally {
      if (mounted) setState(() => _togglingPaid = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final model = widget.model;
    final student = model.student;
    final cycle = model.activeCycle;

    final bool thresholdReached = model.classCount >= model.classesPerCycle;
    final bool isPaid = model.isPaid;

    final Color accentColor;
    final String statusLabel;

    if (isPaid) {
      accentColor = const Color(0xFF10B981); // Emerald Green
      statusLabel = 'Paid';
    } else if (thresholdReached) {
      accentColor = const Color(0xFFF59E0B); // Warm Amber
      statusLabel = 'Payment Due';
    } else {
      accentColor = theme.colorScheme.primary; // Brand Orange
      statusLabel = 'Active';
    }

    final double progress = (model.classCount / model.classesPerCycle).clamp(0.0, 1.0);

    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        decoration: BoxDecoration(
          color: theme.colorScheme.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isPaid
                ? const Color(0xFF10B981)
                : thresholdReached
                    ? const Color(0xFFF59E0B)
                    : theme.colorScheme.border.withValues(alpha: 0.7),
            width: isPaid || thresholdReached ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: accentColor.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header Row: Avatar, Student Name, Status & Pay Toggle
              Row(
                children: [
                  _Avatar(name: student.name, color: accentColor),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          student.name,
                          style: theme.textTheme.p.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: theme.colorScheme.foreground,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: accentColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              statusLabel,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: accentColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Pay / Paid Toggle Button (Visible when minimum class threshold met)
                  if (thresholdReached)
                    InkWell(
                      onTap: _togglePaid,
                      borderRadius: BorderRadius.circular(8),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isPaid
                              ? const Color(0xFF10B981).withValues(alpha: 0.12)
                              : const Color(0xFFF59E0B).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isPaid
                                ? const Color(0xFF10B981)
                                : const Color(0xFFF59E0B),
                          ),
                        ),
                        child: _togglingPaid
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    isPaid
                                        ? LucideIcons.circleCheck
                                        : LucideIcons.circleAlert,
                                    size: 14,
                                    color: isPaid
                                        ? const Color(0xFF10B981)
                                        : const Color(0xFFD97706),
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    isPaid ? 'Paid' : 'Pay',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: isPaid
                                          ? const Color(0xFF10B981)
                                          : const Color(0xFFD97706),
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 14),

              // ── Class Counter & Quick Action Controls Row ────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '${model.classCount}',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: accentColor,
                          height: 1,
                        ),
                      ),
                      Text(
                        ' / ${model.classesPerCycle} classes',
                        style: theme.textTheme.muted.copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),

                  // Undo (-) & Add (+) Icon Buttons
                  Row(
                    children: [
                      // Subtract Button
                      InkWell(
                        onTap: cycle == null || model.classCount <= 0
                            ? null
                            : () => _subtractClass(context),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.muted,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            LucideIcons.minus,
                            size: 16,
                            color: theme.colorScheme.foreground,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Add Button
                      InkWell(
                        onTap: cycle == null
                            ? null
                            : () => showAddClassModal(context, ref, model),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: theme.colorScheme.primary
                                    .withValues(alpha: 0.3),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            LucideIcons.plus,
                            size: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // ── Progress Indicator ───────────────────────────────────
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: theme.colorScheme.muted,
                  valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                  minHeight: 6,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _subtractClass(BuildContext context) async {
    final cycle = widget.model.activeCycle;
    if (cycle == null || widget.model.classCount <= 0) return;

    final confirmed = await showShadDialog<bool>(
      context: context,
      builder: (ctx) => ShadDialog.alert(
        title: const Text('Remove last class?'),
        description: const Text(
          'This will delete the most recently logged class entry.',
        ),
        actions: [
          ShadButton.outline(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ShadButton.destructive(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final db = ref.read(databaseProvider);
    final deleted =
        await db.classesDao.deleteLatestClassForStudent(widget.model.student.id);
    if (deleted) {
      await db.paymentCyclesDao.decrementClassCount(cycle.id);
    }
    ref.invalidate(dashboardStudentsProvider);
  }
}

class _Avatar extends StatelessWidget {
  final String name;
  final Color color;
  const _Avatar({required this.name, required this.color});

  @override
  Widget build(BuildContext context) {
    final initials = name.trim().isEmpty
        ? '?'
        : name.trim().split(' ').map((w) => w[0]).take(2).join().toUpperCase();

    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w800,
          fontSize: 15,
        ),
      ),
    );
  }
}
