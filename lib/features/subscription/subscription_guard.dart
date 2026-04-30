import 'package:autobus/barrel.dart';

import 'services/subscription_storage.dart';
import 'userplan.dart';

class SubscriptionGuard extends StatelessWidget {
  final Map<String, dynamic> user;

  const SubscriptionGuard({required this.user, super.key});

  static String _extractEmail(Map<String, dynamic> u) {
    final v = u['email'] ?? u['user_email'] ?? u['userEmail'] ?? '';
    return v.toString();
  }

  static bool _truthy(dynamic v) {
    if (v == null) return false;
    if (v is bool) return v;
    if (v is num) return v != 0;
    if (v is String) {
      final s = v.trim().toLowerCase();
      return s == 'true' || s == '1' || s == 'yes' || s == 'active';
    }
    return false;
  }

  static bool _isSubscribedFromUser(Map<String, dynamic> user) {
    const directFlags = [
      'is_subscribed',
      'subscribed',
      'has_subscription',
      'hasSubscription',
      'subscription_active',
      'subscriptionActive',
      'active_subscription',
      'activeSubscription',
      'is_premium',
      'premium',
      'paid',
    ];

    for (final k in directFlags) {
      if (_truthy(user[k])) return true;
    }

    const directIds = [
      'plan_id',
      'planId',
      'subscription_plan_id',
      'subscriptionPlanId',
      'active_plan_id',
      'activePlanId',
    ];
    for (final k in directIds) {
      final v = user[k];
      if (v != null && v.toString().trim().isNotEmpty) return true;
    }

    final nestedCandidates = [
      user['subscription'],
      user['plan'],
      user['current_plan'],
      user['currentPlan'],
      user['active_subscription'],
      user['activeSubscription'],
    ];
    for (final c in nestedCandidates) {
      if (c is Map) {
        final m = Map<String, dynamic>.from(c);
        if (_truthy(m['active']) ||
            _truthy(m['is_active']) ||
            _truthy(m['isActive']) ||
            _truthy(m['status'])) {
          return true;
        }
        if (m['plan_id'] != null || m['planId'] != null) return true;
      }
    }

    return false;
  }

  Future<({bool subscribed, String email})> _resolve(
    BuildContext context,
  ) async {
    var resolvedEmail = _extractEmail(user);

    // 1) Prefer server truth (if backend already includes subscription fields).
    try {
      final latest = await context.read<ApiService>().getUserProfile();
      resolvedEmail = _extractEmail(latest).isNotEmpty
          ? _extractEmail(latest)
          : resolvedEmail;

      if (_isSubscribedFromUser(latest)) {
        return (subscribed: true, email: resolvedEmail);
      }
    } catch (_) {
      // Fall back to local cache below.
    }

    // 2) Fallback: if the app previously completed a subscribe flow on this
    // device, it stores the selection.
    final (planId, _) = await SubscriptionStorage().loadSelection();
    final subscribed = planId != null && planId.trim().isNotEmpty;
    return (subscribed: subscribed, email: resolvedEmail);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<({bool subscribed, String email})>(
      future: _resolve(context),
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final data = snap.data;
        final subscribed = data?.subscribed == true;
        if (subscribed) return const Welcome();

        return SelectPlan(userEmail: data?.email ?? '');
      },
    );
  }
}

