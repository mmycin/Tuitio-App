import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'package:tuitio/core/database/tables/students.dart';
import 'package:tuitio/core/database/tables/classes.dart';
import 'package:tuitio/core/database/tables/payment_cycles.dart';
import 'package:tuitio/core/database/daos/student_dao.dart';
import 'package:tuitio/core/database/daos/classes_dao.dart';
import 'package:tuitio/core/database/daos/payment_cycles_dao.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: [
    Students,
    PaymentCycles,
    Classes,
  ],
  daos: [
    StudentDao,
    PaymentCyclesDao,
    ClassesDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
        },
        onUpgrade: (m, from, to) async {
          // Early dev: destructive migration — drop everything and recreate.
          // This keeps the schema clean without manual ALTER TABLE steps.
          await m.recreateAllViews();
          for (final table in allTables) {
            await m.deleteTable(table.actualTableName);
          }
          await m.createAll();
        },
      );

  static LazyDatabase _openConnection() {
    return LazyDatabase(() async {
      final directory = await getApplicationDocumentsDirectory();
      final file = File(p.join(directory.path, 'tuitio.sqlite'));
      return NativeDatabase.createInBackground(file);
    });
  }
}
