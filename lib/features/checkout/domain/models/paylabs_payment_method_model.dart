class PaylabsPaymentMethodModel {
  final String paymentType;
  final String displayName;
  final String category;
  final String? logoUrl;
  final bool isMaintenance;
  final String? maintenanceNote;
  final double minAmount;
  final double maxAmount;

  PaylabsPaymentMethodModel({
    required this.paymentType,
    required this.displayName,
    required this.category,
    this.logoUrl,
    this.isMaintenance = false,
    this.maintenanceNote,
    this.minAmount = 10000,
    this.maxAmount = 100000000,
  });

  factory PaylabsPaymentMethodModel.fromJson(Map<String, dynamic> json) {
    return PaylabsPaymentMethodModel(
      paymentType: json['payment_type'] ?? '',
      displayName: json['display_name'] ?? '',
      category: json['category'] ?? '',
      logoUrl: json['logo_url'],
      isMaintenance: json['is_maintenance'] == true,
      maintenanceNote: json['maintenance_note'],
      minAmount: (json['min_amount'] ?? 10000).toDouble(),
      maxAmount: (json['max_amount'] ?? 100000000).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'payment_type': paymentType,
      'display_name': displayName,
      'category': category,
      'logo_url': logoUrl,
      'is_maintenance': isMaintenance,
      'maintenance_note': maintenanceNote,
      'min_amount': minAmount,
      'max_amount': maxAmount,
    };
  }
}
