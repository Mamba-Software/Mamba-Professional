import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mamba_castelldefels/Data/databaseAccess.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/Styles.dart';
import 'package:mamba_castelldefels/Globals/Widgets/LoadingViewPurple.dart';
import 'package:mamba_castelldefels/Models/Usuario.dart';

// Tus Datos Widget.
class EditBrandInfo extends StatefulWidget {
  const EditBrandInfo({Key? key}) : super(key: key);

  @override
  _EditBrandInfoState createState() => _EditBrandInfoState();
}

class _EditBrandInfoState extends State<EditBrandInfo> {

  // Acceso a Base de Datos
  var _accessDatabase = new DatabaseAccess();
  // Boolean Loading
  bool isLoading = false;
  bool firstBuild = true;

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
  }

  @override
  Widget build(BuildContext context) {
    // Initialises some data the first time that the Widget is build and data is Loaded.
    if(firstBuild){
      nombreCompletoController = TextEditingController(text: currentUser.name);
      selectedDate = currentUser.dateOfBirth == "null" ? DateTime.now() : DateFormat('dd-MM-yyyy').parse(currentUser.dateOfBirth!);
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
      if (nombreCompletoTemp != currentUser.name! && nombreCompletoTemp != "") {
        isUpdated = true;
      } else if (genderTemp != currentUser.gender! && genderTemp != null) {
        isUpdated = true;
      } else if (selectedDateTemp != selectedDate && selectedDateTemp != null) {
        isUpdated = true;
      } else {
        isUpdated = false;
      }
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.yourBrand, style: Theme.of(context).appBarTheme.titleTextStyle,),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, size: 25,),
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              if (isUpdated) {
                if (nombreCompletoTemp.isNotEmpty) {
                  currentUser.name = nombreCompletoTemp;
                };
                if (!(genderTemp == null)) {
                  currentUser.gender = genderTemp;
                };
                if (!(selectedDateTemp == null)) {
                  currentUser.dateOfBirth = dateToString(selectedDateTemp);
                };
                setState(() {
                  isLoading = true;
                });
                await _accessDatabase.updateCurrentUserDatosPerifl(
                currentUser.name!, currentUser.gender!, currentUser.dateOfBirth!);
              }
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: isLoading ?
        LoadingViewPurple()
          :
        SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.05, vertical: MediaQuery.of(context).size.width*0.07),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            AppLocalizations.of(context)!.nameCompleto,
                            style: Styles.purpleTextStyle.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: MediaQuery.of(context).size.height*0.01),
                          Flexible(
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
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey)
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: MediaQuery.of(context).size.height*0.04),
                        ],
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Row(
                            children: [
                              Text(
                                AppLocalizations.of(context)!.email,
                                style: Styles.purpleTextStyle.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(width: MediaQuery.of(context).size.height*0.01),
                              Padding(
                                padding: EdgeInsets.only(bottom: MediaQuery.of(context).size.height*0.005),
                                child: Icon(Icons.lock_outline, color: Theme.of(context).primaryColor, size: 20,),
                              )
                            ],
                          ),
                          SizedBox(height: MediaQuery.of(context).size.height*0.01),
                          Flexible(
                            child: new TextFormField(
                              decoration: InputDecoration(
                                hintText: AppLocalizations.of(context)!.email,
                              ),
                              initialValue: currentUser.email!,
                              enabled: false,
                            ),
                          ),
                          SizedBox(height: MediaQuery.of(context).size.height*0.04),
                        ],
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            AppLocalizations.of(context)!.gender,
                            style: Styles.purpleTextStyle.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: MediaQuery.of(context).size.height*0.01),
                          GenderWidget(
                            key: _genderKey,
                            user: currentUser,
                            selectedGenderChanged: (gender) {
                              setState(() {
                                genderTemp = gender;
                              });
                            },
                          ),
                          SizedBox(height: MediaQuery.of(context).size.height*0.04),
                        ],
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            AppLocalizations.of(context)!.dateOfBirth,
                            style: Styles.purpleTextStyle.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: MediaQuery.of(context).size.height*0.01),
                          Column(
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
                          SizedBox(height: MediaQuery.of(context).size.height*0.04),
                        ],
                      ),
                    ],
                  ),
                ),
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
    return SizedBox.fromSize(
        size: Size(90, 90), // button width and height
        child: ClipOval(
          child: Material(
            color: gender == index ? Theme.of(context).accentColor : Theme.of(context).scaffoldBackgroundColor,
            child: InkWell(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      icon,
                      size: 30,
                      color: Theme.of(context).primaryColor,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text(text, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Theme.of(context).primaryColor)),
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
      );
  }

}


