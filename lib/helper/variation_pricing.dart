import 'package:lestar_user/common/models/product_model.dart';

/// optionPrice remains an additive delta, including pricing_mode == full.
class VariationPricing {
  static bool hasFullPrice(Product product) =>
      product.variations?.any((group) => group.isFullPrice) ?? false;

  static double fullDelta(Product product, List<List<bool?>>? selected) {
    double total = 0;
    final groups = product.variations ?? <Variation>[];
    for (int g = 0; g < groups.length; g++) {
      if (!groups[g].isFullPrice) continue;
      final values = groups[g].variationValues ?? <VariationValue>[];
      for (int v = 0; v < values.length; v++) {
        if (_selected(selected, g, v)) total += values[v].optionPrice ?? 0;
      }
    }
    return total;
  }

  static double itemPrice(Product product, List<List<bool?>>? selected) =>
      (product.price ?? 0) + fullDelta(product, selected);

  static double optionPrice(
    Product product,
    Variation group,
    VariationValue value,
  ) => (value.optionPrice ?? 0) + (group.isFullPrice ? product.price ?? 0 : 0);

  static double startingPrice(Product product) {
    double price = product.price ?? 0;
    for (final group in product.variations ?? <Variation>[]) {
      if (!group.isFullPrice || (group.variationValues?.isEmpty ?? true)) {
        continue;
      }
      price += group.variationValues!
          .map((value) => value.optionPrice ?? 0)
          .reduce((a, b) => a < b ? a : b);
    }
    return price;
  }

  /// Returns the group that needs a new selection, including stale stock.
  static String? invalidFullSelection(
    Product product,
    List<List<bool?>>? selected, {
    int quantity = 1,
  }) {
    final groups = product.variations ?? <Variation>[];
    for (int g = 0; g < groups.length; g++) {
      if (!groups[g].isFullPrice) continue;
      final values = groups[g].variationValues ?? <VariationValue>[];
      int count = 0;
      for (int v = 0; v < values.length; v++) {
        if (!_selected(selected, g, v)) continue;
        count++;
        if (values[v].stockType != null &&
            values[v].stockType != 'unlimited' &&
            values[v].currentStock != null &&
            values[v].currentStock! < quantity) {
          return groups[g].name ?? '';
        }
      }
      if (count != 1) return groups[g].name ?? '';
    }
    return null;
  }

  static List<List<bool?>> remapSelections(
    Product oldProduct,
    List<List<bool?>>? selected,
    Product current,
  ) {
    final oldGroups = oldProduct.variations ?? <Variation>[];
    return (current.variations ?? <Variation>[]).map((group) {
      return (group.variationValues ?? <VariationValue>[]).map<bool?>((value) {
        for (int g = 0; g < oldGroups.length; g++) {
          final oldValues = oldGroups[g].variationValues ?? <VariationValue>[];
          for (int v = 0; v < oldValues.length; v++) {
            if (!_selected(selected, g, v)) continue;
            if (value.optionId != null && oldValues[v].optionId != null) {
              if (value.optionId == oldValues[v].optionId) return true;
            } else if (group.name == oldGroups[g].name &&
                value.level == oldValues[v].level) {
              return true;
            }
          }
        }
        return false;
      }).toList();
    }).toList();
  }

  static bool _selected(List<List<bool?>>? selected, int group, int value) =>
      selected != null &&
      group < selected.length &&
      value < selected[group].length &&
      selected[group][value] == true;
}
