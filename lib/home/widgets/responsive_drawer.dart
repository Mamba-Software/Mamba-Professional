import 'package:flutter/material.dart';
import 'package:mamba/auth/widgets/custom_appbar.dart';
import 'package:mamba/commons/constants/GlobalVars.dart';
import 'package:mamba/commons/constants/assets.dart';
import 'package:mamba/commons/extensions/context.dart';
import 'package:mamba/commons/managers/language_manager.dart';
import 'package:mamba/commons/mixins/platform.dart';
import 'package:mamba/commons/styles/AppColors.dart';
import 'package:mamba/home/widgets/body.dart';
import 'package:mamba/home/widgets/footer.dart';
import 'package:mamba/home/widgets/header.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../../commons/constants/constants.dart';

class ResponsiveDrawer extends StatelessWidget with PlatformMixin {
  final Widget child;

  ResponsiveDrawer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        if (context.isMobile) {
          return Scaffold(
            key: mambaProScaffoldKey,
            drawer: Drawer(
              surfaceTintColor: context.theme.scaffoldBackgroundColor,
              backgroundColor: context.theme.scaffoldBackgroundColor,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(0.0),
                  bottomRight: Radius.circular(0.0),
                ),
              ),
              child: Column(
                children: [
                  // Header
                  Column(
                    children: [
                      Header(
                        height: context.height * 0.25,
                      ),
                      const Divider(
                        color: AppColors.grey,
                        thickness: 0,
                        height: 1,
                      ),
                    ],
                  ),

                  // Body
                  const Body(),
                  // Footer
                  Column(
                    children: [
                      const Divider(
                        color: AppColors.grey,
                        thickness: 0,
                        height: 1,
                      ),
                      Footer(
                        height: context.height * 0.1,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            body: child,
          );
        } else if (context.isTablet) {
          return Scaffold(
            key: mambaProScaffoldKey,
            body: child,
          );
        } else {
          return Scaffold(
            body: ListView(
              children: [
                const CustomAppBar(
                  isDesktop: true,
                  height: kToolbarHeight,
                  maxWidth: 1250,
                ),
                Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    SizedBox(
                      height: context.height,
                      child: Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  constraints:
                                      const BoxConstraints(maxWidth: 400),
                                  child: child,
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: SizedBox(
                              height: context.height,
                              child: Image(
                                fit: BoxFit.fitHeight,
                                image: AssetImage(
                                  Assets.mambaCover,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: kToolbarHeight,
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: context.colorScheme.background,
                        border: Border(
                          top: BorderSide(
                            color: context.theme
                                .dividerColor, // Color of the bottom border
                            width: 0.5, // Width of the bottom border
                          ),
                        ),
                      ),
                      child: Center(
                        child: Container(
                          constraints: const BoxConstraints(
                            maxWidth: 1250,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Flexible(
                                flex: 1,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    TextButton(
                                      onPressed: () async {
                                        FocusScopeNode currentFocus =
                                            FocusScope.of(context);
                                        if (!currentFocus.hasPrimaryFocus) {
                                          currentFocus.unfocus();
                                        }
                                        if (!await launchUrl(
                                            Uri.parse(pricing))) {
                                          throw 'Could not launch $pricing';
                                        }
                                      },
                                      child: Text(
                                        "Pricing",
                                        style: context.textTheme.labelMedium,
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        FocusScopeNode currentFocus =
                                            FocusScope.of(context);
                                        if (!currentFocus.hasPrimaryFocus) {
                                          currentFocus.unfocus();
                                        }
                                        if (!await launchUrl(
                                            Uri.parse(termsAndConditions))) {
                                          throw 'Could not launch $termsAndConditions';
                                        }
                                      },
                                      child: Text(
                                        context.l10n.termsAndConditions,
                                        style: context.textTheme.labelMedium,
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        FocusScopeNode currentFocus =
                                            FocusScope.of(context);
                                        if (!currentFocus.hasPrimaryFocus) {
                                          currentFocus.unfocus();
                                        }
                                        if (!await launchUrl(
                                            Uri.parse(privacy))) {
                                          throw 'Could not launch $privacy';
                                        }
                                      },
                                      child: Text(
                                        context.l10n.privacy,
                                        style: context.textTheme.labelMedium,
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        FocusScopeNode currentFocus =
                                            FocusScope.of(context);
                                        if (!currentFocus.hasPrimaryFocus) {
                                          currentFocus.unfocus();
                                        }
                                        String url = 'mailto:$contactEmail';
                                        if (await canLaunchUrlString(url)) {
                                          await launchUrlString(url);
                                        }
                                      },
                                      child: Text(
                                        context.l10n.getInTouch,
                                        style: context.textTheme.labelMedium,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Flexible(
                                flex: 1,
                                child: Text(
                                  "Copyright © 2024 Mamba Software",
                                  style: context.textTheme.labelMedium,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }
      },
    );
  }
}
