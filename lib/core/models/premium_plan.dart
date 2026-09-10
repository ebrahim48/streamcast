import 'package:flutter/foundation.dart';

/// A purchasable subscription tier.
@immutable
class PremiumPlan {
  const PremiumPlan({
    required this.id,
    required this.label,
    required this.price,
    required this.period,
    this.isPopular = false,
  });

  /// Stored in `sc_premium_plan` — `weekly` | `monthly` | `yearly`.
  final String id;

  /// Card heading, e.g. "Monthly".
  final String label;

  /// Formatted price, e.g. "$6.99".
  final String price;

  /// Billing unit as displayed, e.g. "/month".
  final String period;

  /// Draws the amber border and the "Most Popular" tab.
  final bool isPopular;
}
