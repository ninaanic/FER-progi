import 'package:flutter/material.dart';
import 'package:inventura/back/person.dart';
import 'package:inventura/front/artiklListScreen.dart';
import 'package:inventura/front/productCall.dart';
import 'package:inventura/front/interface.dart';
import 'package:inventura/front/inventureList.dart';
import 'package:inventura/front/scanScreen.dart';
import 'package:inventura/front/skladistaList.dart';
import 'package:inventura/services/auth.dart';
import 'package:inventura/services/enums/roleEnum.dart';
import 'package:provider/src/provider.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _currentIndex = 1;
  PageController _controller = PageController();

  @override
  void initState() {
    _controller = PageController(initialPage: _currentIndex);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Person user = context.watch<Person?>()!;
    List<Widget> _screens = [InventureList(), ScanScreen(), thirdScreen(user), ProductCall()];
    int items = user.role == Role.WORKER
        ? 2
        : user.role == Role.MANAGER
            ? 3
            : 4;
    return StreamBuilder(
        stream: user.self,
        builder: (context, snapshot) {
          return !snapshot.hasData
              ? loader
              : Scaffold(
                  resizeToAvoidBottomInset: false,
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
                        },
                        icon: logoutIcon,
                      )
                    ],
                  ),
                  bottomNavigationBar: BottomNavigationBar(
                    currentIndex: _currentIndex,
                    items: [
                      BottomNavigationBarItem(label: 'Inventura', icon: listIcon, backgroundColor: primaryColor),
                      BottomNavigationBarItem(label: 'Skeniranje', icon: qrIcons, backgroundColor: primaryColor),
                      if (user.role != Role.WORKER) BottomNavigationBarItem(label: 'Skladište', icon: houseIcon, backgroundColor: primaryColor),
                      if (user.role == Role.DIRECTOR) BottomNavigationBarItem(label: 'Artikli', icon: myShopBagIcon, backgroundColor: primaryColor)
                    ],
                    selectedItemColor: Colors.white,
                    unselectedItemColor: Colors.black,
                    onTap: (index) => setState(() {
                      _currentIndex = index;
                      _controller.animateToPage(index, duration: Duration(milliseconds: 250), curve: Curves.ease);
                    }),
                    type: BottomNavigationBarType.shifting,
                  ),
                  body: PageView.builder(
                    itemCount: items,
                    onPageChanged: (index) => setState(() => _currentIndex = index),
                    controller: _controller,
                    itemBuilder: (Context, index) => _screens[index],
                  ),
                );
        });
  }

  Widget thirdScreen(Person user) {
    if (user.role == Role.DIRECTOR)
      return SkladistaList();
    else
      return ArtiklListScreen();
  }
}
