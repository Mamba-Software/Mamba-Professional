import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mamba/commons/extensions/context.dart';
import 'package:mamba/home/cubit/home_navigation_manager.dart';
import 'package:mamba/home/mixin/home_tile_mixin.dart';
import 'package:mamba/home/models/home_navigation_page.dart';

class BodyTile extends StatelessWidget with HomeTileMixin {
  final HomeNavigationPage page;

  const BodyTile({
    super.key,
    required this.page,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      splashColor: context.colorScheme.surface,
      hoverColor: context.colorScheme.surface,
      focusColor: context.colorScheme.surface,
      leading: returnLeadingIcon(context, page),
      title: returnTextWidget(context, page),
      onTap: () => context.read<HomeNavigationManager>().jumpToPage(page),
    );
  }
}
