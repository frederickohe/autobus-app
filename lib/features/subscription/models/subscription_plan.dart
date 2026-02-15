import 'package:autobus/barrel.dart';

class BillingOption extends Equatable {
  final String id;
  final String label;
  final String subtitle;
  final double priceUsd;

  const BillingOption({
    required this.id,
    required this.label,
    required this.subtitle,
    required this.priceUsd,
  });

  factory BillingOption.fromJson(Map<String, dynamic> json) {
    return BillingOption(
      id: (json['id'] ?? '').toString(),
      label: (json['label'] ?? '').toString(),
      subtitle: (json['subtitle'] ?? '').toString(),
      priceUsd: (json['priceUsd'] is num)
          ? (json['priceUsd'] as num).toDouble()
          : double.tryParse((json['priceUsd'] ?? '0').toString()) ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'subtitle': subtitle,
        'priceUsd': priceUsd,
      };

  @override
  List<Object?> get props => [id, label, subtitle, priceUsd];
}

class SubscriptionPlan extends Equatable {
  final String id;
  final String name;
  final String priceText;
  final List<String> features;
  final List<BillingOption> billing;

  const SubscriptionPlan({
    required this.id,
    required this.name,
    required this.priceText,
    required this.features,
    required this.billing,
  });

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlan(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      priceText: (json['priceText'] ?? '').toString(),
      features: ((json['features'] as List?) ?? const [])
          .map((e) => e.toString())
          .toList(),
      billing: ((json['billing'] as List?) ?? const [])
          .map((e) => BillingOption.fromJson((e as Map).cast<String, dynamic>()))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'priceText': priceText,
        'features': features,
        'billing': billing.map((b) => b.toJson()).toList(),
      };

  @override
  List<Object?> get props => [id, name, priceText, features, billing];
}
