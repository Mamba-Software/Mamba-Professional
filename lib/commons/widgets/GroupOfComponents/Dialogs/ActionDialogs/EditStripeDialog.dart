import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba/app/style/AppColors.dart';

class EditStripeDialog extends StatefulWidget {
  const EditStripeDialog({super.key});

  @override
  _EditStripeDialog createState() => _EditStripeDialog();
}

class _EditStripeDialog extends State<EditStripeDialog> {
  // Delete Alert
  bool firstBuild = true;
  bool canDelete = false;
  bool wrongPassword = false;
  String deleteTemp = "";
  TextEditingController? deleteController;

  @override
  Widget build(BuildContext context) {
    if (firstBuild) {
      deleteTemp = "";
      firstBuild = false;
    }
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
                Padding(
                  padding: const EdgeInsets.only(top: 25, bottom: 10.0),
                  child: Text(
                    AppLocalizations.of(context)!.stripeAccountDeactivate,
                    style: Theme.of(context)
                        .textTheme
                        .displaySmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
                Flexible(
                  child: Text(
                    "${AppLocalizations.of(context)!.stripeAccountDeactivateDesc} ",
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.35,
                        child: FloatingActionButton.extended(
                          shape: const StadiumBorder(),
                          heroTag: "33",
                          icon: Icon(
                            Icons.pause_circle_outline,
                            size: MediaQuery.of(context).size.width * 0.06,
                          ),
                          label: Text(
                            AppLocalizations.of(context)!
                                .desactivarBono
                                .split(" ")[0],
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: AppColors.white),
                          ),
                          backgroundColor: AppColors.red,
                          foregroundColor: AppColors.white,
                          onPressed: () {
                            Navigator.pop(context, true);
                          },
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.35,
                        child: FloatingActionButton.extended(
                          shape: const StadiumBorder(),
                          heroTag: "33",
                          icon: Icon(
                            Icons.mode_edit,
                            size: MediaQuery.of(context).size.width * 0.06,
                          ),
                          label: Text(
                            AppLocalizations.of(context)!.edit,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: AppColors.white),
                          ),
                          backgroundColor: Colors.green,
                          foregroundColor: AppColors.white,
                          onPressed: () {
                            Navigator.pop(context, false);
                          },
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
                top: -70,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox.fromSize(
                      size: const Size(80, 80), // button width and height
                      child: ClipOval(
                        child: Material(
                          color: Theme.of(context).primaryColor, // button color
                          child: Icon(
                            Icons.send_to_mobile,
                            color: Theme.of(context).primaryColorDark,
                            size: 40,
                          ), // icon,
                        ),
                      ),
                    ),
                  ],
                ))
          ],
        ),
      ),
    );
  }

  String splitCommonName(String name) {
    List<String> aux = name.split(" ");
    return aux[0];
  }
}
