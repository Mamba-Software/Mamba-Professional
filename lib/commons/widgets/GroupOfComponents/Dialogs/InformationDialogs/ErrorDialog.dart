import 'package:flutter/material.dart';
import 'package:mamba/commons/managers/language_manager.dart';
import 'package:mamba/app/style/AppColors.dart';

class ErrorDialog extends StatelessWidget {
  final String text;
  const ErrorDialog({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(40),
      child: Container(
        padding:
            const EdgeInsets.only(top: 40, bottom: 10, left: 20, right: 20),
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
                  child: Text(
                    text,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(height: 1.5),
                    textAlign: TextAlign.center,
                  ),
                ),
                TextButton(
                    child: Text(
                      context.l10n.close,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(decoration: TextDecoration.underline),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    }),
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
                          color: AppColors.red, // button color
                          child: InkWell(
                            onTap: () async {},
                            child: Icon(
                              Icons.close,
                              color: Colors.white,
                              size: MediaQuery.of(context).size.width * 0.12,
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
