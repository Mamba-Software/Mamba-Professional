// Utils for page selections in Mamba Pro
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mamba_castelldefels/Screens/MambaPro/HasBrandScreens/000-Home/HomePro.dart';
import 'package:mamba_castelldefels/Screens/MambaPro/HasBrandScreens/01-Qui/001-Trainers/Trainers.dart';
import 'package:mamba_castelldefels/Screens/MambaPro/HasBrandScreens/01-Qui/002-Clients/Clients.dart';
import 'package:mamba_castelldefels/Screens/MambaPro/HasBrandScreens/01-Qui/015-AddMembers/MembershipRequestsPro.dart';
import 'package:mamba_castelldefels/Screens/MambaPro/HasBrandScreens/02-Que/004-Categories/Categories.dart';
import 'package:mamba_castelldefels/Screens/MambaPro/HasBrandScreens/02-Que/005-Bonos/Bonos.dart';
import 'package:mamba_castelldefels/Screens/MambaPro/HasBrandScreens/02-Que/008-Information/BrandInfo.dart';
import 'package:mamba_castelldefels/Screens/MambaPro/HasBrandScreens/02-Que/012-Logo/Logo.dart';
import 'package:mamba_castelldefels/Screens/MambaPro/HasBrandScreens/03-Com/007-Contenido/Content.dart';
import 'package:mamba_castelldefels/Screens/MambaPro/HasBrandScreens/04-Quan/014-Historial/BrandEventHistoryPage.dart';
import 'package:mamba_castelldefels/Screens/MambaPro/HasBrandScreens/05-On/011-Locations/Locations.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import '../../Widgets/GroupOfComponents/Calendars/BrandCalendarWidgetPro.dart';
import '../Strings/StringUtils.dart';

class MambaProUtils {

  // Date in the Middle of the Month
  DateTime middleMonthDate = DateTime.now();

  //Function to select the title of the page loaded
  Widget titlePageSelector(var context, pageIndex)
  {
    if(pageIndex == 0)return Text(AppLocalizations.of(context)!.homeBottomNav, style: Theme.of(context).appBarTheme.titleTextStyle,);
    if(pageIndex == 1)return Text(AppLocalizations.of(context)!.staff, style: Theme.of(context).appBarTheme.titleTextStyle,);
    if(pageIndex == 2)return Text(AppLocalizations.of(context)!.clients, style: Theme.of(context).appBarTheme.titleTextStyle,);
    if(pageIndex == 4)return Text(AppLocalizations.of(context)!.categories, style: Theme.of(context).appBarTheme.titleTextStyle,);
    if(pageIndex == 5)return Text(AppLocalizations.of(context)!.bonos, style: Theme.of(context).appBarTheme.titleTextStyle,);
    if(pageIndex == 8)return Text(AppLocalizations.of(context)!.information, style: Theme.of(context).appBarTheme.titleTextStyle,);
    if(pageIndex == 7)return Text(AppLocalizations.of(context)!.content, style: Theme.of(context).appBarTheme.titleTextStyle,);
    if(pageIndex == 6)return Text(AppLocalizations.of(context)!.opinions, style: Theme.of(context).appBarTheme.titleTextStyle,);
    if(pageIndex == 9)return Text(AppLocalizations.of(context)!.stats, style: Theme.of(context).appBarTheme.titleTextStyle,);
    if(pageIndex == 10)return Text(
      StringUtils().toCapitalized(DateFormat('MMMM yyyy', Localizations.localeOf(context).languageCode,).format(middleMonthDate)), style: Theme.of(context).appBarTheme.titleTextStyle,);
    if(pageIndex == 11)return Text(AppLocalizations.of(context)!.locations, style: Theme.of(context).appBarTheme.titleTextStyle,);
    if(pageIndex == 12)return Text(AppLocalizations.of(context)!.logo, style: Theme.of(context).appBarTheme.titleTextStyle,);
    if(pageIndex == 13)return Text(AppLocalizations.of(context)!.feedback, style: Theme.of(context).appBarTheme.titleTextStyle,);
    if(pageIndex == 14)return Text(AppLocalizations.of(context)!.eventHistory, style: Theme.of(context).appBarTheme.titleTextStyle,);
    if(pageIndex == 15)return Text(AppLocalizations.of(context)!.myRequests, style: Theme.of(context).appBarTheme.titleTextStyle,);
    if(pageIndex == 16)return Text(AppLocalizations.of(context)!.howTheySeeMe, style: Theme.of(context).appBarTheme.titleTextStyle,);
    return Container();
  }

  //Function to know the title on listview
  Widget titlePageSelectorListView(var context, int pageIndex)
  {
    if(pageIndex == 0)return Text(AppLocalizations.of(context)!.homeBottomNav);
    if(pageIndex == 1)return Text(AppLocalizations.of(context)!.staff);
    if(pageIndex == 2)return Text(AppLocalizations.of(context)!.clients);
    if(pageIndex == 4)return Text(AppLocalizations.of(context)!.categories);
    if(pageIndex == 5)return Text(AppLocalizations.of(context)!.bonos);
    if(pageIndex == 8)return Text(AppLocalizations.of(context)!.information);
    if(pageIndex == 7)return Text(AppLocalizations.of(context)!.content);
    if(pageIndex == 6)return Text(AppLocalizations.of(context)!.opinions);
    if(pageIndex == 9)return Text(AppLocalizations.of(context)!.stats);
    if(pageIndex == 10)return Text(AppLocalizations.of(context)!.calendar);
    if(pageIndex == 11)return Text(AppLocalizations.of(context)!.locations);
    if(pageIndex == 12)return Text(AppLocalizations.of(context)!.logo);
    if(pageIndex == 13)return Text(AppLocalizations.of(context)!.feedback);
    if(pageIndex == 14)return Text(AppLocalizations.of(context)!.eventHistory);
    if(pageIndex == 15) return Text(AppLocalizations.of(context)!.myRequests);
    if(pageIndex == 16) return Text(AppLocalizations.of(context)!.howTheySeeMe);
    return Container();
  }

  //Function to select the icon to load
  Widget iconSelector(int pageIndexView)
  {
    if(pageIndexView == 1) return const Icon(Icons.record_voice_over);
    if(pageIndexView == 2) return const Icon(Icons.group);
    if(pageIndexView == 8) return const Icon(Icons.feed);
    if(pageIndexView == 13) return const Icon(Icons.question_mark);
    if(pageIndexView == 4) return const Icon(Icons.category);
    if(pageIndexView == 5) return const Icon(Icons.shopping_bag);
    if(pageIndexView == 12) return const Icon(Icons.run_circle);
    if(pageIndexView == 7) return const Icon(Icons.collections);
    if(pageIndexView == 10) return const Icon(Icons.calendar_month);
    if(pageIndexView == 11) return const Icon(Icons.pin_drop);
    if(pageIndexView == 6) return const Icon(Icons.chat_bubble_outline);
    if(pageIndexView == 9) return const Icon(Icons.query_stats);
    if(pageIndexView == 14) return const Icon(Icons.history);
    if(pageIndexView == 15) return const Icon(Icons.group_add);
    if(pageIndexView == 16) return const Icon(Icons.preview);
    return Container();
  }

  /*Function to select the action bar in the page to load
  Widget actionIconsSelector(var context, int pageIndex)
  {
    if (pageIndex == 10) return HomePro(brandId:brandId, numTrainers: numTrainers, numClients: numClients, safeAreaWidth: safeAreaWidth, safeAreaHeight: safeAreaHeight,);
    if (pageIndex == 0) return HomePro(brandId:brandId, numTrainers: numTrainers, numClients: numClients, safeAreaWidth: safeAreaWidth, safeAreaHeight: safeAreaHeight,);
    return Row(
      children: [
        pageIndex == 10 ? IconButton(
          onPressed: () {
            if (_controller.view == CalendarView.month) {
              setState(() {
                _controller.view = CalendarView.week;
              });
            } else {
              setState(() {
                _controller.view = CalendarView.month;
                pageIndex = 10;
              });
            }
          },
          icon: _controller.view == CalendarView.month ? SizedBox(
            width: safeAreaWidth*0.15,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.calendar_view_week,
                  color: Theme.of(context).primaryColor,
                  size: safeAreaWidth*0.05,
                ),
                FittedBox(
                  fit: BoxFit.contain,
                  child: Text(
                      AppLocalizations.of(context)!.weekString,
                      style: Theme.of(context).textTheme.bodyText2,
                      textAlign: TextAlign.center
                  ),
                ),
              ],
            ),
          ) : SizedBox(
            width: safeAreaWidth*0.15,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.calendar_view_month,
                  color: Theme.of(context).primaryColor,
                  size: safeAreaWidth*0.05,
                ),
                FittedBox(
                  fit: BoxFit.contain,
                  child: Text(
                      AppLocalizations.of(context)!.monthString,
                      style: Theme.of(context).textTheme.bodyText2,
                      textAlign: TextAlign.center
                  ),
                ),
              ],
            ),
          ),
        ) : Container(),
        Padding(
          padding: EdgeInsets.only(right: MediaQuery.of(context).size.width*0.01),
          child: IconButton(
            icon: pageIndex == 0 ? Container() : Icon (iconStar ? Icons.favorite : Icons.favorite_border, size: MediaQuery.of(context).size.width*0.06,),
            onPressed: () {
              setState(() {
                iconStar = !iconStar;
                if (iconStar == true) {
                  favourites.add(pageIndex);
                }
                else {
                  favourites.remove(pageIndex);
                }
                favourites.sort();
                _userDataService.addFavouriteToUser(currentBrand.id!, currentUser.id!, favourites);
              }
              );
            },
          ),
        ),
      ],
    );

    if(pageIndex == 0) return HomePro(brandId:brandId, numTrainers: numTrainers, numClients: numClients, safeAreaWidth: safeAreaWidth, safeAreaHeight: safeAreaHeight,);
    if(pageIndex == 1) return Trainers(brandId:brandId, numTrainers: numTrainers );
    if(pageIndex == 2) return Clients(brandId: brandId, numClients: numClients,);
    if(pageIndex == 4) return Categories(brandId:brandId);
    if(pageIndex == 5) return BonosPro(brandId:brandId);
    if(pageIndex == 7) return Content(brandId:brandId);
    if(pageIndex == 8) return BrandInfo(locale: Localizations.localeOf(context), brandId:brandId);
    if(pageIndex == 12) return Logo(brandId:brandId);
    if(pageIndex == 10) {
      return BrandCalendarWidgetPro(
        brandId: brandId,
        dateTime: middleMonthDate,
        controller: _controller,
      );
    }
    if(pageIndex == 11) return Locations(brandId:brandId);
    if(pageIndex == 14) return BrandEventHistoryPage(brandId: brandId);
    if(pageIndex == 15) return MembershipRequestsPro(brandId: brandId);
    return Container();
  }
   */

  //Function to select the page to load
  Widget pageSelector(var context,int pageIndex, String brandId, int numTrainers, int numClients, CalendarController _controller, var safeAreaWidth, var safeAreaHeight)
  {
    if(pageIndex == 0) return HomePro(brandId:brandId, numTrainers: numTrainers, numClients: numClients, safeAreaWidth: safeAreaWidth, safeAreaHeight: safeAreaHeight,);
    if(pageIndex == 1) return Trainers(brandId:brandId, numTrainers: numTrainers );
    if(pageIndex == 2) return Clients(brandId: brandId, numClients: numClients,);
    if(pageIndex == 4) return Categories(brandId:brandId);
    if(pageIndex == 5) return BonosPro(brandId:brandId);
    if(pageIndex == 7) return Content(brandId:brandId);
    if(pageIndex == 8) return BrandInfo(locale: Localizations.localeOf(context), brandId:brandId);
    if(pageIndex == 12) return Logo(brandId:brandId);
    if(pageIndex == 10) {
      return BrandCalendarWidgetPro(
        brandId: brandId,
        dateTime: middleMonthDate,
        controller: _controller,
      );
    }
    if(pageIndex == 11) return Locations(brandId:brandId);
    if(pageIndex == 14) return BrandEventHistoryPage(brandId: brandId);
    if(pageIndex == 15) return MembershipRequestsPro(brandId: brandId);
    return Container();
  }


}