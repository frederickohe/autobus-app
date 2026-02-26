import 'package:autobus/barrel.dart';

class BillingOption extends Equatable {
  final String id;
  final String label;
  final String subtitle;
  final double price;

  const BillingOption({
    required this.id,
    required this.label,
    required this.subtitle,
    required this.price,
  });

  @override
  List<Object?> get props => [id, label, subtitle, price];
}

class SubscriptionPlan extends Equatable {
  final int id;
  final String name;
  final double price;
  final List<String> features;
  final String description;
  final bool isActive;

  const SubscriptionPlan({
    required this.id,
    required this.name,
    required this.price,
    required this.features,
    required this.description,
    required this.isActive,
  });

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlan(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse((json['id'] ?? '0').toString()) ?? 0,
      name: (json['name'] ?? '').toString(),
      price: (json['price'] is num)
          ? (json['price'] as num).toDouble()
          : double.tryParse((json['price'] ?? '0').toString()) ?? 0,
      features: ((json['features'] as List?) ?? [])
          .map((e) => e.toString())
          .toList(),
      description: (json['description'] ?? '').toString(),
      isActive: json['is_active'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'features': features,
      'description': description,
      'is_active': isActive,
    };
  }

  List<BillingOption> get billing => [
    BillingOption(
      id: 'monthly',
      label: 'Monthly',
      subtitle: 'per month',
      price: price,
    ),
    BillingOption(
      id: 'annual',
      label: 'Annual',
      subtitle: 'per year',
      price: _annualPrice,
    ),
  ];

  double get _annualPrice =>
      double.parse((price * 12 * 0.8).toStringAsFixed(2));

  String get priceText => price == 0 ? 'Free' : 'from GHS $price/mo';

  @override
  List<Object?> get props => [id, name, price, features, description, isActive];
}
