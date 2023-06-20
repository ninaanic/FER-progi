import 'package:flutter/material.dart';
import 'package:inventura/back/product.dart';
import 'package:sizer/sizer.dart';

class AddProduct extends StatelessWidget {
  final TextEditingController productNameController = new TextEditingController();
  final TextEditingController productDescriptionController = new TextEditingController();
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Stvorite proizvod"),
      content: SizedBox(
        height: 25.h,
        child: Column(
          children: [
            TextFormField(
              autovalidateMode: AutovalidateMode.onUserInteraction,
              controller: productNameController,
              decoration: InputDecoration(hintText: "Ime proizvoda"),
              validator: (value) => value != null && value.length > 0 ? null : "Ime ne smije biti prazno",
            ),
            SizedBox(height: 10),
            TextFormField(
              maxLines: null,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              controller: productDescriptionController,
              decoration: InputDecoration(hintText: "Opis proizvoda"),
              validator: (value) => value != null && value.length > 0 ? null : "Opis ne smije biti prazan",
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () async {
            await Product.addProduct(productNameController.text, productDescriptionController.text);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("${productNameController.text} stvoren")));
            Navigator.pop(context);
          },
          child: Text("Stvori"),
        ),
      ],
    );
  }
}
