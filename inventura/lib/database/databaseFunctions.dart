import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:inventura/back/inventory.dart';
import 'package:inventura/back/manager.dart';
import 'package:inventura/back/missingProductNotification.dart';
import 'package:inventura/back/person.dart';
import 'package:inventura/back/product.dart';
import 'package:inventura/back/record.dart';
import 'package:inventura/back/warehouse.dart';
import 'package:inventura/back/worker.dart';
import 'package:inventura/back/wrongCountNotification.dart';
import 'package:inventura/database/databaseCollections.dart';
import 'package:inventura/services/enums/roleEnum.dart';
import 'package:inventura/services/extensions/roleExtension.dart';

abstract class DB {
  static FirebaseFirestore firestore = FirebaseFirestore.instance;
  static Future<List<Warehouse>> getWarehouses() async {
    return await firestore.collection(Collections.warehouse).get().then((value) => value.docs.map((e) => Warehouse(e.id)).toList());
  }

  static Future<String?> directorId() async {
    return await firestore
        .collection(Collections.users)
        .where("role", isEqualTo: Role.DIRECTOR.asString)
        .limit(1)
        .get()
        .then((value) => value.docs.length != 0 ? value.docs.first.id : null);
  }

  static Future<bool> hasManager(String location) async {
    return await firestore.collection(Collections.warehouse).doc(location).get().then((value) => value["manager"] != null);
  }

  static Future<List<Product>> getProducts({bool? untracked}) async {
    return await firestore
        .collection(Collections.product)
        .where("parent", isNull: untracked)
        .get()
        .then((value) => value.docs.map((e) => Product(e.id).getProduct(e)!).toList());
  }

  static Future<Product> getProductById(String id) async {
    return await firestore.collection(Collections.product).doc(id).get().then((value) => Product(value.id).getProduct(value)!);
  }

  static Future<String> getUserNameById(String id) async {
    return await firestore.collection(Collections.users).doc(id).get().then((value) => "${value["firstName"]} ${value["lastName"]}");
  }

  static Future<List<Record>> getPersonsRecords(
      {String? userId, String? inventoryId, String? productId, String? warehouseName, int? count, bool? valid}) async {
    List<Record> ret = await firestore
        .collection(Collections.record)
        .where("userId", isEqualTo: userId)
        .where("inventoryId", isEqualTo: inventoryId)
        .where("productId", isEqualTo: productId)
        .where("warehouseName", isEqualTo: warehouseName)
        .where("count", isEqualTo: count)
        .where("valid", isEqualTo: valid)
        .get()
        .then((value) => value.docs.map((e) => Record(e.id).getRecord(e)!).toList());
    return ret;
  }

  /// complete = null -> returns all inventories
  ///
  /// complete = false (default) -> returns all complete inventories
  ///
  /// complete = true -> returns all incomplete inventories
  static Stream<List<Inventory>> getAllInventories([bool? complete = false]) {
    return firestore
        .collection(Collections.inventory)
        .where("endTime", isNull: complete)
        .orderBy("startTime", descending: true).snapshots().map((event) => event.docs.map((e) => Inventory(e.id).getInventory(e)!).toList());
  }

  static Future<Inventory> getCurrentInventory() async {
    return await firestore.collection(Collections.inventory).where("endTime", isNull: true).limit(1).get().then((value) {
      QueryDocumentSnapshot e = value.docs.first;
      return Inventory(e.id).getInventory(e)!;
    });
  }

  static Future<List<Person>> getAllWorkers([Role role = Role.WORKER]) async {
    return await firestore
        .collection(Collections.users)
        .where("role", isEqualTo: role.asString)
        .get()
        .then((value) => value.docs.map((e) => role == Role.WORKER ? Worker(e.id).getData(e)! : Manager(e.id).getData(e)!).toList());
  }

  static Future<List<Worker>> getAllWorkersFromWarehouse(String warehouseName) async {
    return await firestore
        .collection(Collections.users)
        .where("role", isEqualTo: "Skladištar")
        .where("location", isEqualTo: warehouseName)
        .get()
        .then((value) => value.docs.map((e) {
              print("all workers from warehouse " + warehouseName);
              print(e.data());
              return Worker(e.id).getData(e)!;
            }).toList());
  }

  static Future<String?> getLastCompleteInventoryId() async {
    return await firestore
        .collection(Collections.inventory)
        .where("endTime", isNull: false)
        .orderBy("endTime", descending: true)
        .limit(1)
        .get()
        .then((value) => value.docs.length == 0 ? null : value.docs.first.id);
  }

  static Stream<List<WrongCountNotification>> getWrongCountNotifications() {
    return firestore
        .collection(Collections.wrongCountNotification)
        .snapshots()
        .map((event) => event.docs.map((e) => WrongCountNotification(e.id).getNotification(e)!).toList());
  }

  static Stream<List<MissingProductNotification>> getMissingProductNotification({String? recieverId}) {
    try {
      return firestore
          .collection(Collections.missingProductNotification)
          .where("recieverId", isEqualTo: recieverId)
          .snapshots()
          .map((event) => event.docs.map((e) => MissingProductNotification(e.id).getNotification(e)!).toList());
    } catch (e) {
      print(e.toString());
      throw Error();
    }
  }

  static Future<Map<Worker, List<int>>> getWorkersFromWarehouseStatistics(String warehouseName) async {
    Map<Worker, List<int>> retVal = {};
    List<Worker> workers = (await getAllWorkers()).map((e) => e as Worker).toList(); // don't need the info where they usually are ??
    String? _lastInventroyId = await DB.getLastCompleteInventoryId();
    if (_lastInventroyId == null) return {};
    await Future.forEach(workers, (Worker worker) async {
      List<int> temp = await Worker.calculateStatistic(worker.workerId, warehouseName, _lastInventroyId);
      if (temp[1] != 0) retVal[worker] = temp;
    });
    print("lista workera i statistika $retVal");
    return retVal;
  }

  static Stream<int> missingProductNotificationCount({String? recieverId}) {
    return firestore
        .collection(Collections.missingProductNotification)
        .where("recieverId", isEqualTo: recieverId)
        .snapshots()
        .map((event) => event.docs.length);
  }

  static Stream<List<Warehouse>> getWarehousesAsStream() {
    return firestore.collection(Collections.warehouse).snapshots().map((value) => value.docs.map((e) => Warehouse(e.id)).toList());
  }
}
