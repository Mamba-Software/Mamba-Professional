import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:graphic/graphic.dart';
import 'package:mamba/commons/constants/constants.dart';
import 'package:mamba/commons/extensions/context.dart';

class CalendarActionButton extends StatefulWidget {
  final Function(bool) onCreateEventTap;

  const CalendarActionButton({
    required this.onCreateEventTap,
  });

  @override
  _CalendarActionButtonState createState() => _CalendarActionButtonState();
}

class _CalendarActionButtonState extends State<CalendarActionButton> {
  // Dial Open
  ValueNotifier<bool> isDialOpen = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      if (context.isMobile || context.isTablet) {
        return SpeedDial(
          heroTag: "46",
          animatedIcon: AnimatedIcons.add_event,
          animationDuration: Duration(milliseconds: animationDefaultDuration),
          foregroundColor: context.colorScheme.onSecondary,
          overlayColor: context.theme.scaffoldBackgroundColor,
          overlayOpacity: 0.95,
          spacing: defaultPadding,
          spaceBetweenChildren: defaultPadding,
          openCloseDial: isDialOpen,
          children: [
            SpeedDialChild(
              elevation: 4,
              backgroundColor: context.colorScheme.background,
              shape: const CircleBorder(),
              child: Icon(
                Icons.groups,
                size: iconSize,
                color: context.colorScheme.onBackground,
              ),
              labelWidget: Padding(
                padding: EdgeInsets.symmetric(horizontal: defaultPaddingSmall),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      context.l10n.groupEvent,
                      style: context.textTheme.titleLarge,
                      textAlign: TextAlign.right,
                    ),
                    Text(
                      context.l10n.groupEventDesc,
                      style: context.textTheme.bodyLarge,
                      textAlign: TextAlign.right,
                    ),
                  ],
                ),
              ),
              onTap: () => widget.onCreateEventTap(false),
            ),
            SpeedDialChild(
              elevation: 4,
              backgroundColor: context.colorScheme.background,
              shape: const CircleBorder(),
              child: Icon(
                Icons.person,
                size: iconSize,
                color: context.colorScheme.onBackground,
              ),
              labelWidget: Padding(
                padding: EdgeInsets.symmetric(horizontal: defaultPaddingSmall),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      context.l10n.privateEvent,
                      style: context.textTheme.titleLarge,
                      textAlign: TextAlign.right,
                    ),
                    Text(
                      context.l10n.privateEventDesc,
                      style: context.textTheme.bodyLarge,
                      textAlign: TextAlign.right,
                    ),
                  ],
                ),
              ),
              onTap: () => widget.onCreateEventTap(true),
            ),
          ],
        );
      } else {
        return SpeedDial(
          heroTag: "46",
          label: Text(
            context.l10n.createEvent,
            style: context.textTheme.titleLarge?.copyWith(color: context.colorScheme.onSecondary),
            textAlign: TextAlign.right,
          ),
          animatedIcon: AnimatedIcons.add_event,
          animationDuration: Duration(milliseconds: animationDefaultDuration),
          foregroundColor: context.colorScheme.onSecondary,
          overlayColor: context.theme.scaffoldBackgroundColor,
          overlayOpacity: 0.95,
          spacing: defaultPadding,
          spaceBetweenChildren: defaultPadding,
          openCloseDial: isDialOpen,          
          children: [
            SpeedDialChild(
              elevation: 4,
              backgroundColor: context.colorScheme.background,
              shape: const CircleBorder(),
              child: Icon(
                Icons.groups,
                size: iconSize,
                color: context.colorScheme.onBackground,
              ),
              labelWidget: Padding(
                padding: EdgeInsets.symmetric(horizontal: defaultPaddingSmall),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      context.l10n.groupEvent,
                      style: context.textTheme.titleLarge,
                      textAlign: TextAlign.right,
                    ),
                    Text(
                      context.l10n.groupEventDesc,
                      style: context.textTheme.bodyLarge,
                      textAlign: TextAlign.right,
                    ),
                  ],
                ),
              ),
              onTap: () => widget.onCreateEventTap(false),
            ),
            SpeedDialChild(
              elevation: 4,
              backgroundColor: context.colorScheme.background,
              shape: const CircleBorder(),
              child: Icon(
                Icons.person,
                size: iconSize,
                color: context.colorScheme.onBackground,
              ),
              labelWidget: Padding(
                padding: EdgeInsets.symmetric(horizontal: defaultPaddingSmall),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      context.l10n.privateEvent,
                      style: context.textTheme.titleLarge,
                      textAlign: TextAlign.right,
                    ),
                    Text(
                      context.l10n.privateEventDesc,
                      style: context.textTheme.bodyLarge,
                      textAlign: TextAlign.right,
                    ),
                  ],
                ),
              ),
              onTap: () => widget.onCreateEventTap(true),
            ),
          ],
        );
      }
    });
  }
}
