import 'dart:io';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:mamba_castelldefels/Data/DataService/Brand/BrandDataService.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/Dialogs/HomeDialogs/BrandInviteDialog.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/Dialogs/InformationDialogs/ErrorDialog.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/LoadingViews/LoadingView.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';


class QRScanner extends StatefulWidget {
  const QRScanner({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _QRScannerState();
}

class _QRScannerState extends State<QRScanner> {

  // QR Variables
  Barcode? result;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  //  Booleans
  bool isLoading = false;

  // Acceso a Base de Datos
  final _brandDataService = BrandDataService();


  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SizedBox(height: MediaQuery.of(context).size.height*0.02),
          Container(
            height: MediaQuery.of(context).size.height*0.007,
            width: MediaQuery.of(context).size.width*0.15,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: const BorderRadius.all(
                Radius.circular(5),
              ),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height*0.03),
          SizedBox(
            width: MediaQuery.of(context).size.width*0.9,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.qr_code,
                  color: Theme.of(context).primaryColor,
                  size: MediaQuery.of(context).size.width*0.08
                ),
                SizedBox(width: MediaQuery.of(context).size.width*0.02),
                Flexible(
                  child: Text(
                      AppLocalizations.of(context)!.scanQRCode,
                      style: Theme.of(context).textTheme.headline1!.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
                      textAlign: TextAlign.left
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height*0.03),
          Expanded(
              flex: 4,
              child: Stack(
                children: [
                  _buildQrView(context),
                  isLoading ? Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.7),
                    ),
                    child: Container(),
                  ) : Container(),
                ],
              )
          ),
        ],
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    // For this example we check how width or tall the device is and change the scanArea and overlay accordingly.
    var scanArea = (MediaQuery.of(context).size.width < 400 || MediaQuery.of(context).size.height < 400)
        ? 200.0
        : 400.0;
    // To ensure the Scanner view is properly sizes after rotation
    // we need to listen for Flutter SizeChanged notification and update controller
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
          borderColor: Theme.of(context).colorScheme.secondary,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: scanArea
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) {
      result = scanData;
      _onScannedQR();
    });
  }

  Future<void> _onScannedQR() async {
    controller?.pauseCamera();
    setState(() {
      isLoading = true;
    });
    bool existsBrand = await _brandDataService.checkIfBrandExists(result!.code!);
    if (existsBrand) {
      Future.delayed(Duration.zero, () {
        return showDialog(
            context: context,
            builder: (_) {
              return BrandInviteDialog(
                brandId: result!.code!,
              );
            }
        );
      }).whenComplete(() {
        controller?.resumeCamera();
        setState(() {
          isLoading = false;
        });
      });
    } else {
      await Future.delayed(Duration.zero, () {
        return showDialog(
            context: context,
            builder: (_) {
              return ErrorDialog(
                text: AppLocalizations.of(context)!.brandNotFound,
              );
            }
        );
      }).whenComplete(() {
        controller?.resumeCamera();
        setState(() {
          isLoading = false;
        });
      });
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}