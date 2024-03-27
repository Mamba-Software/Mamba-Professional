import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mamba/data/Models/Notifications/RecievedNotification.dart';
import 'package:mamba/events/crud_events/cubit/CrudEventCubit.dart';
import 'package:mamba/events/crud_events/cubit/functions/notificationsEvents.dart';
import 'package:mamba/events/crud_events/models/Event.dart';
import 'package:mamba/events/crud_events/views/mobile/DateTimePage.dart';
import 'package:mamba/events/crud_events/views/mobile/InformationPage.dart';
import 'package:mamba/events/crud_events/views/mobile/MembersPage.dart';
import 'package:mamba/commons/constants/GlobalVars.dart';
import 'package:mamba/app/style/AppColors.dart';
import 'package:mamba/commons/utils/Strings/StringUtils.dart';
import 'package:mamba/commons/widgets/Components/TopSnackBar/TopSnackBarDef.dart';
import 'package:mamba/commons/widgets/GroupOfComponents/Dialogs/ActionDialogs/DeleteConfirmationDialog.dart';
import 'package:mamba/commons/widgets/GroupOfComponents/Dialogs/ActionDialogs/DeleteRecurrentEventDialog.dart';
import 'package:mamba/commons/widgets/GroupOfComponents/Dialogs/ActionDialogs/EditRecurrentEventDialog.dart';
import 'package:mamba/commons/widgets/GroupOfComponents/LoadingViews/LoadingView.dart';
import 'package:flutter/material.dart';
import 'package:mamba/l10n/language_manager.dart';

class AddOrEditEvent extends StatefulWidget {
  Locale locale;

  AddOrEditEvent({super.key, required this.locale});

  @override
  _AddOrEditEventState createState() => _AddOrEditEventState();
}

class _AddOrEditEventState extends State<AddOrEditEvent>
    with SingleTickerProviderStateMixin {
  // Acceso a Base de Datos

  // Boolean Loading
  bool isLoading = false;

  // Tab Controller
  double addEventTabValue = 0.33;
  double updateEventTabValue = 0.50;
  TabController? _tabController;
  int _selectedIndex = 0;
  List<bool> tabs = [true, false, false];

  final _topSnackBar = TopSnackBarDef();
  final _notificationsEvents = NotificationsEvent();

  @override
  initState() {
    super.initState();
    isLoading = true;
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CrudEventCubit, CrudEventLoaded>(
        builder: (context, state) {
      return !state.isLoaded
          ? Scaffold(
              appBar: AppBar(
                toolbarHeight: MediaQuery.of(context).size.height * 0.08,
                title: state.isNew
                    ? Text(context.l10n.createEvent,
                        style: Theme.of(context).appBarTheme.titleTextStyle)
                    : Text(
                        context.l10n.editEvent,
                        style: Theme.of(context).appBarTheme.titleTextStyle,
                      ),
                centerTitle: true,
                leading: IconButton(
                  icon: Icon(
                    Icons.arrow_back,
                    size: MediaQuery.of(context).size.width * 0.06,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                actions: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.15,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.groups,
                          color: Theme.of(context).primaryColor,
                          size: MediaQuery.of(context).size.width * 0.06,
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.1,
                          child: FittedBox(
                            fit: BoxFit.contain,
                            child: Text(context.l10n.group,
                                style: Theme.of(context).textTheme.bodyMedium,
                                textAlign: TextAlign.center),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: MediaQuery.of(context).size.width * 0.03)
                ],
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(0),
                  child: IgnorePointer(
                    child: Column(
                      children: [
                        SizedBox(
                            height: MediaQuery.of(context).size.width * 0.03),
                        LinearProgressIndicator(
                          value: addEventTabValue,
                          backgroundColor:
                              Theme.of(context).scaffoldBackgroundColor,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              body: LoadingView(),
            )
          : Scaffold(
              appBar: AppBar(
                toolbarHeight: MediaQuery.of(context).size.height * 0.08,
                title: state.isNew
                    ? Text(context.l10n.createEvent,
                        style: Theme.of(context).appBarTheme.titleTextStyle)
                    : Text(
                        context.l10n.editEvent,
                        style: Theme.of(context).appBarTheme.titleTextStyle,
                      ),
                centerTitle: true,
                leading: IconButton(
                  icon: Icon(
                    Icons.arrow_back,
                    size: MediaQuery.of(context).size.width * 0.06,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                actions: [
                  !state.isNew
                      ? IconButton(
                          onPressed: () async {
                            if (!state.oldEvent.joinedMembersList!
                                .any((client) => client.purchaseId != "")) {
                              if (!state.oldEvent.isRecurrent!) {
                                // DeleteDialog
                                var result = await showDialog(
                                    context: context,
                                    builder: (_) {
                                      return DeleteConfirmationDialog(
                                          text: context
                                              .l10n.deleteEventConfirmation);
                                    });
                                if (result) {
                                  context
                                      .read<CrudEventCubit>()
                                      .deleteEventFunction(context,
                                          state.oldEvent, state.isPrivate);
                                  // Pop to Last Page
                                  Navigator.pop(context, false);
                                }
                              } else {
                                var result = await showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return DeleteRecurrentEventDialog(
                                      isCompleted: !state.isBeforeEdit,
                                    );
                                  },
                                );
                                if (result != null) {
                                  if (result == 1) {
                                    print("Deleting Only This Event..");
                                    context
                                        .read<CrudEventCubit>()
                                        .deleteEventFunction(context,
                                            state.oldEvent, state.isPrivate);
                                    // Pop to Last Page
                                    Navigator.pop(context, false);
                                  } else {
                                    print(
                                        "Delete This Event and the Rest Forward ...");
                                    context
                                        .read<CrudEventCubit>()
                                        .deleteRecurrentEventFunction(context,
                                            state.oldEvent, state.isPrivate);
                                    // Pop to Last Page

                                    Navigator.pop(context, false);
                                  }
                                }
                              }
                            } else {
                              var result = await showDialog(
                                  context: context,
                                  builder: (_) {
                                    return DeleteConfirmationDialog(
                                        text: context
                                            .l10n.deleteClientsWithPurchases,
                                        permitDelete: false);
                                  });
                            }
                          },
                          icon: SizedBox(
                            width: MediaQuery.of(context).size.width * 0.15,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.delete_outlined,
                                  color: AppColors.red,
                                  size:
                                      MediaQuery.of(context).size.width * 0.07,
                                )
                              ],
                            ),
                          ))
                      : SizedBox(
                          width: MediaQuery.of(context).size.width * 0.15,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.groups,
                                color: Theme.of(context).primaryColor,
                                size: MediaQuery.of(context).size.width * 0.06,
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.1,
                                child: FittedBox(
                                  fit: BoxFit.contain,
                                  child: Text(context.l10n.group,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium,
                                      textAlign: TextAlign.center),
                                ),
                              ),
                            ],
                          ),
                        ),
                  SizedBox(width: MediaQuery.of(context).size.width * 0.03)
                ],
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(0),
                  child: IgnorePointer(
                    child: Column(
                      children: [
                        SizedBox(
                            height: MediaQuery.of(context).size.width * 0.03),
                        LinearProgressIndicator(
                          value: addEventTabValue,
                          backgroundColor:
                              Theme.of(context).scaffoldBackgroundColor,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              resizeToAvoidBottomInset: true,
              body: Column(
                children: [
                  Expanded(
                      child: TabBarView(
                    controller: _tabController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      Scaffold(
                        body: SingleChildScrollView(
                            physics: const ClampingScrollPhysics(),
                            child: Column(
                              children: [
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal:
                                          MediaQuery.of(context).size.width *
                                              0.05),
                                  child: const InformationPage(),
                                ),
                              ],
                            )),
                        resizeToAvoidBottomInset: true,
                      ),
                      Scaffold(
                        body: SingleChildScrollView(
                            physics: const ClampingScrollPhysics(),
                            child: Column(
                              children: [
                                Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal:
                                            MediaQuery.of(context).size.width *
                                                0.05,
                                        vertical:
                                            MediaQuery.of(context).size.width *
                                                0.00),
                                    child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.max,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          DateTimePage(locale: widget.locale)
                                        ])),
                              ],
                            )),
                        resizeToAvoidBottomInset: true,
                      ),
                      Scaffold(
                        body: SingleChildScrollView(
                            physics: const ClampingScrollPhysics(),
                            child: Column(
                              children: [
                                Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal:
                                            MediaQuery.of(context).size.width *
                                                0.05),
                                    child: const Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          MembersPage(),
                                        ])),
                              ],
                            )),
                        resizeToAvoidBottomInset: true,
                      ),
                    ],
                  )),
                ],
              ),
              floatingActionButton: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _selectedIndex != 0
                      ? Padding(
                          padding: EdgeInsets.only(
                              right: MediaQuery.of(context).size.width * 0.01,
                              left: MediaQuery.of(context).size.width * 0.09),
                          child: SizedBox(
                            height: 50,
                            child: FloatingActionButton.extended(
                              shape: const StadiumBorder(),
                              heroTag: "47",
                              onPressed: () {
                                if (_selectedIndex == 1) {
                                  if (!state.isNew) {
                                    mixpanel!.track('edit_event_info',
                                        properties: {
                                          'isPrivate': state.isPrivate
                                        });
                                  } else {
                                    mixpanel!.track('add_event_info',
                                        properties: {
                                          'isPrivate': state.isPrivate
                                        });
                                  }
                                  setState(() {
                                    tabs[1] = false;
                                  });
                                } else if (_selectedIndex == 2) {
                                  if (!state.isNew) {
                                    mixpanel!.track('edit_event_datetime',
                                        properties: {
                                          'isPrivate': state.isPrivate
                                        });
                                  } else {
                                    mixpanel!.track('add_event_datetime',
                                        properties: {
                                          'isPrivate': state.isPrivate
                                        });
                                  }
                                  setState(() {
                                    tabs[2] = false;
                                  });
                                }
                                _tabController!.animateTo(_selectedIndex -= 1);
                                FocusScopeNode currentFocus =
                                    FocusScope.of(context);
                                if (!currentFocus.hasPrimaryFocus &&
                                    currentFocus.focusedChild != null) {
                                  FocusManager.instance.primaryFocus?.unfocus();
                                }
                                setState(() {
                                  addEventTabValue -= 0.33;
                                });
                              },
                              backgroundColor: Theme.of(context).primaryColor,
                              icon: Container(),
                              label: Text(
                                context.l10n.back,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge!
                                    .copyWith(
                                        color:
                                            Theme.of(context).primaryColorDark),
                              ),
                            ),
                          ),
                        )
                      : Padding(
                          padding: EdgeInsets.only(
                              right: MediaQuery.of(context).size.width * 0.01,
                              left: MediaQuery.of(context).size.width * 0.09),
                          child: Container(
                            height: 50,
                          ),
                        ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width * 0.01),
                    child: SizedBox(
                      height: 50,
                      child: FloatingActionButton.extended(
                        heroTag: "48",
                        shape: const StadiumBorder(),
                        onPressed: () async {
                          if (_selectedIndex == 0 &&
                              state.isValidated[0] == true) {
                            if (!state.isNew) {
                              mixpanel!.track('edit_event_datetime',
                                  properties: {'isPrivate': state.isPrivate});
                            } else {
                              mixpanel!.track('add_event_datetime',
                                  properties: {'isPrivate': state.isPrivate});
                            }
                            _tabController!.animateTo(_selectedIndex += 1);
                            FocusScopeNode currentFocus =
                                FocusScope.of(context);
                            if (!currentFocus.hasPrimaryFocus &&
                                currentFocus.focusedChild != null) {
                              FocusManager.instance.primaryFocus?.unfocus();
                            }
                            setState(() {
                              addEventTabValue += 0.33;
                              tabs[1] = true;
                            });
                          } else if (_selectedIndex == 1 &&
                              state.isValidated[1] == true) {
                            if (!state.isNew) {
                              mixpanel!.track('edit_event_members',
                                  properties: {'isPrivate': state.isPrivate});
                            } else {
                              mixpanel!.track('add_event_members',
                                  properties: {'isPrivate': state.isPrivate});
                            }
                            _tabController!.animateTo(_selectedIndex += 1);
                            setState(() {
                              addEventTabValue += 0.33;
                              tabs[2] = true;
                            });
                          } else if (_selectedIndex == 2 &&
                              state.isValidated[2] == true) {
                            if (state.isValidated
                                .every((bool value) => value)) {
                              String eventTimeTime = StringUtils()
                                  .hourMinutesToString(
                                      state.newEvent.startDate!.hour,
                                      state.newEvent.startDate!.minute);
                              if (state.isNew) {
                                context.read<CrudEventCubit>().addEventFunction(
                                    context,
                                    state.newEvent,
                                    state.isPrivate,
                                    _setNotificationBefore(
                                        eventTimeTime, state.newEvent),
                                    _setNotificationAfter(state.newEvent));
                                Navigator.pop(context);
                              } else {
                                if (!state.newEvent.isRecurrent!) {
                                  context
                                      .read<CrudEventCubit>()
                                      .updateEventFunction(
                                          context,
                                          state.newEvent,
                                          state.oldEvent,
                                          _setNotificationBefore(
                                              eventTimeTime, state.newEvent),
                                          _setNotificationAfter(
                                              state.newEvent));
                                  Navigator.pop(context, true);
                                } else {
                                  var result = await showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return EditRecurrentEventDialog(
                                        isCompleted: !context
                                            .read<CrudEventCubit>()
                                            .state
                                            .isBeforeEdit,
                                        clientsModified: context
                                            .read<CrudEventCubit>()
                                            .state
                                            .clientsModified,
                                      );
                                    },
                                  );
                                  if (result != null) {
                                    if (result == 1) {
                                      print("Edit Only This Event..");
                                      context
                                          .read<CrudEventCubit>()
                                          .updateEventFunction(
                                              context,
                                              state.newEvent,
                                              state.oldEvent,
                                              _setNotificationBefore(
                                                  eventTimeTime,
                                                  state.newEvent),
                                              _setNotificationAfter(
                                                  state.newEvent));
                                      Navigator.pop(context, true);
                                    } else {
                                      print(
                                          "Edit This Event and the Rest Forward ...");
                                      context
                                          .read<CrudEventCubit>()
                                          .updateRecurrentEventFunction(
                                              context,
                                              state.newEvent,
                                              state.oldEvent,
                                              _setNotificationBefore(
                                                  eventTimeTime,
                                                  state.newEvent),
                                              _setNotificationAfter(
                                                  state.newEvent));
                                      Navigator.pop(context, false);
                                    }
                                  }
                                }
                              }
                            }
                            /*if (widget.eventId == null) {
                                        _addEventFunction();
                                      } else {
                                        if (event.eventGroupId == null) {
                                          _updateEventFunction();
                                        } else {
                                          var result = await showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return EditRecurrentEventDialog(
                                                isCompleted: !widget.isBeforeEdit,
                                                clientsModified: clientsModified,
                                              );
                                            },
                                          );
                                          if (result != null) {
                                            if (result == 1) {
                                              print("Edit Only This Event..");
                                              _updateEventFunction();
                                            } else {
                                              print(
                                                  "Edit This Event and the Rest Forward ...");
                                              _updateRecurrentEventFunction();
                                            }
                                          }
                                        }
                                      } */
                          }
                        },
                        backgroundColor: _selectedIndex == 2 &&
                                state.isValidated[2] == true
                            ? Colors.green
                            : _selectedIndex == 0 &&
                                    state.isValidated[0] == true
                                ? Theme.of(context).colorScheme.secondary
                                : _selectedIndex == 1 &&
                                        state.isValidated[1] == true
                                    ? Theme.of(context).colorScheme.secondary
                                    : Colors.grey,
                        icon: Container(),
                        label: state.isNew
                            ? Text(
                                _selectedIndex == 2
                                    ? context.l10n.createEvent
                                    : context.l10n.next,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge!
                                    .copyWith(color: AppColors.white),
                              )
                            : Text(
                                _selectedIndex == 2
                                    ? context.l10n.editEvent
                                    : context.l10n.next,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge!
                                    .copyWith(color: AppColors.white),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            );
    });
  }

  ReceivedNotification _setNotificationBefore(
      String eventTimeTime, Event event) {
    return event.isRecurrent!
        ? _notificationsEvents.setEventNotificationBefore(
            event,
            context.l10n.beforeEventTitleNotification(event.title!, 'replace'),
            context.l10n.beforeEventBodyNotification)
        : _notificationsEvents.setEventNotificationBefore(
            event,
            context.l10n
                .beforeEventTitleNotification(event.title!, eventTimeTime),
            context.l10n.beforeEventBodyNotification);
  }

  ReceivedNotification _setNotificationAfter(Event event) {
    return _notificationsEvents.setEventNotificationAfter(
        event,
        context.l10n.afterEventTitleNotification,
        context.l10n.afterEventBodyNotification);
  }
}
