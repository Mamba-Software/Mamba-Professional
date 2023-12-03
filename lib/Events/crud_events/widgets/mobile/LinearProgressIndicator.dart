import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mamba_castelldefels/Events/crud_events/cubit/CrudEventCubit.dart';
import 'package:mamba_castelldefels/Globals/Styles/AppColors/AppColors.dart';

class LinearProgressIndicatorWidget extends StatelessWidget {
  const LinearProgressIndicatorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<CrudEventCubit, CrudEventLoaded, double>(
        selector: (state) {
      return state.isWorking;
    }, builder: (context, isWorking) {
      return SizedBox(
        height: isWorking < 100 ? 2 : 0,
        child: LinearProgressIndicator(
          value: isWorking / 100,
          color: AppColors.mainColor,
          backgroundColor: Colors.transparent,
        ),
      );
    });
  }
}
