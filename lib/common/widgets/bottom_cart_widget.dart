import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lestar_user/common/models/restaurant_model.dart';
import 'package:lestar_user/common/widgets/custom_button_widget.dart';
import 'package:lestar_user/features/cart/controllers/cart_controller.dart';
import 'package:lestar_user/features/restaurant/controllers/restaurant_controller.dart';
import 'package:lestar_user/helper/price_converter.dart';
import 'package:lestar_user/helper/route_helper.dart';
import 'package:lestar_user/util/dimensions.dart';
import 'package:lestar_user/util/styles.dart';

class BottomCartWidget extends StatelessWidget {
  final int? restaurantId;
  final bool fromDineIn;
  const BottomCartWidget({super.key, this.restaurantId, this.fromDineIn = false});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CartController>(builder: (cartController) {
        return Container(
          height: GetPlatform.isIOS ? 100 : 70, width: Get.width,
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraLarge),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor, boxShadow: [BoxShadow(color: const Color(0xFF2A2A2A).withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, -5))],
          ),
          child: SafeArea(
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [

              Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                Text('${'item'.tr}: ${cartController.cartList.length}', style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault)),
                const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                Text(
                  '${'total'.tr}: ${PriceConverter.convertPrice(cartController.calculationCart())}',
                  style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).primaryColor),
                ),
              ]),

              CustomButtonWidget(buttonText: 'view_cart'.tr, width: 130, height: 45, onPressed: () async {
                await Get.toNamed(RouteHelper.getCartRoute(fromDineIn: fromDineIn));
                Get.find<RestaurantController>().makeEmptyRestaurant();
                if(restaurantId != null) {
                  Get.find<RestaurantController>().getRestaurantDetails(Restaurant(id: restaurantId));
                }
              })
            ]),
          ),
        );
      });
  }
}
