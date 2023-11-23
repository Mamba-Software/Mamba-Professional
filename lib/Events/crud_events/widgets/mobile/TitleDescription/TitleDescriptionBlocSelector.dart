import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mamba_castelldefels/Events/crud_events/cubit/CrudEventCubit.dart';
import 'package:mamba_castelldefels/Events/crud_events/widgets/mobile/TitleDescription/TitleDescriptionWidget.dart';

class TitleDescriptionBlocSelector extends StatelessWidget {
  const TitleDescriptionBlocSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return TitleDescriptionWidget();
  }
}
