import 'package:autobus/barrel.dart';

import 'data/subscription_catalog.dart';
import 'models/subscription_plan.dart';

class SelectPlan extends StatefulWidget {
  const SelectPlan({super.key});

  @override
  State<SelectPlan> createState() => _SelectPlanState();
}

class _SelectPlanState extends State<SelectPlan> with TickerProviderStateMixin {
  late final List<SubscriptionPlan> _plans;
  String? _expandedPlanId;
  String? _selectedPlanId;

  @override
  void initState() {
    super.initState();
    _plans = SubscriptionCatalog.loadPlans();
  }

  SubscriptionPlan? get _selectedPlan {
    final id = _selectedPlanId;
    if (id == null) return null;
    return _plans.where((p) => p.id == id).firstOrNull;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _GradientBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 10),
                _HeaderLogo(),

                const SizedBox(height: 22),
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          const SizedBox(height: 34),
                          Text(
                            'User Type',
                            style: GoogleFonts.imprima(
                              color: Colors.white,
                              fontSize: 30,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Select a user type',
                            style: GoogleFonts.imprima(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(height: 8),
                          for (final plan in _plans) ...[
                            Center(
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth: 400,
                                ),
                                child: _PlanExpandableTile(
                                  plan: plan,
                                  expanded: _expandedPlanId == plan.id,
                                  selected: _selectedPlanId == plan.id,
                                  onTap: () {
                                    setState(() {
                                      final isExpanding =
                                          _expandedPlanId != plan.id;
                                      _expandedPlanId = isExpanding
                                          ? plan.id
                                          : null;
                                      _selectedPlanId = plan.id;
                                    });
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                          ],
                          const SizedBox(height: 18),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                _BottomCta(
                  label: 'Next',
                  enabled: _selectedPlan != null,
                  onPressed: () {
                    final selected = _selectedPlan;
                    if (selected == null) return;
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => SubscriptionBillPage(plan: selected),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PlanExpandableTile extends StatelessWidget {
  final SubscriptionPlan plan;
  final bool expanded;
  final bool selected;
  final VoidCallback onTap;

  const _PlanExpandableTile({
    required this.plan,
    required this.expanded,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = Colors.white.withOpacity(selected ? 0.95 : 0.55);

    return AnimatedSize(
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeInOut,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeInOut,
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: 18,
            vertical: expanded ? 18 : 20,
          ),
          decoration: BoxDecoration(
            color: expanded ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: borderColor, width: 1),
          ),
          child: expanded
              ? _ExpandedPlanContent(plan: plan)
              : Center(
                  child: Text(
                    plan.name,
                    style: GoogleFonts.imprima(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}

class _ExpandedPlanContent extends StatelessWidget {
  final SubscriptionPlan plan;
  const _ExpandedPlanContent({required this.plan});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          plan.name,
          style: GoogleFonts.imprima(
            color: CustColors.mainCol,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          plan.priceText,
          style: GoogleFonts.imprima(
            color: CustColors.mainCol,
            fontSize: 34,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 14),
        for (final f in plan.features) ...[
          Row(
            children: [
              Container(
                height: 18,
                width: 18,
                decoration: BoxDecoration(
                  color: CustColors.mainCol,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.check, size: 12, color: Colors.white),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  f,
                  style: GoogleFonts.imprima(
                    color: CustColors.mainCol.withOpacity(0.85),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _BottomCta extends StatelessWidget {
  final String label;
  final bool enabled;
  final VoidCallback onPressed;

  const _BottomCta({
    required this.label,
    required this.enabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.55,
      child: IgnorePointer(
        ignoring: !enabled,
        child: GestureDetector(
          onTap: onPressed,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.6,
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(40),
              border: Border.all(color: Colors.white.withOpacity(0.7)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 34),
                Text(
                  label,
                  style: GoogleFonts.imprima(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Row(
                  children: const [
                    Icon(Icons.chevron_right, color: Colors.white, size: 18),
                    Icon(Icons.chevron_right, color: Colors.white54, size: 18),
                    Icon(Icons.chevron_right, color: Colors.white38, size: 18),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HeaderLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          height: 34,
          width: 34,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFF9C27B0),
          ),
        ),
        Transform.translate(
          offset: const Offset(-12, 0),
          child: Container(
            height: 34,
            width: 34,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF6A1B9A),
            ),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          'Autobus',
          style: GoogleFonts.imprima(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _GradientBackground extends StatelessWidget {
  final Widget child;
  const _GradientBackground({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF130522), Color(0xFF2D0C51), Color(0xFF130522)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: child,
    );
  }
}

extension _FirstOrNullExtension<E> on Iterable<E> {
  E? get firstOrNull => isEmpty ? null : first;
}
