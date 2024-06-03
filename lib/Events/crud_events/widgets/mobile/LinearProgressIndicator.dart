import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mamba/commons/extensions/context.dart';
import 'package:mamba/events/crud_events/cubit/CrudEventCubit.dart';

class LinearProgressIndicatorWidget extends StatelessWidget {
  const LinearProgressIndicatorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<CrudEventCubit, CrudEventLoaded, double>(
        selector: (state) {
      return state.isWorking;
    }, builder: (context, isWorking) {
      return SizedBox(
        height: isWorking < 100 ? 1 : 0,
        child: LinearProgressIndicator(
          value: isWorking / 100,
          color: context.colorScheme.secondary,
          backgroundColor: Colors.transparent,
        ),
      );
    });
  }
}
