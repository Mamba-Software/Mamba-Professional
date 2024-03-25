import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:mamba/app/style/AppColors.dart';
import 'package:mamba/l10n/l10n.dart';

class HTMLPopup {
  static void show({
    required BuildContext context,
    required String html,
    required Function() onAcceptFunction,
  }) {    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return PopScope(
          canPop: false,
          child: Dialog(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            insetPadding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.05,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: MediaQuery.of(context).size.height * 0.65,
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: AppColors.white, // Or any background color for the dialog
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: SingleChildScrollView(
                    child: Center(
                      child: HtmlWidget(
                        html,
                        buildAsync: false,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    onAcceptFunction();
                  },
                  style: TextButton.styleFrom(
                    surfaceTintColor: Colors.transparent,
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.entendido,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
