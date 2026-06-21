import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lestar_user/features/checkout/controllers/checkout_controller.dart';
import 'package:lestar_user/features/checkout/domain/models/paylabs_payment_method_model.dart';
import 'package:lestar_user/util/dimensions.dart';
import 'package:lestar_user/util/styles.dart';

class PaylabsPaymentMethodsWidget extends StatelessWidget {
  final bool disablePayments;
  final bool isSubscriptionPackage;

  const PaylabsPaymentMethodsWidget({
    super.key,
    this.disablePayments = false,
    this.isSubscriptionPackage = false,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CheckoutController>(
      builder: (checkoutController) {
        final methods = checkoutController.paylabsPaymentMethods;

        if (methods == null || methods.isEmpty) {
          return const SizedBox();
        }

        final List<PaylabsPaymentMethodModel> ewallets = methods
            .where((PaylabsPaymentMethodModel m) => m.category == 'ewallet')
            .toList();
        final List<PaylabsPaymentMethodModel> qris = methods
            .where((PaylabsPaymentMethodModel m) => m.category == 'qris')
            .toList();
        final List<PaylabsPaymentMethodModel> vas = methods
            .where((PaylabsPaymentMethodModel m) => m.category == 'va')
            .toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (ewallets.isNotEmpty) ...[
              _sectionTitle(context, 'Pembayaran Instan'),
              const SizedBox(height: Dimensions.paddingSizeExtraSmall),
              ...ewallets.map(
                (PaylabsPaymentMethodModel m) =>
                    _methodItem(context, m, checkoutController),
              ),
            ],
            if (qris.isNotEmpty) ...[
              const SizedBox(height: Dimensions.paddingSizeSmall),
              _sectionTitle(context, 'QRIS'),
              const SizedBox(height: Dimensions.paddingSizeExtraSmall),
              ...qris.map(
                (PaylabsPaymentMethodModel m) =>
                    _methodItem(context, m, checkoutController),
              ),
            ],
            if (vas.isNotEmpty) ...[
              const SizedBox(height: Dimensions.paddingSizeSmall),
              _sectionTitle(context, 'Virtual Account'),
              const SizedBox(height: Dimensions.paddingSizeExtraSmall),
              ...vas.map(
                (PaylabsPaymentMethodModel m) =>
                    _methodItem(context, m, checkoutController),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _sectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 4,
        top: Dimensions.paddingSizeExtraSmall,
      ),
      child: Text(
        title,
        style: robotoMedium.copyWith(
          fontSize: Dimensions.fontSizeSmall,
          color: Theme.of(context).disabledColor,
        ),
      ),
    );
  }

  Widget _methodItem(
    BuildContext context,
    PaylabsPaymentMethodModel method,
    CheckoutController controller,
  ) {
    final bool isSelected =
        controller.paymentMethodIndex == 2 &&
        controller.digitalPaymentName == 'paylabs' &&
        controller.paylabsSelectedPaymentType == method.paymentType;

    final bool isMaintenance = method.isMaintenance;
    final bool isDisabled = disablePayments || isMaintenance;

    return Padding(
      padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeExtraSmall),
      child: InkWell(
        onTap: isDisabled
            ? null
            : () {
                controller.setPaymentMethod(2);
                controller.changeDigitalPaymentName('paylabs');
                controller.selectPaylabsPaymentType(method.paymentType);
              },
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
        child: Opacity(
          opacity: isDisabled ? 0.5 : 1.0,
          child: Container(
            padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
              border: Border.all(
                color: isSelected
                    ? Theme.of(context).primaryColor.withValues(alpha: 0.3)
                    : Theme.of(context).disabledColor.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                if (method.logoUrl != null && method.logoUrl!.isNotEmpty)
                  Image.network(
                    method.logoUrl!,
                    height: 20,
                    width: 20,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) =>
                        _logoFallback(context, method),
                  )
                else
                  _logoFallback(context, method),
                const SizedBox(width: Dimensions.paddingSizeSmall),

                Expanded(
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          method.displayName,
                          style: robotoMedium.copyWith(
                            fontSize: Dimensions.fontSizeSmall,
                            color: isDisabled
                                ? Theme.of(context).disabledColor
                                : Theme.of(context).textTheme.bodyLarge!.color,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isMaintenance) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Colors.red.shade200,
                              width: 0.5,
                            ),
                          ),
                          child: Text(
                            'Gangguan',
                            style: robotoMedium.copyWith(
                              fontSize: 9,
                              color: Colors.red.shade700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                Icon(
                  isSelected ? Icons.check_circle : Icons.circle_outlined,
                  size: 24,
                  color: isSelected
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).disabledColor.withValues(alpha: 0.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _logoFallback(BuildContext context, PaylabsPaymentMethodModel method) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: Theme.of(context).disabledColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      alignment: Alignment.center,
      child: Text(
        method.displayName.substring(
          0,
          method.displayName.length > 2 ? 2 : method.displayName.length,
        ),
        style: robotoMedium.copyWith(
          fontSize: 8,
          color: Theme.of(context).disabledColor,
        ),
      ),
    );
  }
}
