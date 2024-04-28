import 'package:flutter/material.dart';
import 'package:mamba/auth/widgets/custom_appbar.dart';
import 'package:mamba/commons/constants/GlobalVars.dart';
import 'package:mamba/commons/constants/assets.dart';
import 'package:mamba/commons/extensions/context.dart';
import 'package:mamba/commons/managers/language_manager.dart';
import 'package:mamba/commons/mixins/platform.dart';
import 'package:mamba/commons/styles/AppColors.dart';
import 'package:mamba/home/models/MambaProUtils.dart';
import 'package:mamba/home/widgets/footer.dart';
import 'package:mamba/home/widgets/header.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../../commons/constants/constants.dart';

class ResponsiveDrawer extends StatelessWidget with PlatformMixin {
  final Widget child;

  ResponsiveDrawer({super.key, required this.child});

  final _mambaProUtils = MambaProUtils();

  Widget listTilePro(BuildContext context, int pageIndexVar,
      [bool isFavourite = false]) {
    return ListTile(
      leading: _mambaProUtils.iconSelectorListView(context, pageIndexVar),
      title: _mambaProUtils.titlePageSelectorListView(context, pageIndexVar),
      onTap: () => {
        Navigator.pop(context),
        setBrandActive(),
        /*
        setState(() {
          pageIndex = pageIndexVar;
        }),
        */
      },
    );
  }

  Widget buildBrandListOptions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.01),
        Padding(
          padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.04),
          child: Text(
            context.l10n.management,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.left,
          ),
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.01),
        listTilePro(context, 10),
        listTilePro(context, 18),
        listTilePro(context, 9),
        SizedBox(height: MediaQuery.of(context).size.height * 0.01),
        Padding(
          padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.04),
          child: Text(
            context.l10n.yourBrand,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.left,
          ),
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.01),
        listTilePro(context, 5),
        listTilePro(context, 2),
        listTilePro(context, 1),
        SizedBox(height: MediaQuery.of(context).size.height * 0.01),
        Padding(
          padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.04),
          child: Text(
            context.l10n.information,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.left,
          ),
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.01),
        listTilePro(context, 8),
        listTilePro(context, 7),
        listTilePro(context, 11),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: mambaProScaffoldKey,
      drawer: Drawer(
        surfaceTintColor: Theme.of(context).primaryColorDark,
        backgroundColor: Theme.of(context).primaryColorDark,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(0.0),
            bottomRight: Radius.circular(0.0),
          ),
        ),
        child: Column(
          children: [
            // Header
            const Header(),
            const Divider(
              color: AppColors.grey,
              thickness: 0,
              height: 1,
            ),
            // Brand List Options
            Expanded(
              child: ListView(
                physics: const ClampingScrollPhysics(),
                // Remove padding
                padding: EdgeInsets.zero,
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                  // Brand Options
                  buildBrandListOptions(context),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                ],
              ),
            ),
            // Payment
            const Divider(
              color: AppColors.grey,
              thickness: 0,
              height: 1,
            ),
            const Footer(),
          ],
        ),
      ),
      body: child,
    );

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        if (context.isMobile) {
          return Scaffold(
            key: mambaProScaffoldKey,
            drawer: Drawer(
              surfaceTintColor: Theme.of(context).primaryColorDark,
              backgroundColor: Theme.of(context).primaryColorDark,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(0.0),
                  bottomRight: Radius.circular(0.0),
                ),
              ),
              child: Column(
                children: [
                  // Header
                  const Header(),
                  const Divider(
                    color: AppColors.grey,
                    thickness: 0,
                    height: 1,
                  ),
                  // Brand List Options
                  Expanded(
                    child: ListView(
                      physics: const ClampingScrollPhysics(),
                      // Remove padding
                      padding: EdgeInsets.zero,
                      children: [
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.02),
                        // Brand Options
                        buildBrandListOptions(context),
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.05),
                      ],
                    ),
                  ),
                  // Payment
                  const Divider(
                    color: AppColors.grey,
                    thickness: 0,
                    height: 1,
                  ),
                  const Footer(),
                ],
              ),
            ),
            body: child,
          );
        } else if (context.isTablet) {
          return Scaffold(
            appBar: AppBar(
              elevation: 0,
              backgroundColor: Colors.transparent,
            ),
            extendBodyBehindAppBar: true,
            body: Container(
              decoration: BoxDecoration(
                color: context.theme.scaffoldBackgroundColor,
                image: DecorationImage(
                  opacity: 1,
                  colorFilter: ColorFilter.mode(
                    context.colorScheme.secondary.withOpacity(0.25),
                    BlendMode.dstATop,
                  ),
                  image:
                      AssetImage(Assets.mambaCover), // Specify your image path
                  fit: BoxFit
                      .fitHeight, // Cover the entire widget with the image
                ),
              ),
              child: ListView(
                children: [
                  const CustomAppBar(
                    height: kToolbarHeight,
                  ),
                  Center(
                    child: Container(
                      margin: const EdgeInsets.all(30),
                      constraints: const BoxConstraints(maxWidth: 500),
                      child: child,
                    ),
                  ),
                ],
              ),
            ),
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
