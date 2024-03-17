import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba_castelldefels/commons/constants/GlobalVars.dart';
import 'package:mamba_castelldefels/app/style/AppColors.dart';

class DeleteBrandDialog extends StatefulWidget {
  const DeleteBrandDialog({super.key});

  @override
  _DeleteDialogState createState() => _DeleteDialogState();
}

class _DeleteDialogState extends State<DeleteBrandDialog> {
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
                    AppLocalizations.of(context)!.deleteBrandConfirmation,
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: Colors.red, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
                Flexible(
                  child: Text(
                    "${AppLocalizations.of(context)!.writeDeleteBrand} ",
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.02,
                ),
                Flexible(
                  child: Text(currentBrand.name!,
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center),
                ),
                Padding(
                  padding:
                      const EdgeInsets.only(top: 20.0, left: 15, right: 15),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Flexible(
                        child: TextFormField(
                          controller: deleteController,
                          onChanged: (val) {
                            setState(() => deleteTemp = val);
                            if (deleteTemp != currentBrand.name) {
                              setState(() => canDelete = false);
                            } else {
                              setState(() => canDelete = true);
                            }
                          },
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: Colors.red),
                          decoration: InputDecoration(
                            hintText: currentBrand.name,
                            hintStyle: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: Colors.red.withOpacity(0.5)),
                            enabledBorder: OutlineInputBorder(
                              borderSide:
                                  const BorderSide(color: Colors.red, width: 1),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide:
                                  const BorderSide(color: Colors.red, width: 1),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      FloatingActionButton.extended(
                        shape: const StadiumBorder(),
                        heroTag: "32",
                        label: Text(
                          AppLocalizations.of(context)!.delete,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: AppColors.white),
                        ),
                        icon: Icon(
                          Icons.delete_outline,
                          size: MediaQuery.of(context).size.width * 0.06,
                        ),
                        backgroundColor:
                            canDelete ? Colors.red : Colors.red[200],
                        foregroundColor: AppColors.white,
                        onPressed: canDelete
                            ? () async {
                                Navigator.pop(context, true);
                              }
                            : null,
                      ),
                      FloatingActionButton.extended(
                        shape: const StadiumBorder(),
                        heroTag: "33",
                        icon: Icon(
                          Icons.cancel_outlined,
                          size: MediaQuery.of(context).size.width * 0.06,
                        ),
                        label: Text(
                          AppLocalizations.of(context)!.cancel,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                  color: Theme.of(context).primaryColorDark),
                        ),
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Theme.of(context).primaryColorDark,
                        onPressed: () {
                          Navigator.pop(context, false);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
                top: -90,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox.fromSize(
                      size: const Size(100, 100), // button width and height
                      child: ClipOval(
                        child: Material(
                          color: Colors.red, // button color
                          child: InkWell(
                            onTap: () async {
                              setState(() {});
                            },
                            child: const Icon(
                              Icons.delete_outline_outlined,
                              color: Colors.white,
                              size: 60,
                            ), // icon
                          ),
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
