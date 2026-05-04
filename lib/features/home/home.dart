import 'dart:math' as math;

import 'package:autobus/barrel.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  /// Full-screen entrance when leaving the welcome screen (fade, lift, scale with ease-out back).
  static Route<void> routeFromWelcome() {
    return PageRouteBuilder<void>(
      settings: const RouteSettings(name: 'Home'),
      pageBuilder: (context, animation, secondaryAnimation) => const Home(),
      transitionDuration: const Duration(milliseconds: 1600),
      reverseTransitionDuration: const Duration(milliseconds: 700),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        final scaleCurved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,
          reverseCurve: Curves.easeInBack,
        );
        return FadeTransition(
          opacity: Tween<double>(begin: 0, end: 1).animate(curved),
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.1),
              end: Offset.zero,
            ).animate(curved),
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.78, end: 1).animate(scaleCurved),
              alignment: Alignment.center,
              child: child,
            ),
          ),
        );
      },
    );
  }

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  Future<int>? _unreadCountFuture;
  late final AnimationController _bgDriftController;

  @override
  void initState() {
    super.initState();
    _bgDriftController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 26),
    )..repeat();
  }

  @override
  void dispose() {
    _bgDriftController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _unreadCountFuture ??= context
        .read<ApiService>()
        .getUnreadNotificationCount();
  }

  Future<void> _refreshUnread() async {
    setState(() {
      _unreadCountFuture = context
          .read<ApiService>()
          .getUnreadNotificationCount();
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<HomeMenuItem> menuItems = [
      HomeMenuItem("Orders", Carbon.ibm_watson_orders, () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AutoBus(title: 'Orders')),
        );
      }),
      HomeMenuItem("Chatbot", Mdi.robot_outline, () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AutoBus(title: 'Chatbot')),
        );
      }),
      HomeMenuItem("Marketing", Icons8.advertising, () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const DigitalMarketingPage()),
        );
      }),
      HomeMenuItem("Queries", Carbon.query, () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AutoBus(title: 'Queries')),
        );
      }),
      HomeMenuItem("Products", Icons.shopping_bag_outlined, () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AutoBus(title: 'Products')),
        );
      }),
      HomeMenuItem("Messages", Mdi.message_outline, () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AutoBus(title: 'Messages')),
        );
      }),
      HomeMenuItem("Email", Mdi.email_outline, () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AutoBus(title: 'Email')),
        );
      }),
      HomeMenuItem("Reports", MaterialSymbols.data_usage, () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AnalyticsPage()),
        );
      }),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF130522),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: _CosmosDriftingBackground(controller: _bgDriftController),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFF000000).withValues(alpha: 0.68),
                      const Color(0xFF0A0610).withValues(alpha: 0.62),
                      const Color(0xFF000000).withValues(alpha: 0.72),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                20,
                28,
                20,
                32 +
                    MediaQuery.viewPaddingOf(context).bottom +
                    56,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      FutureBuilder<int>(
                        future: _unreadCountFuture,
                        builder: (context, snap) {
                          final unread = snap.data ?? 0;
                          return GestureDetector(
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const NotificationsInboxPage(),
                                ),
                              );
                              await _refreshUnread();
                            },
                            child: _notificationBell(unreadCount: unread),
                          );
                        },
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SettingsPage(),
                            ),
                          );
                        },
                        child: _avatarCircle(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      String displayName = 'Guest';
                      if (state is Authenticated) {
                        displayName =
                            (state.user['fullname'] ??
                                    state.user['email'] ??
                                    'User')
                                .toString();
                      }

                      final firstName = displayName.trim().split(' ').first;

                      return Column(
                        children: [
                          Text(
                            'Hello $firstName',
                            style: GoogleFonts.montserrat(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                          const SizedBox(height: 28),
                          Iconify(
                            Ion.sparkles_sharp,
                            color: const Color(0xFF6A53E7),
                            size: 18,
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 32),
                  _AlertBox(
                    text: 'You need to set up your business profile',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const Profile()),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  _AlertBox(
                    text: 'Enable 2FA to ensure added security',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const Security()),
                      );
                    },
                  ),
                  const SizedBox(height: 36),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: menuItems.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 36,
                          mainAxisSpacing: 36,
                          childAspectRatio: 1.5,
                        ),
                    itemBuilder: (context, index) {
                      return _DashboardCard(item: menuItems[index]);
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _avatarCircle() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        String? avatarUrl;
        String initials = 'U';

        if (state is Authenticated) {
          final u = state.user;
          final name = (u['fullname'] ?? u['email'] ?? 'User').toString();
          initials = name.trim().isNotEmpty
              ? name.trim()[0].toUpperCase()
              : 'U';

          avatarUrl =
              (u['avatar'] ?? u['avatar_url'] ?? u['photo'] ?? u['photo_url'])
                  ?.toString();
          if (avatarUrl != null && avatarUrl.trim().isEmpty) avatarUrl = null;
        }

        return Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF2A1447),
            border: Border.all(color: const Color(0xFFA92FEB), width: 0.5),
          ),
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: CircleAvatar(
              backgroundColor: Color(0xFF2A1447),
              backgroundImage: avatarUrl != null
                  ? NetworkImage(avatarUrl)
                  : null,
              child: avatarUrl == null
                  ? Text(
                      initials,
                      style: GoogleFonts.montserrat(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    )
                  : null,
            ),
          ),
        );
      },
    );
  }

  Widget _notificationBell({required int unreadCount}) {
    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFA92FEB), width: 0.5),
      ),
      child: Stack(
        children: [
          const Center(
            child: Icon(
              Icons.notifications_none,
              color: Colors.white,
              size: 22,
            ),
          ),
          if (unreadCount > 0)
            Positioned(
              right: 14,
              top: 14,
              child: Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: Color(0xFFE53935),
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final HomeMenuItem item;

  const _DashboardCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: item.onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildIcon(item.icon),
            const SizedBox(height: 14),
            Text(
              item.title,
              style: GoogleFonts.montserrat(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w200,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon(dynamic icon) {
    if (icon is IconData) {
      return Icon(icon, color: Colors.white70, size: 30);
    } else {
      // Handle iconify icons (SVG strings)
      return Iconify(icon, color: Colors.white70, size: 30);
    }
  }
}

class HomeMenuItem {
  final String title;
  final dynamic icon; // Changed from IconData to dynamic for Iconify icons
  final VoidCallback onTap;

  HomeMenuItem(this.title, this.icon, this.onTap);
}

/// Full-bleed nebula with a slow drift (no scroll parallax).
class _CosmosDriftingBackground extends StatelessWidget {
  const _CosmosDriftingBackground({required this.controller});

  final AnimationController controller;

  static const String _asset = 'assets/img/cosmos_background.png';

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final t = controller.value * 2 * math.pi;
        final dx = math.sin(t) * 16;
        final dy = math.cos(t * 0.71) * 14;
        return LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            final h = constraints.maxHeight;
            if (w <= 0 || h <= 0) {
              return const ColoredBox(color: Color(0xFF130522));
            }
            return ClipRect(
              child: Transform.translate(
                offset: Offset(dx, dy),
                child: Transform.scale(
                  scale: 1.12,
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: w,
                    height: h,
                    child: child,
                  ),
                ),
              ),
            );
          },
        );
      },
      child: Image.asset(
        _asset,
        fit: BoxFit.cover,
        alignment: Alignment.center,
        filterQuality: FilterQuality.high,
        errorBuilder: (_, __, ___) {
          return Container(
            color: const Color(0xFF130522),
            alignment: Alignment.center,
            child: Text(
              'Add assets/img/cosmos_background.png',
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(
                color: Colors.white54,
                fontSize: 12,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _AlertBox extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const _AlertBox({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFA92FEB), width: 1),
          color: Colors.black.withValues(alpha: 0.05),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: Color(0xFFD60000), size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.montserrat(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),
            const SizedBox(width: 10),
            const Icon(Icons.arrow_outward, color: Color(0xFFD60000), size: 18),
          ],
        ),
      ),
    );
  }
}
