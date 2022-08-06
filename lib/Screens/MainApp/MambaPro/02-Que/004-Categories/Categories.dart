import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba_castelldefels/Data/DataService/BrandDataService.dart';
import 'package:mamba_castelldefels/Data/DataService/RoomDataService.dart';
import 'package:mamba_castelldefels/Globals/Constants.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/Styles/AppColors/AppColors.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Components/Images/CircularImage.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/LoadingViews/LoadingViewPurple.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/ProfileView/ProfileUserView.dart';
import 'package:mamba_castelldefels/Data/Models/Usuario.dart';
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:shimmer/shimmer.dart';

class Categories extends StatefulWidget {
  String brandId;

  Categories({Key? key, required this.brandId}) : super(key: key);

  @override
  _Categories createState() => _Categories();
}

class _Categories extends State<Categories> {

  // Brand Data Service
  var _brandDataService = BrandDataService();

  List<dynamic> sportIcon = [Icons.sports_soccer, Icons.sports_tennis,Icons.sports_tennis, Icons.sports_tennis, Icons.sports_tennis, Icons.sports_tennis, Icons.sports_tennis];
  List<dynamic> sportColor = [Colors.red[100]!, Colors.blue[100]!, Colors.green[100]!, Colors.yellow[100]!, Colors.orange[100]!, Colors.purple[100]!, Colors.brown[100]!];
  List<bool> sportClicked = [false,false,false,false,false,false,false,false];

  List<String> categories = ['Futbol', 'Tennis', 'Basket', 'Rugby', 'Otros', 'Golf', 'Boxeo'];
  List<String> categoriesFromBrand = ['Futbol', 'Basket', 'Tennis', 'DS', 'dsa'];

  String palabrasClave = 'diversion, momento, roldan, coach, vida, disfrutar';

  // Search Controller
  var palabrasClaveController = TextEditingController();

  @override
  initState() {
  }

  Widget buildDetailsTabPage() => SafeArea(
    top: false,
    bottom: false,
    child: Builder(
      builder: (context) => CustomScrollView(
        shrinkWrap: true,
        slivers: [
          SliverOverlapInjector(
            handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
          ),
          SliverToBoxAdapter(
              child: Container()
          ),
          SliverToBoxAdapter(
              child: Container()
          ),
          SliverToBoxAdapter(
              child: Container()
          ),
        ],
      ),
    ),
  );

  Widget categorySection(var icon, String caregory, var color, int index)
  {
    return GestureDetector(
      child: Container(
          decoration: BoxDecoration(
            color: sportClicked[index]? color : Colors.white,
            border: Border.all(
              color: color,
            ),
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          width: 100,
          height: 50,
          child: Padding(
            padding:  EdgeInsets.all(MediaQuery.of(context).size.width*0.03),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Icon(
                      icon,
                    ),
                    SizedBox(width: MediaQuery.of(context).size.width*0.01),
                    Text(caregory),

                  ],
                ),
                SizedBox(height: MediaQuery.of(context).size.height*0.01),
                sportClicked[index]? Icon(
                  Icons.remove_circle_outline,
                ) : Icon(
                  Icons.add_circle_outline,
                ),
              ],
            ),
          )
      ),
        onTap: () =>
        {
          setState(() {
            sportClicked[index] = !sportClicked[index];
          }),
          //categoriesFromBrand.add(categories[index])
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
          backgroundColor: Colors.transparent,
          body:  Container(
              child: Column(
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height*0.02),
                  Padding(
                    padding: EdgeInsets.all(MediaQuery.of(context).size.width*0.04),
                    child: Row(
                      children: [
                        Text('Selecciona las categorias de tu marca', style: Theme.of(context).textTheme.headline3?.copyWith(fontWeight: FontWeight.w400), textAlign: TextAlign.start),
                      ],
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height*0.005,),
                  Expanded(
                    child: Container(
                      child: ListView.builder(
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          itemCount: categories.length,
                          itemBuilder: (context, index) {
                            String category = categories[index];
                            return Padding(
                              padding:  EdgeInsets.all(MediaQuery.of(context).size.width*0.03),
                              child: categorySection(sportIcon[index], category, sportColor[index], index),
                            );
                          }
                      ),
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height*0.02,),
                  Padding(
                    padding: EdgeInsets.all(MediaQuery.of(context).size.width*0.04),
                    child: Row(
                      children: [
                        Text('Indica las palabras clave de tu marca', style: Theme.of(context).textTheme.headline3?.copyWith(fontWeight: FontWeight.w400), textAlign: TextAlign.start),
                        ],
                    ),
                  ),
                  Container(
                    width: 350,
                    height: 200,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey,
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(MediaQuery.of(context).size.width*0.01),
                      child: TextFormField(
                        initialValue: palabrasClave,
                        //controller: palabrasClaveController,
                        onChanged: (value) {
                          palabrasClave = value;
                        },
                        style: Theme.of(context).textTheme.bodyText2,
                        textAlign: TextAlign.left,
                  ),
                    )),
                  SizedBox(height: MediaQuery.of(context).size.height*0.05,),
                  Container(
                    width: 150,
                    height: 50,//
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(MediaQuery.of(context).size.width*0.01),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Guardar todo', style: Theme.of(context).textTheme.headline3?.copyWith(fontWeight: FontWeight.w400), textAlign: TextAlign.start),
                          SizedBox(width: MediaQuery.of(context).size.width*0.01,),
                          Icon(
                            Icons.save,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height*0.20,),

    ],
              ),
    ),

            );
  }

  @override
  void dispose() {
    super.dispose();
  }

}