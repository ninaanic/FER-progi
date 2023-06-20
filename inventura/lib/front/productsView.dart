import 'package:flutter/material.dart';
import 'package:inventura/back/node.dart';
import 'package:inventura/back/product.dart';
import 'package:inventura/front/interface.dart';
import 'package:inventura/front/productSelect.dart';

class ProductsView extends StatelessWidget {
  final Node node;

  ProductsView(this.node);

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Row(
        children: [
          Text("Proizvodi (${node.products.length})"),
          ProductSelect(node),
        ],
      ),
      //tilePadding: EdgeInsets.only(left: 15),
      subtitle: node.products.length == 0 ? Text("Ova kategorija ne sadrži niti jedan proizvod") : null,
      children: node.products
          .map(
            (product) => Padding(
              padding: const EdgeInsets.only(left: 15),
              child: StreamBuilder(
                stream: product.self,
                builder: (context, snapshot) {
                  return !snapshot.hasData
                      ? linearLoader
                      : Row(
                          children: [
                            Expanded(
                              child: Text(
                                product.productName,
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.remove),
                              onPressed: () async {
                                await showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text("Uklanja se ${product.productName} iz kategorije ${node.name}"),
                                    content: Text("Želite li u potpunosti obrisati proizvod?"),
                                    actions: [
                                      TextButton(onPressed: () async => await node.addRemoveProducts([product], false), child: Text("NE")),
                                      TextButton(onPressed: () async => await Product.removeProduct(product.productId), child: Text("DA")),
                                    ],
                                  ),
                                );
                                //await node.addRemoveProducts([product], false);
                              },
                            ),
                          ],
                        );
                },
              ),
            ),
          )
          .toList(),
    );
  }
}
