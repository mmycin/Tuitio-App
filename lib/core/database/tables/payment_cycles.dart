import 'package:drift/drift.dart';

import 'package:tuitio/core/database/tables/students.dart';

/// Represents a single payment cycle for a student.
///
/// A "cycle" is NOT a calendar month — it's a block of contracted classes
/// (e.g. 12 classes). A cycle can span any number of real days.
/// Once [totalClasses] >= student.classesPerMonth AND payment is received,
/// the cycle is closed (isPaid = true) and a new one begins.
class PaymentCycles extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get studentId => integer().references(Students, #id)();

  /// Actual classes taken in this cycle (may exceed classesPerMonth).
  IntColumn get totalClasses =>
      integer().withDefault(const Constant(0))();

  /// Whether payment has been received for this cycle.
  BoolColumn get isPaid =>
      boolean().withDefault(const Constant(false))();

  /// When this cycle started (first class or manual creation).
  DateTimeColumn get startedAt =>
      dateTime().withDefault(currentDateAndTime)();

  /// When payment was received (null if unpaid).
  DateTimeColumn get paidAt => dateTime().nullable()();
}
