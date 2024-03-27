import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mamba/commons/constants/GlobalVars.dart';
import 'package:mamba/commons/widgets/GroupOfComponents/Events/AddEditEvent/AddOrEditEvent_old.dart';
import 'package:mamba/commons/widgets/GroupOfComponents/Events/AddEditEvent/AddOrEditPrivateEvent.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:mamba/commons/managers/language_manager.dart';

typedef DateCallBack = void Function(
    int pageIndex, DateTime? dateTime, CalendarView calendarView);

class PlanEventWidget extends StatefulWidget {
  double height = 0;
  double width = 0;
  bool isPrivate = false;
  ValueChanged<bool?> onClicked;

  PlanEventWidget(
      {super.key,
      required this.height,
      required this.width,
      required this.isPrivate,
      required this.onClicked});

  @override
  _PlanEventWidgetState createState() => _PlanEventWidgetState();
}

class _PlanEventWidgetState extends State<PlanEventWidget> {
  @override
  void initState() {
    super.initState();
  }

  void _addEvent() async {
    if (brandIsActive) {
      Navigator.push(
          context,
          CupertinoPageRoute<String>(
            builder: (context) => GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                FocusScopeNode currentFocus = FocusScope.of(context);
                if (!currentFocus.hasPrimaryFocus &&
                    currentFocus.focusedChild != null) {
                  FocusManager.instance.primaryFocus?.unfocus();
                }
              },
              child: AddOrEditEvent(
                  locale: Localizations.localeOf(context), isBeforeEdit: true),
            ),
          ));
    } else {
      await navigateToPayWall(context);
    }
  }

  void _addPrivateEvent() async {
    if (brandIsActive) {
      Navigator.push(
          context,
          CupertinoPageRoute<String>(
            builder: (context) => GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                FocusScopeNode currentFocus = FocusScope.of(context);
                if (!currentFocus.hasPrimaryFocus &&
                    currentFocus.focusedChild != null) {
                  FocusManager.instance.primaryFocus?.unfocus();
                }
              },
              child: AddOrEditPrivateEvent(
                  locale: Localizations.localeOf(context), isBeforeEdit: true),
            ),
          ));
    } else {
      await navigateToPayWall(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.fitHeight,
      child: Material(
        elevation: 4,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(15.0)),
        ),
        child: Container(
          height: widget.height,
          width: widget.width,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius:
                const BorderRadius.all(Radius.circular(15.0)), // BorderRadius
          ), // BoxDecoration
          child: Container(
            margin: const EdgeInsetsDirectional.only(
                start: 1, end: 1, bottom: 1, top: 1),
            height: widget.height,
            width: widget.width,
            padding: EdgeInsets.all(widget.width * 0.02),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius:
                  const BorderRadius.all(Radius.circular(15.0)), // BorderRadius
            ), // BoxDecoration
            child: SizedBox(
              height: widget.height,
              width: widget.width,
              child: TextButton(
                  onPressed: () async {
                    if (widget.isPrivate) {
                      _addPrivateEvent();
                    } else {
                      _addEvent();
                    }
                    await Future.delayed(const Duration(seconds: 1));
                    widget.onClicked(true);
                  },
                  child: widget.isPrivate
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            SizedBox(
                              height: widget.height,
                              width: widget.width * 0.2,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Icon(Icons.person,
                                      size: widget.width * 0.15,
                                      color:
                                          Theme.of(context).primaryColorDark),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: widget.height,
                              width: widget.width * 0.6,
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      context.l10n.add,
                                      style: Theme.of(context)
                                          .textTheme
                                          .displaySmall
                                          ?.copyWith(
                                              color: Theme.of(context)
                                                  .primaryColorDark),
                                      textAlign: TextAlign.left,
                                    ),
                                    Text(
                                      context.l10n.privateEvent,
                                      style: Theme.of(context)
                                          .textTheme
                                          .displaySmall
                                          ?.copyWith(
                                              color: Theme.of(context)
                                                  .primaryColorDark),
                                      textAlign: TextAlign.left,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            SizedBox(
                              height: widget.height,
                              width: widget.width * 0.2,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Icon(Icons.groups,
                                      size: widget.width * 0.15,
                                      color:
                                          Theme.of(context).primaryColorDark),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: widget.height,
                              width: widget.width * 0.6,
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      context.l10n.add,
                                      style: Theme.of(context)
                                          .textTheme
                                          .displaySmall
                                          ?.copyWith(
                                              color: Theme.of(context)
                                                  .primaryColorDark),
                                      textAlign: TextAlign.left,
                                    ),
                                    Text(
                                      context.l10n.groupEvent,
                                      style: Theme.of(context)
                                          .textTheme
                                          .displaySmall
                                          ?.copyWith(
                                              color: Theme.of(context)
                                                  .primaryColorDark),
                                      textAlign: TextAlign.left,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        )),
            ),
          ),
        ),
      ),
    );
  }
}
