// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:mamba/commons/constants/GlobalVars.dart';
import 'package:mamba/commons/extensions/context.dart';
import 'package:mamba/commons/managers/language_manager.dart';
import 'package:mamba/commons/mixins/platform.dart';
import 'package:mamba/commons/styles/AppColors.dart';
import 'package:mamba/commons/utils/Strings/StringUtils.dart';
import 'package:mamba/commons/widgets/Components/Images/CircularImage.dart';
import 'package:mamba/screens/MambaPro/HasBrandScreens/01-Qui/001-Trainers/RolesInfo.dart';
import 'package:mamba/screens/MambaPro/HasBrandScreens/01-Qui/015-AddMembers/ShareBrandLink.dart';

class Header extends StatelessWidget with PlatformMixin {
  double height;
  double width;

  Header({
    Key? key,
    required this.height,
    required this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: const BoxDecoration(
        color: AppColors.darkGrey,
      ),
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.cover,
                image: CachedNetworkImageProvider(currentBrand.baseImage!),
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
                  AppColors.darkerGrey,
                  AppColors.darkerGrey.withOpacity(0.95),
                  AppColors.darkerGrey.withOpacity(0.9),
                  AppColors.darkerGrey.withOpacity(0.85),
                  AppColors.darkerGrey.withOpacity(0.8),
                  AppColors.darkerGrey.withOpacity(0.7),
                ],
                stops: const [
                  0.2,
                  0.3,
                  0.4,
                  0.5,
                  0.75,
                  1.0,
                ],
              ),
            ),
            child: Padding(
              padding: EdgeInsets.all(width * 0.05),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  CircularImage(
                    size: width * 0.2,
                    image: currentBrand.logoUrl,
                    borderWidth: 0.5,
                    color: AppColors.white,
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
                              style: context.textTheme.headlineMedium
                                  ?.copyWith(color: AppColors.white),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Flexible(
                                child: GestureDetector(
                                  onTap: () => navigateToRolesInformationModal,
                                  child: Text(
                                    returnBrandRoleString(context),
                                    textAlign: TextAlign.left,
                                    style:
                                        context.textTheme.bodyMedium!.copyWith(
                                      color: AppColors.white,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              TextButton(
                                style: TextButton.styleFrom(
                                  backgroundColor: context.colorScheme.secondary
                                      .withOpacity(0.3),
                                  padding: const EdgeInsets.only(
                                      left: 8.0, right: 8.0),
                                  shape: RoundedRectangleBorder(
                                    // add this
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  minimumSize: const Size(30, 30),
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                onPressed: () => navigateShareBrandLink,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.qr_code,
                                      color: context.colorScheme.secondary,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      context.l10n.invite,
                                      style: context.textTheme.bodyMedium!
                                          .copyWith(
                                        color: context.colorScheme.secondary,
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
          ),
        ],
      ),
    );
  }

  // Navigate to Bonos Request Screen
  void navigateToRolesInformationModal(BuildContext context) async {
    mixpanel!.track('drawer_trainer_roles_info');
    showModalBottomSheet<bool?>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      builder: (BuildContext context) {
        return const FractionallySizedBox(
            heightFactor: 0.935, child: RolesInfo());
      },
    );
  }

  Future<void> navigateShareBrandLink(BuildContext context) async {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      builder: (BuildContext context) {
        return const FractionallySizedBox(
          heightFactor: 0.8,
          child: ShareBrandLink(),
        );
      },
    );
  }

  String returnBrandRoleString(BuildContext context) {
    switch (currentUser.brandRole) {
      case 1:
        if (currentBrand.adminID == currentUser.id) {
          return StringUtils()
              .toCapitalized(context.l10n.paySubscriptionDesc.split(" ")[2]);
        } else {
          return context.l10n.owner;
        }
      case 2:
        return context.l10n.administrador;
      case 3:
        return context.l10n.trainer;
      default:
        return context.l10n.trainer;
    }
  }
}
