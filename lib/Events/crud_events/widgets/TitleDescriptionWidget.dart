import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba_castelldefels/Events/crud_events/cubit/CrudEventCubit.dart';
import 'package:mamba_castelldefels/Events/crud_events/models/Event.dart';
import 'package:mamba_castelldefels/Globals/Styles/AppColors/AppColors.dart';

var titleController = TextEditingController();
var descriptionController = TextEditingController();
FocusNode focusNodeDescController = FocusNode();

Widget titleDescriptionWidget(BuildContext context, FocusNode focusNodetitleController) {
  return Column(
    children: [
      BlocSelector<CrudEventCubit, CrudEventState, String>(selector: (state) {
        if (state is CrudEventLoaded) {
          return state.event.title!;
        }
        return '';
      }, builder: (context, titleEvent) {
        titleController.text = titleEvent;
        return Column(
          children: [
            Padding(
                padding:
                    EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.03),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          AppLocalizations.of(context)!.title,
                          style: Theme.of(context).textTheme.headline1,
                        ),
                      ],
                    ),
                  ],
                )),
            Padding(
                padding: const EdgeInsets.only(top: 0),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Flexible(
                      child: TextFormField(
                        focusNode: focusNodetitleController,
                        controller: titleController,
                        validator: (val) => val!.isEmpty ? AppLocalizations.of(context)!.titleError : null,
                        onChanged: (val) {
                          context.read<CrudEventCubit>().editEventInfo(val, 1);
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
                          errorStyle: Theme.of(context).textTheme.caption?.copyWith(color: AppColors.red),
                          hintText: AppLocalizations.of(context)!.titleHint,
                          errorBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.red),
                          ),
                          disabledBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          enabledBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                        ),
                        enabled: true,
                      ),
                    ),
                  ],
                )
            ),
          ],
        );
      }),
      BlocSelector<CrudEventCubit, CrudEventState, String>(selector: (state) {
        if (state is CrudEventLoaded) {
          return state.event.description!;
        }
        return '';
      }, builder: (context, descriptionEvent) {
        descriptionController.text = descriptionEvent;
        return Column(
          children: [
            Padding(
                padding: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.05),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          AppLocalizations.of(context)!.description,
                          style: Theme.of(context).textTheme.headline1,
                        ),
                      ],
                    ),
                  ],
                )
            ),
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
                          context.read<CrudEventCubit>().editEventInfo(val, 2);
                        },
                        style: Theme.of(context).textTheme.bodyText2,
                        decoration: InputDecoration(
                          hintStyle: Theme.of(context).textTheme.caption,
                          hintText: AppLocalizations.of(context)!.descriptionHint,
                          errorBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.red),
                          ),
                          disabledBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          enabledBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
            ),
          ],
        );
      }),

    ],
  );
}
