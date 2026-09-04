import 'package:drift/drift.dart';
import 'package:tuitio/core/database/tables/students.dart';

class Classes extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get studentId => integer().references(Students, #id)();

  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get endedAt => dateTime().nullable()();

  TextColumn get notes => text().nullable()();
}