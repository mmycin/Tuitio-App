import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:tuitio/features/students/student_providers.dart';

class StudentsPage extends ConsumerWidget {
  const StudentsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final students = ref.watch(studentsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Students')),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/students/new');
        },
        child: const Icon(Icons.add),
      ),

      body: students.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('Error: $error')),

        data: (students) {
          if (students.isEmpty) {
            return const Center(child: Text('No students yet'));
          }

          return ListView.builder(
            itemCount: students.length,
            itemBuilder: (context, index) {
              final student = students[index];

              return ListTile(
                title: Text(student.name),
                subtitle: Text(student.phone ?? 'No phone number'),
                onTap: () {},
              );
            },
          );
        },
      ),
    );
  }
}
