// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_cycles_dao.dart';

// ignore_for_file: type=lint
mixin _$PaymentCyclesDaoMixin on DatabaseAccessor<AppDatabase> {
  $StudentsTable get students => attachedDatabase.students;
  $PaymentCyclesTable get paymentCycles => attachedDatabase.paymentCycles;
  PaymentCyclesDaoManager get managers => PaymentCyclesDaoManager(this);
}

class PaymentCyclesDaoManager {
  final _$PaymentCyclesDaoMixin _db;
  PaymentCyclesDaoManager(this._db);
  $$StudentsTableTableManager get students =>
      $$StudentsTableTableManager(_db.attachedDatabase, _db.students);
  $$PaymentCyclesTableTableManager get paymentCycles =>
      $$PaymentCyclesTableTableManager(_db.attachedDatabase, _db.paymentCycles);
}
