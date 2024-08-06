import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mamba/commons/extensions/context.dart';
import 'package:mamba/commons/styles/AppColors.dart';
import 'package:mamba/data/Models/Usuario.dart';

class GenderWidget extends StatefulWidget {
  final ValueChanged<int> selectedGenderChanged;
  final Usuario? user;
  const GenderWidget(
      { //required Key key,
      required this.selectedGenderChanged,
      required this.user})
      : super();

  @override
  _GenderWidgetState createState() => _GenderWidgetState();
}

class _GenderWidgetState extends State<GenderWidget> {
  bool firstBuild = true;
  var gender;

  resetGender() => gender = widget.user!.gender!;

  @override
  Widget build(BuildContext context) {
    if (firstBuild) {
      gender = widget.user!.gender!;
      firstBuild = false;
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _icon(0, text: context.l10n.male, icon: Icons.male_outlined),
        _icon(1, text: context.l10n.female, icon: Icons.female_outlined),
        _icon(2,
            text: context.l10n.transgender, icon: Icons.transgender_outlined),
      ],
    );
  }

  Widget _icon(int index, {required String text, required IconData icon}) {
    return Material(
      elevation: 4,
      shape: const CircleBorder(),
      shadowColor: gender == index
          ? Theme.of(context).colorScheme.secondary.withOpacity(0.5)
          : Theme.of(context).scaffoldBackgroundColor,
      child: SizedBox.fromSize(
        size: Size(
            MediaQuery.of(context).size.width * 0.25,
            MediaQuery.of(context).size.width *
                0.25), // button width and height
        child: ClipOval(
          child: Material(
            color: gender == index
                ? Theme.of(context).colorScheme.secondary
                : Theme.of(context).scaffoldBackgroundColor,
            child: InkWell(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: 30,
                    color: gender == index
                        ? AppColors.white
                        : Theme.of(context).primaryColor,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(text,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: gender == index
                                ? AppColors.white
                                : Theme.of(context).primaryColor)),
                  ),
                ],
              ),
              onTap: () => {
                setState(() {
                  gender = index;
                  widget.selectedGenderChanged(gender);
                }),
              },
            ),
          ),
        ),
      ),
    );
  }
}
