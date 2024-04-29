import 'package:flutter/material.dart';
import 'package:mamba/commons/managers/language_manager.dart';
import 'package:mamba/commons/styles/AppColors.dart';

class DeleteRecurrentEventDialog extends StatefulWidget {
  bool isCompleted;
  DeleteRecurrentEventDialog({super.key, required this.isCompleted});

  @override
  _DeleteRecurrentEventDialogState createState() =>
      _DeleteRecurrentEventDialogState();
}

class _DeleteRecurrentEventDialogState
    extends State<DeleteRecurrentEventDialog> {
  int _value = 0;

  Color getColor(Set<MaterialState> states) {
    const Set<MaterialState> interactiveStates = <MaterialState>{
      MaterialState.pressed,
      MaterialState.hovered,
      MaterialState.focused,
      MaterialState.disabled,
    };
    if (states.any(interactiveStates.contains)) {
      return AppColors.grey;
    }
    return Theme.of(context).primaryColor;
  }

  @override
  void initState() {
    if (widget.isCompleted) _value = 1;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        padding:
            const EdgeInsets.only(top: 40, bottom: 10, left: 10, right: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.only(
                        top: 8.0, bottom: 8.0, right: 10, left: 10),
                    child: Text(
                      context.l10n.deleteRecurrentEvent,
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(height: 1.5),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                      vertical: MediaQuery.of(context).size.height * 0.01,
                      horizontal: MediaQuery.of(context).size.width * 0.05),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ListTile(
                        dense: true,
                        contentPadding:
                            const EdgeInsets.only(left: 0.0, right: 0.0),
                        title: Text(
                          context.l10n.thisEvent,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        leading: Transform.scale(
                          scale: 1.2,
                          child: Radio(
                            value: 1,
                            groupValue: _value,
                            activeColor: Theme.of(context).primaryColor,
                            fillColor: MaterialStateProperty.resolveWith(
                                (states) => getColor(states)),
                            onChanged: (value) {
                              setState(() {
                                _value = int.parse(value.toString());
                              });
                            },
                          ),
                        ),
                      ),
                      ListTile(
                        dense: true,
                        contentPadding:
                            const EdgeInsets.only(left: 0.0, right: 0.0),
                        title: Text(
                          context.l10n.thisEventAndRest,
                          style: widget.isCompleted
                              ? Theme.of(context).textTheme.bodySmall
                              : Theme.of(context).textTheme.bodyMedium,
                        ),
                        subtitle: widget.isCompleted
                            ? Text(
                                context.l10n.notAvailableFinishedEvents,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(fontSize: 12.5),
                              )
                            : null,
                        leading: Transform.scale(
                          scale: 1.2,
                          child: Radio(
                            value: 2,
                            groupValue: _value,
                            activeColor: widget.isCompleted
                                ? AppColors.grey
                                : Theme.of(context).primaryColor,
                            fillColor: MaterialStateProperty.resolveWith(
                                (states) => getColor(states)),
                            onChanged: widget.isCompleted
                                ? null
                                : (value) {
                                    setState(() {
                                      _value = int.parse(value.toString());
                                    });
                                  },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          elevation: 4.0,
                          backgroundColor: _value == 0
                              ? Colors.red.withOpacity(0.5)
                              : Colors.red,
                          fixedSize: Size(
                              MediaQuery.of(context).size.width * 0.35,
                              MediaQuery.of(context).size.height * 0.06),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(30),
                            ),
                          ),
                        ),
                        label: Text(
                          context.l10n.delete,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                  color: _value == 0
                                      ? AppColors.white.withOpacity(0.5)
                                      : AppColors.white),
                        ),
                        icon: Icon(Icons.delete_outline,
                            size: MediaQuery.of(context).size.width * 0.06,
                            color: _value == 0
                                ? AppColors.white.withOpacity(0.5)
                                : AppColors.white),
                        onPressed: _value != 0
                            ? () {
                                Navigator.pop(context, _value);
                              }
                            : null,
                      ),
                      SizedBox(width: MediaQuery.of(context).size.width * 0.01),
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          elevation: 4.0,
                          backgroundColor: Theme.of(context).primaryColor,
                          fixedSize: Size(
                              MediaQuery.of(context).size.width * 0.35,
                              MediaQuery.of(context).size.height * 0.06),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(30),
                            ),
                          ),
                        ),
                        label: Text(
                          context.l10n.cancel,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context).primaryColorDark,
                                  ),
                        ),
                        icon: Icon(
                          Icons.cancel_outlined,
                          size: MediaQuery.of(context).size.width * 0.06,
                          color: Theme.of(context).primaryColorDark,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
                top: -83,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox.fromSize(
                      size: const Size(70, 70), // button width and height
                      child: ClipOval(
                        child: Material(
                          color: Colors.red, // button color
                          child: InkWell(
                            onTap: () async {},
                            child: const Icon(
                              Icons.priority_high,
                              color: Colors.white,
                              size: 45,
                            ), // icon
                          ),
                        ),
                      ),
                    ),
                  ],
                )),
          ],
        ),
      ),
    );
  }
}
