import 'package:drift/drift.dart';

class Students extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get name => text()();

  TextColumn get phone => text().nullable()();

  IntColumn get monthlyFee => integer().nullable()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}