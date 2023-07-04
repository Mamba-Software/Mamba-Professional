import 'package:flutter/material.dart';
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
        padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.04, vertical: MediaQuery.of(context).size.width * 0.04),
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
                  /// USER
                  Text(
                    user.name!,
                    style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.left,
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.005),
                  /// BONO
                  Row(
                    children: [
                      Icon(
                        Icons.confirmation_number_outlined,
                        color: AppColors.grey,
                        size: MediaQuery.of(context).size.width * 0.04,
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
                  SizedBox(height: MediaQuery.of(context).size.height * 0.005),
                  /// DETAILS
                  bonoRequest != null ? buildBonoRequestDetails(context) : buildPurchaseDetails(context),
                  /// STATUS
                  SizedBox(height: MediaQuery.of(context).size.height * 0.005),
                  buildStatusLabel(context),
                  /// DATE
                  SizedBox(height: MediaQuery.of(context).size.height * 0.005),
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
        // SESSIONS
        Icon(
          Icons.calendar_month_outlined,
          color: AppColors.grey,
          size: MediaQuery.of(context).size.width * 0.04,
        ),
        SizedBox(width: MediaQuery.of(context).size.width * 0.01),
        Flexible(
          child: Text(
            bono.sessions! < 5000 ? bono.sessions.toString() + " ses." : StringUtils().toCapitalized(AppLocalizations.of(context)!.ilimitadas),
            style: Theme.of(context).textTheme.caption,
            textAlign: TextAlign.left,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        SizedBox(width: MediaQuery.of(context).size.width * 0.02),
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
        SizedBox(width: MediaQuery.of(context).size.width * 0.04),
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
        // SESSIONS
        Icon(
          Icons.calendar_month_outlined,
          color: AppColors.grey,
          size: MediaQuery.of(context).size.width * 0.04,
        ),
        SizedBox(width: MediaQuery.of(context).size.width * 0.01),
        Flexible(
          child: Text(
            purchase!.sessions! < 5000 ? purchase!.sessions.toString() + " ses." : StringUtils().toCapitalized(AppLocalizations.of(context)!.ilimitadas),
            style: Theme.of(context).textTheme.caption,
            textAlign: TextAlign.left,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        SizedBox(width: MediaQuery.of(context).size.width * 0.02),
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
        SizedBox(width: MediaQuery.of(context).size.width * 0.04),
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
              AppLocalizations.of(context)!.requestSent(DateTimeUtils().formatDateTimeToStringDDMMYYYY(bonoRequest!.timeRequested!.toDate(), Localizations.localeOf(context).languageCode)),
              style: Theme.of(context).textTheme.caption?.copyWith(fontSize: 12.5),
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
              AppLocalizations.of(context)!.purchasedAt(DateTimeUtils().formatDateTimeToStringDDMMYYYY(purchase!.purchasedAt!.toDate(), Localizations.localeOf(context).languageCode)),
              style: Theme.of(context).textTheme.caption?.copyWith(fontSize: 12.5),
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
          Icon(
            Icons.help_outline_outlined,
            color: AppColors.grey,
            size: MediaQuery.of(context).size.width * 0.04,
          ),
          SizedBox(width: MediaQuery.of(context).size.width * 0.01),
          Flexible(
            child: Text(
              AppLocalizations.of(context)!.bonoRequestDescription,
              style: Theme.of(context).textTheme.caption,
              textAlign: TextAlign.left,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      );
    } else {
      if (purchase!.directPurchase != null && purchase!.directPurchase!) {
        return Row(
          children: [
            Icon(
              Icons.new_releases_outlined,
              color: AppColors.grey,
              size: MediaQuery.of(context).size.width * 0.04,
            ),
            SizedBox(width: MediaQuery.of(context).size.width * 0.01),
            Flexible(
              child: Text(
                AppLocalizations.of(context)!.unverfied,
                style: Theme.of(context).textTheme.caption,
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
            Icon(
              Icons.verified_outlined,
              color: AppColors.grey,
              size: MediaQuery.of(context).size.width * 0.04,
            ),
            SizedBox(width: MediaQuery.of(context).size.width * 0.01),
            Flexible(
              child: Text(
                AppLocalizations.of(context)!.verfied,
                style: Theme.of(context).textTheme.caption,
                textAlign: TextAlign.left,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
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
                edit: false,
              ),
            ),
          );
        },
      );
    }
  }
}