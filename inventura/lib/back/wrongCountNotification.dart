import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:inventura/back/manager.dart';
import 'package:inventura/back/record.dart';
import 'package:inventura/database/databaseCollections.dart';
import 'package:inventura/database/databaseFunctions.dart';

class WrongCountNotification {
  String notificationId;
  late Record record;
  late Manager manager;
  late DateTime time;
  late bool resolved;

  WrongCountNotification(this.notificationId);

  @override
  String toString() {
    return this.notificationId + this.record.toString() + ' ' + this.manager.toString();
  }

  Stream<WrongCountNotification?> get self =>
      DB.firestore.collection(Collections.wrongCountNotification).doc(this.notificationId).snapshots().map((event) => getNotification(event));

  WrongCountNotification? getNotification(DocumentSnapshot data) {
    if (!data.exists) return null;
    this.record = Record(data["recordId"]);
    this.manager = Manager(data["managerId"]);
    this.time = (data["time"] as Timestamp).toDate();
    this.resolved = data["resolved"];
    return this;
  }

  Future updateNotificationStatus() async {
    await DB.firestore.collection(Collections.wrongCountNotification).doc(notificationId).delete();
  }

  static Future createNotification(String recordId, String managerId) async {
    await DB.firestore.collection(Collections.wrongCountNotification).doc().set({
      "recordId": recordId,
      "managerId": managerId,
      "time": DateTime.now(),
      "resolved": false,
    });
  }

  Future resolve() async {
    await DB.firestore.collection(Collections.wrongCountNotification).doc(notificationId).update({
      "resolved": true,
    });
  }
}
