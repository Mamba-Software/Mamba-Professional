import 'package:flutter/material.dart';
import 'package:mamba/commons/extensions/context.dart';
import 'package:intl/intl.dart';
import 'package:mamba/data/DataService/Brand/BrandDataService.dart';
import 'package:mamba/data/Models/Bono.dart';
import 'package:mamba/data/Models/Brand.dart';
import 'package:mamba/data/Models/Purchase.dart';
import 'package:mamba/commons/constants/assets.dart';
import 'package:mamba/commons/styles/AppColors.dart';
import 'package:mamba/commons/utils/Strings/StringUtils.dart';
import 'package:mamba/commons/widgets/Components/Images/CircularImage.dart';
import 'package:mamba/commons/widgets/GroupOfComponents/Bonos/BonoCard.dart';
import 'package:shimmer/shimmer.dart';

class PurchaseListTile extends StatefulWidget {
  Purchase purchase;
  double height = 0;
  double width = 0;

  PurchaseListTile(
      {super.key,
      required this.purchase,
      required this.height,
      required this.width});

  @override
  _BonoListTileState createState() => _BonoListTileState();
}

class _BonoListTileState extends State<PurchaseListTile>
    with TickerProviderStateMixin {
  // Boolean Loading
  bool isLoading = true;
  // Acceso a Base de Datos
  final _brandDataService = BrandDataService();
  // Bono
  Bono bono = Bono();
  Brand brand = Brand();

  @override
  void initState() {
    isLoading = true;

    initEventTile();
    super.initState();
  }

  Future<void> initEventTile() async {
    await getBono();
    await getBrand();
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> getBono() async {
    bono = await _brandDataService.getBonoInfo(
        widget.purchase.brandId!, widget.purchase.bonoId!);
  }

  Future<void> getBrand() async {
    brand = await _brandDataService.getBrandDetails(widget.purchase.brandId!);
  }

  Widget buildPaymentMethod() {
    if (widget.purchase.paymentMethod == 0) {
      return Row(
        children: [
          Icon(
            Icons.paid_outlined,
            color: AppColors.grey,
            size: widget.width * 0.05,
          ),
          SizedBox(width: widget.width * 0.02),
          Flexible(
            child: Text(
                "${context.l10n.paymentMethod}: ${context.l10n.cashPaymentMethod}",
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(height: 1.5),
                textAlign: TextAlign.left),
          ),
        ],
      );
    } else if (widget.purchase.paymentMethod == 1) {
      return Row(
        children: [
          Icon(
            Icons.payment_outlined,
            color: AppColors.grey,
            size: widget.width * 0.05,
          ),
          SizedBox(width: widget.width * 0.02),
          Flexible(
            child: Text(
                "${context.l10n.paymentMethod}: ${context.l10n.transferPaymentMethod}",
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(height: 1.5),
                textAlign: TextAlign.left),
          ),
        ],
      );
    } else {
      return Row(
        children: [
          Icon(
            Icons.card_giftcard_outlined,
            color: AppColors.grey,
            size: widget.width * 0.05,
          ),
          SizedBox(width: widget.width * 0.02),
          Flexible(
            child: Text(
                "${context.l10n.paymentMethod}: ${context.l10n.giftPaymentMethod}",
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(height: 1.5),
                textAlign: TextAlign.left),
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Shimmer.fromColors(
            baseColor: AppColors.grey,
            highlightColor: AppColors.grey.withOpacity(0.5),
            child: SizedBox(
              height: widget.height * 0.18,
              width: widget.width,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    height: widget.width * 0.20,
                    width: widget.width * 0.20,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: widget.width * 0.20,
                          width: widget.width * 0.20,
                          decoration: BoxDecoration(
                            color: AppColors.grey,
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      SizedBox(
                        height: widget.height * 18,
                        width: widget.width * 0.56,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: widget.height * 0.03,
                              width: widget.width * 0.20,
                              decoration: BoxDecoration(
                                color: AppColors.grey,
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                            ),
                            SizedBox(
                              height: widget.height * 0.02,
                            ),
                            Container(
                              height: widget.height * 0.02,
                              width: widget.width * 0.35,
                              decoration: BoxDecoration(
                                color: AppColors.grey,
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                            ),
                            SizedBox(
                              height: widget.height * 0.015,
                            ),
                            Container(
                              height: widget.height * 0.02,
                              width: widget.width * 0.5,
                              decoration: BoxDecoration(
                                color: AppColors.grey,
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                            ),
                            SizedBox(
                              height: widget.height * 0.015,
                            ),
                            Container(
                              height: widget.height * 0.02,
                              width: widget.width * 0.5,
                              decoration: BoxDecoration(
                                color: AppColors.grey,
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                            ),
                            SizedBox(
                              height: widget.height * 0.015,
                            ),
                            Container(
                              height: widget.height * 0.02,
                              width: widget.width * 0.5,
                              decoration: BoxDecoration(
                                color: AppColors.grey,
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: widget.height * 15,
                        width: widget.width * 0.12,
                        child: Center(
                          child: Container(
                            height: widget.height * 0.05,
                            width: widget.height * 0.05,
                            decoration: BoxDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          )
        : FittedBox(
            fit: BoxFit.fitHeight,
            child: SizedBox(
              width: widget.width,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: widget.width * 0.25,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        BonoCard(
                            height: widget.height * 0.065,
                            width: widget.width * 0.22,
                            bono: bono,
                            brand: brand,
                            canExpand: false,
                            onlyView: true),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      FittedBox(
                        fit: BoxFit.fitHeight,
                        child: Container(
                          width: widget.width * 0.5,
                          constraints:
                              BoxConstraints(minHeight: widget.height * 0.15),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(bono.title!.toUpperCase(),
                                        style: Theme.of(context)
                                            .textTheme
                                            .displaySmall!
                                            .copyWith(
                                                color: Theme.of(context)
                                                    .primaryColor,
                                                fontWeight: FontWeight.bold),
                                        textAlign: TextAlign.left),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: widget.height * 0.015,
                              ),
                              Row(
                                children: [
                                  CircularImage(
                                    size: widget.width * 0.07,
                                    image: brand.logoUrl!,
                                    color: AppColors.grey,
                                    borderWidth: 0.5,
                                  ),
                                  SizedBox(width: widget.width * 0.02),
                                  Flexible(
                                    child: Text(brand.name!,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(height: 1.5),
                                        textAlign: TextAlign.left),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: widget.height * 0.02,
                              ),
                              Row(
                                children: [
                                  Icon(
                                    Icons.date_range_outlined,
                                    color: AppColors.grey,
                                    size: widget.width * 0.05,
                                  ),
                                  SizedBox(width: widget.width * 0.02),
                                  Flexible(
                                    child: Text(
                                        "${context.l10n.buyDate}: ${StringUtils().toCapitalized(DateFormat('EEEE dd/MM/yy', Localizations.localeOf(context).languageCode).format(widget.purchase.purchasedAt!.toDate()))}",
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(height: 1.5),
                                        textAlign: TextAlign.left),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: widget.height * 0.02,
                              ),
                              buildPaymentMethod(),
                            ],
                          ),
                        ),
                      ),
                      FittedBox(
                        fit: BoxFit.fitWidth,
                        child: widget.purchase.paymentMethod != 2
                            ? SizedBox(
                                width: widget.width * 0.23,
                                child: Center(
                                    child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(
                                        widget.purchase.price!
                                            .toStringAsFixed(2),
                                        style: Theme.of(context)
                                            .textTheme
                                            .displaySmall,
                                        textAlign: TextAlign.center),
                                    Icon(
                                      Icons.euro_symbol_outlined,
                                      color: Theme.of(context).primaryColor,
                                      size: widget.width * 0.05,
                                    ),
                                  ],
                                )))
                            : SizedBox(
                                width: widget.width * 0.23,
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: SizedBox(
                                      width: widget.width * 0.12,
                                      child: Image(
                                        image: AssetImage(Assets.imageGift),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
  }
}
