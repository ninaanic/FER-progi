import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:inventura/back/warehouse.dart';
import 'package:inventura/back/wrongCountNotification.dart';
import 'package:inventura/database/databaseCollections.dart';
import 'package:inventura/database/databaseFunctions.dart';
import 'package:inventura/services/enums/roleEnum.dart';

class Record {
  String recordId;
  late String workerId;
  late String warehouseName;
  late DateTime scanningTime;
  late String productId;
  late int count;
  late String inventoryId;
  late bool valid;

  Record(this.recordId);

  @override
  String toString() {
    return "Record... userId: ${this.workerId}, warehouseName: ${this.warehouseName}, scanningTime: ${this.scanningTime}, productId: ${this.productId}, count: ${this.count}, inventoryId: ${this.inventoryId}, valid: ${this.valid}\n";
  }

  Stream<Record?> get self => DB.firestore.collection(Collections.record).doc(this.recordId).snapshots().map((event) => getRecord(event));

  Record? getRecord(DocumentSnapshot data) {
    if (!data.exists) return null;
    this.workerId = data["userId"];
    this.warehouseName = data["warehouseName"];
    this.scanningTime = (data["scanningTime"] as Timestamp).toDate();
    this.productId = data["productId"];
    this.count = data["count"];
    this.inventoryId = data["inventoryId"];
    this.valid = data["valid"];
    return this;
  }

  static Future<bool> addRecord(
      String workerId, Role workerRole, Warehouse warehouse, DateTime scanningTime, String productId, int count, String inventoryId) async {
    QueryDocumentSnapshot? doc = await DB.firestore
        .collection(Collections.record)
        .where("productId", isEqualTo: productId)
        .where("inventoryId", isEqualTo: inventoryId)
        .where("warehouseName", isEqualTo: warehouse.warehouseName)
        .limit(1)
        .get()
        .then((value) => value.docs.length == 0 ? null : value.docs.first);

    if (doc == null) {
      await DB.firestore.collection(Collections.record).add({
        "valid": true,
        "userId": workerId,
        "warehouseName": warehouse.warehouseName,
        "scanningTime": scanningTime,
        "productId": productId,
        "count": count,
        "inventoryId": inventoryId
      });
      return true;
    }
    if (workerRole != Role.MANAGER) return false;
    if (doc["count"] != count) {
      await DB.firestore.collection(Collections.record).doc(doc.id).update({
        "valid": false,
      });
      await DB.firestore.collection(Collections.record).add({
        "valid": true,
        "userId": workerId,
        "warehouseName": warehouse.warehouseName,
        "scanningTime": scanningTime,
        "productId": productId,
        "count": count,
        "inventoryId": inventoryId
      });
      await WrongCountNotification.createNotification(doc.id, workerId);
    }
    return false;
  }
}
