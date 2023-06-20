import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:inventura/database/databaseCollections.dart';
import 'package:inventura/database/databaseFunctions.dart';
import 'package:inventura/services/enums/roleEnum.dart';
import 'package:inventura/services/extensions/roleExtension.dart';

abstract class Person {
  String workerId;
  late String email;
  late String firstName;
  late String lastName;
  late Role role;

  Person(this.workerId);

  @override
  String toString() {
    return "workerId:${this.workerId}, firstName:${this.firstName}, lastName:${this.lastName}, email:${this.email}\n";
  }

  Stream<Person?> get self => DB.firestore.collection(Collections.users).doc(workerId).snapshots().map((event) => getData(event));

  Person? getData(DocumentSnapshot data);

  static Future createUser(String uid, String email, String firstName, String lastName, Role role) async {
      await DB.firestore.runTransaction((transaction) async {
        await transaction.set(DB.firestore.collection(Collections.users).doc(uid), {
          "email": email,
          "firstName": firstName,
          "lastName": lastName,
          "role": role.asString,
        });
      });
  }
}
