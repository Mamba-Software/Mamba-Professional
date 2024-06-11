import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mamba/data/Models/Location.dart';
import 'package:mamba/events/crud_events/cubit/CrudEventCubit.dart';
import 'package:mamba/events/crud_events/widgets/mobile/DividerAddEditEvent.dart';
import 'package:mamba/events/crud_events/widgets/mobile/Location/LocationLoading.dart';
import 'package:mamba/events/crud_events/widgets/mobile/Location/LocationWidget.dart';
import 'package:mamba/commons/extensions/context.dart';

class LocationBlocSelector extends StatelessWidget {
  const LocationBlocSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<CrudEventCubit, CrudEventLoaded, Location>(
        selector: (state) {
      return state.newEvent.location!;
    }, builder: (context, locationCubit) {
      return Column(
        children: [
          titleEventWidget(context, context.l10n.location),
          locationCubit.id == null
              ? locationLoading(context)
              : LocationWidget(
                  location: locationCubit,
                ),
        ],
      );
    });
  }
}
