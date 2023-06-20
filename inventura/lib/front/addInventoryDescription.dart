import 'package:flutter/material.dart';
import 'package:inventura/back/inventory.dart';
import 'package:inventura/database/databaseFunctions.dart';
import 'package:inventura/front/interface.dart';
import 'package:sizer/sizer.dart';

class AddInventoryDescription extends StatelessWidget {
  final TextEditingController description = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Unesite opis nove inventure'),
      content: SizedBox(width: 250, height: 2),
      actions: [
        Container(
          alignment: Alignment.center,
          child: TextFormField(
            controller: description,
            keyboardType: TextInputType.emailAddress,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            style: plainTxt,
            textAlign: TextAlign.center,
            decoration: inputDecoration,
            validator: (description) {
              if (description!.isEmpty) return null;
            },
          ),
        ),
        SizedBox(height: 3.h),
        Container(
          alignment: Alignment.center,
          child: ElevatedButton(
            onPressed: () async {
              await Inventory.addInventoryEndDate((await DB.getCurrentInventory()).inventoryId, DateTime.now());
              await Inventory.addInventory(DateTime.now(), description.text);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(padding: EdgeInsets.zero, shape: const RoundedRectangleBorder(borderRadius: borderRadius)),
            child: Ink(
              decoration: const BoxDecoration(gradient: gradient, borderRadius: borderRadius),
              child: Container(
                width: 30.w,
                height: 8.h,
                alignment: Alignment.center,
                child: Text(
                  'Dodajte novu inventuru',
                  style: plainTxt,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
