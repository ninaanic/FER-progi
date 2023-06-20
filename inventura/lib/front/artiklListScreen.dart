import 'package:flutter/material.dart';
import 'package:inventura/back/manager.dart';
import 'package:inventura/back/person.dart';
import 'package:inventura/back/product.dart';
import 'package:inventura/back/record.dart';
import 'package:inventura/back/warehouse.dart';
import 'package:inventura/database/databaseFunctions.dart';
import 'package:provider/src/provider.dart';
import 'package:sizer/sizer.dart';

import 'interface.dart';

class ArtiklListScreen extends StatefulWidget {
  @override
  ArtiklListState createState() => ArtiklListState();
}

class ArtiklListState extends State<ArtiklListScreen> {
  late Future<List<Record>> _recordsFuture;
  late Future<Warehouse?> _warehouseFuture;
  @override
  initState() {
    Person person = context.read<Person?>()!;
    Manager manager = Manager(person.workerId);
    _warehouseFuture = manager.getWarehouse();

    _recordsFuture = DB.getLastCompleteInventoryId().then((value) async {
      print(value);
      if (value == null) return [];
      return await DB.getPersonsRecords(
        warehouseName: await _warehouseFuture.then((value) => value == null ? null : value.warehouseName),
        inventoryId: value,
      );
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FutureBuilder(
            future: _warehouseFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) return loader;
              if (snapshot.data == null) return Text("Trenutno nemate dodijeljeno skladište", style: plainTxt);
              Warehouse warehouse = snapshot.data as Warehouse;
              return Column(
                children: [
                  SizedBox(height: 2.h),
                  Text(
                    "Skladište: ${warehouse.warehouseName}",
                    style: title,
                  ),
                  Expanded(
                      child: FutureBuilder(
                    future: _recordsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState != ConnectionState.done) return loader;
                      List<Record> records = (snapshot.data ?? <Record>[]) as List<Record>;

                      return Padding(
                        padding: const EdgeInsets.all(10),
                        child: ListView.separated(
                          itemBuilder: (context, index) {
                            Product product = Product(records[index].productId);
                            print(records[index].valid);
                            return Container(
                              decoration: BoxDecoration(
                                gradient: records[index].valid ? gradient : null,
                                borderRadius: borderRadius,
                                color: records[index].valid ? null : Colors.red,
                              ),
                              child: ListTile(
                                title: StreamBuilder(
                                  stream: product.self,
                                  builder: (context, snapshot) {
                                    if (!snapshot.hasData) return loader;
                                    return Text(product.productName);
                                  },
                                ),
                                trailing: Text('${records[index].count}'),
                              ),
                            );
                          },
                          separatorBuilder: (context, index) => SizedBox(height: 2.h),
                          itemCount: records.length,
                        ),
                      );
                    },
                  ))
                ],
              );
            }),
      ),
    );
  }
}
