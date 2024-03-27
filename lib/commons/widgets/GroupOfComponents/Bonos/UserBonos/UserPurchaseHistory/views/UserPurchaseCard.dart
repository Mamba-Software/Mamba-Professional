import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mamba/data/Models/Bono.dart';
import 'package:mamba/data/Models/BonoRequest.dart';
import 'package:mamba/data/Models/Brand.dart';
import 'package:mamba/commons/managers/language_manager.dart';
import 'package:mamba/data/Models/Purchase.dart';
import 'package:mamba/data/Models/Usuario.dart';
import 'package:mamba/commons/constants/GlobalVars.dart';
import 'package:mamba/commons/utils/Strings/StringUtils.dart';
import 'package:mamba/commons/widgets/Components/Images/CircularImage.dart';
import 'package:mamba/commons/widgets/GroupOfComponents/Bonos/BonoCard.dart';
import 'package:mamba/commons/widgets/GroupOfComponents/Bonos/Purchase/PurchasePage.dart';
import 'package:mamba/app/style/AppColors.dart';

class UserPurchaseCard extends StatelessWidget {
  final Usuario user;
  final Brand brand;
  final Bono bono;
  final BonoRequest? bonoRequest;
  final Purchase? purchase;

  const UserPurchaseCard({
    super.key,
    required this.user,
    required this.brand,
    required this.bono,
    this.bonoRequest,
    this.purchase,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onTapPurchase(context);
      },
      child: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.04,
            vertical: MediaQuery.of(context).size.width * 0.03),
        child: Row(
          children: [
            BonoCard(
                height: MediaQuery.of(context).size.width * 0.09,
                width: MediaQuery.of(context).size.width * 0.15,
                bono: bono,
                brand: brand,
                canExpand: false,
                onlyView: true),
            SizedBox(
                width: MediaQuery.of(context).size.width *
                    0.04), // adjust this value as needed
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// BONO && STATUS
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          bono.title!.toUpperCase(),
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
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

                  /// USER
                  Row(
                    children: [
                      CircularImage(
                        size: MediaQuery.of(context).size.width * 0.05,
                        image: user.imageUrl,
                        color: Theme.of(context).primaryColor,
                        borderWidth: 0.5,
                      ),
                      SizedBox(width: MediaQuery.of(context).size.width * 0.01),
                      Flexible(
                        child: Text(
                          user.name!,
                          style: Theme.of(context).textTheme.bodySmall,
                          textAlign: TextAlign.left,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.01),

                  /// DETAILS
                  bonoRequest != null
                      ? buildBonoRequestDetails(context)
                      : buildPurchaseDetails(context),
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
    TextStyle? priceStyle = Theme.of(context).textTheme.bodySmall;

    if (bonoRequest!.paymentMethod! == 0) {
      paymentIcon = Icons.paid_outlined;
      paymentText = context.l10n.cashPaymentMethod;
    } else if (bonoRequest!.paymentMethod! == 1) {
      paymentIcon = Icons.payment_outlined;
      paymentText = context.l10n.transferPaymentMethod;
    } else {
      paymentIcon = Icons.card_giftcard_outlined;
      paymentText = context.l10n.giftPaymentMethod;
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
            bono.sessions! < 5000 ? bono.sessions.toString() + " ses..." : StringUtils().toCapitalized(context.l10n.ilimitadas),
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
            StringUtils().toCapitalized(context.l10n.desactiveFem),
            style: Theme.of(context).textTheme.bodySmall,
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
            "${bono.price!.toStringAsFixed(2)} €",
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
          style: Theme.of(context).textTheme.bodySmall,
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
    TextStyle? priceStyle = Theme.of(context).textTheme.bodySmall;

    if (purchase!.paymentMethod! == 0) {
      paymentIcon = Icons.paid_outlined;
      paymentText = context.l10n.cashPaymentMethod;
    } else if (purchase!.paymentMethod! == 1) {
      paymentIcon = Icons.send_to_mobile_outlined;
      paymentText = context.l10n.transferPaymentMethod;
    } else if (purchase!.paymentMethod! == 2) {
      paymentIcon = Icons.card_giftcard_outlined;
      paymentText = context.l10n.giftPaymentMethod;
      priceStyle = priceStyle?.copyWith(decoration: TextDecoration.lineThrough);
    } else {
      paymentIcon = Icons.payment_outlined;
      paymentText = context.l10n.cardPaymentMethod;
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
            purchase!.sessions! < 5000 ? purchase!.sessions.toString() + " ses..." : StringUtils().toCapitalized(context.l10n.ilimitadas),
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
            purchase!.isActive!
                ? context.l10n.activeFem
                : context.l10n.desactiveFem,
            style: Theme.of(context).textTheme.bodySmall,
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
            "${purchase!.price!.toStringAsFixed(2)} €",
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
          style: Theme.of(context).textTheme.bodySmall,
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
              DateFormat("E dd MMMM yy, HH:mm",
                      Localizations.localeOf(context).languageCode)
                  .format(bonoRequest!.timeRequested!.toDate())
                  .toUpperCase(),
              style:
                  Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 12),
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
              DateFormat("E dd MMMM yy, HH:mm",
                      Localizations.localeOf(context).languageCode)
                  .format(purchase!.purchasedAt!.toDate())
                  .toUpperCase(),
              style:
                  Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 12),
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
            context.l10n.toConfirm,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: AppColors.red, fontWeight: FontWeight.bold),
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
              color: AppColors.red,
              size: MediaQuery.of(context).size.width * 0.04,
            ),
            SizedBox(width: MediaQuery.of(context).size.width * 0.01),
            Text(
              context.l10n.unverfied,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: AppColors.red, fontWeight: FontWeight.bold),
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
              context.l10n.verfied,
              style: Theme.of(context).textTheme.bodyMedium,
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
      await Navigator.push(
          context,
          CupertinoPageRoute<void>(
            builder: (context) => PurchasePage(
              bono: bono,
              user: user,
              brand: brand,
              bonoRequest: bonoRequest,
              purchase: purchase,
            ),
          ));
    }
  }
}
