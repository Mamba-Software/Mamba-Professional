import 'package:flutter/material.dart';
import 'package:mamba/commons/constants/assets.dart';
import 'package:mamba/commons/styles/AppColors.dart';
import 'package:mamba/commons/extensions/context.dart';

class UpdateAppPopup {
  static void show({
    required BuildContext context,
    required bool isMandatory,
    required Function() onAcceptFunction,
  }) {
    showDialog(
      context: context,
      barrierDismissible: !isMandatory,
      builder: (BuildContext context) {
        return PopScope(
            canPop: !isMandatory,
            child: Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.all(20),
              child: Container(
                padding: const EdgeInsets.only(
                    top: 40, bottom: 30, left: 20, right: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Theme.of(context).scaffoldBackgroundColor,
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: MediaQuery.of(context).size.width * 0.02),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Flexible(
                            child: Text(
                              context.l10n.updateAppTitle,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(
                                      fontWeight: FontWeight.bold, height: 1.5),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.01,
                          ),
                          Flexible(
                            child: Text(
                              context.l10n.updateAppText,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(height: 1.5),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          isMandatory
                              ? Column(
                                  children: [
                                    SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.02,
                                    ),
                                    Container(
                                        padding: EdgeInsets.all(
                                            MediaQuery.of(context).size.width *
                                                0.02),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          color: AppColors.ligtherRed
                                              .withOpacity(0.8),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(
                                              Icons.error_outline,
                                              color: AppColors.white,
                                            ),
                                            SizedBox(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.01),
                                            Text(
                                              context.l10n.mandatoryUpdate,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium
                                                  ?.copyWith(
                                                      height: 1.5,
                                                      color: AppColors.white),
                                              textAlign: TextAlign.center,
                                            ),
                                          ],
                                        )),
                                  ],
                                )
                              : Container(),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.01,
                          ),
                          Center(
                            child: SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.15,
                                child: Image.asset(Assets.appUpdateImage)),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.01,
                          ),
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              elevation: 4.0,
                              backgroundColor:
                                  Theme.of(context).colorScheme.secondary,
                              fixedSize: Size(
                                  MediaQuery.of(context).size.width * 0.35,
                                  MediaQuery.of(context).size.height * 0.06),
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(30),
                                ),
                              ),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                              onAcceptFunction();
                            },
                            child: Text(
                              context.l10n.update,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(
                                    color: AppColors.white,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                        top: -83,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            SizedBox.fromSize(
                              size:
                                  const Size(70, 70), // button width and height
                              child: ClipOval(
                                child: Material(
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                  child: InkWell(
                                    onTap: () async {},
                                    child: const Icon(
                                      Icons.update_outlined,
                                      color: Colors.white,
                                      size: 40,
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
            ));
      },
    );
  }
}
