import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mamba_castelldefels/events/crud_events/cubit/CrudEventCubit.dart';
import 'package:mamba_castelldefels/events/crud_events/widgets/mobile/DateTime/DateTimeEventWidget.dart';
import 'package:mamba_castelldefels/events/crud_events/widgets/mobile/DateTime/RecurrentEvent/RecurrentEventSelector.dart';
import 'package:mamba_castelldefels/commons/widgets/GroupOfComponents/LoadingViews/LoadingView.dart';

class DateTimePage extends StatelessWidget {
  final Locale locale;
  const DateTimePage({super.key, required this.locale});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<CrudEventCubit, CrudEventLoaded, bool>(
        selector: (state) {
      return state.isLoaded;
    }, builder: (context, isLoaded) {
      if (isLoaded) {
        return Column(
          children: [
            DateTimeEventWidget(locale: locale),
            RecurrentEventSelector(locale: locale),
            //dividerAddEditEvent(context, 'recurrent', true),
            SizedBox(height: MediaQuery.of(context).size.height * 0.10),
          ],
        );
      } else {
        return Padding(
          padding: EdgeInsets.symmetric(
              vertical: MediaQuery.of(context).size.height * 0.3),
          child: Center(
            child: LoadingView(
              hasLogo: false,
            ),
          ),
        );
      }
    });
  }
}
