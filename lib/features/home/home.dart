import 'package:autobus/barrel.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Future<int>? _unreadCountFuture;

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
      body: _GradientBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 20),

                /// 🔔 Top Bar
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
                                builder: (_) => const NotificationsInboxPage(),
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

                const SizedBox(height: 18),

                /// 👋 Greeting
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
                        const SizedBox(height: 22),
                        Iconify(
                          Ion.sparkles_sharp,
                          color: const Color(0xFF6A53E7),
                          size: 18,
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 18),

                /// ⚠️ Action boxes
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

                const SizedBox(height: 18),

                /// 📊 Grid Menu
                Expanded(
                  child: GridView.builder(
                    itemCount: menuItems.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 30,
                          mainAxisSpacing: 30,
                          childAspectRatio: 1.55,
                        ),
                    itemBuilder: (context, index) {
                      final item = menuItems[index];

                      return _DashboardCard(item: item);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
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
          border: Border.all(color: const Color(0xFFA92FEB), width: 1),
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

class _GradientBackground extends StatelessWidget {
  final Widget child;
  const _GradientBackground({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
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
