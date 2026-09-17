import 'package:autobus/barrel.dart';
import 'package:autobus/common_design/light_screen_theme.dart';
import 'package:autobus/common_design/widgets/app_bottom_nav.dart';
import 'package:autobus/common_design/widgets/light_screen_scaffold.dart';
import 'package:autobus/icons/figma_icons.dart';
import 'package:autobus/main.dart';
import 'dart:developer';

class SelectPlan extends StatefulWidget {
  final String userEmail;
  /// When true, payment completion calls [upgradeMySubscription] instead of subscribe.
  final bool upgradeFromActivePlan;
  /// Only plans with `price` strictly greater than this are shown (upgrade flow).
  final double? minExclusivePlanPrice;
  /// Passed to [SubscriptionBillPage] so pay+activate returns to this route.
  final String? successPopUntilRouteName;
  /// Light Figma Top up picker (Credits flow). Onboarding keeps the classic UI.
  final bool topUpStyle;
  /// Light Figma Renew picker (Credits → Renew).
  final bool renewStyle;
  final String? remainingCreditsLabel;

  const SelectPlan({
    required this.userEmail,
    this.upgradeFromActivePlan = false,
    this.minExclusivePlanPrice,
    this.successPopUntilRouteName,
    this.topUpStyle = false,
    this.renewStyle = false,
    this.remainingCreditsLabel,
    super.key,
  });

  @override
  State<SelectPlan> createState() => _SelectPlanState();
}

class _SelectPlanState extends State<SelectPlan> with TickerProviderStateMixin {
  List<SubscriptionPlan> _plans = [];
  bool _isLoading = true;
  int? _expandedPlanId; // int to match plan.id
  int? _selectedPlanId; // int to match plan.id

  @override
  void initState() {
    super.initState();
    _fetchPlans();
  }

  List<SubscriptionPlan> get _visiblePlans {
    final minP = widget.minExclusivePlanPrice;
    if (minP == null) return _plans;
    return _plans.where((p) => p.price > minP).toList();
  }

  Future<void> _fetchPlans() async {
    try {
      final plans = await apiService.getSubscriptionPlans();
      if (mounted) {
        setState(() {
          _plans = plans;
          _isLoading = false;
          if (_selectedPlanId != null &&
              !_visiblePlans.any((p) => p.id == _selectedPlanId)) {
            _selectedPlanId = null;
            _expandedPlanId = null;
          }
          if (_usesLightPicker &&
              _selectedPlanId == null &&
              _visiblePlans.isNotEmpty) {
            _selectedPlanId = _visiblePlans.first.id;
          }
        });
      }
    } catch (e) {
      log('SelectPlan: Failed to load plans — $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  SubscriptionPlan? get _selectedPlan => _selectedPlanId == null
      ? null
      : _visiblePlans.where((p) => p.id == _selectedPlanId).firstOrNull;

  bool get _usesLightPicker => widget.topUpStyle || widget.renewStyle;

  @override
  Widget build(BuildContext context) {
    if (_usesLightPicker) return _buildLightPicker(context);

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
                  child: _isLoading
                      ? const Center(
                          child: AutobusLoadingIndicator(size: 36),
                        )
                      : _visiblePlans.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Text(
                              widget.minExclusivePlanPrice != null
                                  ? 'There is no higher plan available right now. Contact support if you need a custom tier.'
                                  : 'No plans available.',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.montserrat(color: Colors.white),
                            ),
                          ),
                        )
                      : Center(
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                const SizedBox(height: 34),
                                Text(
                                  widget.upgradeFromActivePlan
                                      ? 'Upgrade plan'
                                      : 'User Type',
                                  style: GoogleFonts.montserrat(
                                    color: Colors.white,
                                    fontSize: 30,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  widget.upgradeFromActivePlan
                                      ? 'Pick a higher tier to continue'
                                      : 'Select a user type',
                                  style: GoogleFonts.montserrat(
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                for (final plan in _visiblePlans) ...[
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
                  label: widget.upgradeFromActivePlan ? 'Continue' : 'Next',
                  enabled: _selectedPlan != null,
                  onPressed: _goToBill,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _goToBill() {
    final selected = _selectedPlan;
    if (selected == null) return;
    Navigator.of(context).push(
      PageTransition(
        type: PageTransitionType.rightToLeftWithFade,
        duration: const Duration(milliseconds: 1000),
        reverseDuration: const Duration(milliseconds: 600),
        child: SubscriptionBillPage(
          plan: selected,
          userEmail: widget.userEmail,
          isUpgrade: widget.upgradeFromActivePlan,
          successPopUntilRouteName: widget.successPopUntilRouteName,
        ),
      ),
    );
  }

  Widget _buildLightPicker(BuildContext context) {
    final scale = MediaQuery.sizeOf(context).width / appShellDesignWidth;
    final renew = widget.renewStyle;

    return LightScreenScaffold(
      title: renew ? 'Renew' : 'Top up',
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: AutobusLoadingIndicator(size: 36))
                : _visiblePlans.isEmpty
                ? Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24 * scale),
                      child: Text(
                        widget.minExclusivePlanPrice != null
                            ? 'There is no higher plan available right now. Contact support if you need a custom tier.'
                            : 'No plans available.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.montserrat(
                          fontSize: 14 * scale.clamp(0.9, 1.05),
                          color: const Color(0xFF4E4E4E),
                        ),
                      ),
                    ),
                  )
                : ListView(
                    padding: LightScreenTheme.listPagePadding(scale),
                    children: [
                      if (renew) ...[
                        Container(
                          height: 88 * scale,
                          width: double.infinity,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: const Color(0xFF2D0C51),
                            borderRadius: BorderRadius.circular(15 * scale),
                          ),
                          child: Text(
                            widget.remainingCreditsLabel ?? '0 credits left',
                            style: GoogleFonts.montserrat(
                              fontSize: 16 * scale.clamp(0.9, 1.05),
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(height: LightScreenTheme.rowGap * scale),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8 * scale),
                          child: Text(
                            'Choose a plan to renew your credits and keep using Autobus without interruption.',
                            style: GoogleFonts.montserrat(
                              fontSize: 12 * scale.clamp(0.9, 1.05),
                              fontWeight: FontWeight.w400,
                              height: 1.45,
                              color: const Color(0xFF4E4E4E),
                            ),
                          ),
                        ),
                        SizedBox(height: 20 * scale),
                      ],
                      for (var i = 0; i < _visiblePlans.length; i++) ...[
                        if (i > 0) SizedBox(height: LightScreenTheme.rowGap * scale),
                        _TopUpPlanCard(
                          scale: scale,
                          plan: _visiblePlans[i],
                          selected: _selectedPlanId == _visiblePlans[i].id,
                          showPrice: renew,
                          showUnselectedBorder: !renew,
                          showRadioWhenUnselected: !renew,
                          onTap: () => setState(
                            () => _selectedPlanId = _visiblePlans[i].id,
                          ),
                        ),
                      ],
                    ],
                  ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                35 * scale,
                8 * scale,
                35 * scale,
                16 * scale,
              ),
              child: SizedBox(
                width: double.infinity,
                height: 64 * scale,
                child: ElevatedButton(
                  onPressed: _selectedPlan == null ? null : _goToBill,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2D0C51),
                    disabledBackgroundColor: const Color(
                      0xFF2D0C51,
                    ).withValues(alpha: 0.4),
                    foregroundColor: Colors.white,
                    disabledForegroundColor: Colors.white70,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30 * scale),
                    ),
                  ),
                  child: Text(
                    renew ? 'Renew' : 'Top up',
                    style: GoogleFonts.montserrat(
                      fontSize: 16 * scale.clamp(0.9, 1.05),
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
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
                    style: GoogleFonts.montserrat(
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

  static Widget _itemRow({
    required IconData icon,
    required String label,
    required Color baseColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 18,
            width: 18,
            decoration: BoxDecoration(
              color: baseColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 12, color: Colors.white),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.montserrat(
                color: baseColor.withOpacity(0.85),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final col = CustColors.mainCol;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          plan.name,
          style: GoogleFonts.montserrat(
            color: col,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          plan.priceText,
          style: GoogleFonts.montserrat(
            color: col,
            fontSize: 34,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 14),
        if (plan.features.isNotEmpty) ...[
          Text(
            'Features',
            style: GoogleFonts.montserrat(
              color: col.withOpacity(0.75),
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 8),
          for (final f in plan.features)
            _itemRow(icon: Icons.check, label: f, baseColor: col),
        ],
        if (plan.agents.isNotEmpty) ...[
          if (plan.features.isNotEmpty) const SizedBox(height: 6),
          Text(
            'Agents',
            style: GoogleFonts.montserrat(
              color: col.withOpacity(0.75),
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 8),
          for (final a in plan.agents)
            _itemRow(
              icon: Icons.smart_toy_outlined,
              label: SubscriptionPlan.formatAgentLabel(a),
              baseColor: col,
            ),
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
                  style: GoogleFonts.montserrat(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const FigmaChevronTrail(),
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
          style: GoogleFonts.montserrat(
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

class _TopUpPlanCard extends StatelessWidget {
  static const _fill = Color(0xFFF8FAFC);
  static const _subtitle = Color(0xFF938F8F);
  static const _price = Color(0xFF7F03B9);

  final double scale;
  final SubscriptionPlan plan;
  final bool selected;
  final bool showPrice;
  final bool showUnselectedBorder;
  final bool showRadioWhenUnselected;
  final VoidCallback onTap;

  const _TopUpPlanCard({
    required this.scale,
    required this.plan,
    required this.selected,
    required this.onTap,
    this.showPrice = false,
    this.showUnselectedBorder = true,
    this.showRadioWhenUnselected = true,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15 * scale),
        child: Container(
          height: 80 * scale,
          padding: EdgeInsets.symmetric(horizontal: 16 * scale),
          decoration: BoxDecoration(
            color: _fill,
            borderRadius: BorderRadius.circular(15 * scale),
            border: selected
                ? Border.all(color: Colors.black, width: 2)
                : showUnselectedBorder
                ? Border.all(color: const Color(0xFFE5E5E5), width: 1)
                : null,
          ),
          child: Row(
            children: [
              FigmaSvgIcon(
                FigmaIcons.token,
                size: 32 * scale,
              ),
              SizedBox(width: 16 * scale),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plan.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.montserrat(
                        fontSize: 16 * scale.clamp(0.9, 1.05),
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 2 * scale),
                    Text(
                      plan.creditsInTotalLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.montserrat(
                        fontSize: 12 * scale.clamp(0.9, 1.05),
                        fontWeight: FontWeight.w400,
                        color: _subtitle,
                      ),
                    ),
                  ],
                ),
              ),
              if (showPrice) ...[
                SizedBox(width: 8 * scale),
                Text(
                  plan.shortPriceLabel,
                  style: GoogleFonts.montserrat(
                    fontSize: 14 * scale.clamp(0.9, 1.05),
                    fontWeight: FontWeight.w600,
                    color: _price,
                  ),
                ),
              ],
              if (selected || showRadioWhenUnselected) ...[
                SizedBox(width: 8 * scale),
                Container(
                  width: 20 * scale,
                  height: 20 * scale,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black, width: 2),
                  ),
                  child: selected
                      ? Center(
                          child: Container(
                            width: 10 * scale,
                            height: 10 * scale,
                            decoration: const BoxDecoration(
                              color: Colors.black,
                              shape: BoxShape.circle,
                            ),
                          ),
                        )
                      : null,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

extension _FirstOrNullExtension<E> on Iterable<E> {
  E? get firstOrNull => isEmpty ? null : first;
}
