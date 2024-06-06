import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mamba/events/crud_events/cubit/CrudEventCubit.dart';
import 'package:mamba/events/crud_events/widgets/mobile/Bonos/EventBonosBlocSelector.dart';
import 'package:mamba/events/crud_events/widgets/mobile/DividerAddEditEvent.dart';
import 'package:mamba/events/crud_events/widgets/mobile/Location/LocationBlocSelector.dart';
import 'package:mamba/events/crud_events/widgets/mobile/TitleDescription/TitleDescriptionBlocSelector.dart';
import 'package:mamba/commons/widgets/loading/LoadingView.dart';
import 'package:mamba/commons/extensions/context.dart';

class InformationPage extends StatelessWidget {
  const InformationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<CrudEventCubit, CrudEventLoaded, bool>(
        selector: (state) {
      return state.isLoaded;
    }, builder: (context, isLoaded) {
      if (isLoaded) {
        return Container(
          margin: kIsWeb
              ? const EdgeInsets.symmetric(horizontal: 50)
              : const EdgeInsets.symmetric(horizontal: 0),
          child: Column(
            children: [
              const TitleDescriptionBlocSelector(),
              const LocationBlocSelector(),
              dividerAddEditEvent(context, context.l10n.location, true),
              const EventBonosBlocSelector(),
              /*
              dividerAddEditEvent(
                  context, context.l10n.bonos, true),
                  */
              SizedBox(height: MediaQuery.of(context).size.height * 0.15),
            ],
          ),
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
