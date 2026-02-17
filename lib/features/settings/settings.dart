import 'package:autobus/barrel.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        // Handle unauthenticated state (successful logout)
        if (state is Unauthenticated) {
          // Navigate to signin page and remove all previous routes
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const LogorSign()),
            (route) => false,
          );
        }
        // Handle logout errors
        else if (state is AuthError && state.source == 'logout') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.message,
                style: GoogleFonts.imprima(color: Colors.white),
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        body: _SettingsBackground(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  /// 🔝 Top Bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      /// Back Button
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: CustColors.mainCol,
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),

                      /// Company Name / Username
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
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.w300,
                            ),
                          );
                        },
                      ),

                      /// Share Icon
                      _circleIcon(Icons.share_outlined),
                    ],
                  ),

                  const SizedBox(height: 40),

                  /// ⚙️ Settings Card
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      children: _buildMenuItems()
                          .map((item) => _SettingsMenuTile(item: item))
                          .toList(),
                    ),
                  ),

                  const SizedBox(height: 26),

                  /// 🚪 Logout Card with loading state
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      bool isLoading = state is AuthLoading;

                      return GestureDetector(
                        onTap: isLoading ? null : () => _handleLogout(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 18,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                isLoading ? 'Logging out...' : "Logout",
                                style: GoogleFonts.roboto(
                                  color: isLoading ? Colors.grey : Colors.red,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                              if (isLoading)
                                const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.red,
                                    ),
                                  ),
                                )
                              else
                                const Icon(
                                  Icons.logout,
                                  color: Colors.red,
                                  size: 20,
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
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
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.black),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                context.read<AuthBloc>().add(LogoutEvent());
              },
              child: const Text('Logout', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Widget _circleIcon(IconData icon) {
    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white24),
      ),
      child: Icon(icon, color: Colors.white70, size: 18),
    );
  }
}

class _SettingsMenuTile extends StatelessWidget {
  final SettingsMenuItem item;

  const _SettingsMenuTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: item.onTap,
      leading: Icon(item.icon, color: Colors.black87),
      title: Text(
        item.title,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.black54),
    );
  }
}

class SettingsMenuItem {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  SettingsMenuItem(this.title, this.icon, this.onTap);
}

class _SettingsBackground extends StatelessWidget {
  final Widget child;
  const _SettingsBackground({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color.fromARGB(255, 244, 244, 244),
            Color.fromARGB(255, 240, 240, 240),
            Color.fromARGB(255, 236, 236, 236),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: child,
    );
  }
}
