import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:tuitio/core/database/database.dart';
import 'package:tuitio/core/database/database_provider.dart';
import 'package:tuitio/core/database/daos/student_dao.dart';

final studentDaoProvider = Provider<StudentDao>((ref) {
  return ref.watch(databaseProvider).studentDao;
});

final studentsProvider = FutureProvider<List<Student>>((ref) {
  return ref.watch(studentDaoProvider).getAllStudents();
});