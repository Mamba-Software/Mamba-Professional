import 'package:mamba/commons/widgets/GroupOfComponents/PayWall/cubitSuscription/BrandSuscriptionCubit.dart';

import 'dart:io';
import 'package:flutter/foundation.dart';

mixin BrandPermission {
  // Assuming that BrandSuscriptionCubit has a method to get subscription details.
  late BrandSuscriptionCubit brandSuscriptionCubit;

  bool isAllowed(var context) {
    final subscriptionState = context.read<BrandSuscriptionCubit>().state;

    // Replace with your actual subscription state checks
    if (subscriptionState is BrandSuscriptionLoadedTrue) {
      if (subscriptionState.subscription.package == 'Premium') {
      } else if (subscriptionState.subscription.package == 'Premium') {
      } else {}
    }
    return false;
  }

  bool get isAndroid => !kIsWeb && Platform.isAndroid;

  bool get isIOS => !kIsWeb && Platform.isIOS;
}
