import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:tuitio/features/students/student_form_provider.dart';

class StudentFormPage extends ConsumerStatefulWidget {
  const StudentFormPage({super.key});

  @override
  ConsumerState<StudentFormPage> createState() => _StudentFormPageState();
}

class _StudentFormPageState extends ConsumerState<StudentFormPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _monthlyFeeController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _monthlyFeeController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if(!_formKey.currentState!.validate()) return;

    final monthlyFee = int.tryParse(_monthlyFeeController.text.trim());
    if(monthlyFee == null) return;

    await ref.read(studentFormProvider.notifier).createStudent(
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
      monthlyFee: monthlyFee,
    );

    if(!mounted) return;

    final state = ref.read(studentFormProvider);

    if(state.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save student: ${state.error}'),
        )
      );
      return;
    }
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(studentFormProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Student'),
      ),

      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                ),
                validator: (value) {
                  if(value == null || value.trim().isEmpty) {
                    return 'Name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone',
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _monthlyFeeController,
                decoration: const InputDecoration(
                  labelText: 'Monthly Fee',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: state.isLoading ? null : _save,
                  child: state.isLoading ? const CircularProgressIndicator() : const Text('Save'),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}