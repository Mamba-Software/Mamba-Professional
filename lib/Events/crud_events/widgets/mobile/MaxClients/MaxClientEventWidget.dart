import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mamba_castelldefels/events/crud_events/cubit/CrudEventCubit.dart';
import 'package:mamba_castelldefels/events/crud_events/utils/enumAddEditEvent.dart';

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
                maxLength: 3,
                maxLengthEnforcement: MaxLengthEnforcement.enforced,
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
                style: Theme.of(context).textTheme.bodyLarge,
                decoration: InputDecoration(
                  counterText: '',
                  hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).textTheme.bodySmall!.color),
                  hintText: '4',
                  disabledBorder: UnderlineInputBorder(
                    borderSide:
                        BorderSide(color: Theme.of(context).dividerColor),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide:
                        BorderSide(color: Theme.of(context).dividerColor),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide:
                        BorderSide(color: Theme.of(context).dividerColor),
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
