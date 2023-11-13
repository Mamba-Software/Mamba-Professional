import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mamba_castelldefels/Events/crud_events/cubit/CrudEventCubit.dart';
import 'package:mamba_castelldefels/Events/crud_events/widgets/mobile/Bonos/EventBonosBlocSelector.dart';
import 'package:mamba_castelldefels/Events/crud_events/widgets/mobile/Clients/ClientEventSelector.dart';
import 'package:mamba_castelldefels/Events/crud_events/widgets/mobile/DateTime/DateTimeEventWidget.dart';
import 'package:mamba_castelldefels/Events/crud_events/widgets/mobile/Location/LocationBlocSelector.dart';
import 'package:mamba_castelldefels/Events/crud_events/widgets/mobile/MaxClients/MaxClientsEvent.dart';
import 'package:mamba_castelldefels/Events/crud_events/widgets/mobile/Staff/StaffEventSelector.dart';
import 'package:mamba_castelldefels/Events/crud_events/widgets/mobile/TitleDescription/TitleDescriptionBlocSelector.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/LoadingViews/LoadingView.dart';

class MembersPage extends StatelessWidget {
  const MembersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<CrudEventCubit, CrudEventLoaded, bool>(
        selector: (state) {
      return state.isLoaded;
    }, builder: (context, isLoaded) {
      if (isLoaded) {
        return Column(
          children: [
            const StaffEventSelector(),
            const MaxClientsEventSelector(),
            BlocSelector<CrudEventCubit, CrudEventLoaded, bool>(
                selector: (state) {
              return !state.newEvent.isRecurrent! || !state.isNew;
            }, builder: (context, addClients) {
              return addClients ? const ClientEventSelector() : Container();
            }),
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
