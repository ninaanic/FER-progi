import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:inventura/database/databaseCollections.dart';
import 'package:inventura/database/databaseFunctions.dart';

class Product {
  String productId;
  String productName = '';
  String description = '';
  String? parent;

  Product(this.productId);

  @override
  String toString() {
    return "Product:\n|productId:${this.productId}, productName:${this.productName}, \n|description: ${this.description},\n|parent: ${this.parent ?? "product has no parent"}";
  }

  String get getProductId => this.productId;
  String get getProductName => this.productName;
  String get getDescription => this.description;

  Stream<Product?> get self => DB.firestore.collection(Collections.product).doc(this.productId).snapshots().map((event) => getProduct(event));

  Product? getProduct(DocumentSnapshot data) {
    if (!data.exists) return null;
    this.productName = data["name"];
    this.description = data["description"];
    this.parent = data["parent"];
    return this;
  }

  static Future addProduct(String productName, String description) async {
    await DB.firestore.collection(Collections.product).add({
      "parent": null,
      "name": productName,
      "description": description,
    });
  }

  Future updateParent(String? parentId) async {
    await DB.firestore.collection(Collections.product).doc(this.productId).update({
      "parent": parentId,
    });
  }

  static Future removeProduct(String productId) async {
    await DB.firestore.collection(Collections.product).doc(productId).delete();
  }
}
