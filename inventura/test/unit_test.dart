import 'package:inventura/back/inventory.dart';
import 'package:inventura/back/missingProductNotification.dart';
import 'package:inventura/back/node.dart';
import 'package:inventura/back/product.dart';
import 'package:inventura/back/record.dart';
import 'package:inventura/back/worker.dart';
import 'package:inventura/services/enums/roleEnum.dart';
import 'package:test/test.dart';

void main() {
  group('Unit testovi', () {
    test('Stvaranje novog korisnika', () {
      Worker worker = new Worker("A1b1hSr9OXPXXk33JYzO0VTSRm44");
      worker.email = 'ih@gmail.com';
      worker.firstName = 'Ivan';
      worker.lastName = 'Horvat';
      worker.firstName = 'Ivan';
      worker.role = Role.WORKER;

      expect(worker.firstName, 'Ivan');
    });

    test('Stvaranje novog proizvoda', () {
      Product product = new Product("135275630109");
      product.productName = 'Nutella';
      product.parent = null;
      product.description = 'Slasni čokoladni namaz';

      expect(product.parent, null);
    });

    test('Unos novog zapisa skeniranja artikla', () {
      Record record = new Record('1fpcFk3KL6nOPfBe3Ktk');
      record.workerId = 'A1b1hSr9OXPXXk33JYzO0VTSRm44';
      record.warehouseName = 'Maksimir';
      record.scanningTime = DateTime.now();
      record.productId = '135275630109';
      record.count = 10;
      record.inventoryId = '49KCQvrhelkDJyCyJYKm';
      record.valid = false;

      expect(record.valid, false);
    });

    test('Nova grupa proizvoda', () {
      Node node = new Node('31XnIwNGcGOv1gXKyiM0');
      node.name = 'majice';
      node.parentId = 'qAzJTMOzjP0WhtHLgYy3';

      expect(node.children, []);
    });

    test('Stvaranje nove inventure', () {
      Inventory inv = new Inventory('49KCQvrhelkDJyCyJYKm');
      inv.startTime = DateTime.now();
      inv.endTime = null;
      inv.description = 'Nova inventura';

      expect(inv.endTime, null);
    });

    Product product = new Product("135275630109");
    test('Obavijest da proizvod nedostaje', () {
      MissingProductNotification missNot = new MissingProductNotification('XBrdoo0irhiRmdnvX529');
      missNot.product = product;
      missNot.senderId = 'PhFoguXXGZDXxriBegmK9B2PP92';
      missNot.recieverId = 'a6rI4JmS1geiHVPBVCtD1rjN36A3';
      missNot.warehouse = 'Hong Kong';
      missNot.inventoryId = '49KCQvrhelkDJyCyJYKm';
      missNot.resolved = false;

      expect(missNot.resolved, false);
    });
  });
}
