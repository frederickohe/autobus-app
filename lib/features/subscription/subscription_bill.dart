import 'package:autobus/barrel.dart';

import 'models/subscription_plan.dart';
import 'services/subscription_storage.dart';

class SubscriptionBillPage extends StatefulWidget {
  final SubscriptionPlan plan;

  const SubscriptionBillPage({required this.plan, super.key});

  @override
  State<SubscriptionBillPage> createState() => _SubscriptionBillPageState();
}

class _SubscriptionBillPageState extends State<SubscriptionBillPage> {
  late BillingOption _selected;
  final _storage = SubscriptionStorage();

  @override
  void initState() {
    super.initState();
    _selected = widget.plan.billing.first;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _GradientBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          'Subscription Bill',
                          style: GoogleFonts.imprima(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  '${widget.plan.name} \nAccount',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.imprima(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                    height: 1.05,
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  height: 62,
                  width: 62,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(31),
                  ),
                  child: const Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 12),
                const _AccountMeta(),
                const SizedBox(height: 22),
                _BillingSelector(
                  options: widget.plan.billing,
                  selectedId: _selected.id,
                  onSelect: (opt) => setState(() => _selected = opt),
                ),
                const Spacer(),
                _BottomCta(
                  label: 'Subscribe Now',
                  onPressed: () async {
                    await _storage.saveSelection(
                      planId: widget.plan.id,
                      billingId: _selected.id,
                    );
                    await _storage.savePlanSnapshot(widget.plan, _selected);

                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Saved: ${widget.plan.name} • ${_selected.label} ${_selected.subtitle}',
                        ),
                      ),
                    );
                    Navigator.of(context).pushReplacement(
                      PageTransition(
                        type: PageTransitionType.rightToLeftWithFade,
                        duration: const Duration(milliseconds: 1000),
                        reverseDuration: const Duration(milliseconds: 600),
                        child: const Signin(),
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

class _AccountMeta extends StatelessWidget {
  const _AccountMeta();

  @override
  Widget build(BuildContext context) {
    // Temporary values, would be updated with endpoint
    const company = 'Star Foods Limited';
    const address = 'North Kaneshie, Accra Ghana';
    const email = 'starmeals@email.com';
    const phone = '+233 39473439820023';

    TextStyle metaStyle(Color c) => GoogleFonts.imprima(
      color: c,
      fontSize: 13,
      fontWeight: FontWeight.w500,
    );

    return Column(
      children: [
        Text(company, style: metaStyle(Colors.white.withOpacity(0.9))),
        const SizedBox(height: 6),
        Text(address, style: metaStyle(Colors.white.withOpacity(0.75))),
        const SizedBox(height: 6),
        Text(email, style: metaStyle(Colors.white.withOpacity(0.75))),
        const SizedBox(height: 6),
        Text(phone, style: metaStyle(Colors.white.withOpacity(0.75))),
      ],
    );
  }
}

class _BillingSelector extends StatelessWidget {
  final List<BillingOption> options;
  final String selectedId;
  final ValueChanged<BillingOption> onSelect;

  const _BillingSelector({
    required this.options,
    required this.selectedId,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.07),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          for (int i = 0; i < options.length; i++) ...[
            Expanded(
              child: _BillingOptionTile(
                option: options[i],
                active: options[i].id == selectedId,
                onTap: () => onSelect(options[i]),
              ),
            ),
            if (i != options.length - 1)
              Container(
                width: 1,
                height: 74,
                color: Colors.white.withOpacity(0.18),
              ),
          ],
        ],
      ),
    );
  }
}

class _BillingOptionTile extends StatelessWidget {
  final BillingOption option;
  final bool active;
  final VoidCallback onTap;

  const _BillingOptionTile({
    required this.option,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg = active ? Colors.white.withOpacity(0.1) : Colors.transparent;
    final labelColor = active ? Colors.white : Colors.white.withOpacity(0.82);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          children: [
            Text(
              option.label,
              style: GoogleFonts.imprima(
                color: labelColor,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              option.subtitle,
              style: GoogleFonts.imprima(
                color: labelColor.withOpacity(0.85),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '\$ ${option.priceUsd.toStringAsFixed(0)}',
              style: GoogleFonts.imprima(
                color: labelColor,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomCta extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _BottomCta({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          width: double.infinity,
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
