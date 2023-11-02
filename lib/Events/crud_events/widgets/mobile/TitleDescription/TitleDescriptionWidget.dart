import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba_castelldefels/Events/crud_events/cubit/CrudEventCubit.dart';
import 'package:mamba_castelldefels/Events/crud_events/models/Event.dart';
import 'package:mamba_castelldefels/Events/crud_events/utils/enumAddEditEvent.dart';
import 'package:mamba_castelldefels/Events/crud_events/widgets/mobile/DividerAddEditEvent.dart';
import 'package:mamba_castelldefels/Globals/Styles/AppColors/AppColors.dart';

class TitleDescriptionWidget extends StatefulWidget {
  TitleDescriptionWidget({super.key});

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
        titleEventWidget(context, AppLocalizations.of(context)!.title),
        Padding(
            padding:
                EdgeInsets.only(top: MediaQuery.of(context).size.height * 0),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Flexible(
                  child: TextFormField(
                    focusNode: focusNodetitleController,
                    controller: titleController,
                    validator: (val) => val!.isEmpty
                        ? AppLocalizations.of(context)!.titleError
                        : null,
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
                    style: Theme.of(context).textTheme.bodyText2,
                    decoration: InputDecoration(
                      hintStyle: Theme.of(context).textTheme.caption,
                      hintText: AppLocalizations.of(context)!.titleHint,
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
                    enabled: true,
                  ),
                ),
              ],
            )),
        dividerAddEditEvent(context, AppLocalizations.of(context)!.title,
            validateText(titleString)),
        titleEventWidget(context, AppLocalizations.of(context)!.description),
        Padding(
            padding: const EdgeInsets.only(top: 0.0),
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
                    style: Theme.of(context).textTheme.bodyText2,
                    decoration: InputDecoration(
                      hintStyle: Theme.of(context).textTheme.caption,
                      hintText: AppLocalizations.of(context)!.descriptionHint,
                      errorBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.red),
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
            )),
        dividerAddEditEvent(
            context, AppLocalizations.of(context)!.description, true),
      ],
    );
  }
}

bool validateText(String text) {
  if (text == "") {
    return false;
  }
  return true;
}


  // return Column(
  //   children: [
  //     BlocSelector<CrudEventCubit, CrudEventState, String>(
  //       selector: (state) {
  //         if (state is CrudEventLoaded) {
  //           titleNotifier.value = state.event.title!;
  //         }
  //         return ''; // This return value won't be used, but is required for the BlocSelector's type signature
  //       },
  //       builder: (context, _) {
  //         return ValueListenableBuilder<String>(
  //           valueListenable: titleNotifier,
  //           builder: (context, titleValue, child) {
  //             titleController.text = titleValue;
  //             return Column(
  //               children: [
  //                 Padding(
  //                     padding: EdgeInsets.only(
  //                         top: MediaQuery.of(context).size.height * 0.03),
  //                     child: Row(
  //                       mainAxisSize: MainAxisSize.max,
  //                       children: <Widget>[
  //                         Column(
  //                           mainAxisAlignment: MainAxisAlignment.start,
  //                           mainAxisSize: MainAxisSize.min,
  //                           children: <Widget>[
  //                             Text(
  //                               AppLocalizations.of(context)!.title,
  //                               style: Theme.of(context).textTheme.headline1,
  //                             ),
  //                           ],
  //                         ),
  //                       ],
  //                     )),
  //                 Padding(
  //                     padding: const EdgeInsets.only(top: 0),
  //                     child: Row(
  //                       mainAxisSize: MainAxisSize.max,
  //                       children: <Widget>[
  //                         Flexible(
  //                           child: TextFormField(
  //                             focusNode: focusNodetitleController,
  //                             controller: titleController,
  //                             validator: (val) => val!.isEmpty
  //                                 ? AppLocalizations.of(context)!.titleError
  //                                 : null,
  //                             onChanged: (val) {
  //                               context
  //                                   .read<CrudEventCubit>()
  //                                   .editEventInfo(val, 1);
  //                             },
  //                             onEditingComplete: () {
  //                               if (descriptionController.text.isEmpty) {
  //                                 focusNodeDescController.requestFocus();
  //                               } else {
  //                                 focusNodetitleController.unfocus();
  //                               }
  //                             },
  //                             style: Theme.of(context).textTheme.bodyText2,
  //                             decoration: InputDecoration(
  //                               hintStyle: Theme.of(context).textTheme.caption,
  //                               errorStyle: Theme.of(context)
  //                                   .textTheme
  //                                   .caption
  //                                   ?.copyWith(color: AppColors.red),
  //                               hintText:
  //                                   AppLocalizations.of(context)!.titleHint,
  //                               errorBorder: const UnderlineInputBorder(
  //                                 borderSide: BorderSide(color: Colors.red),
  //                               ),
  //                               disabledBorder: const UnderlineInputBorder(
  //                                 borderSide: BorderSide(color: Colors.grey),
  //                               ),
  //                               enabledBorder: const UnderlineInputBorder(
  //                                 borderSide: BorderSide(color: Colors.grey),
  //                               ),
  //                               focusedBorder: const UnderlineInputBorder(
  //                                 borderSide: BorderSide(color: Colors.grey),
  //                               ),
  //                             ),
  //                             enabled: true,
  //                           ),
  //                         ),
  //                       ],
  //                     )),
  //               ],
  //             );
  //           },
  //         );
  //       },
  //     ),
  //     BlocSelector<CrudEventCubit, CrudEventState, String>(selector: (state) {
  //       if (state is CrudEventLoaded) {
  //         return state.event.description!;
  //       }
  //       return '';
  //     }, builder: (context, descriptionEvent) {
  //       descriptionController.text = descriptionEvent;
  //       return Column(
  //         children: [
  //           Padding(
  //               padding: EdgeInsets.only(
  //                   top: MediaQuery.of(context).size.height * 0.05),
  //               child: Row(
  //                 mainAxisSize: MainAxisSize.max,
  //                 children: <Widget>[
  //                   Column(
  //                     mainAxisAlignment: MainAxisAlignment.start,
  //                     mainAxisSize: MainAxisSize.min,
  //                     children: <Widget>[
  //                       Text(
  //                         AppLocalizations.of(context)!.description,
  //                         style: Theme.of(context).textTheme.headline1,
  //                       ),
  //                     ],
  //                   ),
  //                 ],
  //               )),
  //           Padding(
  //               padding: const EdgeInsets.only(top: 0.0),
  //               child: Row(
  //                 mainAxisSize: MainAxisSize.max,
  //                 children: <Widget>[
  //                   Flexible(
  //                     child: TextFormField(
  //                       focusNode: focusNodeDescController,
  //                       keyboardType: TextInputType.visiblePassword,
  //                       controller: descriptionController,
  //                       minLines: 1,
  //                       maxLines: 4,
  //                       onChanged: (val) {
  //                         context.read<CrudEventCubit>().editEventInfo(val, 2);
  //                       },
  //                       style: Theme.of(context).textTheme.bodyText2,
  //                       decoration: InputDecoration(
  //                         hintStyle: Theme.of(context).textTheme.caption,
  //                         hintText:
  //                             AppLocalizations.of(context)!.descriptionHint,
  //                         errorBorder: const UnderlineInputBorder(
  //                           borderSide: BorderSide(color: Colors.red),
  //                         ),
  //                         disabledBorder: const UnderlineInputBorder(
  //                           borderSide: BorderSide(color: Colors.grey),
  //                         ),
  //                         enabledBorder: const UnderlineInputBorder(
  //                           borderSide: BorderSide(color: Colors.grey),
  //                         ),
  //                         focusedBorder: const UnderlineInputBorder(
  //                           borderSide: BorderSide(color: Colors.grey),
  //                         ),
  //                       ),
  //                     ),
  //                   ),
  //                 ],
  //               )),
  //         ],
  //       );
  //     }),
  //   ],
  // );

