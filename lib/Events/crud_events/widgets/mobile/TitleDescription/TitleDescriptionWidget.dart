import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mamba/commons/managers/language_manager.dart';
import 'package:mamba/events/crud_events/cubit/CrudEventCubit.dart';
import 'package:mamba/events/crud_events/utils/enumAddEditEvent.dart';
import 'package:mamba/events/crud_events/widgets/mobile/DividerAddEditEvent.dart';
import 'package:mamba/commons/styles/AppColors.dart';

class TitleDescriptionWidget extends StatefulWidget {
  const TitleDescriptionWidget({super.key});

  @override
  _TitleDescriptionWidgetState createState() => _TitleDescriptionWidgetState();
}

class _TitleDescriptionWidgetState extends State<TitleDescriptionWidget> {
  final TextEditingController titleController = TextEditingController();
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
    if (state.isLoaded) {
      titleController.text = state.newEvent.title!;
      titleString = titleController.text;
      // Event Description
      descriptionController.text = state.newEvent.description!;
      descriptionString = descriptionController.text;
    }
    //focusNodetitleController.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        titleEventWidget(context, context.l10n.title),
        Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).size.height * 0.01),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Flexible(
                  child: TextFormField(
                    focusNode: focusNodetitleController,
                    controller: titleController,
                    validator: (val) =>
                        val!.isEmpty ? context.l10n.titleError : null,
                    onChanged: (val) {
                      context.read<CrudEventCubit>().editEventInfo(
                          val, EditEventType.title, null, descriptionString);
                      setState(() {
                        titleString = val;
                      });
                    },
                    onEditingComplete: () {
                      if (descriptionController.text.isEmpty) {
                        focusNodeDescController.requestFocus();
                      } else {
                        focusNodetitleController.unfocus();
                      }
                    },
                    style: Theme.of(context).textTheme.bodyMedium,
                    decoration: InputDecoration(
                      hintStyle: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(
                              color: titleString.isEmpty
                                  ? AppColors.red
                                  : Theme.of(context)
                                      .textTheme
                                      .bodySmall!
                                      .color),
                      hintText: context.l10n.titleHint,
                      errorStyle: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: AppColors.red),
                      errorBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: AppColors.red),
                      ),
                      disabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                            color: titleString.isEmpty
                                ? AppColors.red
                                : Theme.of(context).dividerColor),
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                            color: titleString.isEmpty
                                ? AppColors.red
                                : Theme.of(context).dividerColor),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                            color: titleString.isEmpty
                                ? AppColors.red
                                : Theme.of(context).dividerColor),
                      ),
                    ),
                    enabled: true,
                  ),
                ),
              ],
            )),
        titleEventWidget(context, context.l10n.description),
        Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).size.height * 0.01),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Flexible(
                  child: TextFormField(
                    focusNode: focusNodeDescController,
                    keyboardType: TextInputType.visiblePassword,
                    controller: descriptionController,
                    minLines: 1,
                    maxLines: 4,
                    onChanged: (val) {
                      context.read<CrudEventCubit>().editEventInfo(
                          val, EditEventType.description, null, titleString);
                      setState(() {
                        descriptionString = val;
                      });
                    },
                    style: Theme.of(context).textTheme.bodyMedium,
                    decoration: InputDecoration(
                      hintStyle: Theme.of(context).textTheme.bodySmall,
                      hintText: context.l10n.descriptionHint,
                      errorBorder: UnderlineInputBorder(
                        borderSide:
                            BorderSide(color: Theme.of(context).dividerColor),
                      ),
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
            )),
      ],
    );
  }
}
