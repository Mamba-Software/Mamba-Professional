import 'package:flutter/material.dart';
import 'package:mamba_castelldefels/Data/Models/Bono.dart';
import 'package:mamba_castelldefels/Data/Models/BonoRequest.dart';
import 'package:mamba_castelldefels/Data/Models/Brand.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba_castelldefels/Data/Models/Usuario.dart';
import 'package:mamba_castelldefels/Globals/Constants.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/Utils/Date/DateTimeUtils.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/Bonos/BonoCard.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Components/Images/CircularImage.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/Bonos/ConfirmBuyBono.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/Bonos/OtorgarBono.dart';

class BonoRequestObject extends StatefulWidget {
  Bono bono;
  Usuario user;
  BonoRequest bonoRequest;
  Brand brand;

  BonoRequestObject({Key? key, required this.bono,required this.user,required this.bonoRequest, required this.brand }) : super(key: key);
  @override
  BonoRequestObjectState createState() => BonoRequestObjectState();
}

class BonoRequestObjectState extends State<BonoRequestObject> {

  // Variables
  bool isFirstBuild = true;
  String originalPaymentString = "";
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (isFirstBuild) {
      if (widget.bonoRequest.paymentMethod == 0) {
        originalPaymentString = AppLocalizations.of(context)!.cashPaymentMethod;
      } else {
        originalPaymentString = AppLocalizations.of(context)!.transferPaymentMethod;
      }
      isFirstBuild = false;
    }
    return ListTile(
      tileColor: Theme.of(context).backgroundColor.withOpacity(0.75),
      contentPadding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.05, vertical: MediaQuery.of(context).size.width*0.03),
      minLeadingWidth: MediaQuery.of(context).size.width*0.15,
      leading: CircularImage(
        size: MediaQuery.of(context).size.width*0.15,
        image: widget.user.imageUrl,
        color: Theme.of(context).primaryColor,
        borderWidth: 1.0,
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            widget.user.name!,
            style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.left,
          ),
          const SizedBox(height: 8),
          RichText(
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.fade,
            textAlign: TextAlign.left,
            text: TextSpan(
              style: Theme.of(context).textTheme.caption,
              children: [
                TextSpan(
                  text: AppLocalizations.of(context)!.bono+": ",
                ),
                TextSpan(
                  text: widget.bono.title!.toUpperCase(),
                  style: Theme.of(context).textTheme.bodyText2,
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          RichText(
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.fade,
            textAlign: TextAlign.left,
            text: TextSpan(
              style: Theme.of(context).textTheme.caption,
              children: [
                TextSpan(
                  text: AppLocalizations.of(context)!.paymentMethod+": ",
                ),
                TextSpan(
                  text: originalPaymentString,
                  style: Theme.of(context).textTheme.bodyText2,
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            AppLocalizations.of(context)!.requestSent(DateTimeUtils().formatDateTimeToStringDDMMYYYY(widget.bonoRequest.timeRequested!.toDate(), Localizations.localeOf(context).languageCode)),
            style: Theme.of(context).textTheme.caption,
            textAlign: TextAlign.left,
          ),
        ],
      ),
      subtitle: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.width*0.07,
            width: MediaQuery.of(context).size.width*0.4,
            child: FittedBox(
              fit: BoxFit.contain,
              child: Container(
                padding: const EdgeInsets.all(5),
                margin: const EdgeInsets.only(top: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.green,
                ),
                child: Center(
                  child: Text(
                    AppLocalizations.of(context)!.bonoRequestDescription,
                    style: Theme.of(context).textTheme.bodyText1?.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.visible,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      trailing: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: MediaQuery.of(context).size.width*0.1,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.width*0.1,
                width: MediaQuery.of(context).size.width*0.1,
                child: FittedBox(
                  fit: BoxFit.fitHeight,
                  child: Image(
                    image: widget.bonoRequest.paymentMethod == 0 ? AssetImage(Constants.imageCash) : AssetImage(Constants.imageTransfer),
                  ),
                ),
              ),
              /*
              BonoCard(
                height: MediaQuery.of(context).size.height*0.04,
                width: MediaQuery.of(context).size.width*0.15,
                bono: widget.bono,
                brand: widget.brand,
                canExpand: false,
                onlyView: true,
              ),

               */
            ],
          ),
        ),
      ),
      onTap: () async {
        if(!brandIsActive) {
          await navigateToPayWall(context);
        }
        else {
          await showModalBottomSheet<bool?>(
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            clipBehavior: Clip.antiAliasWithSaveLayer,
            builder: (BuildContext context) {
              return FractionallySizedBox(
                heightFactor: 0.95,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    FocusScopeNode currentFocus = FocusScope.of(context);
                    if (!currentFocus.hasPrimaryFocus &&
                        currentFocus.focusedChild != null) {
                      FocusManager.instance.primaryFocus?.unfocus();
                    }
                  },
                  child: OtorgarBono(
                    bono: widget.bono,
                    user: widget.user,
                    brand: widget.brand,
                    bonoRequest: widget.bonoRequest,
                    edit: false,
                  ),
                ),
              );
            },
          );
        }
      },
    );
  }
}