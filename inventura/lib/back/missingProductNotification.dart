import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:inventura/back/product.dart';
import 'package:inventura/database/databaseCollections.dart';
import 'package:inventura/database/databaseFunctions.dart';

class MissingProductNotification {
  String notificationId;
  late Product product;
  late String senderId;
  late String recieverId;
  late String warehouse;
  late String inventoryId;
  late bool resolved;

  MissingProductNotification(this.notificationId);

  @override
  String toString() {
    return this.notificationId + this.product.productId + ' ' + this.senderId + '' + this.recieverId;
  }

  Stream<MissingProductNotification?> get self =>
      DB.firestore.collection(Collections.missingProductNotification).doc(this.notificationId).snapshots().map((event) => getNotification(event));

  MissingProductNotification? getNotification(DocumentSnapshot data) {
    if (!data.exists) return null;
    this.product = Product(data["productId"]);
    this.senderId = data["senderId"];
    this.recieverId = data["recieverId"];
    this.warehouse = data["warehouse"];
    this.inventoryId = data["inventoryId"];
    this.resolved = data["resolved"];
    return this;
  }

  Future updateNotificationStatus() async {
    await DB.firestore.collection(Collections.missingProductNotification).doc(notificationId).delete();
  }

  static Future createNotification(String productId, String senderId, String recieverId, String warehouse) async {
    await DB.firestore.collection(Collections.missingProductNotification).add({
      "productId": productId,
      "senderId": senderId,
      "recieverId": recieverId,
      "warehouse": warehouse,
      "inventoryId": await DB.getCurrentInventory(),
      "resolved": false,
    });
  }

  Future forward() async {
    await DB.firestore.collection(Collections.missingProductNotification).doc(notificationId).update({
      "senderId": recieverId,
      "recieverId": await DB.directorId(),
    });
  }

  Future resolve() async {
    await DB.firestore.collection(Collections.missingProductNotification).doc(notificationId).update({
      "resolved": true,
    });
  }
}
