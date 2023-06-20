import 'dart:async';

import 'package:flutter/material.dart';
import 'package:inventura/back/person.dart';
import 'package:inventura/back/product.dart';
import 'package:inventura/back/record.dart';
import 'package:inventura/back/warehouse.dart';
import 'package:inventura/back/worker.dart';
import 'package:inventura/database/databaseFunctions.dart';
import 'package:inventura/front/interface.dart';
import 'package:inventura/services/auth.dart';
import 'package:inventura/services/enums/statEnum.dart';
import 'package:provider/src/provider.dart';
import 'package:sizer/sizer.dart';

class WarehouseStatusScreen extends StatefulWidget {
  const WarehouseStatusScreen({Key? key, required this.warehouse}) : super(key: key);
  final Warehouse warehouse;

  @override
  State<StatefulWidget> createState() {
    return WarehouseStatusState();
  }
}

class WarehouseStatusState extends State<WarehouseStatusScreen> {
  ChooseStat? _choose = ChooseStat.ARTICLS;
  late Future<List<Record>> _future;
  late Future<Map<Worker, List<int>>> _future2;
  late Text workerBld;

  @override
  initState() {
    _future = DB.getLastCompleteInventoryId().then((value) async {
      if (value == null) return [];
      return await DB.getPersonsRecords(warehouseName: widget.warehouse.warehouseName, inventoryId: value, valid: true);
    });
    _future2 = DB.getWorkersFromWarehouseStatistics(widget.warehouse.warehouseName);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Person user = context.read<Person?>()!;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: primaryColor,
        actions: [
          Center(
            child: Text(
              user.firstName + ' ' + user.lastName,
              style: plainTxt,
              textAlign: TextAlign.center,
            ),
          ),
          IconButton(
            onPressed: () async {
              await context.read<AuthService>().signOut();
              Navigator.pop(context);
            },
            icon: logoutIcon,
          )
        ],
      ),
      body: Center(
        child: Column(
          children: [
            SizedBox(
              height: 2.h,
            ),
            Text(
              widget.warehouse.warehouseName,
              style: title,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width / 2,
                  child: ListTile(
                    title: Text(
                      'Artikli',
                      style: plainTxt,
                    ),
                    leading: Radio<ChooseStat>(
                      value: ChooseStat.ARTICLS,
                      groupValue: _choose,
                      onChanged: (ChooseStat? value) {
                        setState(() {
                          _choose = value;
                        });
                      },
                    ),
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width / 2,
                  child: ListTile(
                    title: Text(
                      'Skladištari',
                      style: plainTxt,
                    ),
                    leading: Radio<ChooseStat>(
                      value: ChooseStat.WORKER,
                      groupValue: _choose,
                      onChanged: (ChooseStat? value) {
                        setState(() {
                          _choose = value;
                        });
                      },
                    ),
                  ),
                )
              ],
            ),
            Expanded(
              child: FutureBuilder(
                future: _choose == ChooseStat.ARTICLS ? _future : _future2,
                builder: (context, snapshot) {
                  Map<String, int> products = {};
                  Map<Worker, List<int>> mapWorkerStat = {};
                  if (snapshot.connectionState != ConnectionState.done) return loader;
                  if (_choose == ChooseStat.ARTICLS) {
                    List<Record> records = (snapshot.data ?? <Record>[]) as List<Record>;
                    products = filteredProductId(records);
                  } else {
                    mapWorkerStat = (snapshot.data ?? <Worker, List<int>>{}) as Map<Worker, List<int>>;
                  }
                  return Padding(
                    padding: const EdgeInsets.all(10),
                    child: ListView.separated(
                      separatorBuilder: (context, index) => SizedBox(
                        height: 2.h,
                      ),
                      itemCount: _choose == ChooseStat.ARTICLS ? products.length : mapWorkerStat.length,
                      itemBuilder: (context, index) {
                        return Container(
                          decoration: BoxDecoration(gradient: gradient, borderRadius: borderRadius),
                          child: ListTile(
                              title: _choose == ChooseStat.ARTICLS
                                  ? StreamBuilder(
                                      stream: Product(products.keys.elementAt(index)).self,
                                      builder: (context, snapshot) {
                                        if (!snapshot.hasData) return loader;
                                        Product product = snapshot.data as Product;
                                        return Text(product.productName);
                                      },
                                    )
                                  : Text(mapWorkerStat.keys.elementAt(index).firstName + " " + mapWorkerStat.keys.elementAt(index).lastName),
                              trailing: _choose == ChooseStat.ARTICLS
                                  ? Text('${products.values.elementAt(index)}')
                                  : Text('${mapWorkerStat.values.elementAt(index)[0]} / ${mapWorkerStat.values.elementAt(index)[1]}')),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Set<String> filteredWorkerId(List<Record> records) {
    Set<String> results = records.map((e) => e.workerId).toSet();
    return results;
  }

  Map<String, int> filteredProductId(List<Record> records) {
    Set<String> results = records.map((e) => e.productId).toSet();
    Map<String, int> unitedRec = Map();
    for (String id in results) {
      unitedRec[id] = 0;
    }
    unitedRec.forEach((key, value) {
      for (Record r in records) {
        if (key == r.productId) {
          unitedRec.update(key, (value) => value += r.count);
        }
      }
    });
    return unitedRec;
  }
}
