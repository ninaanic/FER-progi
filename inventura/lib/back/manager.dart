import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:inventura/back/warehouse.dart';
import 'package:inventura/database/databaseCollections.dart';
import 'package:inventura/database/databaseFunctions.dart';
import 'package:inventura/services/enums/roleEnum.dart';
import 'package:inventura/services/extensions/stringExtension.dart';

import 'person.dart';

class Manager extends Person {
  @override
  String get workerId => super.workerId;
  @override
  String get email => super.email;
  @override
  String get firstName => super.firstName;
  @override
  String get lastName => super.lastName;
  @override
  Role get role => Role.MANAGER;

  @override
  String toString() {
    return "Manager:\n|" + super.toString();
  }

  Manager(String workerId) : super(workerId);

  @override
  Manager? getData(DocumentSnapshot data) {
    if (!data.exists) return null;
    this.firstName = data["firstName"];
    this.lastName = data["lastName"];
    this.email = data["email"];
    this.role = (data["role"] as String).asRole;
    return this;
  }

  Future<Warehouse?> getWarehouse() async {
    return await DB.firestore.collection(Collections.warehouse).where("manager", isEqualTo: this.workerId).get().then((value) {
      print(value.docs.length);
      if (value.docs.length == 0) return null;
      return value.docs.map((e) => Warehouse(e.id)).toList()[0];
    });
  }
}
