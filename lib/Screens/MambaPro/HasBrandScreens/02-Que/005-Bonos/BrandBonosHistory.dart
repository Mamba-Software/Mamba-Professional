// ignore_for_file: avoid_print
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mamba_castelldefels/Data/DataService/Brand/BrandDataService.dart';
import 'package:mamba_castelldefels/Data/DataService/Purchase/PurchaseDataService.dart';

class BrandBonosHistory extends StatefulWidget {
  String? brandId;

  BrandBonosHistory({Key? key, this.brandId}) : super(key: key);

  @override
  _BrandBonosHistoryState createState() => _BrandBonosHistoryState();
}

class _BrandBonosHistoryState extends State<BrandBonosHistory> {

  // Boolean Loading
  bool isLoading = true;
  bool isList = true;
  bool isExpanded = false;
  // Acceso a Base de Datos
  final _brandDataService = BrandDataService();
  final _purchaseDataService = PurchaseDataService();
  // Page View Controller
  int _numPages = 5;
  PageController? _pageController;
  ScrollController? _scrollController;
  int _currentPage = 0;
  // Map <Purchase, Bono, Brand, Events>
  var pageViewList = [];

  @override
  void initState() {
    //initEventHistory();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }

  /*

  Future<void> initEventHistory() async {
    await getUserPurchases();
    _numPages = pageViewList.length;
    // Define Selection
    if (widget.purchaseId != null) {
      _currentPage = pageViewList.indexWhere((element) => element[0].id == widget.purchaseId);
      isExpanded = true;
      isList = false;
    }
    _pageController = PageController(initialPage: _currentPage);
    _scrollController = ScrollController(initialScrollOffset: _currentPage*MediaQuery.of(context).size.height*0.2);
    // Is Loading False
    setState(() {
      isLoading = false;
    });
  }

  // Navigate to Event Screen on Tap
  Future<void> navigateToEventScreen(String eventId) async {
    await Navigator.push(
        context,
        CupertinoPageRoute<void>(
          builder: (context) => EventPage(
            eventId: eventId,
          ),
        )
    );
  }

  // Gets the Events Done by the User
  Future<void> getUserPurchases() async {
    final List<Purchase> listPurchases = await _purchaseDataService.getAllUserPurchases(widget.userId);
    listPurchases.sort((a,b) {
      var aDate =  a.purchasedAt!.toDate();
      var bDate =  b.purchasedAt!.toDate();
      return bDate.compareTo(aDate);
    });
    // Create PageView List
    for (Purchase purchase in listPurchases) {
      var result = [];
      // L'afegim al resultat Purchase
      result.add(purchase);
      result.add(purchase.bono);
      result.add(purchase.brand);
      // Add Event List
      List<Event> events = List.from(purchase.events);
      result.add(events);
      // Add to Final pageview
      pageViewList.add(result);
    }
  }

  Widget buildPaymentMethod(Purchase purchase) {
    if (purchase.paymentMethod == 0) {
      return Row(
        children: [
          Text(
              AppLocalizations.of(context)!.cashPaymentMethod,
              style: Theme.of(context).textTheme.bodyText1,
              textAlign: TextAlign.left
          ),
          const SizedBox(width: 1),
          Icon(Icons.paid_outlined, color: Theme.of(context).primaryColor, size: MediaQuery.of(context).size.width*0.05,),
        ],
      );
    } else if (purchase.paymentMethod == 1) {
      return Row(
        children: [
          Text(
              AppLocalizations.of(context)!.transferPaymentMethod,
              style: Theme.of(context).textTheme.bodyText1,
              textAlign: TextAlign.left
          ),
          const SizedBox(width: 1),
          Icon(Icons.payment_outlined, color: Theme.of(context).primaryColor, size: MediaQuery.of(context).size.width*0.05,),
        ],
      );
    } else {
      return Row(
        children: [
          Text(
              AppLocalizations.of(context)!.giftPaymentMethod,
              style: Theme.of(context).textTheme.bodyText1,
              textAlign: TextAlign.left
          ),
          const SizedBox(width: 1),
          Icon(Icons.card_giftcard_outlined, color: Theme.of(context).primaryColor, size: MediaQuery.of(context).size.width*0.05,),
        ],
      );
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.purchaseHistory,
          style: Theme.of(context).appBarTheme.titleTextStyle,
          textAlign: TextAlign.center,
        ),
        elevation: 2,
        centerTitle: true,
        backgroundColor: Theme.of(context).backgroundColor,
        leading: Padding(
          padding: EdgeInsets.only(left: MediaQuery.of(context).size.width*0.0),
          child: MaterialButton(
            onPressed: () {
              Navigator.pop(context);
            },
            elevation: 0,
            color: Theme.of(context).backgroundColor,
            textColor: AppColors.white,
            child: Icon(
              Icons.arrow_back,
              color: Theme.of(context).primaryColor,
              size: MediaQuery.of(context).size.width*0.06,
            ),
            padding: EdgeInsets.zero,
            shape: const CircleBorder(),
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.03),
            child: IconButton(
              icon:  !isList ? Icon(
                FontAwesomeIcons.list,
                size: MediaQuery.of(context).size.width*0.05,
                color: Theme.of(context).primaryColor
              ) : Icon(
                Icons.view_array_outlined,
                size: MediaQuery.of(context).size.width*0.08,
                color: Theme.of(context).primaryColor
              ),
              onPressed: () {
                setState(() {
                  isList = !isList;
                  _scrollController = ScrollController(initialScrollOffset: _currentPage*MediaQuery.of(context).size.height*0.2);
                  isExpanded = false;
                });
              }
            ),
          )
        ],
      ),
      backgroundColor: Theme.of(context).backgroundColor,
      body: isLoading ? LoadingView(
        color: Theme.of(context).primaryColor,
        hasLogo: false,
        isSmall: true,
      ) : Stack(
        children: [
          Stack(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  pageViewList.isNotEmpty ? Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      physics: const ClampingScrollPhysics(),
                      itemCount: pageViewList.length,
                      onPageChanged: (page) {
                        setState(() {
                          _currentPage = page;
                        });
                      },
                      itemBuilder: (context, index) {
                        Purchase purchase = pageViewList[index][0];
                        Bono bono = pageViewList[index][1];
                        Brand brand = pageViewList[index][2];
                        List<Event> events = pageViewList[index][3];
                        return SingleChildScrollView(
                          physics: const ClampingScrollPhysics(),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: MediaQuery.of(context).size.height*0.045),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Stack(
                                    children: [
                                      ClientBonoCard(
                                        height: MediaQuery.of(context).size.height*0.22,
                                        width: MediaQuery.of(context).size.width*0.84,
                                        bono: bono,
                                        brand: brand,
                                        purchase: purchase,
                                        isExpanded: isExpanded,
                                        canExpand: true,
                                        onlyView: true,
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            isExpanded = !isExpanded;
                                          });
                                        },
                                        child: Container(
                                          height: MediaQuery.of(context).size.height*0.21,
                                          width: MediaQuery.of(context).size.width*0.84,
                                          color: Colors.transparent,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(height: MediaQuery.of(context).size.height*0.03),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.05),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                        AppLocalizations.of(context)!.info,
                                        style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.w600),
                                        textAlign: TextAlign.center
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: MediaQuery.of(context).size.height*0.01),
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.width*0.02, horizontal: MediaQuery.of(context).size.width*0.05),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Text(
                                            AppLocalizations.of(context)!.price+": ",
                                            style: Theme.of(context).textTheme.caption,
                                            textAlign: TextAlign.left
                                        ),
                                        Text(
                                            purchase.price!.toStringAsFixed(2)+" €",
                                            style: Theme.of(context).textTheme.bodyText1,
                                            textAlign: TextAlign.left
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Text(
                                            AppLocalizations.of(context)!.buyDate+": ",
                                            style: Theme.of(context).textTheme.caption,
                                            textAlign: TextAlign.left
                                        ),
                                        Text(
                                            StringUtils().toCapitalized(DateFormat('EEEE dd/MM/yy', Localizations.localeOf(context).languageCode).format(purchase.purchasedAt!.toDate())),
                                            style: Theme.of(context).textTheme.bodyText1,
                                            textAlign: TextAlign.left
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Text(
                                            AppLocalizations.of(context)!.paymentMethod+": ",
                                            style: Theme.of(context).textTheme.caption,
                                            textAlign: TextAlign.left
                                        ),
                                        buildPaymentMethod(purchase)
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: MediaQuery.of(context).size.height*0.02),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.05),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                        AppLocalizations.of(context)!.sessions,
                                        style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.w600),
                                        textAlign: TextAlign.center
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                            AppLocalizations.of(context)!.newerFirst,
                                            style: Theme.of(context).textTheme.caption,
                                            textAlign: TextAlign.center
                                        ),
                                        const SizedBox(width: 2),
                                        Icon(
                                          Icons.arrow_downward,
                                          size: MediaQuery.of(context).size.width*0.04,
                                          color: AppColors.grey,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: MediaQuery.of(context).size.height*0.01),
                              events.isNotEmpty ? Container(
                                padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.05),
                                child: ListView.builder(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: events.length,
                                    itemBuilder: (context, index) {
                                      Event event = events[index];
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                                        child: GestureDetector(
                                          onTap: () {
                                            navigateToEventScreen(event.id!);
                                          },
                                          child: UserEventCard(
                                            event: event,
                                            height: MediaQuery.of(context).size.height*0.15,
                                            width: MediaQuery.of(context).size.width*0.9,
                                            isMyEvent: true,
                                            showEmoji: false,
                                          ),
                                        ),
                                      );
                                    }
                                ),
                              ) : Padding(
                                padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.width*0.02, horizontal: MediaQuery.of(context).size.width*0.05),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                        AppLocalizations.of(context)!.noData,
                                        style: Theme.of(context).textTheme.bodyText2,
                                        textAlign: TextAlign.center
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: MediaQuery.of(context).size.height*0.1),
                            ],
                          ),
                        );
                      },
                    ),
                  ) : Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(height: MediaQuery.of(context).size.height*0.03),
                            SizedBox(
                                width: MediaQuery.of(context).size.width*0.25,
                                child: Image.asset(Constants.emptyCalendar)
                            ),
                            SizedBox(height: MediaQuery.of(context).size.height*0.005),
                            Text(AppLocalizations.of(context)!.noData, style: Theme.of(context).textTheme.caption, textAlign: TextAlign.center,),
                            SizedBox(height: MediaQuery.of(context).size.height*0.05),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              pageViewList.isNotEmpty ? Column(
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height*0.02),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width*0.2,
                        child: PageViewDotIndicator(
                          currentItem: _currentPage,
                          count: _numPages,
                          unselectedColor: Theme.of(context).primaryColor.withOpacity(0.5),
                          selectedColor: Theme.of(context).primaryColor,
                          size: const Size(8, 8),
                          unselectedSize: const Size(5, 5),
                          duration: const Duration(milliseconds: 150),
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.03),
                          alignment: Alignment.center,
                          fadeEdges: true,
                          boxShape: BoxShape.circle, //defaults to circle
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height*0.02),
                ],
              ) : Container(),
            ],
          ),
          Visibility(
            visible: isList && pageViewList.isNotEmpty,
            child: Container(
              color: Theme.of(context).backgroundColor,
              height: MediaQuery.of(context).size.height,
              child: ListView.builder(
                controller: _scrollController,
                shrinkWrap: true,
                physics: const ClampingScrollPhysics(),
                itemCount: pageViewList.length,
                itemBuilder: (context,int index) {
                  Purchase purchase = pageViewList[index][0];
                  Bono bono = pageViewList[index][1];
                  Brand brand = pageViewList[index][2];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _currentPage = index;
                        _pageController!.jumpToPage(_currentPage);
                        isList = false;
                      });
                    },
                    child: Stack(
                      children: [
                        Column(
                          children: [
                            index == 0 ? SizedBox(height: MediaQuery.of(context).size.height*0.03) : Container(),
                            Padding(
                                padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.05),
                                child: FittedBox(
                                  fit: BoxFit.fitHeight,
                                  child: SizedBox(
                                    width: MediaQuery.of(context).size.width,
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        ClientBonoCard(
                                          height: MediaQuery.of(context).size.height*0.08,
                                          width: MediaQuery.of(context).size.width*0.27,
                                          bono: bono,
                                          brand: brand,
                                          purchase: purchase,
                                          canExpand: false,
                                          onlyView: true,
                                        ),
                                        FittedBox(
                                          fit: BoxFit.fitHeight,
                                          child: Container(
                                            width: MediaQuery.of(context).size.width*0.68,
                                            constraints: BoxConstraints(
                                                minHeight: MediaQuery.of(context).size.height*0.05
                                            ),
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Flexible(
                                                      child: Text(
                                                        bono.title!.toUpperCase(),
                                                        style: Theme.of(context).textTheme.headline1,
                                                        textAlign: TextAlign.left,
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 8),
                                                Row(
                                                  children: [
                                                    CircularImage(
                                                      size: MediaQuery.of(context).size.width*0.05,
                                                      image: brand.logoUrl!,
                                                      color: AppColors.grey,
                                                      borderWidth: 0.5,
                                                    ),
                                                    SizedBox(width: MediaQuery.of(context).size.width*0.01),
                                                    Flexible(
                                                      child: Text(
                                                        brand.name!,
                                                        style: Theme.of(context).textTheme.headline3?.copyWith(fontWeight: FontWeight.normal),
                                                        textAlign: TextAlign.left,
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 16),
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                        AppLocalizations.of(context)!.price+": ",
                                                        style: Theme.of(context).textTheme.caption,
                                                        textAlign: TextAlign.left
                                                    ),
                                                    Text(
                                                        purchase.price!.toStringAsFixed(2)+" €",
                                                        style: Theme.of(context).textTheme.bodyText1,
                                                        textAlign: TextAlign.left
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 8),
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                        AppLocalizations.of(context)!.buyDate+": ",
                                                        style: Theme.of(context).textTheme.caption,
                                                        textAlign: TextAlign.left
                                                    ),
                                                    Text(
                                                        StringUtils().toCapitalized(DateFormat('EEEE dd/MM/yy', Localizations.localeOf(context).languageCode).format(purchase.purchasedAt!.toDate())),
                                                        style: Theme.of(context).textTheme.bodyText1,
                                                        textAlign: TextAlign.left
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 8),
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                        AppLocalizations.of(context)!.paymentMethod+": ",
                                                        style: Theme.of(context).textTheme.caption,
                                                        textAlign: TextAlign.left
                                                    ),
                                                    buildPaymentMethod(purchase)
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height*0.03, horizontal: MediaQuery.of(context).size.width*0.05),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Container(
                                    height: 0.5,
                                    width: MediaQuery.of(context).size.width*0.61,
                                    color: AppColors.grey,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Container(
                          height: MediaQuery.of(context).size.height*0.2,
                          width: MediaQuery.of(context).size.width,
                          color: Colors.transparent,
                        )
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      )
    );
  }
   */
}
