import 'package:flutter/material.dart';
import 'package:inventura/back/warehouse.dart';
import 'package:inventura/database/databaseFunctions.dart';
import 'package:inventura/front/addWarehousePopUp.dart';
import 'package:inventura/front/interface.dart';
import 'package:inventura/front/size_config.dart';
import 'package:inventura/front/warehouseStatus.dart';
import 'package:sizer/sizer.dart';

class SkladistaList extends StatelessWidget {
  final Stream _streamWarehouse = DB.getWarehousesAsStream();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: SizeConfig.safeBlockVertical! * 2,
          vertical: SizeConfig.safeBlockHorizontal! * 5,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Skladišta', style: title),
            SizedBox(height: 1.h),
            Expanded(
                child: StreamBuilder(
                    stream: _streamWarehouse,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return loader;
                      List<Warehouse> warehouses = (snapshot.data ?? <Warehouse>[]) as List<Warehouse>;
                      return ListView.builder(
                          itemCount: warehouses.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                                onTap: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) => WarehouseStatusScreen(
                                            warehouse: warehouses[index],
                                          )));
                                },
                                title: Container(
                                  height: 6.h,
                                  child: Center(
                                    child: Text(
                                      warehouses[index].warehouseName,
                                      textAlign: TextAlign.center,
                                      style: listItemTxt,
                                    ),
                                  ),
                                  decoration: const BoxDecoration(gradient: gradient, borderRadius: borderRadius),
                                ));
                          });
                    })),
            SizedBox(height: 1.h),
            FloatingActionButton(
              onPressed: () async => await showDialog(context: context, builder: (BuildContext context) => AddWarehousePopUp()),
              backgroundColor: Colors.black,
              child: addIconWhite,
            )
          ],
        ),
      ),
    );
  }

  String getDate(String date) {
    String newDate = '';
    List<String> pomoc = date.split(" ");
    pomoc = pomoc[0].split("-");
    newDate = pomoc[2] + "." + pomoc[1] + "." + pomoc[0] + ".";
    return newDate;
  }
}
