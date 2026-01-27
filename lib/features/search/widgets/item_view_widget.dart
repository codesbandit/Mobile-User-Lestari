import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lestar_user/common/widgets/footer_view_widget.dart';
import 'package:lestar_user/common/widgets/product_view_widget.dart';
import 'package:lestar_user/features/search/controllers/search_controller.dart'
    as search;
import 'package:lestar_user/util/dimensions.dart';

class ItemViewWidget extends StatelessWidget {
  final bool isRestaurant;
  final ScrollController scrollController;
  const ItemViewWidget({
    super.key,
    required this.isRestaurant,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<search.SearchController>(
        builder: (searchController) {
          return SingleChildScrollView(
            controller: scrollController,
            child: FooterViewWidget(
              child: Center(
                child: SizedBox(
                  width: Dimensions.webMaxWidth,
                  child: Column(
                    children: [
                      ProductViewWidget(
                        isRestaurant: isRestaurant,
                        products: searchController.searchProductList,
                        restaurants: searchController.searchRestList,
                        noDataText: isRestaurant
                            ? 'no_restaurant_found'.tr
                            : 'no_food_found'.tr,
                        fromSearch: true,
                      ),

                      searchController.paginate
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  bottom: Dimensions.paddingSizeExtraOverLarge,
                                ),
                                child: CircularProgressIndicator(),
                              ),
                            )
                          : const SizedBox(),
                    ],
                  ),
                  // child: PaginatedListViewWidget(
                  //   scrollController: scrollController,
                  //   totalSize: searchController.totalSize,
                  //   offset: searchController.pageOffset,
                  //   onPaginate: (int? offset) async => searchController.searchData1(searchController.searchText, offset!),
                  //   productView: ProductViewWidget(
                  //     isRestaurant: isRestaurant, products: searchController.searchProductList, restaurants: searchController.searchRestList,
                  //     noDataText: isRestaurant ? 'no_restaurant_found'.tr : 'no_food_found'.tr,
                  //     fromSearch: true,
                  //   ),
                  // ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
