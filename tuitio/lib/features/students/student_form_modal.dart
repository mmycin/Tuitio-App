import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'package:tuitio/core/database/database.dart';
import 'package:tuitio/features/students/student_form_provider.dart';
import 'package:tuitio/features/students/student_providers.dart';

/// Opens the student create/edit bottom sheet.
///
/// Pass [student] to open in edit mode; omit for create mode.
Future<void> showStudentFormModal(
  BuildContext context,
  WidgetRef ref, {
  Student? student,
}) async {
  await showShadSheet(
    context: context,
    side: ShadSheetSide.bottom,
    builder: (ctx) => _StudentFormSheet(student: student),
  );
  ref.invalidate(studentsProvider);
  ref.invalidate(dashboardStudentsProvider);
}

class _StudentFormSheet extends ConsumerStatefulWidget {
  final Student? student;
  const _StudentFormSheet({this.student});

  @override
  ConsumerState<_StudentFormSheet> createState() => _StudentFormSheetState();
}

class _StudentFormSheetState extends ConsumerState<_StudentFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _feeCtrl;
  late final TextEditingController _classesCtrl;

  bool get _isEditing => widget.student != null;

  @override
  void initState() {
    super.initState();
    final s = widget.student;
    _nameCtrl = TextEditingController(text: s?.name ?? '');
    _phoneCtrl = TextEditingController(text: s?.phone ?? '');
    _feeCtrl =
        TextEditingController(text: s?.monthlyFee?.toString() ?? '');
    _classesCtrl = TextEditingController(
        text: s?.classesPerMonth.toString() ?? '12');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _feeCtrl.dispose();
    _classesCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameCtrl.text.trim();
    final phone =
        _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim();
    final fee = int.tryParse(_feeCtrl.text.trim());
    final classes = int.tryParse(_classesCtrl.text.trim()) ?? 12;

    final notifier = ref.read(studentFormProvider.notifier);

    if (_isEditing) {
      await notifier.updateStudent(
        student: widget.student!,
        name: name,
        phone: phone,
        monthlyFee: fee,
        classesPerMonth: classes,
      );
    } else {
      await notifier.createStudent(
        name: name,
        phone: phone,
        monthlyFee: fee,
        classesPerMonth: classes,
      );
    }

    if (!mounted) return;
    final state = ref.read(studentFormProvider);
    if (state.hasError) {
      ShadToaster.of(context).show(
        ShadToast.destructive(
          title: const Text('Error'),
          description: Text(state.error.toString()),
        ),
      );
      return;
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final formState = ref.watch(studentFormProvider);

    return ShadSheet(
      title: Text(
        _isEditing ? 'Edit Student' : 'New Student',
        style: theme.textTheme.h4,
      ),
      description: Text(
        _isEditing
            ? 'Update ${widget.student!.name}\'s information.'
            : 'Fill in the details below to add a new student.',
        style: theme.textTheme.muted,
      ),
      child: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Name
              _FormField(
                label: 'Full Name *',
                child: ShadInput(
                  controller: _nameCtrl,
                  placeholder: const Text('e.g. Rahim Uddin'),
                  leading: const Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: Icon(LucideIcons.user, size: 16),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Phone
              _FormField(
                label: 'Phone',
                child: ShadInput(
                  controller: _phoneCtrl,
                  placeholder: const Text('e.g. 01XXXXXXXXX'),
                  keyboardType: TextInputType.phone,
                  leading: const Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: Icon(LucideIcons.phone, size: 16),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Monthly fee + classes per cycle in a row
              Row(
                children: [
                  Expanded(
                    child: _FormField(
                      label: 'Monthly Fee',
                      child: ShadInput(
                        controller: _feeCtrl,
                        placeholder: const Text('৳ Amount'),
                        keyboardType: TextInputType.number,
                        leading: const Padding(
                          padding: EdgeInsets.only(left: 8),
                          child: Icon(LucideIcons.banknote, size: 16),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _FormField(
                      label: 'Classes / Cycle',
                      child: ShadInput(
                        controller: _classesCtrl,
                        placeholder: const Text('e.g. 12'),
                        keyboardType: TextInputType.number,
                        leading: const Padding(
                          padding: EdgeInsets.only(left: 8),
                          child: Icon(LucideIcons.hash, size: 16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Submit
              ShadButton(
                onPressed: formState.isLoading ? null : _submit,
                child: formState.isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(_isEditing ? 'Save Changes' : 'Create Student'),
              ),

              // Delete button (edit mode only)
              if (_isEditing) ...[
                const SizedBox(height: 8),
                ShadButton.destructive(
                  onPressed: formState.isLoading
                      ? null
                      : () => _confirmDelete(context),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(LucideIcons.trash2, size: 14),
                      SizedBox(width: 8),
                      Text('Delete Student'),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final navigator = Navigator.of(context);
    final confirmed = await showShadDialog<bool>(
      context: context,
      builder: (ctx) => ShadDialog.alert(
        title: const Text('Delete student?'),
        description: Text(
          'This will permanently delete ${widget.student!.name} '
          'and all their class history. This cannot be undone.',
        ),
        actions: [
          ShadButton.outline(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ShadButton.destructive(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;
    await ref
        .read(studentFormProvider.notifier)
        .deleteStudent(widget.student!.id);
    navigator.pop();
  }
}

class _FormField extends StatelessWidget {
  final String label;
  final Widget child;
  const _FormField({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.small.copyWith(
            color: theme.colorScheme.mutedForeground,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}
