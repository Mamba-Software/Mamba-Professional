import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mamba/commons/extensions/context.dart';
import 'package:mamba/data/DataService/User/UserDataService.dart';
import 'package:mamba/commons/constants/assets.dart';
import 'package:mamba/commons/constants/GlobalVars.dart';
import 'package:mamba/commons/styles/AppColors.dart';
import 'package:mamba/commons/utils/Date/DateTimeUtils.dart';
import 'package:mamba/commons/widgets/Components/Images/CircularImage.dart';
import 'package:mamba/data/Models/Usuario.dart';
import 'package:mamba/commons/widgets/loading/LoadingView.dart';
import 'package:mamba/user/bloc/user_bloc.dart';
import 'package:mamba/user/mixin/user.dart';
import 'package:mamba/user/profile/views/Settings/SettingsEditPhotoPage.dart';
import 'package:mamba/user/profile/views/settings/widgets/SettingsYourDataWidget.dart';
import 'package:mamba/user/profile/views/settings/widgets/birthDayWidget.dart';
import 'package:mamba/user/profile/views/settings/widgets/genderWidget.dart';

// Tus Datos Widget.
class SettingsYourData extends StatelessWidget {
  const SettingsYourData({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserBloc, UserState>(builder: (context, state) {
      if (state is UserLoaded) {
        return SettingsYourDataWidget(user: state.user);
      } else {
        return Container();
      }
    });
  }
}
