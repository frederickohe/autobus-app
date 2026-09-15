import 'package:autobus/barrel.dart';
import 'package:autobus/common_design/light_screen_theme.dart';
import 'package:autobus/common_design/widgets/app_bottom_nav.dart';
import 'package:autobus/common_design/widgets/light_list_card.dart';
import 'package:autobus/common_design/widgets/light_screen_scaffold.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  Map<String, dynamic>? _subscriptionStatus;
  bool _subscriptionLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadSubscriptionSummary());
  }

  Future<void> _loadSubscriptionSummary() async {
    final auth = context.read<AuthBloc>().state;
    if (auth is! Authenticated) {
      if (mounted) {
        setState(() {
          _subscriptionLoading = false;
          _subscriptionStatus = null;
        });
      }
      return;
    }
    try {
      final api = context.read<ApiService>();
      final s = await api.getMySubscriptionStatus();
      if (!mounted) return;
      setState(() {
        _subscriptionStatus = s;
        _subscriptionLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _subscriptionStatus = null;
        _subscriptionLoading = false;
      });
    }
  }

  String _subscriptionTitle() {
    if (_subscriptionLoading) return 'Loading…';
    final s = _subscriptionStatus;
    if (s == null) return 'No active plan';
    final active = s['has_active_subscription'] == true;
    if (!active) return 'No active plan';
    final name = (s['plan_name'] ?? '').toString().trim();
    return name.isEmpty ? 'Active subscription' : name;
  }

  String _subscriptionSubtitle() {
    if (_subscriptionLoading) return ' ';
    final s = _subscriptionStatus;
    if (s == null) return 'Tap Subscription below to choose a plan';
    final active = s['has_active_subscription'] == true;
    if (!active) return 'Tap Subscription below to choose a plan';
    final d = s['days_remaining'];
    final days = d is int ? d : int.tryParse(d?.toString() ?? '0') ?? 0;
    if (days > 1) return '$days days until renewal';
    if (days == 1) return '1 day until renewal';
    return 'Renews today';
  }

  String _usernameFromState(AuthState state) {
    if (state is Authenticated) {
      return state.user['fullname'] ?? state.user['email'] ?? 'User';
    }
    return 'Guest';
  }

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.sizeOf(context).width / appShellDesignWidth;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Unauthenticated) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const LogorSign()),
            (route) => false,
          );
        } else if (state is AuthError && state.source == 'logout') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.message,
                style: GoogleFonts.montserrat(color: Colors.white),
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          return LightScreenScaffold(
            title: _usernameFromState(state),
            body: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                20 * scale,
                20 * scale,
                20 * scale,
                32 * scale,
              ),
              child: Column(
                children: [
                  LightListCard(
                    scale: scale,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _subscriptionTitle(),
                          style: GoogleFonts.montserrat(
                            color: Colors.black87,
                            fontSize: 20 * scale.clamp(0.9, 1.05),
                            fontWeight: FontWeight.w800,
                            height: 1.2,
                          ),
                        ),
                        SizedBox(height: 6 * scale),
                        Text(
                          _subscriptionSubtitle(),
                          style: LightScreenTheme.listSubtitle(scale),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 12 * scale),
                  LightListCard(
                    scale: scale,
                    padding: EdgeInsets.symmetric(vertical: 4 * scale),
                    child: Column(
                      children: _buildMenuItems()
                          .map((item) => _SettingsMenuTile(
                                scale: scale,
                                item: item,
                              ))
                          .toList(),
                    ),
                  ),
                  SizedBox(height: 12 * scale),
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, authState) {
                      final isLoading = authState is AuthLoading;

                      return LightListCard(
                        scale: scale,
                        onTap: isLoading ? null : () => _handleLogout(context),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              isLoading ? 'Logging out...' : 'Logout',
                              style: GoogleFonts.montserrat(
                                color: isLoading ? Colors.grey : Colors.red,
                                fontSize: 14 * scale.clamp(0.9, 1.05),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (isLoading)
                              const AutobusLoadingIndicator(size: 20)
                            else
                              const Icon(
                                Icons.logout,
                                color: Colors.red,
                                size: 20,
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  List<SettingsMenuItem> _buildMenuItems() {
    return [
      SettingsMenuItem("Profile", Icons.person_outline, () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const Profile()),
        );
      }),
      SettingsMenuItem("Subscription", Icons.auto_awesome_rounded, () {
        Navigator.push(
          context,
          MaterialPageRoute(
            settings: const RouteSettings(name: kManageSubscriptionRouteName),
            builder: (_) => const ManageSubscriptionPage(),
          ),
        ).then((_) => _loadSubscriptionSummary());
      }),
      SettingsMenuItem("Notifications", Icons.notifications_none, () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const NotificationsPage()),
        );
      }),
      SettingsMenuItem("Password & Security", Icons.lock_outline, () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const Security()),
        );
      }),
      SettingsMenuItem("Help & Support", Icons.help_outline, () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const HelpPage()),
        );
      }),
    ];
  }

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final textTheme = Theme.of(context).textTheme;
        return Dialog(
          elevation: 0,
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red.withOpacity(0.10),
                  ),
                  child: const Icon(Icons.logout, color: Colors.red, size: 26),
                ),
                const SizedBox(height: 14),
                Text(
                  'Log out?',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'You can log back in at any time.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(
                    fontSize: 13.5,
                    height: 1.35,
                    fontWeight: FontWeight.w400,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.black87,
                          side: BorderSide(
                            color: Colors.black.withOpacity(0.12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          textStyle: textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: GoogleFonts.montserrat(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          context.read<AuthBloc>().add(LogoutEvent());
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          textStyle: textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        child: Text(
                          'Continue',
                          style: GoogleFonts.montserrat(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SettingsMenuTile extends StatelessWidget {
  final double scale;
  final SettingsMenuItem item;

  const _SettingsMenuTile({required this.scale, required this.item});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: item.onTap,
      contentPadding: EdgeInsets.symmetric(horizontal: 8 * scale),
      leading: Icon(item.icon, color: Colors.black87, size: 22 * scale),
      title: Text(item.title, style: LightScreenTheme.listTitle(scale)),
      trailing: Icon(
        Icons.chevron_right,
        color: LightScreenTheme.muted,
        size: 20 * scale,
      ),
    );
  }
}

class SettingsMenuItem {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  SettingsMenuItem(this.title, this.icon, this.onTap);
}
