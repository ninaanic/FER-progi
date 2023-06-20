import 'package:flutter/material.dart';
import 'package:inventura/back/missingProductNotification.dart';
import 'package:inventura/back/person.dart';
import 'package:inventura/back/product.dart';
import 'package:inventura/back/warehouse.dart';
import 'package:inventura/database/databaseFunctions.dart';
import 'package:inventura/front/interface.dart';
import 'package:inventura/services/enums/roleEnum.dart';
import 'package:provider/src/provider.dart';

class MissingProductPopUp extends StatefulWidget {
  @override
  _MissingProductPopUpState createState() => _MissingProductPopUpState();
}

class _MissingProductPopUpState extends State<MissingProductPopUp> {
  Future _productsFuture = DB.getProducts();
  Future _warehouseFuture = Warehouse.getClosestWarehouse();
  Product? selected;
  bool loading = false;

  List<Product>? products;
  Warehouse? closest;

  @override
  Widget build(BuildContext context) {
    final Person user = context.read<Person?>()!;
    return FutureBuilder(
        future: Future.wait([
          _productsFuture,
          _warehouseFuture,
        ]),
        builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (snapshot.connectionState != ConnectionState.done && (products == null && closest == null)) return loader;
          products = (snapshot.data![0] ?? <Product>[]) as List<Product>;
          closest = (snapshot.data![1] as Warehouse);
          return AlertDialog(
            title: Text(
              'Odaberite artikl koji nedostaje u skladištu ${closest!.warehouseName}',
              textAlign: TextAlign.center,
            ),
            content: SizedBox(
              width: 250,
              height: 400,
              child: loading
                  ? loader
                  : ListView.separated(
                      itemBuilder: (BuildContext context, int index) {
                        return ListTile(
                          title: Text(products![index].productName),
                          selected: selected == products![index],
                          onTap: () => setState(() => selected = products![index]),
                        );
                      },
                      separatorBuilder: (BuildContext context, int index) => Divider(),
                      itemCount: products!.length,
                    ),
            ),
            actions: [
              Container(
                alignment: Alignment.center,
                child: TextButton(
                  onPressed: () async {
                    if (selected == null || loading) return;
                    setState(() => loading = true);
                    await MissingProductNotification.createNotification(
                        selected!.productId, user.workerId, await closest!.getManagerId(), closest!.warehouseName);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Nedostatak ${selected!.productName} prijavljen")));
                    Navigator.pop(context);
                  },
                  child: user.role == Role.WORKER ? Text(
                    'Dojavite šefu skladišta',
                    style: plainTxt,
                  ) : Text(
                    'Dojavite direktoru',
                    style: plainTxt,
                  ),
                ),
                decoration: const BoxDecoration(gradient: gradient, borderRadius: borderRadius),
              )
            ],
          );
        });
  }
}
