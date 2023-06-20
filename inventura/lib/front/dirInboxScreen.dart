import 'package:flutter/material.dart';
import 'package:inventura/back/manager.dart';
import 'package:inventura/back/missingProductNotification.dart';
import 'package:inventura/back/person.dart';
import 'package:inventura/back/product.dart';
import 'package:inventura/back/record.dart';
import 'package:inventura/back/warehouse.dart';
import 'package:inventura/back/wrongCountNotification.dart';
import 'package:inventura/database/databaseFunctions.dart';
import 'package:inventura/front/interface.dart';
import 'package:inventura/front/size_config.dart';
import 'package:inventura/services/auth.dart';
import 'package:provider/src/provider.dart';
import 'package:sizer/sizer.dart';

class DirInboxScreen extends StatefulWidget {
  @override
  _DirInboxScreenState createState() => _DirInboxScreenState();
}

class _DirInboxScreenState extends State<DirInboxScreen> {
  final Stream _streamWrong = DB.getWrongCountNotifications();
  final Stream _streamMissing = DB.getMissingProductNotification();
  bool isSwitched = false;
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
      body: Center(
        child: Column(
          children: [
            SizedBox(height: SizeConfig.screenHeight! * 0.02),
            Text('Obavijesti', style: title),
            SizedBox(height: SizeConfig.screenHeight! * 0.03),
            Container(
              padding: EdgeInsets.only(left: 12.w),
              child: Row(
                children: [
                  Text(
                    'Nove obavijesti',
                    style: plainTxt,
                  ),
                  Switch(
                    value: isSwitched,
                    onChanged: (value) => setState(() => isSwitched = value),
                  ),
                  Text(
                    'Razriješene obavijesti',
                    style: plainTxt,
                  )
                ],
              ),
            ),
            Expanded(
                child: Column(
              children: [
                Text(
                  'Razriješene obavijesti:',
                  style: plainTxtBold,
                ),
                SizedBox(height: SizeConfig.screenHeight! * 0.02),
                Text(
                  'Pogrešno izbrojeni artikli :',
                  style: plainTxt,
                ),
                Expanded(
                  child: StreamBuilder(
                      stream: _streamWrong,
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return loader;
                        List<WrongCountNotification> notifications =
                            (snapshot.data as List<WrongCountNotification>).where((element) => element.resolved == isSwitched).toList();
                        return ListView.separated(
                            shrinkWrap: true,
                            separatorBuilder: (context, index) => SizedBox(height: 1.h),
                            itemCount: notifications.length,
                            itemBuilder: (context, index) {
                              Manager manager = notifications[index].manager;
                              Record record = notifications[index].record;
                              return Container(
                                decoration: const BoxDecoration(
                                  gradient: gradient,
                                  borderRadius: borderRadius,
                                ),
                                child: Card(
                                  color: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  child: ListTile(
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        StreamBuilder(
                                          stream: notifications[index].manager.self,
                                          builder: (context, snapshot) => !snapshot.hasData
                                              ? linearLoader
                                              : Row(
                                                  children: [
                                                    Text("Šef skladišta: ", style: plainTxtBold),
                                                    Text(
                                                      "${notifications[index].manager.firstName} ${notifications[index].manager.lastName}",
                                                      style: plainTxt,
                                                    ),
                                                  ],
                                                ),
                                        ),
                                        StreamBuilder(
                                          stream: record.self,
                                          builder: (context, snapshot) => !snapshot.hasData
                                              ? linearLoader
                                              : StreamBuilder(
                                                  stream: Product(record.productId).self,
                                                  builder: (context, snapshot) => !snapshot.hasData
                                                      ? linearLoader
                                                      : Row(
                                                          children: [
                                                            Text("Proizvod: ", style: plainTxtBold),
                                                            Text(
                                                              "${(snapshot.data as Product).productName}",
                                                              style: plainTxt,
                                                            ),
                                                          ],
                                                        ),
                                                ),
                                        ),
                                        FutureBuilder(
                                          future: manager.getWarehouse(),
                                          builder: (context, snapshot) => !snapshot.hasData
                                              ? linearLoader
                                              : Row(
                                                  children: [
                                                    Text("Skladište: ", style: plainTxtBold),
                                                    Text(
                                                      "${(snapshot.data as Warehouse).warehouseName}",
                                                      style: plainTxt,
                                                    ),
                                                  ],
                                                ),
                                        ),
                                      ],
                                    ),
                                    trailing: isSwitched
                                        ? null
                                        : ElevatedButton(
                                            onPressed: () async => await notifications[index].resolve(),
                                            style: ElevatedButton.styleFrom(
                                              padding: EdgeInsets.zero,
                                              shape: const RoundedRectangleBorder(borderRadius: borderRadius),
                                            ),
                                            child: Ink(
                                              decoration: const BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: borderRadius,
                                              ),
                                              child: Container(
                                                width: 30.w,
                                                height: 5.h,
                                                alignment: Alignment.center,
                                                child: Text(
                                                  'Razriješi',
                                                  style: plainTxt,
                                                ),
                                              ),
                                            ),
                                          ),
                                  ),
                                ),
                              );
                            });
                      }),
                ),
                SizedBox(height: 1.h),
                Text(
                  'Artikli koji nedostaju :',
                  style: plainTxt,
                ),
                Expanded(
                  child: StreamBuilder(
                    stream: _streamMissing,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return loader;
                      List<MissingProductNotification> notifications =
                          (snapshot.data as List<MissingProductNotification>).where((element) => element.resolved == isSwitched).toList();
                      return ListView.separated(
                        itemCount: notifications.length,
                        itemBuilder: (context, index) => StreamBuilder(
                            stream: notifications[index].self,
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) return linearLoader;
                              Product product;
                              product = notifications[index].product;
                              return StreamBuilder(
                                  stream: product.self,
                                  builder: (context, snapshot) {
                                    if (!snapshot.hasData) return linearLoader;
                                    return Container(
                                      height: 10.h,
                                      decoration: const BoxDecoration(
                                        gradient: gradient,
                                        borderRadius: borderRadius,
                                      ),
                                      child: ListTile(
                                        title: Text('Nedostaje artikl:', style: plainTxtBold),
                                        subtitle: Text(
                                          product.productName,
                                          textAlign: TextAlign.left,
                                          style: plainTxt,
                                        ),
                                        trailing: isSwitched
                                            ? null
                                            : ElevatedButton(
                                                onPressed: () async => await notifications[index].resolve(),
                                                style: ElevatedButton.styleFrom(
                                                  padding: EdgeInsets.zero,
                                                  shape: const RoundedRectangleBorder(borderRadius: borderRadius),
                                                ),
                                                child: Ink(
                                                  decoration: const BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius: borderRadius,
                                                  ),
                                                  child: Container(
                                                    width: 30.w,
                                                    height: 5.h,
                                                    alignment: Alignment.center,
                                                    child: Text(
                                                      'Razriješi',
                                                      style: plainTxt,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                      ),
                                    );
                                  });
                            }),
                        separatorBuilder: (context, index) => SizedBox(height: 1.h),
                      );
                    },
                  ),
                )
              ],
            ))
          ],
        ),
      ),
    );
  }
}
