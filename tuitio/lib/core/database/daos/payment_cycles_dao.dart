import 'package:drift/drift.dart';

import 'package:tuitio/core/database/database.dart';
import 'package:tuitio/core/database/tables/payment_cycles.dart';

import 'package:tuitio/core/database/tables/students.dart';

part 'payment_cycles_dao.g.dart';

@DriftAccessor(tables: [PaymentCycles, Students])
class PaymentCyclesDao extends DatabaseAccessor<AppDatabase>
    with _$PaymentCyclesDaoMixin {
  PaymentCyclesDao(super.db);

  // ── Queries ──────────────────────────────────────────────────────────────

  /// Stream of ALL cycles for a student, newest first.
  Stream<List<PaymentCycle>> watchCyclesForStudent(int studentId) {
    return (select(paymentCycles)
          ..where((c) => c.studentId.equals(studentId))
          ..orderBy([(c) => OrderingTerm.desc(c.startedAt)]))
        .watch();
  }

  /// Stream of all paid cycles joined with student info, for real-time Salary tab updates.
  Stream<List<TypedResult>> watchPaidCyclesWithStudents() {
    final query = select(paymentCycles).join([
      innerJoin(students, students.id.equalsExp(paymentCycles.studentId)),
    ])
      ..where(paymentCycles.isPaid.equals(true))
      ..orderBy([OrderingTerm.desc(paymentCycles.paidAt)]);

    return query.watch();
  }

  /// All cycles for a student, newest first.
  Future<List<PaymentCycle>> getCyclesForStudent(int studentId) {
    return (select(paymentCycles)
          ..where((c) => c.studentId.equals(studentId))
          ..orderBy([(c) => OrderingTerm.desc(c.startedAt)]))
        .get();
  }

  /// The latest unpaid (active) cycle for a student, if any.
  Future<PaymentCycle?> getActiveCycle(int studentId) {
    return (select(paymentCycles)
          ..where((c) =>
              c.studentId.equals(studentId) & c.isPaid.equals(false))
          ..orderBy([(c) => OrderingTerm.desc(c.startedAt)])
          ..limit(1))
        .getSingleOrNull();
  }

  /// Stream of the active cycle for a student.
  Stream<PaymentCycle?> watchActiveCycle(int studentId) {
    return (select(paymentCycles)
          ..where((c) =>
              c.studentId.equals(studentId) & c.isPaid.equals(false))
          ..orderBy([(c) => OrderingTerm.desc(c.startedAt)])
          ..limit(1))
        .watchSingleOrNull();
  }

  // ── Mutations ─────────────────────────────────────────────────────────────

  /// Create a new payment cycle, optionally with a starting class count
  /// (used for carryover when a previous cycle had extra classes).
  Future<int> createCycle({
    required int studentId,
    int startingCount = 0,
  }) {
    return into(paymentCycles).insert(
      PaymentCyclesCompanion.insert(
        studentId: studentId,
        totalClasses: Value(startingCount),
      ),
    );
  }

  /// Increment the class count for a cycle by 1.
  Future<void> incrementClassCount(int cycleId) async {
    await (update(paymentCycles)..where((c) => c.id.equals(cycleId)))
        .write(
      PaymentCyclesCompanion.custom(
        totalClasses: paymentCycles.totalClasses + const Constant(1),
      ),
    );
  }

  /// Decrement the class count for a cycle by 1 (min 0).
  Future<void> decrementClassCount(int cycleId) async {
    final cycle = await (select(paymentCycles)
          ..where((c) => c.id.equals(cycleId)))
        .getSingle();

    if (cycle.totalClasses <= 0) return;

    await (update(paymentCycles)..where((c) => c.id.equals(cycleId)))
        .write(
      PaymentCyclesCompanion(
        totalClasses: Value(cycle.totalClasses - 1),
      ),
    );
  }

  /// Mark a cycle as paid and return the carryover count.
  /// Carryover = max(0, totalClasses - classesPerMonth).
  Future<int> markPaid(int cycleId) async {
    final now = DateTime.now();
    await (update(paymentCycles)..where((c) => c.id.equals(cycleId)))
        .write(
      PaymentCyclesCompanion(
        isPaid: const Value(true),
        paidAt: Value(now),
      ),
    );
    // Return the cycle data to compute carryover in the calling layer.
    final cycle = await (select(paymentCycles)
          ..where((c) => c.id.equals(cycleId)))
        .getSingle();
    return cycle.totalClasses;
  }

  /// Mark a cycle as unpaid (toggle back).
  Future<void> markUnpaid(int cycleId) async {
    await (update(paymentCycles)..where((c) => c.id.equals(cycleId)))
        .write(
      const PaymentCyclesCompanion(
        isPaid: Value(false),
        paidAt: Value(null),
      ),
    );
  }
}
