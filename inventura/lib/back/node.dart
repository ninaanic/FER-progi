import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:inventura/back/product.dart';
import 'package:inventura/database/databaseCollections.dart';
import 'package:inventura/database/databaseFunctions.dart';

class Node {
  String nodeId;
  String name = '';
  String? parentId;
  List<Product> products = [];
  List<Node> children = [];

  Node(this.nodeId);

  @override
  String toString() {
    return "Node:\n|nodeId: ${this.nodeId}, name: ${this.name}, parentId: ${this.parentId ?? "node has no parent"},\n|products: ${this.products},\n|children: ${this.children}";
  }

  Stream<Node?> get self => DB.firestore.collection(Collections.node).doc(this.nodeId).snapshots().map((event) => getNode(event));

  Node? getNode(DocumentSnapshot data) {
    if (!data.exists) return null;
    this.name = data["name"];
    this.parentId = data["parentId"];
    this.products = (data["products"] as List<dynamic>).map((e) => Product(e as String)).toList();
    this.children = (data["children"] as List<dynamic>).map((e) => Node(e as String)).toList();
    return this;
  }

  Future addRemoveProducts(List<Product> products, [bool add = true]) async {
    if (add)
      this.products.addAll(products);
    else
      this.products.remove(products[0]);

    await DB.firestore.collection(Collections.node).doc(nodeId).update({"products": this.products.map((e) => e.productId).toList()});
    if (add)
      await Future.forEach(products, (Product element) async => await element.updateParent(this.nodeId));
    else
      await Future.forEach(products, (Product element) async => await element.updateParent(null));
  }

  Future addRemoveChild(String childId, [bool add = true]) async {
    List<String> nodeIds = this.children.map((e) => e.nodeId).toList();
    add ? nodeIds.add(childId) : nodeIds.remove(childId);
    await DB.firestore.collection(Collections.node).doc(nodeId).update({"children": nodeIds});
  }

  static Future addNode(String name, Node parent) async {
    await DB.firestore.collection(Collections.node).add({
      "name": name,
      "parentId": parent.nodeId,
      "products": [],
      "children": [],
    }).then((value) async => await parent.addRemoveChild(value.id));
  }

  static Future<bool> removeNode(Node node) async {
    if (node.children.length != 0 || node.products.length != 0) return false;
    DB.firestore.runTransaction((transaction) async {
      List<String> parentChildren = [];
      await DB.firestore
          .collection(Collections.node)
          .doc(node.parentId)
          .get()
          .then((value) => (value["children"] as List<dynamic>).forEach((e) => parentChildren.add(e as String)));
      parentChildren.remove(node.nodeId);
      await DB.firestore.collection(Collections.node).doc(node.parentId).update({"children": parentChildren});
      await DB.firestore.collection(Collections.node).doc(node.nodeId).delete();
    });
    return true;
  }
}
