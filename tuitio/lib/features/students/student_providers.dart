import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:tuitio/core/database/database.dart';
import 'package:tuitio/core/database/database_provider.dart';
import 'package:tuitio/core/database/daos/student_dao.dart';
import 'package:tuitio/core/database/daos/payment_cycles_dao.dart';
import 'package:tuitio/core/database/daos/classes_dao.dart';

// ── DAO providers ───────────────────────────────────────────────────────────

final studentDaoProvider = Provider<StudentDao>((ref) {
  return ref.watch(databaseProvider).studentDao;
});

final cyclesDaoProvider = Provider<PaymentCyclesDao>((ref) {
  return ref.watch(databaseProvider).paymentCyclesDao;
});

final classesDaoProvider = Provider<ClassesDao>((ref) {
  return ref.watch(databaseProvider).classesDao;
});

// ── Data providers ──────────────────────────────────────────────────────────

final studentsProvider = FutureProvider<List<Student>>((ref) {
  return ref.watch(studentDaoProvider).getAllStudents();
});

/// Combined model for a student + their active cycle.
class DashboardStudentModel {
  final Student student;
  final PaymentCycle? activeCycle;

  const DashboardStudentModel({
    required this.student,
    required this.activeCycle,
  });

  int get classCount => activeCycle?.totalClasses ?? 0;
  int get classesPerCycle => student.classesPerMonth;

  /// True if class count meets or exceeds the contracted amount.
  bool get isAtCapacity => classCount >= classesPerCycle;

  /// True if payment is due (at/over capacity AND not paid).
  bool get isPaymentDue => isAtCapacity && !(activeCycle?.isPaid ?? true);

  /// True if the current cycle is paid.
  bool get isPaid => activeCycle?.isPaid ?? false;
}

/// Stream of all students enriched with their active payment cycle.
final dashboardStudentsProvider =
    StreamProvider<List<DashboardStudentModel>>((ref) async* {
  final studentDao = ref.watch(studentDaoProvider);
  final cyclesDao = ref.watch(cyclesDaoProvider);

  final students = await studentDao.getAllStudents();

  // For each student, fetch active cycle and combine.
  final models = await Future.wait(
    students.map((s) async {
      final cycle = await cyclesDao.getActiveCycle(s.id);
      return DashboardStudentModel(student: s, activeCycle: cycle);
    }),
  );

  yield models;

  // Re-yield when either students or cycles change.
  // We use a simple polling / re-read approach here —
  // for full reactivity users can pull-to-refresh.
});