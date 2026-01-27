import 'package:flutter/material.dart';
import 'package:lestar_user/features/home/widgets/restaurants_view_widget.dart';
import 'package:lestar_user/util/dimensions.dart';

class DineInRestaurantShimmerWidget extends StatelessWidget {
  const DineInRestaurantShimmerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 10,
      physics: NeverScrollableScrollPhysics(),
      padding: EdgeInsets.all(Dimensions.paddingSizeLarge),
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
          child: SizedBox(
            height: 195,
            child: WebRestaurantShimmer(isDineInRestaurant: true),
          ),
        );
      },
    );
  }
}
