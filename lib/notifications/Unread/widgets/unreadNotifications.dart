import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mamba/commons/constants/GlobalVars.dart';
import 'package:mamba/commons/styles/AppColors.dart';
import 'package:mamba/commons/widgets/Components/Badges/CounterBadgeIcon.dart';
import 'package:mamba/notifications/Unread/cubit/UnreadNotChatsCubit.dart';

Widget unreadNotifications(BuildContext context) {
  return BlocBuilder<UnreadNotChatsCubit, List<int>>(builder: (context, state) {
    return CounterBadgeIcon(
      counter: state[0],
      top: 5,
      right: 7,
      child: InkWell(
        onTap: () => navigateToNotificationsScreen(context),
        splashColor: Colors.white
            .withOpacity(0.2), // Customize splash color and radius if needed
        borderRadius:
            BorderRadius.circular(24), // Optional: customize the splash radius
        child: Padding(
          padding: const EdgeInsets.all(8), // Control the space around the icon
          child: Icon(
            Icons.notifications,
            color: AppColors.white,
            size: MediaQuery.of(context).size.width * 0.06,
          ),
        ),
      ),
    );
  });
}
