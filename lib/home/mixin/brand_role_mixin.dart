import 'package:flutter/material.dart';
import 'package:mamba/commons/constants/GlobalVars.dart';
import 'package:mamba/commons/extensions/context.dart';
import 'package:mamba/commons/utils/Strings/StringUtils.dart';
import 'package:mamba/screens/MambaPro/HasBrandScreens/01-Qui/001-Trainers/RolesInfo.dart';
import 'package:mamba/screens/MambaPro/HasBrandScreens/01-Qui/015-AddMembers/ShareBrandLink.dart';

mixin BrandRoleMixin {
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
          heightFactor: 0.935,
          child: RolesInfo(),
        );
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
