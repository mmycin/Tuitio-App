import 'package:drift/drift.dart';

import 'package:tuitio/core/database/database.dart';
import 'package:tuitio/core/database/tables/classes.dart';

part 'classes_dao.g.dart';

@DriftAccessor(tables: [Classes])
class ClassesDao extends DatabaseAccessor<AppDatabase>
    with _$ClassesDaoMixin {
  ClassesDao(super.db);

  Future<List<ClassesData>> getClassesForStudent(int studentId) {
    return (select(classes)
      ..where((c) => c.studentId.equals(studentId))
      ..orderBy([
            (c) => OrderingTerm.desc(c.startedAt),
      ]))
        .get();
  }

  Future<int> insertClass(ClassesCompanion classData) {
    return into(classes).insert(classData);
  }

  Future<int> deleteClass(int id) {
    return (delete(classes)..where((c) => c.id.equals(id))).go();
  }
}