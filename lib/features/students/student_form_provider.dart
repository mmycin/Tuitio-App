import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';

import 'package:tuitio/core/database/database.dart';
import 'package:tuitio/features/students/student_providers.dart';

final studentFormProvider =
    AsyncNotifierProvider<StudentFormNotifier, void>(
  StudentFormNotifier.new,
);

class StudentFormNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  /// Create a new student and automatically start their first payment cycle.
  Future<void> createStudent({
    required String name,
    String? phone,
    int? monthlyFee,
    int classesPerMonth = 12,
  }) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final studentDao = ref.read(studentDaoProvider);
      final cyclesDao = ref.read(cyclesDaoProvider);

      final studentId = await studentDao.insertStudent(
        StudentsCompanion.insert(
          name: name,
          phone: Value(phone),
          monthlyFee: Value(monthlyFee),
          classesPerMonth: Value(classesPerMonth),
        ),
      );

      // Auto-create the first payment cycle.
      await cyclesDao.createCycle(studentId: studentId);

      ref.invalidate(studentsProvider);
      ref.invalidate(dashboardStudentsProvider);
    });
  }

  /// Update an existing student's info (does NOT touch cycles).
  Future<void> updateStudent({
    required Student student,
    required String name,
    String? phone,
    int? monthlyFee,
    int? classesPerMonth,
  }) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      await ref.read(studentDaoProvider).updateStudent(
            StudentsCompanion(
              id: Value(student.id),
              name: Value(name),
              phone: Value(phone),
              monthlyFee: Value(monthlyFee),
              classesPerMonth: Value(classesPerMonth ?? student.classesPerMonth),
            ),
          );

      ref.invalidate(studentsProvider);
      ref.invalidate(dashboardStudentsProvider);
    });
  }

  /// Delete a student and all their data.
  Future<void> deleteStudent(int id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(studentDaoProvider).deleteStudent(id);
      ref.invalidate(studentsProvider);
      ref.invalidate(dashboardStudentsProvider);
    });
  }
}
