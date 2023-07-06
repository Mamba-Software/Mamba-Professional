import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mamba_castelldefels/Data/Models/Bono.dart';
import 'package:mamba_castelldefels/Data/Models/BonoRequest.dart';
import 'package:mamba_castelldefels/Data/Models/Brand.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba_castelldefels/Data/Models/Usuario.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/Utils/Date/DateTimeUtils.dart';
import 'package:mamba_castelldefels/Globals/Utils/Strings/StringUtils.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Components/Images/CircularImage.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/Bonos/OtorgarBono.dart';
import '../../../../../../../Data/Models/Purchase.dart';
import '../../../../../../../Globals/Styles/AppColors/AppColors.dart';
import '../../../../../../../Globals/Widgets/GroupOfComponents/Bonos/BonoCard.dart';

class PurchaseCard extends StatelessWidget {
  final Usuario user;
  final Brand brand;
  final Bono bono;
  final BonoRequest? bonoRequest;
  final Purchase? purchase;

  const PurchaseCard({
    Key? key,
    required this.user,
    required this.brand,
    required this.bono,
    this.bonoRequest,
    this.purchase,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onTapPurchase(context);
      },
      child: Container(
        color: bonoRequest != null ? Theme.of(context).backgroundColor : Theme.of(context).scaffoldBackgroundColor,
        padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.04, vertical: MediaQuery.of(context).size.width * 0.03),
        child: Row(
          children: [
            CircularImage(
              size: MediaQuery.of(context).size.width * 0.15,
              image: user.imageUrl,
              color: Theme.of(context).primaryColor,
              borderWidth: 1.0,
            ),
            SizedBox(width: MediaQuery.of(context).size.width * 0.04), // adjust this value as needed
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// USER && STATUS
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          user.name!,
                          style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.left,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      SizedBox(width: MediaQuery.of(context).size.width * 0.01),
                      buildStatusLabel(context),
                    ],
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                  /// BONO
                  Row(
                    children: [
                      BonoCard(
                          height: MediaQuery.of(context).size.width * 0.03,
                          width: MediaQuery.of(context).size.width * 0.05,
                          bono: bono,
                          brand: brand,
                          canExpand: false,
                          onlyView: true
                      ),
                      SizedBox(width: MediaQuery.of(context).size.width * 0.01),
                      Flexible(
                        child: Text(
                          bono.title!.toUpperCase(),
                          style: Theme.of(context).textTheme.caption,
                          textAlign: TextAlign.left,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                  /// DETAILS
                  bonoRequest != null ? buildBonoRequestDetails(context) : buildPurchaseDetails(context),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                  /// DATE
                  buildDateDetails(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildBonoRequestDetails(BuildContext context) {
    IconData paymentIcon;
    String paymentText;
    TextStyle? priceStyle = Theme.of(context).textTheme.caption;

    if (bonoRequest!.paymentMethod! == 0) {
      paymentIcon = Icons.paid_outlined;
      paymentText = AppLocalizations.of(context)!.cashPaymentMethod;
    } else if (bonoRequest!.paymentMethod! == 1) {
      paymentIcon = Icons.payment_outlined;
      paymentText = AppLocalizations.of(context)!.transferPaymentMethod;
    } else {
      paymentIcon = Icons.card_giftcard_outlined;
      paymentText = AppLocalizations.of(context)!.giftPaymentMethod;
      priceStyle = priceStyle?.copyWith(decoration: TextDecoration.lineThrough);
    }

    return Row(
      children: [
        /* SESSIONS
        Icon(
          Icons.calendar_month_outlined,
          color: AppColors.grey,
          size: MediaQuery.of(context).size.width * 0.04,
        ),
        SizedBox(width: MediaQuery.of(context).size.width * 0.01),
        Flexible(
          child: Text(
            bono.sessions! < 5000 ? bono.sessions.toString() + " ses..." : StringUtils().toCapitalized(AppLocalizations.of(context)!.ilimitadas),
            style: Theme.of(context).textTheme.caption,
            textAlign: TextAlign.left,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        SizedBox(width: MediaQuery.of(context).size.width * 0.01),
         */
        // IS ACTIVE
        Icon(
          Icons.circle,
          color: AppColors.red,
          size: MediaQuery.of(context).size.width * 0.03,
        ),
        SizedBox(width: MediaQuery.of(context).size.width * 0.01),
        Flexible(
          child: Text(
            StringUtils().toCapitalized(AppLocalizations.of(context)!.desactive),
            style: Theme.of(context).textTheme.caption,
            textAlign: TextAlign.left,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        SizedBox(width: MediaQuery.of(context).size.width * 0.01),
        // PRICE
        Icon(
          Icons.attach_money_outlined,
          color: AppColors.grey,
          size: MediaQuery.of(context).size.width * 0.04,
        ),
        Flexible(
          child: Text(
            bono.price!.toStringAsFixed(2) + " €",
            style: priceStyle,
            textAlign: TextAlign.left,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        SizedBox(width: MediaQuery.of(context).size.width * 0.02),
        // PAYMENT METHOD
        Icon(
          paymentIcon,
          color: AppColors.grey,
          size: MediaQuery.of(context).size.width * 0.04,
        ),
        SizedBox(width: MediaQuery.of(context).size.width * 0.01),
        Text(
          paymentText,
          style: Theme.of(context).textTheme.caption,
          textAlign: TextAlign.left,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),

      ],
    );
  }

  Widget buildPurchaseDetails(BuildContext context) {
    IconData paymentIcon;
    String paymentText;
    TextStyle? priceStyle = Theme.of(context).textTheme.caption;

    if (purchase!.paymentMethod! == 0) {
      paymentIcon = Icons.paid_outlined;
      paymentText = AppLocalizations.of(context)!.cashPaymentMethod;
    } else if (purchase!.paymentMethod! == 1) {
      paymentIcon = Icons.payment_outlined;
      paymentText = AppLocalizations.of(context)!.transferPaymentMethod;
    } else {
      paymentIcon = Icons.card_giftcard_outlined;
      paymentText = AppLocalizations.of(context)!.giftPaymentMethod;
      priceStyle = priceStyle?.copyWith(decoration: TextDecoration.lineThrough);
    }

    return Row(
      children: [
        //SESSIONS
        /*
        Icon(
          Icons.calendar_month_outlined,
          color: AppColors.grey,
          size: MediaQuery.of(context).size.width * 0.04,
        ),
        SizedBox(width: MediaQuery.of(context).size.width * 0.01),
        Flexible(
          child: Text(
            purchase!.sessions! < 5000 ? purchase!.sessions.toString() + " ses..." : StringUtils().toCapitalized(AppLocalizations.of(context)!.ilimitadas),
            style: Theme.of(context).textTheme.caption,
            textAlign: TextAlign.left,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        SizedBox(width: MediaQuery.of(context).size.width * 0.01),
        */
        // IS ACTIVE
        Icon(
          Icons.circle,
          color: purchase!.isActive! ? Colors.green : AppColors.red,
          size: MediaQuery.of(context).size.width * 0.03,
        ),
        SizedBox(width: MediaQuery.of(context).size.width * 0.01),
        Flexible(
          child: Text(
            purchase!.isActive! ? AppLocalizations.of(context)!.active : AppLocalizations.of(context)!.desactive,
            style: Theme.of(context).textTheme.caption,
            textAlign: TextAlign.left,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        SizedBox(width: MediaQuery.of(context).size.width * 0.01),
        // PRICE
        Icon(
          Icons.attach_money_outlined,
          color: AppColors.grey,
          size: MediaQuery.of(context).size.width * 0.04,
        ),
        Flexible(
          child: Text(
            purchase!.price!.toStringAsFixed(2) + " €",
            style: priceStyle,
            textAlign: TextAlign.left,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        SizedBox(width: MediaQuery.of(context).size.width * 0.02),
        // PAYMENT METHOD
        Icon(
          paymentIcon,
          color: AppColors.grey,
          size: MediaQuery.of(context).size.width * 0.04,
        ),
        SizedBox(width: MediaQuery.of(context).size.width * 0.01),
        Text(
          paymentText,
          style: Theme.of(context).textTheme.caption,
          textAlign: TextAlign.left,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),

      ],
    );
  }

  Widget buildDateDetails(BuildContext context) {
    if (bonoRequest != null) {
      return Row(
        children: [
          Flexible(
            child: Text(
              DateFormat("E dd MMMM yy, HH:mm", Localizations.localeOf(context).languageCode).format(bonoRequest!.timeRequested!.toDate()).toUpperCase(),
              style: Theme.of(context).textTheme.caption?.copyWith(fontSize: 12),
              textAlign: TextAlign.left,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      );
    } else {
      return Row(
        children: [
          Flexible(
            child: Text(
              DateFormat("E dd MMMM yy, HH:mm", Localizations.localeOf(context).languageCode).format(purchase!.purchasedAt!.toDate()).toUpperCase(),
              style: Theme.of(context).textTheme.caption?.copyWith(fontSize: 12),
              textAlign: TextAlign.left,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      );
    }

  }

  Widget buildStatusLabel(BuildContext context) {
    if (bonoRequest != null) {
      return Row(
        children: [
          // SESSIONS
          SizedBox(width: MediaQuery.of(context).size.width * 0.01),
          Icon(
            Icons.help_outline_outlined,
            color: AppColors.red,
            size: MediaQuery.of(context).size.width * 0.04,
          ),
          SizedBox(width: MediaQuery.of(context).size.width * 0.01),
          Text(
            AppLocalizations.of(context)!.toConfirm,
            style: Theme.of(context).textTheme.caption?.copyWith(color: AppColors.red),
            textAlign: TextAlign.right,
          ),
        ],
      );
    } else {
      if (purchase!.directPurchase != null && purchase!.directPurchase!) {
        return Row(
          children: [
            SizedBox(width: MediaQuery.of(context).size.width * 0.01),
            Icon(
              Icons.new_releases_outlined,
              color: AppColors.mainColor,
              size: MediaQuery.of(context).size.width * 0.04,
            ),
            SizedBox(width: MediaQuery.of(context).size.width * 0.01),
            Text(
              AppLocalizations.of(context)!.unverfied,
              style: Theme.of(context).textTheme.caption?.copyWith(color: AppColors.mainColor),
              textAlign: TextAlign.right,
            ),
          ],
        );
      } else {
        return Row(
          children: [
            SizedBox(width: MediaQuery.of(context).size.width * 0.01),
            Icon(
              Icons.verified_outlined,
              color: Theme.of(context).primaryColor,
              size: MediaQuery.of(context).size.width * 0.04,
            ),
            SizedBox(width: MediaQuery.of(context).size.width * 0.01),
            Text(
              AppLocalizations.of(context)!.verfied,
              style: Theme.of(context).textTheme.bodyText2,
              textAlign: TextAlign.right,
            ),
          ],
        );
      }
    }

  }

  void onTapPurchase(BuildContext context) async {
    if (!brandIsActive) {
      await navigateToPayWall(context);
    } else {
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
            heightFactor: 0.935,
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
                bono: bono,
                user: user,
                brand: brand,
                bonoRequest: bonoRequest,
                edit: bonoRequest != null ? false : true,
              ),
            ),
          );
        },
      );
    }
  }
}