import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mamba/auth/widgets/custom_appbar.dart';
import 'package:mamba/calendar/views/calendar.dart';
import 'package:mamba/commons/constants/GlobalVars.dart';
import 'package:mamba/commons/constants/assets.dart';
import 'package:mamba/commons/constants/constants.dart';
import 'package:mamba/commons/extensions/context.dart';
import 'package:mamba/commons/mixins/platform.dart';
import 'package:mamba/commons/styles/AppColors.dart';
import 'package:mamba/commons/widgets/Components/Images/CircularImage.dart';
import 'package:mamba/home/cubit/home_manager.dart';
import 'package:mamba/home/models/home_nav_page.dart';
import 'package:mamba/home/widgets/appbar/AppBarIcon.dart';
import 'package:mamba/home/widgets/side_menu/side_menu.dart';

class ResponsiveEvent extends StatelessWidget with PlatformMixin {
  final Widget child;

  const ResponsiveEvent({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        if (!kIsWeb) {
          return child;
        } else {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: defaultPadding),
            child: Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius:
                      BorderRadius.circular(2.0), // Adjust the radius as needed
                ),
                child: Padding(
                    padding: EdgeInsets.all(defaultPadding), child: child)),
          );
        }
      },
    );
  }
}
