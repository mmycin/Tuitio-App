import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'package:tuitio/core/database/database.dart';
import 'package:tuitio/core/database/database_provider.dart';
import 'package:tuitio/features/students/student_providers.dart';
import 'package:tuitio/features/students/student_form_modal.dart';

// ── Providers ────────────────────────────────────────────────────────────────

final _studentByIdProvider =
    FutureProvider.family<Student?, int>((ref, id) {
  return ref.watch(studentDaoProvider).getStudentById(id);
});

final _cyclesForStudentProvider =
    StreamProvider.family<List<PaymentCycle>, int>((ref, studentId) {
  return ref.watch(cyclesDaoProvider).watchCyclesForStudent(studentId);
});

final _classesForStudentProvider =
    StreamProvider.family<List<ClassesData>, int>((ref, studentId) {
  return ref.watch(classesDaoProvider).watchClassesForStudent(studentId);
});

// ── Page ────────────────────────────────────────────────────────────────────

class StudentDetailPage extends ConsumerWidget {
  final int studentId;
  const StudentDetailPage({super.key, required this.studentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ShadTheme.of(context);
    final studentAsync = ref.watch(_studentByIdProvider(studentId));
    final cyclesAsync = ref.watch(_cyclesForStudentProvider(studentId));
    final classesAsync = ref.watch(_classesForStudentProvider(studentId));

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: studentAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (student) {
          if (student == null) {
            return const Center(child: Text('Student not found'));
          }
          return _StudentDetailBody(
            student: student,
            cyclesAsync: cyclesAsync,
            classesAsync: classesAsync,
          );
        },
      ),
    );
  }
}

class _StudentDetailBody extends ConsumerWidget {
  final Student student;
  final AsyncValue<List<PaymentCycle>> cyclesAsync;
  final AsyncValue<List<ClassesData>> classesAsync;

  const _StudentDetailBody({
    required this.student,
    required this.cyclesAsync,
    required this.classesAsync,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ShadTheme.of(context);

    return CustomScrollView(
      slivers: [
        // ── App bar ────────────────────────────────────────────────────
        SliverAppBar(
          backgroundColor: theme.colorScheme.background,
          surfaceTintColor: Colors.transparent,
          floating: true,
          leading: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(LucideIcons.arrowLeft),
          ),
          title: Text(
            student.name,
            style: theme.textTheme.h4.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: IconButton(
                onPressed: () =>
                    showStudentFormModal(context, ref, student: student),
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    LucideIcons.pencil,
                    size: 16,
                    color: theme.colorScheme.primary,
                  ),
                ),
                tooltip: 'Edit Student',
              ),
            ),
          ],
        ),

        // ── Student info card ──────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: _StudentInfoCard(student: student),
          ),
        ),

        // ── Payment Cycle History Section Header ───────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 10),
            child: Row(
              children: [
                Icon(
                  LucideIcons.receipt,
                  size: 18,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Payment Cycles',
                  style: theme.textTheme.h4.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),

        // ── Cycle list ─────────────────────────────────────────────────
        cyclesAsync.when(
          loading: () => const SliverToBoxAdapter(
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => SliverToBoxAdapter(
            child: Center(child: Text('Error: $e')),
          ),
          data: (cycles) {
            if (cycles.isEmpty) {
              return SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'No payment cycles recorded.',
                      style: theme.textTheme.muted,
                    ),
                  ),
                ),
              );
            }

            return SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              sliver: SliverList.separated(
                itemCount: cycles.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, i) {
                  final cycleNumber = cycles.length - i;
                  return _CycleHistoryRow(
                    cycle: cycles[i],
                    cycleNumber: cycleNumber,
                    classesPerCycle: student.classesPerMonth,
                  );
                },
              ),
            );
          },
        ),

        // ── Detailed Class History Section Header ──────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 28, 16, 10),
            child: Row(
              children: [
                Icon(
                  LucideIcons.calendarCheck2,
                  size: 18,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Logged Class History',
                  style: theme.textTheme.h4.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),

        // ── Detailed Class Sessions List (Date & Time) ─────────────────
        classesAsync.when(
          loading: () => const SliverToBoxAdapter(
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => SliverToBoxAdapter(
            child: Center(child: Text('Error loading class logs: $e')),
          ),
          data: (classList) {
            if (classList.isEmpty) {
              return SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.card,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: theme.colorScheme.border),
                    ),
                    child: Center(
                      child: Text(
                        'No class sessions logged yet.',
                        style: theme.textTheme.muted,
                      ),
                    ),
                  ),
                ),
              );
            }

            return SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              sliver: SliverList.separated(
                itemCount: classList.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, i) {
                  return _ClassSessionTile(
                    classData: classList[i],
                    indexNumber: classList.length - i,
                  );
                },
              ),
            );
          },
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 32)),
      ],
    );
  }
}

// ── Student info card ────────────────────────────────────────────────────────

class _StudentInfoCard extends StatelessWidget {
  final Student student;
  const _StudentInfoCard({required this.student});

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: Text(
              student.name.trim().split(' ').map((w) => w[0]).take(2).join().toUpperCase(),
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            ),
          ),
          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student.name,
                  style: theme.textTheme.p.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 12,
                  runSpacing: 4,
                  children: [
                    if (student.phone != null)
                      _InfoChip(
                        icon: LucideIcons.phone,
                        label: student.phone!,
                      ),
                    if (student.monthlyFee != null)
                      _InfoChip(
                        icon: LucideIcons.banknote,
                        label: '৳${student.monthlyFee}',
                      ),
                    _InfoChip(
                      icon: LucideIcons.hash,
                      label: '${student.classesPerMonth} classes/cycle',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: theme.colorScheme.mutedForeground),
        const SizedBox(width: 4),
        Text(
          label,
          style: theme.textTheme.muted.copyWith(fontSize: 12),
        ),
      ],
    );
  }
}

// ── Cycle history row ────────────────────────────────────────────────────────

class _CycleHistoryRow extends ConsumerWidget {
  final PaymentCycle cycle;
  final int cycleNumber;
  final int classesPerCycle;

  const _CycleHistoryRow({
    required this.cycle,
    required this.cycleNumber,
    required this.classesPerCycle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ShadTheme.of(context);

    final bool thresholdReached = cycle.totalClasses >= classesPerCycle;
    final Color accentColor = cycle.isPaid
        ? const Color(0xFF10B981) // Emerald Green
        : thresholdReached
            ? const Color(0xFFF59E0B) // Amber
            : theme.colorScheme.mutedForeground;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      decoration: BoxDecoration(
        color: theme.colorScheme.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: cycle.isPaid
              ? const Color(0xFF10B981).withValues(alpha: 0.5)
              : thresholdReached
                  ? const Color(0xFFF59E0B).withValues(alpha: 0.5)
                  : theme.colorScheme.border,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            // Cycle Pill
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Text(
                '#$cycleNumber',
                style: TextStyle(
                  color: accentColor,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Cycle Details (No confusing "+2 extra" badge)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Cycle $cycleNumber',
                    style: theme.textTheme.p.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        '${cycle.totalClasses}/$classesPerCycle classes',
                        style: theme.textTheme.muted.copyWith(fontSize: 12),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '• ${_formatDate(cycle.startedAt)}',
                        style: theme.textTheme.muted.copyWith(fontSize: 12),
                      ),
                      if (cycle.paidAt != null) ...[
                        Text(
                          ' → ${_formatDate(cycle.paidAt!)}',
                          style: theme.textTheme.muted.copyWith(fontSize: 12),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            // Paid toggle (only when threshold met or already paid)
            if (thresholdReached || cycle.isPaid)
              _PaidToggle(cycle: cycle)
            else
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.muted,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Ongoing',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.mutedForeground,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[dt.month - 1]} ${dt.day}';
  }
}

// ── Paid toggle ────────────────────────────────────────────────────────────

class _PaidToggle extends ConsumerStatefulWidget {
  final PaymentCycle cycle;
  const _PaidToggle({required this.cycle});

  @override
  ConsumerState<_PaidToggle> createState() => _PaidToggleState();
}

class _PaidToggleState extends ConsumerState<_PaidToggle> {
  bool _working = false;

  Future<void> _toggle() async {
    if (_working) return;
    setState(() => _working = true);

    try {
      final db = ref.read(databaseProvider);
      final cyclesDao = db.paymentCyclesDao;

      if (widget.cycle.isPaid) {
        await cyclesDao.markUnpaid(widget.cycle.id);
      } else {
        final totalClasses = await cyclesDao.markPaid(widget.cycle.id);
        final studentDao = db.studentDao;
        final student =
            await studentDao.getStudentById(widget.cycle.studentId);
        if (student != null) {
          final carryover =
              (totalClasses - student.classesPerMonth).clamp(0, totalClasses);
          await cyclesDao.createCycle(
            studentId: widget.cycle.studentId,
            startingCount: carryover,
          );
        }
      }

      ref.invalidate(dashboardStudentsProvider);
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final isPaid = widget.cycle.isPaid;

    return GestureDetector(
      onTap: _toggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isPaid
              ? const Color(0xFF10B981).withValues(alpha: 0.12)
              : theme.colorScheme.muted,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isPaid
                ? const Color(0xFF10B981)
                : theme.colorScheme.border,
          ),
        ),
        child: _working
            ? const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isPaid ? LucideIcons.circleCheck : LucideIcons.circle,
                    size: 13,
                    color: isPaid
                        ? const Color(0xFF10B981)
                        : theme.colorScheme.mutedForeground,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    isPaid ? 'Paid' : 'Unpaid',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: isPaid
                          ? const Color(0xFF10B981)
                          : theme.colorScheme.mutedForeground,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

// ── Class Session Tile (Date & Time log) ───────────────────────────────────

class _ClassSessionTile extends StatelessWidget {
  final ClassesData classData;
  final int indexNumber;

  const _ClassSessionTile({
    required this.classData,
    required this.indexNumber,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final dt = classData.startedAt;

    final String dayName = _getDayName(dt.weekday);
    final String monthName = _getMonthName(dt.month);
    final String timeStr = _formatTime(dt);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.border.withValues(alpha: 0.7)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          // Class counter badge
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Text(
              '#$indexNumber',
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Date & Time details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '$dayName, $monthName ${dt.day}, ${dt.year}',
                      style: theme.textTheme.p.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.muted,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            LucideIcons.clock,
                            size: 10,
                            color: theme.colorScheme.mutedForeground,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            timeStr,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.mutedForeground,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (classData.notes != null && classData.notes!.trim().isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    classData.notes!,
                    style: theme.textTheme.muted.copyWith(fontSize: 12),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getDayName(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[(weekday - 1) % 7];
  }

  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return months[(month - 1) % 12];
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour == 0 ? 12 : (dt.hour > 12 ? dt.hour - 12 : dt.hour);
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }
}
