import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:inventura/back/geolocator.dart';
import 'package:inventura/back/manager.dart';
import 'package:inventura/back/person.dart';
import 'package:inventura/back/warehouse.dart';
import 'package:inventura/database/databaseFunctions.dart';
import 'package:inventura/front/interface.dart';
import 'package:inventura/services/enums/roleEnum.dart';
import 'package:sizer/sizer.dart';

class AddWarehousePopUp extends StatefulWidget {
  @override
  _AddWarehousePopUpState createState() => _AddWarehousePopUpState();
}

class _AddWarehousePopUpState extends State<AddWarehousePopUp> {
  Future _futureManagers = DB.getAllWorkers(Role.MANAGER);
  late Manager manager;
  int _selected = 0;
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Dodavanje skladišta'),
      content: SizedBox(
        width: 250,
        height: 400,
        child: Column(
          children: [inputWarehouseName(), chooseManager()],
        ),
      ),
      actions: [
        Container(
          alignment: Alignment.center,
          child: TextButton(
            onPressed: () async {
              Position position = await determinePosition();
              Warehouse.addWarehouse(_warehouseName, manager, position);
              Navigator.pop(context);
            },
            child: Text(
              "Dodajte skladište na trenutnoj lokaciji",
              style: plainTxt,
            ),
          ),
          decoration: const BoxDecoration(gradient: gradient, borderRadius: borderRadius),
        )
      ],
    );
  }

  String _warehouseName = '';

  Widget inputWarehouseName() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Text(
          'Unesite ime skladišta',
          style: plainTxt,
        ),
        SizedBox(height: 0.5.h),
        Container(
          alignment: Alignment.centerLeft,
          height: 10.h,
          child: TextFormField(
            initialValue: _warehouseName,
            onChanged: (value) => setState(() => _warehouseName = value),
            keyboardType: TextInputType.name,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            style: plainTxt,
            textAlign: TextAlign.center,
            decoration: inputDecoration,
            validator: (warehouseName) {
              if (warehouseName!.isEmpty)
                return "Ime skladišta ne smije biti prazno";
              else
                return null;
            },
          ),
        ),
        SizedBox(height: 1.h),
        Text(
          'Odaberite šefa skladišta',
          style: plainTxt,
        ),
        SizedBox(height: 0.5.h),
      ],
    );
  }

  Widget chooseManager() {
    return Expanded(
      child: FutureBuilder(
          future: _futureManagers,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) return loader;
            List<Manager> managers = ((snapshot.data ?? <Person>[]) as List<Person>).map((e) => e as Manager).toList();
            return ListView.separated(
                //shrinkWrap: true,
                itemBuilder: (BuildContext context, int index) {
                  manager = managers[0];
                  return ListTile(
                      title: Text(managers[index].lastName),
                      selected: _selected == index,
                      onTap: () => setState(() {
                            manager = managers[index];
                            _selected = index;
                          }));
                },
                separatorBuilder: (BuildContext context, int index) => Divider(),
                itemCount: managers.length);
          }),
    );
  }
}
