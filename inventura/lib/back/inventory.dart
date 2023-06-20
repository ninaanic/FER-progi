import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:inventura/database/databaseCollections.dart';
import 'package:inventura/database/databaseFunctions.dart';

class Inventory {
  String inventoryId;
  late DateTime startTime;
  late DateTime? endTime;
  late String description;

  Inventory(this.inventoryId); //, this.startTime, this.endTime, this.description);

  @override
  String toString() {
    return "Inventory:\n|inventoryId: ${this.inventoryId}, startTime: ${this.startTime}, endTime: ${this.endTime ?? "ongoing"}, description: ${this.description}";
  }

  Inventory? getInventory(DocumentSnapshot data) {
    if (!data.exists) return null;
    this.inventoryId = data.id;
    this.startTime = (data["startTime"] as Timestamp).toDate();
    this.endTime = data["endTime"] == null ? null : (data["endTime"] as Timestamp).toDate();
    this.description = data["inventoryDescription"];
    return this;
  }

  static Future addInventory(DateTime startTime, String description) async {
    await DB.firestore.collection(Collections.inventory).add({"startTime": startTime, "inventoryDescription": description, "endTime": null});
  }

  static Future addInventoryEndDate(String inventoryId, DateTime endTime) async {
    await DB.firestore.collection(Collections.inventory).doc(inventoryId).update({"endTime": endTime});
  }
}
