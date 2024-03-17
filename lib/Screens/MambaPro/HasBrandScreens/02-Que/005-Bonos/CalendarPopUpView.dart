import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mamba_castelldefels/commons/constants/GlobalVars.dart';
import 'package:mamba_castelldefels/app/style/AppColors.dart';
import 'package:mamba_castelldefels/Screens/MambaPro/HasBrandScreens/02-Que/005-Bonos/CustomCalendarView.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CalendarPopupView extends StatefulWidget {
  const CalendarPopupView(
      {super.key,
      this.initialStartDate,
      this.initialEndDate,
      this.onApplyClick,
      this.barrierDismissible = true,
      this.minimumDate,
      this.maximumDate});

  final DateTime? minimumDate;
  final DateTime? maximumDate;
  final bool barrierDismissible;
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;
  final Function(DateTime, DateTime)? onApplyClick;

  @override
  _CalendarPopupViewState createState() => _CalendarPopupViewState();
}

class _CalendarPopupViewState extends State<CalendarPopupView>
    with TickerProviderStateMixin {
  AnimationController? animationController;
  DateTime? startDate;
  DateTime? endDate;

  @override
  void initState() {
    animationController = AnimationController(
        duration: const Duration(milliseconds: 400), vsync: this);
    if (widget.initialStartDate != null) {
      startDate = widget.initialStartDate;
    }
    if (widget.initialEndDate != null) {
      endDate = widget.initialEndDate;
    }
    animationController?.forward();
    super.initState();
  }

  @override
  void dispose() {
    animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: InkWell(
          splashColor: Colors.transparent,
          focusColor: Colors.transparent,
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent,
          onTap: () {
            if (widget.barrierDismissible) {
              Navigator.pop(context);
            }
          },
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(23.0),
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.lightGrey,
                  borderRadius: BorderRadius.all(Radius.circular(24.0)),
                ),
                child: InkWell(
                  borderRadius: const BorderRadius.all(
                    Radius.circular(24.0),
                  ),
                  onTap: () {},
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Container(
                        decoration: const BoxDecoration(
                          color: AppColors.black,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(24.0),
                            topRight: Radius.circular(24.0),
                          ),
                        ),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                    AppLocalizations.of(context)!.from,
                                    textAlign: TextAlign.left,
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                  ),
                                  const SizedBox(
                                    height: 4,
                                  ),
                                  Text(
                                    startDate != null
                                        ? currentUser.idioma == 'es'
                                            ? DateFormat.yMd('es')
                                                .format(startDate!)
                                            : DateFormat.yMd('cat')
                                                .format(startDate!)
                                        : '--/-- ',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.white),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              height: 74,
                              width: 1,
                              color: AppColors.lightGrey,
                            ),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                    AppLocalizations.of(context)!.to,
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                  ),
                                  const SizedBox(
                                    height: 4,
                                  ),
                                  Text(
                                    endDate != null
                                        ? currentUser.idioma == 'es'
                                            ? DateFormat.yMd('es')
                                                .format(endDate!)
                                            : DateFormat.yMd('cat')
                                                .format(endDate!)
                                        : '--/-- ',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.white),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                      Container(
                        height: 1,
                        width: 400,
                        color: AppColors.lightGrey,
                      ),
                      CustomCalendarView(
                        minimumDate: widget.minimumDate,
                        maximumDate: widget.maximumDate,
                        initialEndDate: widget.initialEndDate,
                        initialStartDate: widget.initialStartDate,
                        startEndDateChange:
                            (DateTime startDateData, DateTime endDateData) {
                          setState(() {
                            startDate = startDateData;
                            endDate = endDateData;
                          });
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 16, right: 16, bottom: 16, top: 8),
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.black,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(24.0)),
                            boxShadow: <BoxShadow>[
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.6),
                                blurRadius: 8,
                                offset: const Offset(4, 4),
                              ),
                            ],
                          ),
                          child: Material(
                            color: AppColors.black,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(25.0),
                              ),
                            ),
                            elevation: 4,
                            child: InkWell(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(25.0)),
                              highlightColor: Theme.of(context).primaryColor,
                              onTap: () {
                                try {
                                  widget.onApplyClick!(startDate!, endDate!);
                                  Navigator.pop(context);
                                } catch (_) {}
                              },
                              child: Center(
                                child: Text(
                                  AppLocalizations.of(context)!.confirm,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.copyWith(color: AppColors.white),
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
