import 'package:flutter/material.dart';
import 'package:inventura/back/person.dart';
import 'package:inventura/front/dirInboxScreen.dart';
import 'package:inventura/front/interface.dart';
import 'package:inventura/services/enums/roleEnum.dart';
import 'package:provider/src/provider.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

import 'artiklInfoPopUp.dart';
import 'inboxScreen.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return ScanState();
  }
}

class ScanState extends State<ScanScreen> {
  QRViewController? controller;
  String? code;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    controller!.pauseCamera();
  }

  @override
  Widget build(BuildContext context) {
    Person user = context.watch<Person?>()!;
    bool isWorker = user.role == Role.WORKER;
    double scanArea = (MediaQuery.of(context).size.width < 400 || MediaQuery.of(context).size.height < 400) ? 250.0 : 300.0;
    return Scaffold(
      body: QRView(
        key: qrKey,
        onQRViewCreated: _onQRViewCreated,
        overlay: QrScannerOverlayShape(
          borderColor: primaryColor,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: scanArea,
        ),
        onPermissionSet: (ctrl, p) => _onPermissionSet(
          context,
          ctrl,
          p,
        ),
      ),
      floatingActionButton: Row(
        children: [
          !isWorker ? Spacer(flex: 5) : Spacer(flex: 1),
          FloatingActionButton(
            heroTag: 'btn1',
            tooltip: 'scan',
            onPressed: () async {
              if (code == null) return;

              await controller!.pauseCamera();
              await showDialog(
                context: context,
                builder: (BuildContext context) => ArtiklInfoPopupScreen(productId: code!),
              );
              await controller!.resumeCamera();
            },
            child: Material(
              color: Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: borderRadius),
              child: qrIcons_scan,
            ),
          ),
          !isWorker ? Spacer(flex: 3) : Spacer(flex: 1),
          if (!isWorker)
            FloatingActionButton(
              heroTag: 'btn2',
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => user.role == Role.MANAGER ? InboxScreen() : DirInboxScreen()),
              ),
              backgroundColor: primaryColor,
              child: inboxIcon,
            )
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    controller.scannedDataStream.listen((scanData) {
      if (code != scanData.code) {
        setState(() {
          code = scanData.code;
        });
      }
    });
    setState(() {
      this.controller = controller;
    });
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nemate dopuštenje')),
      );
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
