import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba_castelldefels/Data/Models/Brand.dart';
import 'package:mamba_castelldefels/app/style/AppColors.dart';
import 'package:mamba_castelldefels/commons/widgets/Components/Images/CircularImage.dart';

class CancelRequestConfirmationDialog extends StatelessWidget {
  final String text;
  final Brand brand;
  const CancelRequestConfirmationDialog(
      {super.key, required this.text, required this.brand});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        padding:
            const EdgeInsets.only(top: 80, bottom: 10, left: 10, right: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(
                      top: 16.0, bottom: 24.0, right: 10, left: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          text,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(height: 1.5),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
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
                          AppLocalizations.of(context)!.anular,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: AppColors.white),
                        ),
                        icon: Icon(
                          Icons.remove_circle_outline,
                          size: MediaQuery.of(context).size.width * 0.06,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          Navigator.pop(context, true);
                        },
                      ),
                      SizedBox(width: MediaQuery.of(context).size.width * 0.01),
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          elevation: 4.0,
                          backgroundColor: Theme.of(context).primaryColor,
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
                          AppLocalizations.of(context)!.cancel,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context).primaryColorDark,
                                  ),
                        ),
                        icon: Icon(
                          Icons.cancel_outlined,
                          size: MediaQuery.of(context).size.width * 0.06,
                          color: Theme.of(context).primaryColorDark,
                        ),
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
                bottom: 0,
                top: -150,
                child: Column(
                  children: <Widget>[
                    CircularImage(
                      size: MediaQuery.of(context).size.width * 0.25,
                      image: brand.logoUrl,
                      color: Theme.of(context).colorScheme.secondary,
                      borderWidth: 2,
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                    Expanded(
                      child: Text(
                        brand.name!,
                        style: Theme.of(context)
                            .textTheme
                            .displayLarge
                            ?.copyWith(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.left,
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
