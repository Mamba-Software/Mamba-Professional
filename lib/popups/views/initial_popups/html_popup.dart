import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';

class HTMLPopup {
  static void show({
    required BuildContext context,
    required String html, // HTML content to display
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(20),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.red, // Background color for the container
              borderRadius: BorderRadius.circular(15),
            ),
            child: const SingleChildScrollView(
              // Enables scrolling for long HTML content
              child: HtmlWidget(
                '''
  <h3>Heading</h3>
  <p>
    A paragraph with <strong>strong</strong>, <em>emphasized</em>
    and <span style="color: red">colored</span> text.
  </p>
  ''',
              ),
            ),
          ),
        );
      },
    );
  }
}
