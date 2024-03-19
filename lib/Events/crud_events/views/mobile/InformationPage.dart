import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mamba_castelldefels/events/crud_events/cubit/CrudEventCubit.dart';
import 'package:mamba_castelldefels/events/crud_events/widgets/mobile/Bonos/EventBonosBlocSelector.dart';
import 'package:mamba_castelldefels/events/crud_events/widgets/mobile/DividerAddEditEvent.dart';
import 'package:mamba_castelldefels/events/crud_events/widgets/mobile/Location/LocationBlocSelector.dart';
import 'package:mamba_castelldefels/events/crud_events/widgets/mobile/TitleDescription/TitleDescriptionBlocSelector.dart';
import 'package:mamba_castelldefels/commons/widgets/GroupOfComponents/LoadingViews/LoadingView.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class InformationPage extends StatelessWidget {
  const InformationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<CrudEventCubit, CrudEventLoaded, bool>(
        selector: (state) {
      return state.isLoaded;
    }, builder: (context, isLoaded) {
      if (isLoaded) {
        return Column(
          children: [
            const TitleDescriptionBlocSelector(),
            const LocationBlocSelector(),
            dividerAddEditEvent(
                context, AppLocalizations.of(context)!.location, true),
            const EventBonosBlocSelector(),
            /*
            dividerAddEditEvent(
                context, AppLocalizations.of(context)!.bonos, true),
                */
            SizedBox(height: MediaQuery.of(context).size.height * 0.15),
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
