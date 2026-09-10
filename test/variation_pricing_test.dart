import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:lestar_user/common/models/product_model.dart';
import 'package:lestar_user/common/models/online_cart_model.dart'
    show OnlineCartModel;
import 'package:lestar_user/features/auth/controllers/auth_controller.dart';
import 'package:lestar_user/common/models/restaurant_model.dart';
import 'package:lestar_user/features/cart/controllers/cart_controller.dart';
import 'package:lestar_user/features/cart/domain/models/cart_model.dart';
import 'package:lestar_user/features/cart/domain/repositories/cart_repository_interface.dart';
import 'package:lestar_user/features/cart/domain/services/cart_service.dart';
import 'package:lestar_user/features/restaurant/controllers/restaurant_controller.dart';
import 'package:lestar_user/features/splash/controllers/splash_controller.dart';
import 'package:lestar_user/helper/cart_helper.dart';
import 'package:lestar_user/helper/variation_pricing.dart';

class UnusedRepository implements CartRepositoryInterface {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class TestAuth extends GetxController implements AuthController {
  @override
  bool isLoggedIn() => true;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class RefreshService extends CartService {
  final List<CartModel> carts;
  final bool fail;
  RefreshService(this.carts, {this.fail = false})
    : super(cartRepositoryInterface: UnusedRepository());
  @override
  Future<List<OnlineCartModel>> getCartDataOnline(String? id) async {
    if (fail) throw StateError('Offline');
    return [];
  }

  @override
  List<CartModel> formatOnlineCartToLocalCart({
    required List<OnlineCartModel> onlineCartModel,
  }) => carts;
}

class TestRestaurant extends GetxController implements RestaurantController {
  Restaurant? value;
  @override
  Restaurant? get restaurant => value;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class TestSplash extends GetxController implements SplashController {
  @override
  DateTime get currentTime => DateTime(2026, 9, 10, 12);
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Variation sizeGroup({String mode = 'full'}) => Variation.fromJson({
  'name': 'Ukuran',
  'pricing_mode': mode,
  'type': 'single',
  'required': 'on',
  'min': '0',
  'max': '0',
  'values': [
    {
      'label': '500 gram',
      'optionPrice': 0,
      'option_id': 11,
      'stock_type': 'unlimited',
    },
    {
      'label': 'Premium 1 kg',
      'optionPrice': 18500,
      'option_id': 12,
      'stock_type': 'unlimited',
    },
  ],
});

Product product({
  String mode = 'full',
  double discount = 0,
  String discountType = 'percent',
}) => Product(
  id: 1,
  price: 20000,
  discount: discount,
  discountType: discountType,
  restaurantDiscount: 0,
  addOns: [],
  variations: [
    sizeGroup(mode: mode),
    Variation(
      name: 'Tambahan',
      variationValues: [VariationValue(level: 'Box', optionPrice: 2000)],
    ),
  ],
);

CartModel cart(Product p, {int quantity = 1}) => CartModel(
  1,
  40500,
  40500,
  0,
  quantity,
  [],
  [],
  false,
  p,
  [
    [false, true],
    [true],
  ],
  null,
  [],
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    Get.testMode = true;
    Get.put<AuthController>(TestAuth());
    Get.put<SplashController>(TestSplash());
    Get.put<RestaurantController>(TestRestaurant());
  });
  tearDown(() => Get.reset());

  test('full price adds the delta once and leaves toppings separate', () {
    final p = product();
    expect(
      VariationPricing.itemPrice(p, [
        [false, true],
        [true],
      ]),
      38500,
    );
    expect(
      VariationPricing.fullDelta(p, [
        [false, true],
        [true],
      ]),
      18500,
    );
    expect(
      VariationPricing.optionPrice(
        p,
        p.variations![0],
        p.variations![0].variationValues![1],
      ),
      38500,
    );
    expect(
      VariationPricing.optionPrice(
        p,
        p.variations![1],
        p.variations![1].variationValues![0],
      ),
      2000,
    );
  });

  test('legacy missing/unknown mode remains additional', () {
    final json = sizeGroup().toJson()..remove('pricing_mode');
    expect(Variation.fromJson(json).isFullPrice, false);
    expect(
      Variation.fromJson({...json, 'pricing_mode': 'future'}).isFullPrice,
      false,
    );
    expect(
      VariationPricing.itemPrice(product(mode: 'additional'), [
        [false, true],
        [true],
      ]),
      20000,
    );
  });

  test(
    'cached model round trip preserves mode, required and selection type',
    () {
      final restored = Variation.fromJson(sizeGroup().toJson());
      expect(restored.isFullPrice, true);
      expect(restored.required, true);
      expect(restored.multiSelect, false);
      expect(restored.variationValues![1].optionPrice, 18500);
    },
  );

  test('starting price uses cheapest full choice even with a lower base', () {
    final p = product()..price = 19000;
    p.variations![0].variationValues![0].optionPrice = 1000;
    expect(VariationPricing.startingPrice(p), 20000);
  });

  test('missing, double, and out of stock selections are rejected', () {
    final p = product();
    expect(VariationPricing.invalidFullSelection(p, []), 'Ukuran');
    expect(
      VariationPricing.invalidFullSelection(p, [
        [true, true],
      ]),
      'Ukuran',
    );
    expect(
      VariationPricing.invalidFullSelection(p, [
        [false, true],
      ]),
      null,
    );
    p.variations![0].variationValues![1].stockType = 'fixed';
    p.variations![0].variationValues![1].currentStock = 1;
    expect(
      VariationPricing.invalidFullSelection(p, [
        [false, true],
      ], quantity: 2),
      'Ukuran',
    );
  });

  test('editing a reordered cart follows IDs, not indices', () {
    final old = product();
    final current = product();
    current.variations![0].variationValues = current
        .variations![0]
        .variationValues!
        .reversed
        .toList();
    final selected = VariationPricing.remapSelections(old, [
      [false, true],
      [false],
    ], current);
    expect(selected[0], [true, false]);
    expect(VariationPricing.itemPrice(current, selected), 38500);
    current.variations![0].variationValues!.removeAt(0);
    expect(
      VariationPricing.invalidFullSelection(
        current,
        VariationPricing.remapSelections(old, [
          [false, true],
        ], current),
      ),
      'Ukuran',
    );
  });

  test('legacy choices without IDs remap by group and label', () {
    final old = product();
    final current = product();
    for (final value in old.variations![0].variationValues!) {
      value.optionId = null;
    }
    expect(
      VariationPricing.remapSelections(old, [
        [false, true],
      ], current)[0],
      [false, true],
    );
  });

  for (final entry in [
    (0.0, 'percent', 81000.0),
    (10.0, 'percent', 72900.0),
    (5000.0, 'amount', 71000.0),
  ]) {
    test(
      'cart totals and presentation agree for ${entry.$1} ${entry.$2}, quantity 2',
      () {
        final controller = CartController(
          cartServiceInterface: CartService(
            cartRepositoryInterface: UnusedRepository(),
          ),
        );
        controller.cartList.add(
          cart(
            product(discount: entry.$1, discountType: entry.$2),
            quantity: 2,
          ),
        );
        expect(controller.calculationCart(), entry.$3);
        expect(controller.displayItemPrice, 77000);
        expect(controller.displayVariationPrice, 4000);
        expect(
          controller.displayItemPrice +
              controller.displayVariationPrice +
              controller.addOns -
              controller.itemDiscountPrice,
          controller.subTotal,
        );
      },
    );
  }

  test('legacy cart totals and separate variation amount are unchanged', () {
    final controller = CartController(
      cartServiceInterface: CartService(
        cartRepositoryInterface: UnusedRepository(),
      ),
    );
    controller.cartList.add(cart(product(mode: 'additional')));
    expect(controller.calculationCart(), 40500);
    expect(controller.displayItemPrice, 20000);
    expect(controller.displayVariationPrice, 20500);
  });

  test('checkout payload still uses selected labels and option IDs', () {
    final p = product();
    final result = CartHelper.getSelectedVariations(
      productVariations: p.variations,
      selectedVariations: [
        [false, true],
        [false],
      ],
    );
    expect(result.$1.single.values!.label, ['Premium 1 kg']);
    expect(result.$2, [12]);
  });

  test('checkout snapshot detects price and selection changes', () {
    final c = cart(product());
    final before = CartController.pricingSnapshot([c]);
    c.product!.price = 21000;
    expect(CartController.pricingSnapshot([c]), isNot(before));
  });

  test('failed refresh preserves cart and releases loading state', () async {
    final saved = cart(product());
    final controller = CartController(
      cartServiceInterface: RefreshService([], fail: true),
    );
    controller.cartList.add(saved);
    expect(await controller.getCartDataOnline(), false);
    expect(controller.cartList.single, same(saved));
    expect(controller.isLoading, false);
  });

  for (final rule in [
    (5000.0, 0.0, 76000.0),
    (0.0, 80000.0, 72900.0),
    (0.0, 90000.0, 81000.0),
  ]) {
    test('restaurant discount limits update subtotal: $rule', () {
      (Get.find<RestaurantController>() as TestRestaurant).value = Restaurant(
        discount: Discount(maxDiscount: rule.$1, minPurchase: rule.$2),
      );
      final controller = CartController(
        cartServiceInterface: CartService(
          cartRepositoryInterface: UnusedRepository(),
        ),
      );
      controller.cartList.add(cart(product(discount: 10), quantity: 2));
      expect(controller.calculationCart(), rule.$3);
      expect(
        controller.displayItemPrice +
            controller.displayVariationPrice -
            controller.itemDiscountPrice,
        controller.subTotal,
      );
    });
  }

  test(
    'checkout accepts a freshly fetched unchanged valid selection',
    () async {
      final saved = cart(product());
      final controller = CartController(
        cartServiceInterface: RefreshService([saved]),
      );
      controller.cartList.add(saved);
      expect(
        await controller.validateCheckoutCart(expectedCart: [saved]),
        true,
      );
      expect(controller.subTotal, 40500);
    },
  );
}
