import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:inventura/back/geolocator.dart';
import 'package:inventura/back/manager.dart';
import 'package:inventura/database/databaseCollections.dart';
import 'package:inventura/database/databaseFunctions.dart';

class Warehouse {
  String warehouseName;
  late Manager manager;
  late Position GPSLocation;

  Warehouse(this.warehouseName);

  String toString() {
    return "Warehouse:\n|warehouseName: ${this.warehouseName}, ... ";
  }

  static Future addWarehouse(String warehouseName, Manager manager, Position GPSLocation) async {
    DB.firestore.runTransaction((transaction) async {
      await transaction.set(DB.firestore.collection(Collections.warehouse).doc(warehouseName), {
        "manager": manager.workerId,
        "GPSLocation": GeoPoint(GPSLocation.latitude, GPSLocation.longitude),
      });
    });
  }

  Warehouse? getWarehouse(DocumentSnapshot data) {
    if (!data.exists) return null;
    this.warehouseName = data.id;
    this.GPSLocation = Position(
        longitude: (data["GPSLocation"] as GeoPoint).longitude,
        latitude: (data["GPSLocation"] as GeoPoint).latitude,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        heading: 0,
        speed: 0,
        speedAccuracy: 0,
        isMocked: false);
    if (this.manager.workerId != data["manager"]) this.manager = Manager(data["manager"]);
    return this;
  }

  Future<String> getManagerId() async {
    return await DB.firestore.collection(Collections.warehouse).doc(warehouseName).get().then((value) => value["manager"]);
  }

  static Future<Warehouse> getClosestWarehouse() async {
    Position currentLocation = await determinePosition();
    List<Warehouse> listAllWarehouses = await DB.firestore.collection(Collections.warehouse).get().then((value) => value.docs.map((e) {
          Warehouse temp = Warehouse(e.id);
          temp.manager = Manager(e["manager"]);
          GeoPoint tempGPS = e["GPSLocation"];
          temp.GPSLocation = Position(
              longitude: tempGPS.longitude,
              latitude: tempGPS.latitude,
              timestamp: DateTime.now(),
              accuracy: 0,
              altitude: 0,
              heading: 0,
              speed: 0,
              speedAccuracy: 0,
              isMocked: false);
          return temp;
        }).toList());
    print("all Warehouses:");
    print(listAllWarehouses);
    late Warehouse closestWarehouse;
    double minDistanceInMeters = 1e9;
    print("current");
    print(currentLocation);
    listAllWarehouses.forEach((warehouse) {
      print(warehouse.GPSLocation);
      double distanceInMeters = Geolocator.distanceBetween(
          warehouse.GPSLocation.latitude, warehouse.GPSLocation.longitude, currentLocation.latitude, currentLocation.longitude);
      print(distanceInMeters);
      if (distanceInMeters < minDistanceInMeters) {
        minDistanceInMeters = distanceInMeters;
        closestWarehouse = warehouse;
      }
    });
    return closestWarehouse;
  }
}
