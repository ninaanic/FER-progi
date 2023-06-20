import 'package:flutter/material.dart';
import 'package:inventura/back/inventory.dart';
import 'package:inventura/back/person.dart';
import 'package:inventura/database/databaseFunctions.dart';
import 'package:inventura/front/historyScanScreen.dart';
import 'package:inventura/front/interface.dart';
import 'package:inventura/front/size_config.dart';
import 'package:inventura/services/enums/roleEnum.dart';
import 'package:provider/src/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:inventura/services/extensions/dateTimeExtension.dart';

import 'addInventoryDescription.dart';

class InventureList extends StatelessWidget {
  final Stream<List<Inventory>> _getInventoriesFuture = DB.getAllInventories(null);

  @override
  Widget build(BuildContext context) {
    final Person user = context.read<Person?>()!;
    return Scaffold(
      body: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: SizeConfig.safeBlockVertical! * 2,
            //vertical: SizeConfig.safeBlockHorizontal! * 5,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 2.h),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Povijest unosa",
                  style: title,
                ),
              ),
              SizedBox(height: 1.h),
              Expanded(
                child: StreamBuilder(
                    stream: _getInventoriesFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) return loader;
                      List<Inventory> inventories = (snapshot.data ?? <Inventory>[]) as List<Inventory>;
                      return ListView.separated(
                        itemBuilder: (context, index) {
                          return Container(
                            constraints: BoxConstraints(
                              maxHeight: 10.h,
                              maxWidth: 7.w,
                            ),
                            decoration: BoxDecoration(gradient: gradient, borderRadius: borderRadius),
                            child: ListTile(
                              title: Text(inventories[index].description),
                              trailing: Text(inventories[index].endTime == null ? 'aktivna' : inventories[index].endTime.toStringFixed),
                              onTap: () async => await Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => HistoryScanScreen(inventories[index]),
                                ),
                              ),
                            ),
                          );
                        },
                        separatorBuilder: (context, index) => SizedBox(height: 2.h),
                        itemCount: inventories.length,
                      );
                    }),
              ),
              if (user.role == Role.DIRECTOR)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: ElevatedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) => AddInventoryDescription(),
                        );
                      },
                      style: ElevatedButton.styleFrom(padding: EdgeInsets.zero, shape: const RoundedRectangleBorder(borderRadius: borderRadius)),
                      child: Ink(
                        decoration: const BoxDecoration(gradient: gradient, borderRadius: borderRadius),
                        child: Container(
                          width: 50.w,
                          height: 8.h,
                          alignment: Alignment.center,
                          child: Text(
                            'Završite aktivnu inventuru',
                            style: plainTxt,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ),
                )
            ],
          )),
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
