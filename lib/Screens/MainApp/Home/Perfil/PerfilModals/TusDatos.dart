import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mamba_castelldefels/Data/databaseAccess.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba_castelldefels/Globals/Widgets/LoadingView.dart';
import 'package:mamba_castelldefels/Globals/Styles.dart';
import 'package:mamba_castelldefels/Models/Usuario.dart';

// Tus Datos Widget.
class TusDatos extends StatefulWidget {
  final ValueChanged<bool?> isUpdated;
  const TusDatos({Key? key, required this.isUpdated}) : super(key: key);

  @override
  _TusDatosState createState() => _TusDatosState();
}

class _TusDatosState extends State<TusDatos> {

  // Acceso a Base de Datos
  var _accessDatabase = new DatabaseAccess();
  // Boolean Loading
  bool isLoading = false;
  bool firstBuild = true;
  // Model Usuario
  Usuario? user;

  // Form Values
  final _formKey = GlobalKey<FormState>();
  String nombreCompletoTemp = "";
  var nombreCompletoController;

  // Gender Widget value
  int? genderTemp;
  final _genderKey = GlobalKey<_GenderWidgetState>();

  // Date of Birth
  var selectedDate;
  var selectedDateTemp;

  // Boolean isUpdated
  bool isUpdated = false;

  @override
  void initState() {
    super.initState();
    isLoading = true;
    getUser();
  }
  // Gets user data when opening.
  void getUser() async {
    user = await _accessDatabase.getCurrentUserDetails();
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Initialises some data the first time that the Widget is build and data is Loaded.
    if(!isLoading && firstBuild){
      nombreCompletoController = TextEditingController(text: user!.name);
      selectedDate = user!.dateOfBirth == "null" ? DateTime.now() : DateFormat('dd-MM-yyyy').parse(user!.dateOfBirth!);
      firstBuild = false;
    }
    // Widget to Select your date.
    Future<void> _selectDate(BuildContext context) async {
      final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: selectedDate,
          firstDate: DateTime(DateTime.now().year - 60),
          lastDate: DateTime(DateTime.now().year + 1),
          initialEntryMode: DatePickerEntryMode.input);
      if (picked != null && picked != selectedDate && picked != DateTime.now())
        setState(() {
          selectedDateTemp = picked;
        });
    }
    // Date to String Function.
    String dateToString(DateTime date) {
      final DateFormat formatter = DateFormat('dd-MM-yyyy');
      final String formatted = formatter.format(date);
      return formatted;
    }
    // Checking if there has been a change that has not been saved.
    if (!isLoading) {
      if (nombreCompletoTemp != user!.name! && nombreCompletoTemp != "") {
        isUpdated = true;
      } else if (genderTemp != user!.gender! && genderTemp != null) {
        isUpdated = true;
      } else if (selectedDateTemp != selectedDate && selectedDateTemp != null) {
        isUpdated = true;
      } else {
        isUpdated = false;
      }
    }
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height*0.86,
      ),
      padding: MediaQuery.of(context).viewInsets,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: Styles.accent),
                    onPressed: () => {
                      Navigator.pop(context)
                    },
                  ),
                  Text(AppLocalizations.of(context)!.info, style:  Styles.purpleTextStyle.copyWith(fontWeight: FontWeight.bold, fontSize: 24)),
                  IconButton(
                    icon: Icon(Icons.save, color: isUpdated ? Colors.green : Styles.accentLight),
                    onPressed: isUpdated ? () => {
                      setState(() {
                        widget.isUpdated(isUpdated);
                        if(_formKey.currentState!.validate()){
                          if (nombreCompletoTemp.isNotEmpty) {
                            user!.name = nombreCompletoTemp;
                          };
                          if (!(genderTemp == null)) {
                            user!.gender = genderTemp;
                          };
                          if (!(selectedDateTemp == null)) {
                            user!.dateOfBirth = dateToString(selectedDateTemp);
                          };
                          // Update User DataBase
                          _accessDatabase.updateCurrentUserDatosPerifl(user!.name!, user!.gender!, user!.dateOfBirth!);
                          Navigator.pop(context);
                        }
                      })
                    } : null,
                  ),
                ],
              ),
              isLoading ?
                Container(
                  height: MediaQuery.of(context).size.height * 0.4,
                  child: LoadingView()
                )
                  :
                Container(
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
                                        style: Styles.purpleTextStyle.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
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
                                        setState(() => {
                                          nombreCompletoTemp = val
                                        });
                                      },
                                      decoration: InputDecoration(
                                        hintText: AppLocalizations.of(context)!.nameCompleto,
                                      ),
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
                                        style: Styles.purpleTextStyle.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 10),
                                    child: Icon(Icons.lock_outline, color: Styles.accent, size: 20,),
                                  ),
                                ],
                              )),
                          Padding(
                              padding: EdgeInsets.only(
                                  left: 25.0, right: 25.0, top: 4.0),
                              child: new Row(
                                mainAxisSize: MainAxisSize.max,
                                children: <Widget>[
                                  new Flexible(
                                    child: new TextFormField(
                                      decoration: InputDecoration(
                                        hintText: AppLocalizations.of(context)!.email,
                                      ),
                                      initialValue: user!.email!,
                                      enabled: false,
                                    ),
                                  ),
                                ],
                              )),
                          Padding(
                              padding: EdgeInsets.only(
                                  left: 20.0, right: 20.0, top: 10.0),
                              child: GenderWidget(
                                key: _genderKey,
                                user: user,
                                selectedGenderChanged: (gender) {
                                  setState(() {
                                    genderTemp = gender;
                                  });
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
                                        style: Styles.purpleTextStyle.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
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
                                        new Theme(
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
                                                    selectedDateTemp == null ? dateToString(selectedDate) : dateToString(selectedDateTemp),
                                                    style: Styles.purpleTextStyle.copyWith(fontSize: 16, color: Colors.black87),
                                                  ),
                                                )
                                            )
                                        ) else (
                                          Theme(
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
                                                      selectedDateTemp == null ? AppLocalizations.of(context)!.selectDateOfBirth : dateToString(selectedDateTemp),
                                                      style: Styles.purpleTextStyle.copyWith(fontSize: 16, color: Colors.black87),
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
      ),
    );
  }
}

class GenderWidget extends StatefulWidget {
  final ValueChanged<int> selectedGenderChanged;
  final Usuario? user;
  GenderWidget({required Key key, required this.selectedGenderChanged, required this.user}) : super(key: key);

  @override
  _GenderWidgetState createState() => _GenderWidgetState();
}

class _GenderWidgetState extends State<GenderWidget> {
  bool firstBuild = true;
  var gender;

  @override
  resetGender() => gender = widget.user!.gender!;
  Widget build(BuildContext context) {
    if (firstBuild) {
      gender = widget.user!.gender!;
      firstBuild = false;
    }
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
        size: Size(90, 90), // button width and height
        child: ClipOval(
          child: Material(
            color: gender == index ? Styles.accentLight : null, // button color
            child: InkWell(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      icon,
                      size: 38,
                      color: Styles.accent,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text(text, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Styles.accent)),
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
      )
    );
  }

}


