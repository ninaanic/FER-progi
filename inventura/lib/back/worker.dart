import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:inventura/back/record.dart';
import 'package:inventura/services/enums/roleEnum.dart';
import 'package:inventura/services/extensions/stringExtension.dart';
import 'package:inventura/database/databaseFunctions.dart';
import 'person.dart';

class Worker extends Person {
  @override
  String get workerId => super.workerId;
  @override
  String get email => super.email;
  @override
  String get firstName => super.firstName;
  @override
  String get lastName => super.lastName;
  @override
  Role get role => Role.WORKER;

  @override
  String toString() {
    return "Worker... " + super.toString();
  }

  Worker(String workerId) : super(workerId);

  @override
  Worker? getData(DocumentSnapshot data) {
    if (!data.exists) return null;
    this.email = data["email"];
    this.firstName = data["firstName"];
    this.lastName = data["lastName"];
    this.role = (data["role"] as String).asRole;
    return this;
  }

  static Future<List<int>> calculateStatistic(String workerId, String warehouseName, String lastInventoryId) async {
    List<int> list = [];
    List<Record> scanned = await DB.getPersonsRecords(userId: workerId, warehouseName: warehouseName, inventoryId: lastInventoryId);
    int numScanned = scanned.length;
    int numCorrect = scanned.where((element) => element.valid).length;

    list.add(numCorrect);
    list.add(numScanned);

    return list;
  }
  }
