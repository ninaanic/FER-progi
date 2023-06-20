import 'package:flutter/material.dart';
import 'package:inventura/back/inventory.dart';
import 'package:inventura/back/person.dart';
import 'package:inventura/back/product.dart';
import 'package:inventura/back/record.dart';
import 'package:inventura/back/warehouse.dart';
import 'package:inventura/database/databaseFunctions.dart';
import 'package:inventura/front/interface.dart';
import 'package:inventura/front/size_config.dart';
import 'package:inventura/services/auth.dart';
import 'package:inventura/services/enums/roleEnum.dart';
import 'package:provider/src/provider.dart';
import 'package:sizer/sizer.dart';
import 'missingProductPopUp.dart';
import 'package:inventura/services/extensions/dateTimeExtension.dart';

class HistoryScanScreen extends StatefulWidget {
  final Inventory _inventory;
  HistoryScanScreen(this._inventory);

  @override
  State<HistoryScanScreen> createState() => _HistoryScanScreenState();
}

class _HistoryScanScreenState extends State<HistoryScanScreen> {
  Warehouse? warehouse;
  late final Future _getRecords;
  final Future _getWarehouses = DB.getWarehouses();

  @override
  void initState() {
    final Person user = context.read<Person?>()!;
    _getRecords = DB.getPersonsRecords(
      userId: user.role == Role.DIRECTOR ? null : user.workerId,
      inventoryId: widget._inventory.inventoryId,
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Person user = context.read<Person?>()!;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: primaryColor,
        actions: [
          Center(
            child: Text(
              '${user.firstName} ${user.lastName}',
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
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget._inventory.description,
                style: title,
              ),
              if (widget._inventory.endTime != null) Text("Inventura ${widget._inventory.endTime!.toStringFixed}") else Text("Aktivna Inventura"),
              SizedBox(height: SizeConfig.screenHeight! * 0.03),
              Expanded(
                child: Container(
                  child: FutureBuilder(
                      future: _getRecords,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState != ConnectionState.done) return loader;
                        List<Record> records = (snapshot.data as List<Record>)
                            .where((element) => warehouse == null || element.warehouseName == warehouse!.warehouseName)
                            .toList();
                        return ListView.separated(
                          shrinkWrap: true,
                          itemBuilder: (context, index) => Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              gradient: records[index].valid ? gradient : null,
                              borderRadius: borderRadius,
                              color: records[index].valid ? null : Colors.red,
                            ),
                            margin: EdgeInsets.symmetric(horizontal: 20.0),
                            constraints: BoxConstraints(
                              maxHeight: 10.h,
                              maxWidth: 7.w,
                            ),
                            child: FutureBuilder(
                                future: Future.wait([
                                  DB.getProductById(records[index].productId),
                                  DB.getUserNameById(records[index].workerId),
                                ]),
                                builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
                                  if (snapshot.connectionState != ConnectionState.done) return linearLoader;
                                  Product product = snapshot.data![0] as Product;
                                  String userName = snapshot.data![1] as String;
                                  return Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Artikl: ${product.productName}',
                                          style: plainTxtBold,
                                        ),
                                        Text(
                                          'Lokacija: ${records[index].warehouseName} / Stanje: ${records[index].count}\n${userName}',
                                          style: plainTxt,
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                          ),
                          separatorBuilder: (context, index) => SizedBox(height: SizeConfig.screenHeight! * 0.02),
                          itemCount: records.length,
                        );
                      }),
                ),
              ),
              SizedBox(height: SizeConfig.screenHeight! * 0.05),
              if (user.role != Role.DIRECTOR)
                FutureBuilder(
                  future: DB.getCurrentInventory(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) return linearLoader;
                    if (widget._inventory.inventoryId == (snapshot.data as Inventory).inventoryId)
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) => MissingProductPopUp(),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.zero,
                            shape: const RoundedRectangleBorder(borderRadius: borderRadius),
                          ),
                          child: Ink(
                            decoration: const BoxDecoration(
                              gradient: gradient,
                              borderRadius: borderRadius,
                            ),
                            child: Container(
                              width: 30.w,
                              height: 6.h,
                              alignment: Alignment.center,
                              child: Text(
                                'Nema artikla',
                                style: plainTxt,
                              ),
                            ),
                          ),
                        ),
                      );
                    else
                      return SizedBox();
                  },
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: user.role != Role.DIRECTOR
          ? null
          : FloatingActionButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text("Odaberite skladište"),
                    content: FutureBuilder(
                        future: _getWarehouses,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState != ConnectionState.done) return loader;
                          List<Warehouse> warehouses = snapshot.data as List<Warehouse>;
                          return SizedBox(
                            height: 60.h,
                            width: 50.w,
                            child: ListView.separated(
                              shrinkWrap: true,
                              itemBuilder: (context, index) => ListTile(
                                title: Text(warehouses[index].warehouseName),
                                selected: warehouse == warehouses[index],
                                onTap: () {
                                  setState(() => warehouse = warehouses[index]);
                                  Navigator.pop(context);
                                },
                              ),
                              separatorBuilder: (context, index) => SizedBox(height: 15),
                              itemCount: warehouses.length,
                            ),
                          );
                        }),
                    actions: [
                      TextButton(
                        onPressed: () {
                          setState(() => warehouse = null);
                          Navigator.pop(context);
                        },
                        child: Text("Ukloni filter"),
                      )
                    ],
                  ),
                );
              },
              child: Icon(Icons.filter_alt),
            ),
    );
  }
}
