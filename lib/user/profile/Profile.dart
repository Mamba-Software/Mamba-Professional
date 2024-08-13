import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mamba/Events/cubit/events_bloc.dart';
import 'package:mamba/app/router/custom_transitions.dart';
import 'package:mamba/commons/extensions/context.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:mamba/commons/constants/constants.dart';
import 'package:mamba/commons/mixins/platform.dart';
import 'package:mamba/data/DataService/Event/EventDataService.dart';
import 'package:mamba/data/DataService/User/UserDataService.dart';
import 'package:mamba/events/crud_events/models/Event.dart';
import 'package:mamba/commons/constants/GlobalVars.dart';
import 'package:mamba/commons/styles/AppColors.dart';
import 'package:mamba/commons/utils/Date/DateTimeUtils.dart';
import 'package:mamba/commons/utils/SharePlus/SharePlusUtils.dart';
import 'package:mamba/commons/utils/Strings/StringUtils.dart';
import 'package:mamba/commons/widgets/Components/Images/CircularImage.dart';
import 'package:mamba/commons/widgets/Components/Images/ImageFullScreen.dart';
import 'package:mamba/commons/widgets/GroupOfComponents/Stats/SessionsMade.dart';
import 'package:mamba/home/widgets/responsive_menu.dart';
import 'package:mamba/user/bloc/user_bloc.dart';
import 'package:mamba/user/mixin/user.dart';
import 'package:mamba/user/profile/views/Feedback/Help.dart';
import 'package:mamba/user/profile/views/settings/Settings.dart';
import 'package:mamba/user/profile/views/settings/SettingsYourData.dart';
import 'package:mamba/user/profile/views/settings/widgets/ProfileWdiget.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher_string.dart';

// Profile Page
class Profile extends StatelessWidget {
  static String routeName = 'profile';

  static GoRoute route = GoRoute(
    name: routeName,
    path: "profile",
    pageBuilder: (BuildContext context, GoRouterState state) =>
        CustomTransitions.instance.customTransitionPage(
      state: state,
      child: const Profile(),
    ),
    routes: [
      Settings.route,
    ],
  );

  const Profile({super.key});

  @override
  Widget build(Object context) {
    return BlocBuilder<UserBloc, UserState>(builder: (context, state) {
      if (state is UserLoaded) {
        return ProfileWidget(user: state.user);
      } else {
        return Container();
      }
    });
  }
}
