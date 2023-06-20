import 'package:flutter/material.dart';
import 'package:inventura/back/product.dart';
import 'package:inventura/database/databaseFunctions.dart';
import 'package:inventura/front/interface.dart';

class RemoveProduct extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: DB.getProducts(untracked: true),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) return loader;
          List<Product> untracked = snapshot.data as List<Product>;
          return ListView(
            children: untracked.map((e) {
              return ListTile(
                title: Text(e.productName),
                textColor: Colors.black,
                trailing: IconButton(
                  icon: Icon(Icons.remove),
                  onPressed: () {},
                ),
              );
            }).toList(),
          );
        });
  }
}
