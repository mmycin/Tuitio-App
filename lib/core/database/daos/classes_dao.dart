import 'package:drift/drift.dart';

import 'package:tuitio/core/database/database.dart';
import 'package:tuitio/core/database/tables/classes.dart';

part 'classes_dao.g.dart';

@DriftAccessor(tables: [Classes])
class ClassesDao extends DatabaseAccessor<AppDatabase>
    with _$ClassesDaoMixin {
  ClassesDao(super.db);

  // ── Queries ──────────────────────────────────────────────────────────────

  /// All classes for a given payment cycle, newest first.
  Future<List<ClassesData>> getClassesForCycle(int cycleId) {
    return (select(classes)
          ..where((c) => c.cycleId.equals(cycleId))
          ..orderBy([(c) => OrderingTerm.desc(c.startedAt)]))
        .get();
  }

  /// Stream of classes for a cycle (for reactive UI).
  Stream<List<ClassesData>> watchClassesForCycle(int cycleId) {
    return (select(classes)
          ..where((c) => c.cycleId.equals(cycleId))
          ..orderBy([(c) => OrderingTerm.desc(c.startedAt)]))
        .watch();
  }

  /// Stream of all classes for a student, newest first.
  Stream<List<ClassesData>> watchClassesForStudent(int studentId) {
    return (select(classes)
          ..where((c) => c.studentId.equals(studentId))
          ..orderBy([(c) => OrderingTerm.desc(c.startedAt)]))
        .watch();
  }

  /// The most-recently-logged class for a student (used for "undo last class").
  Future<ClassesData?> getLatestClassForStudent(int studentId) {
    return (select(classes)
          ..where((c) => c.studentId.equals(studentId))
          ..orderBy([(c) => OrderingTerm.desc(c.startedAt)])
          ..limit(1))
        .getSingleOrNull();
  }

  // ── Mutations ─────────────────────────────────────────────────────────────

  Future<int> insertClass(ClassesCompanion classData) {
    return into(classes).insert(classData);
  }

  Future<int> deleteClass(int id) {
    return (delete(classes)..where((c) => c.id.equals(id))).go();
  }

  /// Delete the latest class entry for a student (subtract / undo).
  Future<bool> deleteLatestClassForStudent(int studentId) async {
    final latest = await getLatestClassForStudent(studentId);
    if (latest == null) return false;
    await deleteClass(latest.id);
    return true;
  }
}