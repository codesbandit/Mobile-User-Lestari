import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:lestar_user/common/widgets/custom_snackbar_widget.dart';
import 'package:lestar_user/features/checkout/controllers/checkout_controller.dart';
import 'package:lestar_user/features/coupon/controllers/coupon_controller.dart';
import 'package:lestar_user/features/coupon/domain/models/customer_coupon_model.dart';
import 'package:lestar_user/features/coupon/widgets/coupon_card_widget.dart';
import 'package:lestar_user/features/language/controllers/localization_controller.dart';
import 'package:lestar_user/features/restaurant/controllers/restaurant_controller.dart';
import 'package:lestar_user/helper/price_converter.dart';
import 'package:lestar_user/helper/responsive_helper.dart';
import 'package:lestar_user/util/dimensions.dart';
import 'package:lestar_user/util/images.dart';
import 'package:lestar_user/util/styles.dart';

class CouponBottomSheet extends StatefulWidget {
  final CheckoutController checkoutController;
  final double price;
  final double discount;
  final double addOns;
  final double deliveryCharge;
  final double charge;
  final double total;
  const CouponBottomSheet({
    super.key,
    required this.checkoutController,
    required this.price,
    required this.discount,
    required this.addOns,
    required this.deliveryCharge,
    required this.total,
    required this.charge,
  });

  @override
  State<CouponBottomSheet> createState() => _CouponBottomSheetState();
}

class _CouponBottomSheetState extends State<CouponBottomSheet> {
  List<Coupon>? _availableCouponList;
  List<Coupon>? _unavailableCouponList;
  List<JustTheController>? _availableToolTipControllerList;
  List<JustTheController>? _unavailableToolTipControllerList;

  @override
  void initState() {
    super.initState();

    if (Get.find<CouponController>().customerCouponModel?.available != null &&
        Get.find<CouponController>()
            .customerCouponModel!
            .available!
            .isNotEmpty) {
      _availableCouponList = [];
      _availableToolTipControllerList = [];
      for (var coupon
          in Get.find<CouponController>().customerCouponModel!.available!) {
        if (widget.deliveryCharge == 0 &&
            coupon.couponType != 'free_delivery') {
          _availableCouponList!.add(coupon);
          _availableToolTipControllerList!.add(JustTheController());
        } else if (widget.deliveryCharge != 0) {
          _availableCouponList!.add(coupon);
          _availableToolTipControllerList!.add(JustTheController());
        }
      }
    }

    if (Get.find<CouponController>().customerCouponModel?.unavailable != null &&
        Get.find<CouponController>()
            .customerCouponModel!
            .unavailable!
            .isNotEmpty) {
      _unavailableCouponList = [];
      _unavailableToolTipControllerList = [];
      for (var coupon
          in Get.find<CouponController>().customerCouponModel!.unavailable!) {
        if (widget.deliveryCharge == 0 &&
            coupon.couponType != 'free_delivery') {
          _unavailableCouponList!.add(coupon);
          _unavailableToolTipControllerList!.add(JustTheController());
        } else if (widget.deliveryCharge != 0) {
          _unavailableCouponList!.add(coupon);
          _unavailableToolTipControllerList!.add(JustTheController());
        }
      }
    }
  }

  @override
  void dispose() {
    super.dispose();

    if (_availableToolTipControllerList != null) {
      for (var toolTip in _availableToolTipControllerList!) {
        toolTip.dispose();
      }
    }

    if (_unavailableToolTipControllerList != null) {
      for (var toolTip in _unavailableToolTipControllerList!) {
        toolTip.dispose();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double totalPrice = widget.total;
    return Container(
      width: 500,
      height: context.height * 0.7,
      margin: EdgeInsets.only(top: GetPlatform.isWeb ? 0 : 30),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: ResponsiveHelper.isMobile(context)
            ? const BorderRadius.vertical(
                top: Radius.circular(Dimensions.radiusExtraLarge),
              )
            : const BorderRadius.all(
                Radius.circular(Dimensions.radiusExtraLarge),
              ),
      ),
      child: GetBuilder<CouponController>(
        builder: (couponController) {
          return Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 30),

                  !ResponsiveHelper.isDesktop(context)
                      ? Container(
                          height: 4,
                          width: 35,
                          margin: const EdgeInsets.symmetric(
                            vertical: Dimensions.paddingSizeDefault,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).disabledColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        )
                      : const SizedBox(),

                  IconButton(
                    onPressed: () => Get.back(),
                    icon: Icon(
                      Icons.clear,
                      color: Theme.of(context).disabledColor,
                    ),
                  ),
                ],
              ),

              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                  border: Border.all(
                    color: Theme.of(context).primaryColor,
                    width: 0.3,
                  ),
                ),
                padding: const EdgeInsets.only(
                  left: Dimensions.paddingSizeExtraSmall,
                ),
                margin: const EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingSizeDefault,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 45,
                        child: TextField(
                          controller:
                              widget.checkoutController.couponController,
                          style: robotoRegular.copyWith(
                            height: ResponsiveHelper.isMobile(context)
                                ? null
                                : 2,
                          ),
                          decoration: InputDecoration(
                            hintText: 'enter_promo_code'.tr,
                            hintStyle: robotoRegular.copyWith(
                              color: Theme.of(context).hintColor,
                            ),
                            isDense: true,
                            filled: true,
                            enabled: couponController.discount == 0,
                            fillColor: Theme.of(context).cardColor,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.horizontal(
                                left: Radius.circular(
                                  Get.find<LocalizationController>().isLtr
                                      ? 10
                                      : 0,
                                ),
                                right: Radius.circular(
                                  Get.find<LocalizationController>().isLtr
                                      ? 0
                                      : 10,
                                ),
                              ),
                              borderSide: BorderSide.none,
                            ),
                            prefixIcon: Icon(
                              Icons.local_offer_outlined,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        String couponCode = widget
                            .checkoutController
                            .couponController
                            .text
                            .trim();
                        if (couponController.discount! < 1 &&
                            !couponController.freeDelivery) {
                          if (couponCode.isNotEmpty &&
                              !couponController.isLoading) {
                            couponController
                                .applyCoupon(
                                  couponCode,
                                  (widget.price - widget.discount) +
                                      widget.addOns,
                                  widget.deliveryCharge,
                                  widget.charge,
                                  totalPrice,
                                  Get.find<RestaurantController>()
                                      .restaurant!
                                      .id,
                                )
                                .then((discount) {
                                  if (discount! > 0) {
                                    showCustomSnackBar(
                                      '${'you_got_discount_of'.tr} ${PriceConverter.convertPrice(discount)}',
                                      isError: false,
                                    );
                                    if (widget
                                            .checkoutController
                                            .isPartialPay ||
                                        widget
                                                .checkoutController
                                                .paymentMethodIndex ==
                                            1) {
                                      totalPrice = totalPrice - discount;
                                      widget.checkoutController
                                          .checkBalanceStatus(totalPrice);
                                    }
                                  }
                                });
                          } else if (couponCode.isEmpty) {
                            showCustomSnackBar('enter_a_coupon_code'.tr);
                          }
                        } else {
                          totalPrice = totalPrice + couponController.discount!;
                          couponController.removeCouponData(true);
                          widget.checkoutController.couponController.text = '';
                          if (widget.checkoutController.isPartialPay ||
                              widget.checkoutController.paymentMethodIndex ==
                                  1) {
                            widget.checkoutController.checkBalanceStatus(
                              totalPrice,
                            );
                          }
                        }
                      },
                      child: Container(
                        height: 45,
                        width:
                            (couponController.discount! <= 0 &&
                                !couponController.freeDelivery)
                            ? 100
                            : 50,
                        alignment: Alignment.center,
                        margin: const EdgeInsets.all(
                          Dimensions.paddingSizeExtraSmall,
                        ),
                        decoration: BoxDecoration(
                          color:
                              (couponController.discount! <= 0 &&
                                  !couponController.freeDelivery)
                              ? Theme.of(context).primaryColor
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(
                            Dimensions.radiusDefault,
                          ),
                        ),
                        child:
                            (couponController.discount! <= 0 &&
                                !couponController.freeDelivery)
                            ? !couponController.isLoading
                                  ? Text(
                                      'apply'.tr,
                                      style: robotoMedium.copyWith(
                                        color: Colors.white,
                                      ),
                                    )
                                  : const SizedBox(
                                      height: 30,
                                      width: 30,
                                      child: CircularProgressIndicator(
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    )
                            : Icon(
                                Icons.clear,
                                color: Theme.of(context).colorScheme.error,
                              ),
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child:
                    _availableCouponList != null &&
                        _availableCouponList!.isNotEmpty
                    ? SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: Dimensions.paddingSizeSmall,
                        ),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                left: Dimensions.paddingSizeDefault,
                                right: Dimensions.paddingSizeDefault,
                                top: Dimensions.paddingSizeDefault,
                                bottom: Dimensions.paddingSizeSmall,
                              ),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'available_promo_for_this_order'.tr,
                                  style: robotoBold.copyWith(
                                    fontSize: Dimensions.fontSizeDefault,
                                  ),
                                ),
                              ),
                            ),

                            GridView.builder(
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 1,
                                    mainAxisSpacing:
                                        Dimensions.paddingSizeSmall,
                                    crossAxisSpacing:
                                        Dimensions.paddingSizeSmall,
                                    childAspectRatio: 3,
                                  ),
                              itemCount: _availableCouponList!.length,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              padding: const EdgeInsets.all(
                                Dimensions.paddingSizeDefault,
                              ),
                              itemBuilder: (context, index) {
                                return InkWell(
                                  onTap: () {
                                    if (_availableCouponList![index].code !=
                                        null) {
                                      widget
                                          .checkoutController
                                          .couponController
                                          .text = _availableCouponList![index]
                                          .code
                                          .toString();
                                    }
                                    if (widget
                                        .checkoutController
                                        .couponController
                                        .text
                                        .isNotEmpty) {
                                      if (couponController.discount! < 1 &&
                                          !couponController.freeDelivery) {
                                        if (widget
                                                .checkoutController
                                                .couponController
                                                .text
                                                .isNotEmpty &&
                                            !couponController.isLoading) {
                                          couponController
                                              .applyCoupon(
                                                widget
                                                    .checkoutController
                                                    .couponController
                                                    .text,
                                                (widget.price -
                                                        widget.discount) +
                                                    widget.addOns,
                                                widget.deliveryCharge,
                                                widget.charge,
                                                totalPrice,
                                                Get.find<RestaurantController>()
                                                    .restaurant!
                                                    .id,
                                                hideBottomSheet: true,
                                              )
                                              .then((discount) {
                                                widget
                                                        .checkoutController
                                                        .couponController
                                                        .text =
                                                    '${widget.checkoutController.couponController.text}(${couponController.freeDelivery ? 'free_delivery'.tr : PriceConverter.convertPrice(couponController.discount)})';
                                                if (discount! > 0) {
                                                  // orderController.couponController.text = 'coupon_applied'.tr;
                                                  showCustomSnackBar(
                                                    '${'you_got_discount_of'.tr} ${PriceConverter.convertPrice(discount)}',
                                                    isError: false,
                                                  );
                                                  if (widget
                                                          .checkoutController
                                                          .isPartialPay ||
                                                      widget
                                                              .checkoutController
                                                              .paymentMethodIndex ==
                                                          1) {
                                                    // totalPrice = totalPrice - discount;
                                                    widget.checkoutController
                                                        .checkBalanceStatus(
                                                          totalPrice,
                                                          discount: discount,
                                                        );
                                                  }
                                                } else {
                                                  if (widget
                                                          .checkoutController
                                                          .isPartialPay ||
                                                      widget
                                                              .checkoutController
                                                              .paymentMethodIndex ==
                                                          1) {
                                                    widget.checkoutController
                                                        .checkBalanceStatus(
                                                          totalPrice,
                                                        );
                                                  }
                                                }
                                              });
                                        } else if (widget
                                            .checkoutController
                                            .couponController
                                            .text
                                            .isEmpty) {
                                          showCustomSnackBar(
                                            'enter_a_coupon_code'.tr,
                                          );
                                        }
                                      } else {
                                        totalPrice =
                                            totalPrice +
                                            couponController.discount!;
                                        couponController.removeCouponData(true);
                                        widget
                                                .checkoutController
                                                .couponController
                                                .text =
                                            '';
                                        if (widget
                                                .checkoutController
                                                .isPartialPay ||
                                            widget
                                                    .checkoutController
                                                    .paymentMethodIndex ==
                                                1) {
                                          widget.checkoutController
                                              .checkBalanceStatus(totalPrice);
                                        }
                                      }
                                    }
                                  },
                                  child: CouponCardWidget(
                                    toolTipController:
                                        _availableToolTipControllerList,
                                    couponList: _availableCouponList,
                                    index: index,
                                    onCopyClick: () {
                                      if (_availableCouponList![index].code !=
                                          null) {
                                        widget
                                            .checkoutController
                                            .couponController
                                            .text = _availableCouponList![index]
                                            .code
                                            .toString();
                                      }
                                    },
                                  ),
                                );
                              },
                            ),

                            _unavailableCouponList != null &&
                                    _unavailableCouponList!.isNotEmpty
                                ? Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: Dimensions.paddingSizeDefault,
                                      vertical: Dimensions.paddingSizeSmall,
                                    ),
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        'unavailable_promo'.tr,
                                        style: robotoBold.copyWith(
                                          fontSize: Dimensions.fontSizeDefault,
                                        ),
                                      ),
                                    ),
                                  )
                                : const SizedBox(),

                            _unavailableCouponList != null &&
                                    _unavailableCouponList!.isNotEmpty
                                ? GridView.builder(
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 1,
                                          mainAxisSpacing:
                                              Dimensions.paddingSizeSmall,
                                          crossAxisSpacing:
                                              Dimensions.paddingSizeSmall,
                                          childAspectRatio: 3,
                                        ),
                                    itemCount: _unavailableCouponList!.length,
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    padding: const EdgeInsets.all(
                                      Dimensions.paddingSizeDefault,
                                    ),
                                    itemBuilder: (context, index) {
                                      return CouponCardWidget(
                                        unavailable: true,
                                        toolTipController:
                                            _unavailableToolTipControllerList,
                                        couponList: _unavailableCouponList,
                                        index: index,
                                        onCopyClick: () {},
                                      );
                                    },
                                  )
                                : const SizedBox(),
                          ],
                        ),
                      )
                    : Column(
                        children: [
                          Image.asset(Images.noCoupon, height: 70),
                          const SizedBox(height: Dimensions.paddingSizeSmall),

                          Text('no_promo_available'.tr, style: robotoMedium),
                          const SizedBox(
                            height: Dimensions.paddingSizeExtraSmall,
                          ),

                          Text(
                            '${'please_add_manually_or_collect_promo_from'.tr} ${'your_business_name'.tr}',
                            style: robotoMedium.copyWith(
                              fontSize: Dimensions.fontSizeSmall,
                              color: Theme.of(context).disabledColor,
                            ),
                          ),
                          const SizedBox(height: 50),
                        ],
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
