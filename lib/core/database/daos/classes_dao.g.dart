// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'classes_dao.dart';

// ignore_for_file: type=lint
mixin _$ClassesDaoMixin on DatabaseAccessor<AppDatabase> {
  $StudentsTable get students => attachedDatabase.students;
  $PaymentCyclesTable get paymentCycles => attachedDatabase.paymentCycles;
  $ClassesTable get classes => attachedDatabase.classes;
  ClassesDaoManager get managers => ClassesDaoManager(this);
}

class ClassesDaoManager {
  final _$ClassesDaoMixin _db;
  ClassesDaoManager(this._db);
  $$StudentsTableTableManager get students =>
      $$StudentsTableTableManager(_db.attachedDatabase, _db.students);
  $$PaymentCyclesTableTableManager get paymentCycles =>
      $$PaymentCyclesTableTableManager(_db.attachedDatabase, _db.paymentCycles);
  $$ClassesTableTableManager get classes =>
      $$ClassesTableTableManager(_db.attachedDatabase, _db.classes);
}
