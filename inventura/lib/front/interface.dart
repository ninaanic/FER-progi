import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

const borderRadius = BorderRadius.all(Radius.circular(10));
const inputDecoration = InputDecoration(
  isDense: true,
  contentPadding: EdgeInsets.fromLTRB(10, 15, 10, 0),
  enabledBorder: OutlineInputBorder(
    borderRadius: borderRadius,
    borderSide: BorderSide(color: primaryColor, width: 2.0),
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: borderRadius,
    borderSide: BorderSide(color: primaryColor, width: 3.0),
  ),
  focusedErrorBorder: OutlineInputBorder(
    borderRadius: borderRadius,
    borderSide: BorderSide(color: Colors.red, width: 3.0),
  ),
  errorBorder: OutlineInputBorder(
    borderRadius: borderRadius,
    borderSide: BorderSide(color: Colors.red, width: 2.0),
  ),
);

const Widget loader = Center(child: CircularProgressIndicator());
const Widget linearLoader = Center(child: LinearProgressIndicator());

const gradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [const Color(0xff3becee), const Color(0xff15aae3)]);

const primaryColor = const Color(0xff21dff3);

TextStyle title = TextStyle(
    fontSize: 20.sp, fontWeight: FontWeight.bold, color: Colors.black);

TextStyle titleMini = TextStyle(fontSize: 15.sp, color: Colors.black);

TextStyle plainTxt = TextStyle(fontSize: 10.sp, color: Colors.black);

TextStyle plainTxtBold = TextStyle(
    fontSize: 10.sp, color: Colors.black, fontWeight: FontWeight.bold);

TextStyle errorTxt = TextStyle(fontSize: 10.sp, color: Colors.red);

TextStyle listItemTxt = TextStyle(fontSize: 15.sp, color: Colors.black);

TextStyle textButtonTxt = TextStyle(fontSize: 11.sp, color: primaryColor);

const logoutIcon = Icon(
  Icons.logout,
  color: Colors.black,
);
const qrIcons = Icon(
  Icons.qr_code_2_rounded,
);

const qrIcons_scan = Icon(
  Icons.qr_code_2_rounded,
  size: 56,
  color: Colors.black,
);

const listIcon = Icon(Icons.format_list_bulleted_rounded);
const houseIcon = Icon(Icons.house_rounded);
const myShopBagIcon = Icon(Icons.shopping_bag);
const checkIcon = Icon(Icons.check, color: Colors.white);
const addIcon = Icon(Icons.add_circle, color: Colors.black);
const addIconWhite = Icon(Icons.add, size: 40, color: Colors.white);
const cancelIcon = Icon(Icons.cancel_rounded, color: Colors.black);
const xIcon = Icon(Icons.close, color: Colors.white);
const removeIcon = Icon(Icons.remove_circle, color: Colors.black);
const inboxIcon = Icon(Icons.local_post_office_rounded, color: Colors.black);
