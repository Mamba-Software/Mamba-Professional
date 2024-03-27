import 'package:flutter/material.dart';
import 'package:mamba/l10n/language_manager.dart';
import 'package:mamba/data/Models/Bono.dart';
import 'package:mamba/data/Models/BonoRequest.dart';
import 'package:mamba/app/style/AppColors.dart';
import 'package:mamba/commons/widgets/GroupOfComponents/Bonos/BonoCard.dart';
import 'package:mamba/commons/widgets/Components/Images/CircularImage.dart';
import 'package:mamba/data/Models/Brand.dart';
import 'package:mamba/data/Models/Usuario.dart';

class RequestBonoConfirmationDialog extends StatefulWidget {
  Bono bono;
  Usuario user;
  BonoRequest bonoRequest;
  Brand brand;

  RequestBonoConfirmationDialog(
      {super.key,
      required this.bono,
      required this.user,
      required this.bonoRequest,
      required this.brand});

  @override
  _RequestBonoConfirmationDialogState createState() =>
      _RequestBonoConfirmationDialogState();
}

class _RequestBonoConfirmationDialogState
    extends State<RequestBonoConfirmationDialog> {
  // Boolean Loading
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Theme.of(context).scaffoldBackgroundColor),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(height: MediaQuery.of(context).size.height * 0.08),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          "ha solicitado la confirmación de compra del bono",
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(height: 1.5),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      BonoCard(
                          height: MediaQuery.of(context).size.height * 0.12,
                          width: MediaQuery.of(context).size.width * 0.4,
                          bono: widget.bono,
                          brand: widget.brand,
                          canExpand: false,
                          onlyView: true)
                    ],
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          "pagado con",
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(height: 1.5),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          elevation: 4.0,
                          backgroundColor: Colors.green,
                          fixedSize: Size(
                              MediaQuery.of(context).size.width * 0.35,
                              MediaQuery.of(context).size.height * 0.06),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(30),
                            ),
                          ),
                        ),
                        label: Text(
                          context.l10n.accept,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: AppColors.white),
                        ),
                        icon: Icon(
                          Icons.check_circle_outline,
                          size: MediaQuery.of(context).size.width * 0.06,
                          color: Colors.white,
                        ),
                        onPressed: null,
                      ),
                      SizedBox(width: MediaQuery.of(context).size.width * 0.01),
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          elevation: 4.0,
                          backgroundColor: Colors.red,
                          fixedSize: Size(
                              MediaQuery.of(context).size.width * 0.35,
                              MediaQuery.of(context).size.height * 0.06),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(30),
                            ),
                          ),
                        ),
                        label: Text(
                          context.l10n.delete,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: AppColors.white),
                        ),
                        icon: Icon(Icons.cancel_outlined,
                            size: MediaQuery.of(context).size.width * 0.06,
                            color: AppColors.white),
                        onPressed: null,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
                top: -90,
                child: Column(
                  children: <Widget>[
                    CircularImage(
                      size: MediaQuery.of(context).size.width * 0.25,
                      image: widget.user.imageUrl,
                      color: Theme.of(context).primaryColor,
                      borderWidth: 1,
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal:
                                MediaQuery.of(context).size.width * 0.10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(
                              child: Text(
                                widget.user.name!,
                                style: Theme.of(context)
                                    .textTheme
                                    .displayLarge
                                    ?.copyWith(fontWeight: FontWeight.bold),
                                textAlign: TextAlign.left,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                )),
          ],
        ),
      ),
    );
  }
}
