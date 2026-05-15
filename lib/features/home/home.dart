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

class _HomeState extends State<Home> {
  Future<int>? _unreadCountFuture;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
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
    print('=== HOME SCREEN BUILDING ===');
    final List<HomeMenuItem> menuItems = [
      HomeMenuItem("Intelligence", MaterialSymbols.psychology_outline, () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ManageIntelligence()),
        );
      }),
      HomeMenuItem("Interact", Mdi.account_group_outline, () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ManageInteractions()),
        );
      }),
      HomeMenuItem("Chats", Mdi.chat_outline, () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ManageChats()),
        );
      }),
      HomeMenuItem("Email", Mdi.email_outline, () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ManageEmails()),
        );
      }),
      HomeMenuItem("Marketing", Icons8.advertising, () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ManageMarketing()),
        );
      }),
      HomeMenuItem("Orders", Carbon.ibm_watson_orders, () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ManageOrders()),
        );
      }),
      HomeMenuItem("Products", Icons.shopping_bag_outlined, () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ManageProducts()),
        );
      }),
      HomeMenuItem("Reports", MaterialSymbols.account_balance, () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AnalyticsPage()),
        );
      }),
    ];

    // Two-stop gradient: Figma dashboard top #1E0C37 → black.
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF130522), Color(0xFF000000)],
              ),
            ),
          ),
          // Content
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                20,
                16,
                20,
                32 + MediaQuery.viewPaddingOf(context).bottom + 56,
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
                      const UserAvatar(showRingDecoration: false),
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
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Hello $firstName',
                            style: GoogleFonts.montserrat(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 20,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Center(
                            child: Iconify(
                              Ion.sparkles_sharp,
                              color: const Color(0xFFA855F7),
                              size: 20,
                            ),
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
                  const SizedBox(height: 12),
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
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          // Figma tiles: 149 × 115 → width / height
                          childAspectRatio: 149 / 115,
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
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF7C3AED), Color(0xFFF43F5E)],
            ),
          ),
          padding: const EdgeInsets.all(2),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF0A051D),
              border: Border.all(color: const Color(0xFF0A051D), width: 2),
            ),
            child: CircleAvatar(
              backgroundColor: const Color(0xFF0A051D),
              backgroundImage: avatarUrl != null
                  ? NetworkImage(avatarUrl)
                  : null,
              child: avatarUrl == null
                  ? Text(
                      initials,
                      style: GoogleFonts.montserrat(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
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
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: CustColors.mainCol, width: 1),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          const Center(
            child: Icon(
              Icons.notifications_none,
              color: Colors.white,
              size: 20,
            ),
          ),
          if (unreadCount > 0)
            Positioned(
              right: 12,
              top: 12,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFFEF4444),
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
          border: Border.all(color: const Color(0xFF3F1163), width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildIcon(item.icon),
            const SizedBox(height: 12),
            Text(
              item.title,
              style: GoogleFonts.montserrat(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w300,
              ),
              textAlign: TextAlign.center,
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

class _AlertBox extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const _AlertBox({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 46,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF3F1163), width: 1.5),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.warning_outlined,
              color: Color(0xFFEF4444),
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.montserrat(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Transform.rotate(
              angle: -0.785,
              child: const Icon(
                Icons.arrow_outward,
                color: Color(0xFFEF4444),
                size: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
