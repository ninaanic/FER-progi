import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:inventura/services/enums/roleEnum.dart';
import 'package:inventura/services/extensions/stringExtension.dart';
import 'person.dart';

class Director extends Person {
  @override
  String get workerId => super.workerId;
  @override
  String get email => super.email;
  @override
  String get firstName => super.firstName;
  @override
  String get lastName => super.lastName;
  @override
  Role get role => Role.DIRECTOR;

  Director(String workerId) : super(workerId);

  @override
  String toString() {
    return "Director:\n|" + super.toString();
  }

  @override
  Director getData(DocumentSnapshot data) {
    this.firstName = data["firstName"];
    this.lastName = data["lastName"];
    this.email = data["email"];
    this.role = (data["role"] as String).asRole;
    return this;
  }
}
