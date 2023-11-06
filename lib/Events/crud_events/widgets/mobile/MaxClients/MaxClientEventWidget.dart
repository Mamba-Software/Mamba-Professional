import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mamba_castelldefels/Events/crud_events/cubit/CrudEventCubit.dart';
import 'package:mamba_castelldefels/Events/crud_events/utils/enumAddEditEvent.dart';
import 'package:mamba_castelldefels/Globals/Styles/AppColors/AppColors.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Components/CupertinoSelect/SelectMembersDialog.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

TextEditingController membersController = TextEditingController();

class MaxClientEventWidget extends StatefulWidget {
  final int maxMembers;

  const MaxClientEventWidget({super.key, required this.maxMembers});

  @override
  _MaxClientEventWidgetState createState() => _MaxClientEventWidgetState();
}

class _MaxClientEventWidgetState extends State<MaxClientEventWidget> {
  final TextEditingController membersController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  String titleString = '';
  String descriptionString = '';
  final FocusNode focusNodeDescController = FocusNode();
  FocusNode focusNodetitleController = FocusNode();
  bool isLoading = true;

  @override
  initState() {
    super.initState();
    final state = context.read<CrudEventCubit>().state;
    if (state.isLoaded && state.isNew) {
      membersController.text = 4.toString();
    } else {
      membersController.text = state.newEvent.maxMembers!.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: <Widget>[
            Flexible(
              child: TextFormField(
                keyboardType: TextInputType.number,
                focusNode: null,
                controller: membersController,
                maxLines: null,
                minLines: 1,
                validator: (val) => val!.isEmpty ? null : null,
                onChanged: (val) {
                  if (val.isEmpty) {
                    context
                        .read<CrudEventCubit>()
                        .editEventInfo('4', EditEventType.maxMembers);
                  } else {
                    context
                        .read<CrudEventCubit>()
                        .editEventInfo(val, EditEventType.maxMembers);
                  }
                },
                style: Theme.of(context).textTheme.bodyText1,
                decoration: InputDecoration(
                  suffixStyle: Theme.of(context).textTheme.caption,
                  hintStyle: Theme.of(context).textTheme.caption,
                  hintText: '4',
                  errorBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.transparent),
                  ),
                  disabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.transparent),
                  ),
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.transparent),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.transparent),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
