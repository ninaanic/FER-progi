import 'package:flutter/material.dart';
import 'package:inventura/back/node.dart';
import 'package:inventura/back/product.dart';
import 'package:inventura/database/databaseFunctions.dart';
import 'package:inventura/front/interface.dart';

class ProductSelect extends StatefulWidget {
  final Node node;

  ProductSelect(this.node);

  @override
  State<ProductSelect> createState() => _ProductSelectState();
}

class _ProductSelectState extends State<ProductSelect> {
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return loading
        ? loader
        : IconButton(
            icon: Icon(Icons.add),
            onPressed: () async {
              setState(() => loading = true);
              await showDialog(
                  context: context,
                  builder: (context) {
                    bool loading = false;
                    List<Product> selected = [];
                    Future _future = DB.getProducts(untracked: true);
                    return StatefulBuilder(
                      builder: (context, setState) {
                        return AlertDialog(
                          title: Text(widget.node.name),
                          content: SizedBox(
                            width: 250,
                            height: 400,
                            child: FutureBuilder(
                                future: _future,
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState != ConnectionState.done) return loader;
                                  List<Product> untracked = snapshot.data as List<Product>;
                                  return loading
                                      ? loader
                                      : ListView(
                                          children: untracked.map((e) {
                                            return ListTile(
                                              title: Text(e.productName),
                                              textColor: Colors.black,
                                              selected: selected.contains(e),
                                              onTap: () => setState(() => selected.contains(e) ? selected.remove(e) : selected.add(e)),
                                            );
                                          }).toList(),
                                        );
                                }),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () async {
                                setState(() => loading = true);
                                await widget.node.addRemoveProducts(selected);
                                setState(() => selected.clear());
                                setState(() => loading = false);
                                Navigator.of(context).pop();
                              },
                              child: Text("Dodajte odabrane proizvode"),
                            )
                          ],
                        );
                      },
                    );
                  });
              setState(() => loading = false);
            },
          );
  }
}
