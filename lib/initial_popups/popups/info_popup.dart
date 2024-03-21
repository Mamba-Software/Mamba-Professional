import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class InfoPopUp {
  static void showInfoPopUp({required BuildContext context, required String message, required Function() onTap}) {
    showCupertinoDialog<void>(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          content: Text(message, style: const TextStyle(fontSize: 16)),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              textStyle: TextStyle(color: Theme.of(context).colorScheme.secondary),
              child: Text(context.l10n.accept),
              onPressed: () {
                HapticFeedback.lightImpact();
                Navigator.pop(context);
                onTap();
              },
            ),
          ],
        );
      },
    );
  }
}
