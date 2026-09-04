import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import 'package:tuitio/core/database/database.dart';

import 'package:tuitio/features/students/student_providers.dart';

final studentFormProvider = AsyncNotifierProvider<StudentFormNotifier, void>(
  StudentFormNotifier.new,
);

class StudentFormNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> createStudent({
    required String name,
    String? phone,
    int? monthlyFee,
  }) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      await ref
          .read(studentDaoProvider)
          .insertStudent(
            StudentsCompanion.insert(
              name: name,
              phone: Value(phone),
              monthlyFee: Value(monthlyFee),
            ),
          );

      // Refresh the student list.
      ref.invalidate(studentsProvider);
    });
  }
}
