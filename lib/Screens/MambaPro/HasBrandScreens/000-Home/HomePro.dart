import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba_castelldefels/Data/DataService/Brand/BrandDataService.dart';
import 'package:mamba_castelldefels/Data/DataService/User/UserDataService.dart';
import 'package:mamba_castelldefels/Data/Models/Bono.dart';
import 'package:mamba_castelldefels/Data/Models/Usuario.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Screens/MambaPro/HasBrandScreens/04-Quan/010-Calendar/BrandCalendarWeekWidget.dart';

class HomePro extends StatefulWidget {
  String brandId;
  int numClients;
  int numTrainers;
  var safeAreaHeight;
  var safeAreaWidth;

  HomePro({Key? key, required this.brandId, required this.numTrainers, required this.numClients, this.safeAreaWidth, this.safeAreaHeight}) : super(key: key);

  @override
  _HomePro createState() => _HomePro();
}

class _HomePro extends State<HomePro> {

  // Brand Data Service
  final _brandDataService = BrandDataService();
  // User Data Service
  final _userDataService = UserDataService();

  // Boolean Loading
  bool graphClients = false;
  bool graphBonos  = false;

  var data = [
    {'category': 'Shirts', 'sales': 30},
    {'category': 'Shirts', 'sales': 20},
    {'category': 'Shirts', 'sales': 20},
    {'category': 'Pants', 'sales': 4},
    {'category': 'Heels', 'sales': 3},
    {'category': 'Socks', 'sales': 5},
  ];

  var eventsClients;

  var clientesFecha = new Map();
  List<Map<dynamic, dynamic>> clientesFechaGraph = [];

  List<Map<dynamic, dynamic>> bonosVendidosGraph = [];


  @override
  initState() {
    print(data);
    super.initState();
    makeClientesFecha();
    makeBonosVendidos();
  }

  //Datos del grafico clientes por fecha
  Future<void> makeClientesFecha() async {
    List<Usuario> brandClients = await _brandDataService.getBrandClients(widget.brandId);
    Usuario client;
    int clientes;
    String s;
    for (var i=0; i< brandClients.length; i++) {
      client = await _userDataService.getUserDetails(brandClients[i].id!);
      if (clientesFecha.isNotEmpty) {
          if (clientesFecha.containsKey(client.dateJoined)) {
            clientes = clientesFecha[client.dateJoined] + 1;
            clientesFecha.update(client.dateJoined, (value) => clientes);
          }
          else {
          clientesFecha.putIfAbsent(client.dateJoined, () => 1);
        }
      }
      else {
        clientesFecha.putIfAbsent(client.dateJoined, () => 1);
      }
    }

    clientesFecha.forEach((key, value) {
      clientesFechaGraph.add ({'fecha': key, 'clientes': value});
    });
    print(clientesFechaGraph);

    setState(() {
      graphClients = false;
    });
  }

  //Datos del grafico bonos vendidos
  Future<void> makeBonosVendidos() async {
    List<Bono> bonosBrand = await _brandDataService.getAllBonosFromBrandList(widget.brandId);
    Bono bono;
    for (var i=0; i< bonosBrand.length; i++) {
      bono = bonosBrand[i];
      bonosVendidosGraph.add({ 'bono': bono.title.toString(), 'compras': bono.compras,});
    }
    print(bonosVendidosGraph);
    setState(() {
      graphBonos = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
          backgroundColor: Colors.transparent,
          body: Padding(
            padding:  EdgeInsets.symmetric( vertical: MediaQuery.of(context).size.height*0.04, horizontal:  MediaQuery.of(context).size.width*0.04,),
            child: ListView(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.04),
                  child: Text(
                    AppLocalizations.of(context)!.calendarWeekBrandText(currentBrand.name!),
                    style: Theme.of(context).textTheme.bodyText1!.copyWith(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.left,
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.width * 0.01,
                ),
                BrandCalendarWeekWidget(brandId: widget.brandId, width: widget.safeAreaWidth, height: widget.safeAreaWidth,),
                /*!graphClients? Column(
                  children: [
                    UserCalendarPro(userId: currentUser.id!, width: widget.safeAreaWidth, height: widget.safeAreaWidth,),

                    SizedBox(height: MediaQuery.of(context).size.height*0.02),
                     Row(
                       children: [
                         Shimmer.fromColors(
                          baseColor: AppColors.grey,
                          highlightColor: AppColors.grey.withOpacity(0.5),
                          child: Container(
                            height: MediaQuery.of(context).size.height*0.03,
                            width: MediaQuery.of(context).size.width*0.4,
                            decoration: BoxDecoration(
                              borderRadius: new BorderRadius.all(
                                const Radius.circular(10.0),
                              ),
                              color: AppColors.grey,
                            ),
                          ),
                    ),
                       ],
                     ),
                    SizedBox(height: MediaQuery.of(context).size.height*0.02),
                    Container(
                      width: 500,
                      height: 200,
                      child: Shimmer.fromColors(
                        baseColor: AppColors.grey,
                        highlightColor: AppColors.grey.withOpacity(0.5),
                        child: Container(
                          height: MediaQuery.of(context).size.height*0.08,
                          width: MediaQuery.of(context).size.height*0.08,
                          decoration: BoxDecoration(
                            color: AppColors.grey,
                            shape: BoxShape.rectangle,
                          ),
                        ),
                      ),
                    ),


                  ],
                ) : Column(
                  children: [
                      Row(
                        children: [
                          Text('Clientes por fecha', style: Theme.of(context).textTheme.headline3?.copyWith(fontWeight: FontWeight.w400), textAlign: TextAlign.start),
                        ],
                      ),
                    SizedBox(height: MediaQuery.of(context).size.height*0.02),
                      Container(
                      width: 500,
                      height: 200,
                      child: Chart(
                        data: clientesFechaGraph,
                        variables: {
                          'fecha': Variable(
                            accessor: (Map map) => map['fecha'] as String,
                          ),
                          'clientes': Variable(
                            accessor: (Map map) => map['clientes'] as num,
                            scale: LinearScale(min: 0),
                          ),
                        },
                        elements: [LineElement(
                        ),
                        ],
                        coord: RectCoord(color: const Color(0xffdddddd)),
                        axes: [
                          Defaults.horizontalAxis,
                          Defaults.verticalAxis,
                        ],
                        selections: {
                          'touchMove': PointSelection(
                            on: {
                              GestureType.scaleUpdate,
                              GestureType.tapDown,
                              GestureType.longPressMoveUpdate
                            },
                            dim: Dim.x,
                          )
                        },
                        tooltip: TooltipGuide(
                          followPointer: [false, true],
                          align: Alignment.topLeft,
                          offset: const Offset(-20, -20),
                        ),
                        crosshair: CrosshairGuide(followPointer: [false, true]),
                      ),
                    )
                  ],
                ), */
                SizedBox(height: MediaQuery.of(context).size.height*0.05),
                /*
                !graphBonos? Column(
                  children: [
                    Row(
                      children: [
                        Shimmer.fromColors(
                          baseColor: AppColors.grey,
                          highlightColor: AppColors.grey.withOpacity(0.5),
                          child: Container(
                            height: MediaQuery.of(context).size.height*0.03,
                            width: MediaQuery.of(context).size.width*0.4,
                            decoration: BoxDecoration(
                              borderRadius: new BorderRadius.all(
                                const Radius.circular(10.0),
                              ),
                              color: AppColors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height*0.02),
                    Container(
                      width: 500,
                      height: 200,
                      child: Shimmer.fromColors(
                        baseColor: AppColors.grey,
                        highlightColor: AppColors.grey.withOpacity(0.5),
                        child: Container(
                          height: MediaQuery.of(context).size.height*0.08,
                          width: MediaQuery.of(context).size.height*0.08,
                          decoration: BoxDecoration(
                            color: AppColors.grey,
                            shape: BoxShape.rectangle,
                          ),
                        ),
                      ),
                    ),
                  ],
                )  : Column(
                  children: [
                    Row(
                      children: [
                        Text('Bonos vendidos', style: Theme.of(context).textTheme.headline3?.copyWith(fontWeight: FontWeight.w400), textAlign: TextAlign.start),
                      ],
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height*0.02),
                    Container(
                      width: 500,
                      height: 200,
                      child: Chart(
                        data: bonosVendidosGraph,
                        variables: {
                          'bono': Variable(
                            accessor: (Map map) => map['bono'] as String,
                          ),
                          'compras': Variable(
                            accessor: (Map map) => map['compras'] as num,
                            scale: LinearScale(min: 0),
                          ),
                        },
                        elements: [IntervalElement(
                        ),
                        ],
                        coord: RectCoord(transposed: true, color: const Color(0xffdddddd)),
                        axes: [
                          Defaults.horizontalAxis,
                          Defaults.verticalAxis,
                        ],
                        selections: {
                          'touchMove': PointSelection(
                            on: {
                              GestureType.scaleUpdate,
                              GestureType.tapDown,
                              GestureType.longPressMoveUpdate
                            },
                            dim: Dim.x,
                          )
                        },
                        tooltip: TooltipGuide(
                          followPointer: [false, true],
                          align: Alignment.topLeft,
                          offset: const Offset(-20, -20),
                        ),
                        crosshair: CrosshairGuide(followPointer: [false, true]),
                      ),
                    )
                  ],
                ),*/
            ]
            ),
          ),
          );
  }

  @override
  void dispose() {
    super.dispose();
  }

}