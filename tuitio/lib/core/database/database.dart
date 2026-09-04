import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'package:tuitio/core/database/tables/students.dart';
import 'package:tuitio/core/database/tables/classes.dart';

part 'database.g.dart';

@DriftDatabase(tables: [Students, Classes])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  static LazyDatabase _openConnection() {
    return LazyDatabase(() async {
      final directory = await getApplicationDocumentsDirectory();

      final file = File(
        p.join(directory.path, 'tuitio.sqlite'),
      );

      return NativeDatabase.createInBackground(file);
    });
  }
}
