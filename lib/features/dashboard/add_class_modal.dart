import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:drift/drift.dart' hide Column;

import 'package:tuitio/core/database/database.dart';
import 'package:tuitio/core/database/database_provider.dart';
import 'package:tuitio/features/students/student_providers.dart';

/// Opens the Add Class bottom sheet for a given student.
/// Call this from the dashboard card's [+] button.
Future<void> showAddClassModal(
  BuildContext context,
  WidgetRef ref,
  DashboardStudentModel model,
) async {
  await showShadSheet(
    context: context,
    side: ShadSheetSide.bottom,
    builder: (ctx) => _AddClassSheet(model: model),
  );
  // Re-fetch dashboard data after close.
  ref.invalidate(dashboardStudentsProvider);
}

class _AddClassSheet extends ConsumerStatefulWidget {
  final DashboardStudentModel model;
  const _AddClassSheet({required this.model});

  @override
  ConsumerState<_AddClassSheet> createState() => _AddClassSheetState();
}

class _AddClassSheetState extends ConsumerState<_AddClassSheet> {
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  final _notesController = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = now;
    _selectedTime = TimeOfDay.fromDateTime(now);
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving) return;

    final cycle = widget.model.activeCycle;
    if (cycle == null) {
      _showError('No active payment cycle found. Please contact support.');
      return;
    }

    setState(() => _saving = true);

    try {
      final db = ref.read(databaseProvider);
      final startedAt = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      // Insert class session.
      await db.classesDao.insertClass(
        ClassesCompanion.insert(
          studentId: widget.model.student.id,
          cycleId: cycle.id,
          startedAt: startedAt,
          notes: Value(_notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim()),
        ),
      );

      // Increment the cycle count.
      await db.paymentCyclesDao.incrementClassCount(cycle.id);

      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) _showError(e.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showError(String message) {
    ShadToaster.of(context).show(
      ShadToast.destructive(
        title: const Text('Error'),
        description: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return ShadSheet(
      title: Text(
        'Add Class',
        style: theme.textTheme.h4,
      ),
      description: Text(
        widget.model.student.name,
        style: theme.textTheme.muted,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Date picker ───────────────────────────────────────────────
            _SectionLabel('Date'),
            const SizedBox(height: 8),
            ShadButton.outline(
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now().add(const Duration(days: 1)),
                );
                if (picked != null) setState(() => _selectedDate = picked);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_formatDate(_selectedDate)),
                  const Icon(LucideIcons.calendarDays, size: 16),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Time picker ───────────────────────────────────────────────
            _SectionLabel('Time'),
            const SizedBox(height: 8),
            ShadButton.outline(
              onPressed: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: _selectedTime,
                );
                if (picked != null) setState(() => _selectedTime = picked);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_selectedTime.format(context)),
                  const Icon(LucideIcons.clock, size: 16),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Notes ─────────────────────────────────────────────────────
            _SectionLabel('Notes (optional)'),
            const SizedBox(height: 8),
            ShadInput(
              controller: _notesController,
              placeholder: const Text('e.g. Covered chapter 5'),
              maxLines: 2,
            ),
            const SizedBox(height: 24),

            // ── Submit ────────────────────────────────────────────────────
            ShadButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Add Class'),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return Text(
      text,
      style: theme.textTheme.small.copyWith(
        color: theme.colorScheme.mutedForeground,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
