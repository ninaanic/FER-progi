import 'package:flutter/material.dart';
import 'package:inventura/back/missingProductNotification.dart';
import 'package:inventura/back/person.dart';
import 'package:inventura/back/product.dart';
import 'package:inventura/database/databaseFunctions.dart';
import 'package:inventura/front/interface.dart';
import 'package:inventura/front/size_config.dart';
import 'package:inventura/services/auth.dart';
import 'package:provider/src/provider.dart';
import 'package:sizer/sizer.dart';

class InboxScreen extends StatelessWidget {
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
        padding: EdgeInsets.symmetric(
          horizontal: SizeConfig.safeBlockVertical! * 2,
          vertical: SizeConfig.safeBlockHorizontal! * 5,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Obavijesti', style: title),
            SizedBox(height: 3.h),
            Expanded(
              child: StreamBuilder(
                  stream: DB.getMissingProductNotification(recieverId: user.workerId),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return loader;
                    List<MissingProductNotification> notifications = snapshot.data as List<MissingProductNotification>;
                    return ListView.separated(
                      itemCount: notifications.length,
                      itemBuilder: (context, index) => StreamBuilder(
                          stream: notifications[index].self,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) return linearLoader;
                            Product product = notifications[index].product;
                            return StreamBuilder(
                                stream: product.self,
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData) return linearLoader;
                                  return Container(
                                    decoration: const BoxDecoration(
                                      gradient: gradient,
                                      borderRadius: borderRadius,
                                    ),
                                    child: Card(
                                      color: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      child: ListTile(
                                        title: Text('Nedostaje artikl:'),
                                        subtitle: Text(
                                          product.productName,
                                          textAlign: TextAlign.left,
                                        ),
                                        trailing: ElevatedButton(
                                          onPressed: () async => await notifications[index].forward(),
                                          style: ElevatedButton.styleFrom(
                                              padding: EdgeInsets.zero, shape: const RoundedRectangleBorder(borderRadius: borderRadius)),
                                          child: Ink(
                                            decoration: const BoxDecoration(color: Colors.white, borderRadius: borderRadius),
                                            child: Container(
                                              width: 30.w,
                                              height: 5.h,
                                              alignment: Alignment.center,
                                              child: Text(
                                                'Pošalji direktoru',
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
                      separatorBuilder: (context, index) => SizedBox(height: 1.h),
                    );
                  }),
            ),
          ],
        ),
      ),
    );
  }
}
