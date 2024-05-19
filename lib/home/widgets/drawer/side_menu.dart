import 'package:flutter/material.dart';
import 'package:mamba/commons/constants/constants.dart';
import 'package:mamba/commons/extensions/context.dart';
import 'package:mamba/commons/mixins/platform.dart';
import 'package:mamba/home/widgets/drawer/body.dart';
import 'package:mamba/home/widgets/drawer/footer.dart';
import 'package:mamba/home/widgets/drawer/header.dart';

class SideMenu extends StatelessWidget with PlatformMixin {
  const SideMenu({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: sideMenuWidth,
      backgroundColor: context.colorScheme.background,
      surfaceTintColor: context.colorScheme.background,      
      shape: const RoundedRectangleBorder(
        side: BorderSide.none,
        borderRadius: BorderRadius.zero,
      ),
      child: const Column(
        children: [
          Header(),
          Body(),
          Footer(),
        ],
      ),
    );
  }
}
