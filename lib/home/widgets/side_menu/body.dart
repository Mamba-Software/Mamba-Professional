import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mamba/commons/constants/GlobalVars.dart';
import 'package:mamba/commons/constants/constants.dart';
import 'package:mamba/commons/extensions/context.dart';
import 'package:mamba/commons/managers/language_manager.dart';
import 'package:mamba/commons/mixins/platform.dart';
import 'package:mamba/commons/widgets/Components/Badges/MobileBadge.dart';
import 'package:mamba/home/cubit/home_navigation_manager.dart';
import 'package:mamba/home/mixin/brand_role_mixin.dart';
import 'package:mamba/home/mixin/home_tile_mixin.dart';
import 'package:mamba/home/models/home_navigation_page.dart';
import 'package:mamba/snackbar/cubit/snackbar_cubit.dart';
import 'package:mamba/snackbar/models/custom_snackbar.dart';
import 'package:mamba/snackbar/models/snackbar_type.dart';

class Body extends StatelessWidget with PlatformMixin, BrandRoleMixin {
  final double width;

  const Body({
    required this.width,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      if (context.isMobile || context.isTablet) {
        // Header Widget
        return Expanded(
          child: ListView(
            physics: const ClampingScrollPhysics(),
            padding: EdgeInsets.zero,
            children: [
              SizedBox(height: defaultPadding),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      context.l10n.management,
                      style: context.textTheme.labelLarge,
                      textAlign: TextAlign.left,
                    ),
                  ),
                  const BodyTile(
                    page: HomeNavigationPage.BOOKINGS,
                    webSupported: true,
                  ),
                  const BodyTile(
                    page: HomeNavigationPage.PAYMENTS,
                  ),
                  const BodyTile(
                    page: HomeNavigationPage.STATS,
                  ),
                  SizedBox(height: defaultPaddingSmall),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: defaultPadding),
                    child: Text(
                      context.l10n.yourBrand,
                      style: context.textTheme.labelLarge,
                      textAlign: TextAlign.left,
                    ),
                  ),
                  const BodyTile(
                    page: HomeNavigationPage.RATES,
                  ),
                  const BodyTile(
                    page: HomeNavigationPage.CLIENTS,
                  ),
                  const BodyTile(
                    page: HomeNavigationPage.STAFF,
                  ),
                  SizedBox(height: defaultPaddingSmall),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: defaultPadding),
                    child: Text(
                      context.l10n.information,
                      style: context.textTheme.labelLarge,
                      textAlign: TextAlign.left,
                    ),
                  ),
                  const BodyTile(page: HomeNavigationPage.INFO),
                  const BodyTile(
                    page: HomeNavigationPage.IMAGES,
                  ),
                  const BodyTile(
                    page: HomeNavigationPage.LOCATIONS,
                  ),
                ],
              ),
              SizedBox(height: defaultPadding),
            ],
          ),
        );
      } else {
        // Header Widget
        if (width == sideMenuWidth) {
          return Expanded(
            child: ListView(
              physics: const ClampingScrollPhysics(),
              padding: EdgeInsets.zero,
              children: [
                Padding(
                  padding: EdgeInsets.all(defaultPadding),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            currentBrand.name!,
                            style: context.textTheme.labelLarge!.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.left,
                          ),
                          TextButton(
                            style: TextButton.styleFrom(
                              backgroundColor: context.colorScheme.secondary
                                  .withOpacity(0.3),
                              padding: EdgeInsets.symmetric(
                                  horizontal: defaultPaddingSmall),
                              shape: RoundedRectangleBorder(
                                // add this
                                borderRadius:
                                    BorderRadius.circular(borderRadiusSmall),
                              ),
                              minimumSize: const Size(30, 30),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            onPressed: () => {},
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.qr_code,
                                  color: context.colorScheme.secondary,
                                  size: iconSizeSmall,
                                ),
                                SizedBox(
                                  width: defaultPaddingSmall,
                                ),
                                Text(
                                  context.l10n.invite,
                                  style: context.textTheme.bodyMedium!.copyWith(
                                    color: context.colorScheme.secondary,
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                      GestureDetector(
                        onTap: () => navigateToRolesInformationModal,
                        child: Text(
                          returnBrandRoleString(context),
                          textAlign: TextAlign.left,
                          style: context.textTheme.labelLarge!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: defaultPadding,
                          vertical: defaultPaddingSmall),
                      child: Text(
                        context.l10n.management,
                        style: context.textTheme.labelLarge,
                        textAlign: TextAlign.left,
                      ),
                    ),
                    const BodyTile(
                      page: HomeNavigationPage.BOOKINGS,
                      webSupported: true,
                    ),
                    const BodyTile(
                      page: HomeNavigationPage.PAYMENTS,
                    ),
                    const BodyTile(
                      page: HomeNavigationPage.STATS,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: defaultPadding,
                          vertical: defaultPaddingSmall),
                      child: Text(
                        context.l10n.yourBrand,
                        style: context.textTheme.labelLarge,
                        textAlign: TextAlign.left,
                      ),
                    ),
                    const BodyTile(
                      page: HomeNavigationPage.RATES,
                    ),
                    const BodyTile(
                      page: HomeNavigationPage.CLIENTS,
                    ),
                    const BodyTile(
                      page: HomeNavigationPage.STAFF,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: defaultPadding,
                          vertical: defaultPaddingSmall),
                      child: Text(
                        context.l10n.information,
                        style: context.textTheme.labelLarge,
                        textAlign: TextAlign.left,
                      ),
                    ),
                    const BodyTile(page: HomeNavigationPage.INFO),
                    const BodyTile(
                      page: HomeNavigationPage.IMAGES,
                    ),
                    const BodyTile(
                      page: HomeNavigationPage.LOCATIONS,
                    ),
                  ],
                ),
                SizedBox(height: defaultPadding),
              ],
            ),
          );
        } else {
          return Expanded(
            child: ListView(
              physics: const ClampingScrollPhysics(),
              padding: EdgeInsets.all(defaultPaddingSmall),
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                  padding:
                      EdgeInsets.symmetric(vertical: defaultPaddingSmall / 2),
                      child: TextButton(
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          backgroundColor:
                              context.colorScheme.secondary.withOpacity(0.3),
                          shape: RoundedRectangleBorder(
                            // add this
                            borderRadius:
                                BorderRadius.circular(borderRadiusSmall),
                          ),
                        ),
                        onPressed: () => {},
                        child: Padding(
                          padding:
                              EdgeInsets.symmetric(vertical: defaultPaddingSmall),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.qr_code,
                                color: context.colorScheme.secondary,
                                size: iconSizeBig,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: defaultPaddingSmall),
                      child: Divider(
                        color: context.theme.dividerColor,
                        thickness: 1,
                        height: 1,
                      ),
                    ),
                    const BodyTile(
                      page: HomeNavigationPage.BOOKINGS,
                      webSupported: true,
                    ),
                    const BodyTile(
                      page: HomeNavigationPage.PAYMENTS,
                    ),
                    const BodyTile(
                      page: HomeNavigationPage.STATS,
                    ),
                    Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: defaultPaddingSmall),
                      child: Divider(
                        color: context.theme.dividerColor,
                        thickness: 1,
                        height: 1,
                      ),
                    ),
                    const BodyTile(
                      page: HomeNavigationPage.RATES,
                    ),
                    const BodyTile(
                      page: HomeNavigationPage.CLIENTS,
                    ),
                    const BodyTile(
                      page: HomeNavigationPage.STAFF,
                    ),
                    Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: defaultPaddingSmall),
                      child: Divider(
                        color: context.theme.dividerColor,
                        thickness: 1,
                        height: 1,
                      ),
                    ),
                    const BodyTile(
                      page: HomeNavigationPage.INFO,
                    ),
                    const BodyTile(
                      page: HomeNavigationPage.IMAGES,
                    ),
                    const BodyTile(
                      page: HomeNavigationPage.LOCATIONS,
                    ),
                  ],
                ),
                SizedBox(height: defaultPadding),
              ],
            ),
          );
        }
      }
    });
  }
}

class BodyTile extends StatelessWidget with HomeTileMixin {
  final HomeNavigationPage page;
  final bool? webSupported;

  const BodyTile({
    super.key,
    required this.page,
    this.webSupported,
  });

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (BuildContext context) {
        if (context.isMobile || context.isTablet) {
          return ListTile(
            splashColor: context.theme.scaffoldBackgroundColor,
            hoverColor: context.theme.scaffoldBackgroundColor,
            focusColor: context.theme.scaffoldBackgroundColor,
            leading: returnLeadingIcon(context, page),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                returnTextWidget(context, page),
                if (context.isDesktop && webSupported == null) const OnlyMobileBadge(),
              ],
            ),
            onTap: () {
              bool isWebSupported =
                  context.read<HomeNavigationManager>().isWebSupported(page);
              if (isWebSupported) {
                context.read<HomeNavigationManager>().jumpToPage(page);
              } else {
                CustomSnackbar snackbar = CustomSnackbar(
                  type: SnackbarType.information,
                  message: context.l10n.mobileOnly,
                  icon: Icons.smartphone,
                  color: Colors.blue,
                );
                context.read<SnackbarCubit>().enqueueSnackbarAction(snackbar);
              }
            },
          );
        } else {
          return BlocBuilder<HomeNavigationManager, HomeNavigationManagerState>(
            builder: (BuildContext context, HomeNavigationManagerState state) {
              void onTap() {
                bool isWebSupported =
                    context.read<HomeNavigationManager>().isWebSupported(page);
                if (isWebSupported) {
                  context.read<HomeNavigationManager>().jumpToPage(page);
                } else {
                  CustomSnackbar snackbar = CustomSnackbar(
                    type: SnackbarType.information,
                    message: context.l10n.mobileOnly,
                    icon: Icons.smartphone,
                    color: Colors.blue,
                  );
                  context.read<SnackbarCubit>().enqueueSnackbarAction(snackbar);
                }
              }
              if (state.isExtendedDesktop) {
                return Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: defaultPaddingSmall,
                    vertical: 1,
                  ),
                  child: ListTile(
                    splashColor: context.theme.scaffoldBackgroundColor,
                    hoverColor: context.theme.scaffoldBackgroundColor,
                    focusColor: context.theme.scaffoldBackgroundColor,
                    leading: returnLeadingIcon(context, page),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        returnTextWidget(
                          context,
                          page,
                          context.textTheme.bodyLarge!
                              .copyWith(fontSize: title1),
                        ),
                        if (webSupported == null) const OnlyMobileBadge(),
                      ],
                    ),
                    selected: state.page == page,
                    selectedColor: context.theme.scaffoldBackgroundColor,
                    selectedTileColor: context.theme.scaffoldBackgroundColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(borderRadiusSmall),
                    ),
                    onTap: () => onTap(),
                  ),
                );
              } else {
                return Padding(
                  padding:
                      EdgeInsets.symmetric(vertical: defaultPaddingSmall / 2),
                  child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: state.page == page
                          ? context.theme.scaffoldBackgroundColor
                          : context.colorScheme.background,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(borderRadiusSmall),
                      ),
                    ),
                    onPressed: () => onTap(),
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: defaultPaddingSmall),
                      child: returnLeadingIcon(context, page, iconSizeBig),
                    ),
                  ),
                );
              }
            },
          );
        }
      },
    );
  }
}
