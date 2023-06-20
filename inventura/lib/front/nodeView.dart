import 'package:flutter/material.dart';
import 'package:inventura/back/node.dart';
import 'package:inventura/front/interface.dart';
import 'package:inventura/front/productsView.dart';
import 'package:inventura/front/size_config.dart';

class NodeView extends StatelessWidget {
  final Node node;
  final TextEditingController newCategoryName = new TextEditingController();

  NodeView(this.node);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: node.self,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return linearLoader;
          List<Widget> _children = List<Widget>.from(node.children.map((e) => NodeView(e)).toList());
          return Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.blue,
              ),
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: ExpansionTile(
              maintainState: true,
              childrenPadding: EdgeInsets.only(left: 20),
              title: Row(
                children: [
                  Expanded(child: Text(node.name)),
                  if (node.parentId != null)
                    IconButton(
                      onPressed: () async {
                        if (!await Node.removeNode(node)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Grupa nije prazna pa zato ne može biti obrisana"),
                            ),
                          );
                        }
                      },
                      icon: Icon(Icons.remove),
                    )
                ],
              ),
              subtitle: Column(
                children: [
                  if (node.products.length == 0)
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: newCategoryName,
                            style: plainTxt,
                            textAlign: TextAlign.center,
                            cursorHeight: SizeConfig.screenHeight! * 0.03,
                            decoration: inputDecoration.copyWith(hintText: 'Naziv potkategorije'),
                          ),
                        ),
                        IconButton(
                          iconSize: 20,
                          icon: Icon(Icons.add),
                          onPressed: () async {
                            String name = newCategoryName.text;
                            if (name.isEmpty) return;
                            newCategoryName.clear();
                            await Node.addNode(name, node);
                          },
                        ),
                      ],
                    ),
                  if (node.children.length == 0) ProductsView(node),
                ],
              ),
              children: _children,
            ),
          );
        });
  }
}
