import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba/app/style/AppColors.dart';

class GenderWidget extends StatefulWidget {
  final ValueChanged<int> selectedGenderChanged;
  final int? genderTemp;
  const GenderWidget(
      {super.key,
      required this.selectedGenderChanged,
      required this.genderTemp});

  @override
  _GenderWidgetState createState() => _GenderWidgetState();
}

class _GenderWidgetState extends State<GenderWidget> {
  bool firstBuild = true;
  var gender;

  @override
  Widget build(BuildContext context) {
    if (firstBuild) {
      if (widget.genderTemp != null) gender = widget.genderTemp;
      firstBuild = false;
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _icon(0,
            text: AppLocalizations.of(context)!.male,
            icon: Icons.male_outlined),
        _icon(1,
            text: AppLocalizations.of(context)!.female,
            icon: Icons.female_outlined),
        _icon(2,
            text: AppLocalizations.of(context)!.transgender,
            icon: Icons.transgender_outlined),
      ],
    );
  }

  Widget _icon(int index, {required String text, required IconData icon}) {
    return SizedBox.fromSize(
      size: const Size(90, 90), // button width and height
      child: ClipOval(
        child: Material(
          shape: CircleBorder(
            side: BorderSide(
                color: gender == index ? Colors.white : Colors.black, width: 1),
          ),
          color: AppColors.black,
          child: InkWell(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 30,
                  color: AppColors.white,
                ),
                Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      text,
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          color: AppColors.white, fontWeight: FontWeight.bold),
                    )),
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
    );
  }
}
