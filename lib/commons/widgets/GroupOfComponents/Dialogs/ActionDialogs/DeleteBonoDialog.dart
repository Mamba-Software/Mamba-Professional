import 'package:flutter/material.dart';
import 'package:mamba/commons/managers/language_manager.dart';
import 'package:mamba/commons/styles/AppColors.dart';

class DeleteBonoDialog extends StatelessWidget {
  final bool hasPurchases;
  final bool isActive;
  const DeleteBonoDialog(
      {super.key, required this.hasPurchases, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        padding:
            const EdgeInsets.only(top: 40, bottom: 10, left: 10, right: 10),
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
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.only(
                        top: 8.0, bottom: 8.0, right: 10, left: 10),
                    child: Text(
                      hasPurchases && isActive
                          ? context.l10n.deactivateBonoConfirmation
                          : context.l10n.deleteBonoConfirmation,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(height: 1.5),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                hasPurchases
                    ? Container(
                        height: MediaQuery.of(context).size.height * 0.1,
                        width: MediaQuery.of(context).size.width * 0.8,
                        margin: EdgeInsets.symmetric(
                            vertical:
                                MediaQuery.of(context).size.height * 0.02),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          color: AppColors.red.withOpacity(0.2),
                          borderRadius: const BorderRadius.all(
                            Radius.circular(10),
                          ),
                          border: Border.all(color: AppColors.red, width: 2),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.info_outlined,
                              color: AppColors.red,
                              size: MediaQuery.of(context).size.width * 0.08,
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 4.0),
                                child: Text(
                                  context.l10n.bonosNoDeleteWarning,
                                  textAlign: TextAlign.left,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                          color: AppColors.red, height: 1.5),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : Container(
                        height: MediaQuery.of(context).size.height * 0.1,
                        width: MediaQuery.of(context).size.width * 0.8,
                        margin: EdgeInsets.symmetric(
                            vertical:
                                MediaQuery.of(context).size.height * 0.02),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.2),
                          borderRadius: const BorderRadius.all(
                            Radius.circular(10),
                          ),
                          border: Border.all(color: Colors.green, width: 2),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outlined,
                              color: Colors.green,
                              size: MediaQuery.of(context).size.width * 0.08,
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                context.l10n.bonosCanDeleteWarning,
                                textAlign: TextAlign.left,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                        color: Colors.green, height: 1.3),
                              ),
                            ),
                          ],
                        ),
                      ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: hasPurchases && isActive == false
                        ? MainAxisAlignment.center
                        : MainAxisAlignment.spaceEvenly,
                    children: [
                      hasPurchases && isActive == false
                          ? Container()
                          : OutlinedButton.icon(
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
                                hasPurchases
                                    ? context.l10n.mambaProActivated
                                        .split(" ")[0]
                                    : context.l10n.delete,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(color: AppColors.white),
                              ),
                              icon: Icon(
                                hasPurchases
                                    ? Icons.pause_circle_outline
                                    : Icons.delete_outline,
                                size: MediaQuery.of(context).size.width * 0.06,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                Navigator.pop(context, true);
                              },
                            ),
                      hasPurchases && isActive == false
                          ? Container()
                          : SizedBox(
                              width: MediaQuery.of(context).size.width * 0.01),
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
                          context.l10n.cancel,
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
                top: -83,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox.fromSize(
                      size: const Size(70, 70), // button width and height
                      child: ClipOval(
                        child: Material(
                          color: Colors.red, // button color
                          child: InkWell(
                            onTap: () async {},
                            child: const Icon(
                              Icons.priority_high,
                              color: Colors.white,
                              size: 45,
                            ), // icon
                          ),
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
