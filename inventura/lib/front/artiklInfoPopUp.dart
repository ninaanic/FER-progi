import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inventura/back/person.dart';
import 'package:inventura/back/product.dart';
import 'package:inventura/back/record.dart';
import 'package:inventura/back/warehouse.dart';
import 'package:inventura/database/databaseFunctions.dart';
import 'package:inventura/front/size_config.dart';
import 'package:inventura/services/enums/roleEnum.dart';
import 'package:provider/src/provider.dart';
import 'package:sizer/sizer.dart';
import 'interface.dart';

class ArtiklInfoPopupScreen extends StatefulWidget {
  const ArtiklInfoPopupScreen({Key? key, required this.productId}) : super(key: key);
  final String productId;

  @override
  State<StatefulWidget> createState() {
    return ArtiklInfoPopup();
  }
}

class ArtiklInfoPopup extends State<ArtiklInfoPopupScreen> {
  late Future<Product> _productFuture;
  Future<Warehouse> _warehouseFuture = Warehouse.getClosestWarehouse();

  Product? product;
  Warehouse? closest;

  Duration dur = Duration(seconds: 10);
  late DateTime close;
  bool loading = false;
  TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    close = DateTime.now().add(dur);
    _productFuture = DB.getProductById(widget.productId);
    _controller.text = "1"; // broj artikala koliko zelimo spremit u bazu, inicijalno je 1 (onaj skenirani)
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return loading
        ? loader
        : StreamBuilder(
            stream: Stream.periodic(dur),
            builder: (context, snapshot) {
              if (DateTime.now().isAfter(close) && !loading) {
                WidgetsBinding.instance?.addPostFrameCallback((_) => closer());
                return loader;
              }
              return FutureBuilder(
                  future: Future.wait([
                    _productFuture,
                    _warehouseFuture,
                  ]),
                  builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
                    if (snapshot.connectionState != ConnectionState.done && product == null && closest == null) return loader;

                    product = snapshot.data![0];
                    closest = snapshot.data![1];

                    return AlertDialog(
                        content: Container(
                            alignment: Alignment.center,
                            color: Colors.white,
                            height: 30.h,
                            width: width,
                            child: Center(
                                child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('${product!.productName}', style: plainTxtBold),
                                SizedBox(height: SizeConfig.screenHeight! * 0.01),
                                Column (
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text('Opis: ${product!.description}', style: plainTxt, textAlign: TextAlign.center),
                                    Text('Lokacija: ${closest!.warehouseName}', style: plainTxt),
                                  ],
                                ),
                                SizedBox(height: SizeConfig.screenHeight! * 0.01),
                                Column(children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      new IconButton(
                                          onPressed: () {
                                            int currentValue = int.parse(_controller.text);
                                            setState(() {
                                              close = DateTime.now().add(dur);
                                              currentValue > 0 ? currentValue-- : currentValue == 0;
                                              _controller.text = (currentValue).toString();
                                            });
                                          },
                                          icon: removeIcon),
                                      Container(
                                        width: 10.w,
                                        child: TextFormField(
                                          controller: _controller,
                                          textAlign: TextAlign.center,
                                          keyboardType: TextInputType.numberWithOptions(decimal: false, signed: false),
                                          inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
                                          onChanged: (_) => setState(() => close = DateTime.now().add(dur)),
                                          onEditingComplete: () {
                                            setState(() {
                                              close = DateTime.now().add(dur);
                                              if (_controller.text.isEmpty) {
                                                _controller.text = '0';
                                              }
                                            });
                                          },
                                        ),
                                      ),
                                      new IconButton(
                                          onPressed: () {
                                            int currentValue = int.parse(_controller.text);
                                            setState(() {
                                              close = DateTime.now().add(dur);
                                              currentValue++;
                                              _controller.text = (currentValue).toString();
                                            });
                                          },
                                          icon: addIcon)
                                    ],
                                  )
                                ]),
                                Row(
                                  children: [
                                    Expanded(
                                        child: Center(
                                      child: ElevatedButton(
                                        onPressed: () => Navigator.pop(context),
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
                                            width: 20.w,
                                            height: 5.h,
                                            alignment: Alignment.center,
                                            child: Text(
                                              'Odbaci',
                                              style: plainTxt,
                                            ),
                                          ),
                                        ),
                                      ),
                                    )),
                                    Expanded(
                                        child: Center(
                                      child: ElevatedButton(
                                        onPressed: () => closer(),
                                        style: ElevatedButton.styleFrom(
                                            padding: EdgeInsets.zero, shape: const RoundedRectangleBorder(borderRadius: borderRadius)),
                                        child: Ink(
                                          decoration: const BoxDecoration(
                                            gradient: gradient,
                                            borderRadius: borderRadius,
                                          ),
                                          child: Container(
                                            width: 20.w,
                                            height: 5.h,
                                            alignment: Alignment.center,
                                            child: Text(
                                              'Spremi',
                                              style: plainTxt,
                                            ),
                                          ),
                                        ),
                                      ),
                                    )),
                                  ],
                                ),
                              ],
                            ))));
                  });
            });
  }

  void closer() async {
    setState(() {
      loading = true;
    });
    Person user = context.read<Person?>()!;
    bool write = await Record.addRecord(
      user.workerId,
      user.role,
      (await _warehouseFuture.then((value) => value)),
      DateTime.now(),
      widget.productId,
      int.parse(_controller.text),
      (await DB.getCurrentInventory()).inventoryId,
    );
    if (user.role != Role.MANAGER)
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(write ? "Proizvod uspješno zapisan" : "Zapis za proizvod već postoji")));
    else
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(write ? "Proizvod uspješno zapisan" : "Provedena kontrola proizvoda")));
    Navigator.pop(context);
  }
}
