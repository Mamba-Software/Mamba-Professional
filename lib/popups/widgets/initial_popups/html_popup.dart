import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:mamba/l10n/l10n.dart';
import 'package:mamba/popups/cubit/popups_cubit.dart';
import 'package:mamba/screens/MambaPro/Profile/ProfileScreens/Settings/Settings.dart';
import 'package:mamba/settings/data/settings_repository.dart';

class HTMLPopup {
  static void show({
    required BuildContext context,
    required String html, // HTML content to display
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return PopScope(
          onPopInvoked: (popsocpe) {

          },
          child: Dialog(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            insetPadding: EdgeInsets.symmetric(
              vertical: MediaQuery.of(context).size.height * 0.1,
              horizontal: MediaQuery.of(context).size.width * 0.05,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: MediaQuery.of(context).size.height * 0.65,
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .primaryColorDark, // Or any background color for the dialog
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: SingleChildScrollView(
                    // Allows the HTML content to scroll
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
                    RepositoryProvider.of<SettingsRepository>(context).setWhatsNewBoolean(true);
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: Text(
                    AppLocalizations.of(context)!.entendido,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).primaryColorDark,
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
