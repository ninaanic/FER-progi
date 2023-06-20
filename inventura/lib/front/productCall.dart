import 'package:inventura/front/addProduct.dart';
import 'package:inventura/front/interface.dart';
import 'package:flutter/material.dart';
import 'package:inventura/back/node.dart';
import 'package:inventura/front/nodeView.dart';
import 'package:sizer/sizer.dart';

class ProductCall extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AddProduct(),
          );
        },
        backgroundColor: Colors.black,
        child: addIconWhite,
      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          SizedBox(height: 3.h),
          Align(
            alignment: Alignment.center,
            child: Text(
              'Upravljanje proizvodima',
              style: title,
            ),
          ),
          SizedBox(height: 2.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 2.w),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Dodajte artikl',
                style: plainTxt,
              ),
            ),
          ),
          SizedBox(height: 1.h),
          Flexible(
            child: Container(
              height: MediaQuery.of(context).size.height,
              child: SingleChildScrollView(
                child: NodeView(Node("root")),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
