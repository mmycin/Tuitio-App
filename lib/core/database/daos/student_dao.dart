import 'package:drift/drift.dart';

import 'package:tuitio/core/database/database.dart';
import 'package:tuitio/core/database/tables/students.dart';

part 'student_dao.g.dart';

@DriftAccessor(tables: [Students])
class StudentDao extends DatabaseAccessor<AppDatabase> with _$StudentDaoMixin {
  StudentDao(super.db);

  Future<List<Student>> getAllStudents() async {
    final result = await select(students).get();
    return result.reversed.toList();
  }

  Future<Student?> getStudentById(int id) {
    return (select(students)..where((s) => s.id.equals(id))).getSingleOrNull();
  }

  Future<int> insertStudent(StudentsCompanion student) {
    return into(students).insert(student);
  }

  Future<bool> updateStudent(StudentsCompanion student) {
    return update(students).replace(student);
  }

  Future<int> deleteStudent(int id) {
    return (delete(students)..where((s) => s.id.equals(id))).go();
  }
}
