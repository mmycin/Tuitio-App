import 'package:drift/drift.dart';

import 'package:tuitio/core/database/tables/students.dart';
import 'package:tuitio/core/database/tables/payment_cycles.dart';

class Classes extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get studentId => integer().references(Students, #id)();

  /// Which payment cycle this class belongs to.
  IntColumn get cycleId =>
      integer().references(PaymentCycles, #id)();

  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get endedAt => dateTime().nullable()();

  TextColumn get notes => text().nullable()();
}