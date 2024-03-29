import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:lottie/lottie.dart';
import 'package:mamba/commons/constants/assets.dart';
import 'package:mamba/app/styles/AppColors.dart';
import 'package:mamba/commons/extensions/context.dart';
import 'package:mamba/commons/managers/language_manager.dart';

class RateAppPopup {
  static void show({
    required BuildContext context,
    required Function() onAcceptFunction,
    required Function() onDeclineFunction,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return PopScope(
            canPop: false,
            child: Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.all(20),
              child: Container(
                padding: const EdgeInsets.only(
                    top: 80, bottom: 10, left: 20, right: 20),
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
                              context.l10n.rateAppTitle,
                              style: Theme.of(context)
                                  .textTheme
                                  .displayLarge
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
                              context.l10n.rateAppText,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(height: 1.5),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.03,
                          ),
                          RatingBar.builder(
                            allowHalfRating: true,
                            initialRating: 0,
                            itemCount: 5,
                            itemSize: MediaQuery.of(context).size.height * 0.06,
                            itemBuilder: (context, index) => Icon(
                              Icons.star,
                              color: context.colorScheme.secondary,
                            ),
                            onRatingUpdate: (rating) {
                              Navigator.pop(context);
                              onAcceptFunction();
                            },
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.01,
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                              onAcceptFunction();
                            },
                            child: Material(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              child: TextFormField(
                                textCapitalization:
                                    TextCapitalization.sentences,
                                minLines: 2,
                                maxLines: 5,
                                enabled: false,
                                style: Theme.of(context).textTheme.displaySmall,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Theme.of(context).backgroundColor,
                                  hintText: context.l10n.optional,
                                  hintStyle: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                          color: AppColors.grey,
                                          fontWeight: FontWeight.normal),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15.0),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15.0),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15.0),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15.0),
                                  ),
                                  contentPadding:
                                      const EdgeInsets.fromLTRB(12, 12, 12, 12),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.03,
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              onDeclineFunction();
                            },
                            style: TextButton.styleFrom(
                              surfaceTintColor: Colors.transparent,
                              foregroundColor: Colors.transparent,
                              backgroundColor: Colors.transparent,
                            ),
                            child: Text(
                              context.l10n.close,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(
                                    color: AppColors.grey,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ),
                          Text(
                            context.l10n.mambaWithLove,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(fontSize: 10),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                        top: -160,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            SizedBox.fromSize(
                              size: const Size(
                                  140, 140), // button width and height
                              child: ClipOval(
                                child: Material(
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                  child: Lottie.asset(
                                    Assets.rateOurApp,
                                    fit: BoxFit.cover,
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
