import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mamba_castelldefels/commons/constants/GlobalVars.dart';
import 'package:mamba_castelldefels/app/style/AppColors.dart';
import 'package:mamba_castelldefels/commons/widgets/Components/Badges/CounterBadgeIcon.dart';
import 'package:mamba_castelldefels/notifications/Unread/cubit/UnreadNotChatsCubit.dart';

Widget unreadChats(BuildContext context) {
  return BlocBuilder<UnreadNotChatsCubit, List<int>>(builder: (context, state) {
    return CounterBadgeIcon(
      counter: state[1],
      top: 5,
      right: 7,
      child: InkWell(
        onTap: () => navigateToChatScreen(context),
        splashColor: Colors.white
            .withOpacity(0.2), // Customize splash color and radius if needed
        borderRadius:
            BorderRadius.circular(24), // Optional: customize the splash radius
        child: Padding(
          padding: const EdgeInsets.all(8), // Control the space around the icon
          child: Icon(
            Icons.chat,
            color: AppColors.white,
            size: MediaQuery.of(context).size.width * 0.06,
          ),
        ),
      ),
    );
  });
}
