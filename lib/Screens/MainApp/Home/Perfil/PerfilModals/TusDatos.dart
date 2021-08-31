import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rounded_date_picker/flutter_rounded_date_picker.dart';
import 'package:intl/intl.dart';
import 'package:mamba_castelldefels/Globals/Globals.dart';
import 'package:mamba_castelldefels/Providers/ClientProvider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TusDatos extends StatefulWidget {
  const TusDatos({Key? key}) : super(key: key);

  @override
  _TusDatosState createState() => _TusDatosState();
}

class _TusDatosState extends State<TusDatos> {
  bool _editStatus = false;
  // Form Values
  final _formKey = GlobalKey<FormState>();
  String nombreCompletoTemp = "";
  String emailTemp = "";
  final nombreCompletoController = TextEditingController(text: currentUser.name);
  final emailController = TextEditingController(text: currentUser.email);
  // Gender Widget value
  int? genderTemp = null;
  final _genderKey = GlobalKey<_GenderWidgetState>();
  // Reverse String
  String reverseStringUsingSplit(String input) {
    var chars = input.split('');
    return chars.reversed.join();
  }
  // Date of Birth
  DateTime selectedDate = currentUser.dateOfBirth == null ?
    DateTime.now()
      :
    DateFormat('dd-MM-yyyy').parse(currentUser.dateOfBirth);

  @override
  Widget build(BuildContext context) {
    Future<void> _selectDate(BuildContext context) async {
      final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: selectedDate,
          firstDate: DateTime(DateTime.now().year - 60),
          lastDate: DateTime(DateTime.now().year + 1),
          initialEntryMode: DatePickerEntryMode.input);
      if (picked != null && picked != selectedDate)
        setState(() {
          selectedDate = picked;
        });
    }

    String dateToString(DateTime date) {
      final DateFormat formatter = DateFormat('dd-MM-yyyy');
      final String formatted = formatter.format(date);
      return formatted;
    }

    return Container(
      padding: MediaQuery.of(context).viewInsets,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back, color: purpleColor),
                  onPressed: () => {Navigator.of(context).pop()},
                ),
                Text(AppLocalizations.of(context)!.info, style: purpleTextStyle.copyWith(fontWeight: FontWeight.bold, fontSize: 24)),
                !_editStatus ? IconButton(
                    icon: Icon(Icons.edit, color: purpleColor),
                    onPressed: () => {
                      setState(() => _editStatus = !_editStatus)
                    }
                ) :
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.save, color: Colors.green),
                      onPressed: () => {
                        setState(() {
                          if(_formKey.currentState!.validate()){
                            if (!nombreCompletoTemp.isEmpty) currentUser.name = nombreCompletoTemp;
                            if (!emailTemp.isEmpty) currentUser.email = emailTemp;
                            if (!(genderTemp == null)) currentUser.gender = genderTemp;
                            if (!(dateToString(selectedDate) == dateToString(DateTime.now()))) currentUser.dateOfBirth = dateToString(selectedDate);
                            Provider.of<ClientProvider>(context, listen: false).updateClientFirebase(currentUser);
                            _editStatus = !_editStatus;
                            //FocusScope.of(context).requestFocus(new FocusNode());
                          }
                        })
                      },
                    ),
                    SizedBox.fromSize(
                      size: Size(10, 0),
                    ),
                    IconButton(
                      icon: Icon(Icons.highlight_off, color: Colors.red),
                      onPressed: () => {
                        setState(() {
                          nombreCompletoController.text = currentUser.name;
                          emailController.text = currentUser.email;
                          _genderKey.currentState!.resetGender();
                          selectedDate = currentUser.dateOfBirth == null ? DateTime.now() : DateFormat('dd-MM-yyyy').parse(currentUser.dateOfBirth);
                          _editStatus = !_editStatus;
                          //FocusScope.of(context).requestFocus(new FocusNode());
                        })
                      },
                    )
                  ],
                ),
              ],
            ),
            new Container(
              child: Padding(
                padding: EdgeInsets.only(bottom: 25.0),
                child: Form(
                  key: _formKey,
                  child: new Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                          padding: EdgeInsets.only(
                              left: 25.0, right: 25.0, top: 25.0),
                          child: new Row(
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              new Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  new Text(
                                    AppLocalizations.of(context)!.nameCompleto,
                                    style: purpleTextStyle.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ],
                          )),
                      Padding(
                          padding: EdgeInsets.only(
                              left: 25.0, right: 25.0, top: 2.0),
                          child: new Row(
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              new Flexible(
                                child: new TextFormField(
                                  controller: nombreCompletoController,
                                  validator: (val) => val!.isEmpty ? AppLocalizations.of(context)!.nameCompletoError : null,
                                  onChanged: (val) {
                                    setState(() => nombreCompletoTemp = val);
                                  },
                                  decoration: InputDecoration(
                                    hintText: AppLocalizations.of(context)!.nameCompleto,
                                  ),
                                  enabled: _editStatus,
                                ),
                              ),
                            ],
                          )),
                      Padding(
                          padding: EdgeInsets.only(
                              left: 25.0, right: 25.0, top: 25.0),
                          child: new Row(
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              new Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  new Text(
                                    AppLocalizations.of(context)!.email,
                                    style: purpleTextStyle.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ],
                          )),
                      Padding(
                          padding: EdgeInsets.only(
                              left: 25.0, right: 25.0, top: 2.0),
                          child: new Row(
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              new Flexible(
                                child: new TextFormField(
                                  controller: emailController,
                                  validator: (val) => val!.isEmpty ? AppLocalizations.of(context)!.emailError : null,
                                  onChanged: (val) {
                                    setState(() => emailTemp = val);
                                  },
                                  decoration: InputDecoration(
                                    hintText: AppLocalizations.of(context)!.email,
                                  ),
                                  enabled: _editStatus,
                                ),
                              ),
                            ],
                          )),
                      Padding(
                          padding: EdgeInsets.only(
                              left: 25.0, right: 25.0, top: 10.0),
                          child: GenderWidget(
                            key: _genderKey,
                            editStatus: (_editStatus),
                            selectedGenderChanged: (gender) {
                              genderTemp = gender;
                            },
                          )
                      ),
                      Padding(
                          padding: EdgeInsets.only(
                              left: 25.0, right: 25.0, top: 12.0),
                          child: new Row(
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              new Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  new Text(
                                    AppLocalizations.of(context)!.dateOfBirth,
                                    style: purpleTextStyle.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ],
                          )),
                      Padding(
                          padding: EdgeInsets.only(
                              left: 25.0, right: 25.0, top: 8.0),
                          child: new Row(
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              new Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  if (dateToString(selectedDate) != dateToString(DateTime.now()))
                                    _editStatus == false ? Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 14.5),
                                    child: Text(
                                        dateToString(selectedDate),
                                        style: purpleTextStyle.copyWith(fontSize: 16, color: Colors.black87)
                                    )) : new Theme(
                                          data: ThemeData(fontFamily: 'Raleway').copyWith(
                                            colorScheme: ColorScheme.light().copyWith(
                                              primary: Colors.amber,
                                            ),
                                          ),
                                          child: new Builder(
                                              builder: (context) => new
                                                TextButton(
                                                  style: TextButton.styleFrom(
                                                    padding: EdgeInsets.zero,
                                                  ),
                                                  onPressed: () => _selectDate(context),
                                                  child: Text(
                                                    dateToString(selectedDate),
                                                    style: purpleTextStyle.copyWith(fontSize: 16, color: Colors.black87, decoration: TextDecoration.underline),
                                                  ),
                                                )
                                          )
                                    ) else (
                                    _editStatus == false ?  Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 14.5),
                                      child: Text(
                                            AppLocalizations.of(context)!.noDateOfBirth,
                                            style: purpleTextStyle.copyWith(fontSize: 16, color: Colors.black87)
                                      ),
                                    ) : Theme(
                                          data: ThemeData(fontFamily: 'Raleway').copyWith(
                                            colorScheme: ColorScheme.light().copyWith(
                                              primary: Colors.amber,
                                            ),
                                          ),
                                          child: new Builder(
                                            builder: (context) => new
                                              TextButton(
                                              style: TextButton.styleFrom(
                                                padding: EdgeInsets.zero,
                                              ),
                                              onPressed: () => _selectDate(context),
                                              child: Text(
                                                AppLocalizations.of(context)!.selectDateOfBirth,
                                                style: purpleTextStyle.copyWith(fontSize: 16, color: Colors.black87, decoration: TextDecoration.underline),
                                              ),
                                            )
                                          )
                                        )
                                  ),
                                ],
                              ),
                            ],
                          )
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}



class GenderWidget extends StatefulWidget {
  final ValueChanged<int> selectedGenderChanged;
  final bool editStatus;
  //final Function resetGender;
  GenderWidget({required Key key, required this.selectedGenderChanged, required this.editStatus}) : super(key: key);

  @override
  _GenderWidgetState createState() => _GenderWidgetState();
}

class _GenderWidgetState extends State<GenderWidget> {
  int gender = currentUser.gender;

  @override
  resetGender() => gender = currentUser.gender;
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _icon(0, text: AppLocalizations.of(context)!.male, icon: Icons.male_outlined),
        _icon(1, text: AppLocalizations.of(context)!.female, icon: Icons.female_outlined),
        _icon(2, text: AppLocalizations.of(context)!.transgender, icon: Icons.transgender_outlined),
      ],
    );
  }
  Widget _icon(int index, {required String text, required IconData icon}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox.fromSize(
        size: Size(80, 80), // button width and height
        child: ClipOval(
          child: Material(
            color: gender == index ? purpleColorTrans : null, // button color
            child: InkWell(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      icon,
                      size: 38,
                      color: purpleColor,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text(text, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: purpleColor)),
                    ),
                  ],
                ),
                onTap: widget.editStatus ? () => {
                  setState(() {
                    gender = index;
                    widget.selectedGenderChanged(gender);
                  }),
                } : null,
            ),
          ),
        ),
      )
    );
  }

}




