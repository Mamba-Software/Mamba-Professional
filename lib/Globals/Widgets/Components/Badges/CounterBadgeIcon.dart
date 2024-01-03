import 'package:flutter/material.dart';

class CounterBadgeIcon extends StatefulWidget {
  final int counter;
  final double? top;
  final double? right;
  final Widget child;

  const CounterBadgeIcon({super.key, required this.counter, this.top = 0, this.right = 0, required this.child});

  @override
  _CounterBadgeIconState createState() => _CounterBadgeIconState();
}

class _CounterBadgeIconState extends State<CounterBadgeIcon> {

  @override
  Widget build(BuildContext context) {
    final text = widget.counter.toString();
    final deltaFontSize = (text.length - 1) * 3.0;

    return widget.counter > 0 && widget.counter < 9 ? Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.centerRight,
      children: [
        widget.child,
        Positioned(
          top: widget.top ?? 0,
          right: widget.right ?? 0,
          child: CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.secondary,
            radius: 7,
            child: Text(
              text,
              style: TextStyle(
                fontSize: 8 - deltaFontSize,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    ) : widget.counter > 9 ? Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.centerRight,
      children: [
        widget.child,
        Positioned(
          top: widget.top ?? 0,
          right: widget.right ?? 0,
          child: CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.secondary,
            radius: 7,
            child: Text(
              "+9",
              style: TextStyle(
                fontSize: 10 - deltaFontSize,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    ) : widget.child;
  }
}