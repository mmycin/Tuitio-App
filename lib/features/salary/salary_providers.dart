import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tuitio/core/database/database.dart';
import 'package:tuitio/features/students/student_providers.dart';

class SalaryRecord {
  final Student student;
  final PaymentCycle cycle;

  const SalaryRecord({
    required this.student,
    required this.cycle,
  });

  int get amount => student.monthlyFee ?? 0;
  DateTime get paidAt => cycle.paidAt ?? cycle.startedAt;
}

/// Reactive database stream that automatically emits updated salary records
/// whenever any payment cycle is marked paid or unpaid in real time.
final salaryRecordsProvider = StreamProvider<List<SalaryRecord>>((ref) {
  final cyclesDao = ref.watch(cyclesDaoProvider);

  return cyclesDao.watchPaidCyclesWithStudents().map((rows) {
    return rows.map((row) {
      final cycle = row.readTable(cyclesDao.paymentCycles);
      final student = row.readTable(cyclesDao.students);
      return SalaryRecord(student: student, cycle: cycle);
    }).toList();
  });
});

final totalSalaryProvider = Provider<int>((ref) {
  final recordsAsync = ref.watch(salaryRecordsProvider);
  return recordsAsync.when(
    data: (records) => records.fold<int>(0, (sum, r) => sum + r.amount),
    loading: () => 0,
    error: (err, stack) => 0,
  );
});
