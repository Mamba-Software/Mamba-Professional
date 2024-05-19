import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mamba/commons/constants/GlobalVars.dart';
import 'package:mamba/commons/constants/assets.dart';
import 'package:mamba/commons/constants/constants.dart';
import 'package:mamba/commons/extensions/context.dart';
import 'package:mamba/commons/managers/language_manager.dart';
import 'package:mamba/commons/mixins/platform.dart';
import 'package:mamba/commons/widgets/Components/Images/CircularImage.dart';
import 'package:mamba/home/cubit/home_navigation_manager.dart';
import 'package:mamba/home/mixin/brand_role_mixin.dart';
import 'package:mamba/home/widgets/appbar/AppBarIcon.dart';

class Header extends StatelessWidget with PlatformMixin, BrandRoleMixin {
  final double width;
  
  const Header({
    required this.width,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (BuildContext context) {
        if (context.isMobile || context.isTablet) {
          // Sizes and Colours Used for Table and Mobile
          double height = context.height * 0.25;
          double width = sideMenuWidth;
          Color dividerColor = context.theme.dividerColor;
          Color backgroundColor = context.colorScheme.background;
          // Header Widget
          return SizedBox(
            height: height,
            width: width,
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image:
                          CachedNetworkImageProvider(currentBrand.baseImage!),
                    ),
                  ),
                ),
                Container(
                  height: height,
                  width: width,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    gradient: LinearGradient(
                      begin: FractionalOffset.bottomCenter,
                      end: FractionalOffset.topCenter,
                      colors: [
                        backgroundColor,
                        backgroundColor.withOpacity(0.95),
                        backgroundColor.withOpacity(0.9),
                        backgroundColor.withOpacity(0.85),
                        backgroundColor.withOpacity(0.8),
                        backgroundColor.withOpacity(0.7),
                      ],
                      stops: const [
                        0.3,
                        0.35,
                        0.4,
                        0.45,
                        0.75,
                        1.0,
                      ],
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Padding(
                        padding: EdgeInsets.all(width * 0.05),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            CircularImage(
                              size: width * 0.2,
                              image: currentBrand.logoUrl,
                              borderWidth: 1,
                              color: dividerColor,
                            ),
                            SizedBox(
                              width: width * 0.05,
                            ),
                            Expanded(
                              child: SizedBox(
                                height: width * 0.2,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        currentBrand.name!,
                                        style: context.textTheme.headlineMedium,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    SizedBox(height: defaultPaddingSmall / 2),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Flexible(
                                          child: GestureDetector(
                                            onTap: () =>
                                                navigateToRolesInformationModal,
                                            child: Text(
                                              returnBrandRoleString(context),
                                              textAlign: TextAlign.left,
                                              style:
                                                  context.textTheme.bodyMedium!,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: defaultPaddingSmall),
                                        TextButton(
                                          style: TextButton.styleFrom(
                                            backgroundColor: context
                                                .colorScheme.secondary
                                                .withOpacity(0.3),
                                            padding: EdgeInsets.symmetric(
                                                horizontal:
                                                    defaultPaddingSmall),
                                            shape: RoundedRectangleBorder(
                                              // add this
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      defaultPaddingSmall),
                                            ),
                                            minimumSize: const Size(30, 30),
                                            tapTargetSize: MaterialTapTargetSize
                                                .shrinkWrap,
                                          ),
                                          onPressed: () =>
                                              navigateShareBrandLink,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.qr_code,
                                                color: context
                                                    .colorScheme.secondary,
                                                size: iconSizeSmall,
                                              ),
                                              SizedBox(
                                                width: defaultPaddingSmall,
                                              ),
                                              Text(
                                                context.l10n.invite,
                                                style: context
                                                    .textTheme.bodyMedium!
                                                    .copyWith(
                                                  color: context
                                                      .colorScheme.secondary,
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Divider(
                        color: context.theme.dividerColor,
                        thickness: 1,
                        height: 1,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        } else {
          return Column(
            children: [
              width == sideMenuWidth
                  ? Container(
                      height: desktopAppBarHeight,
                      width: sideMenuWidth,
                      padding:
                          EdgeInsets.symmetric(horizontal: defaultPaddingSmall),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(width: 10),
                          AppBarIcon(
                            icon: Icons.menu,
                            iconSize: iconSize,
                            color: context.colorScheme.onBackground,
                            onTap: () => context
                                .read<HomeNavigationManager>()
                                .toogleDesktopSideMenu(),
                          ),
                          SizedBox(width: defaultPaddingSmall),
                          Container(
                            height: 30,
                            width: 30,
                            decoration: BoxDecoration(
                              color: context.colorScheme.primary,
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                image: AssetImage(
                                  Assets.mambaLogoIcon,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: defaultPaddingSmall),
                          Text(
                            appName,
                            style: context.textTheme.headlineLarge,
                          ),
                        ],
                      ),
                    )
                  : Container(
                      height: desktopAppBarHeight,
                      width: collapsedSideMenuWidth,
                      padding:
                          EdgeInsets.symmetric(horizontal: defaultPaddingSmall),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          AppBarIcon(
                            icon: Icons.menu,
                            iconSize: iconSize,
                            color: context.colorScheme.onBackground,
                            onTap: () => context
                                .read<HomeNavigationManager>()
                                .toogleDesktopSideMenu(),
                          ),
                        ],
                      ),
                    ),
              Divider(
                color: context.theme.dividerColor,
                thickness: 1,
                height: 1,
              ),
            ],
          );
        }
      },
    );
  }
}
