import 'package:autobus/barrel.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    final List<HomeMenuItem> menuItems = [
      HomeMenuItem("Orders", Carbon.ibm_watson_orders, () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AutoBus()),
        );
      }),
      HomeMenuItem("Marketing", Icons8.advertising, () {}),
      HomeMenuItem("Payments", FluentEmojiHighContrast.money_bag, () {}),
      HomeMenuItem("Messages", Mdi.phone_message_outline, () {}),
      HomeMenuItem("Records", Mdi.database_arrow_down_outline, () {}),
      HomeMenuItem("Reports", MaterialSymbols.data_usage, () {}),
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
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const NotificationsPage(),
                          ),
                        );
                      },
                      child: _circleIcon(Icons.notifications_none),
                    ),

                    BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        String username = 'Guest';
                        if (state is Authenticated) {
                          username =
                              state.user['fullname'] ??
                              state.user['email'] ??
                              'User';
                        }
                        return Text(
                          username,
                          style: GoogleFonts.roboto(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w300,
                          ),
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
                      child: _circleIcon(Icons.settings_outlined),
                    ),
                  ],
                ),

                const SizedBox(height: 80),

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

  Widget _circleIcon(dynamic icon) {
    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white24),
      ),
      child: icon is IconData
          ? Icon(icon, color: Colors.white70, size: 18)
          : Iconify(icon, color: Colors.white70, size: 8),
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
          border: Border.all(color: Colors.white24),
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.05),
              Colors.white.withOpacity(0.02),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildIcon(item.icon),
            const SizedBox(height: 14),
            Text(
              item.title,
              style: GoogleFonts.roboto(
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
        image: const DecorationImage(
          image: AssetImage("assets/img/dashimg.png"),
          fit: BoxFit.cover,
          opacity: 0.1,
        ),
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
