import 'package:autobus/barrel.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  bool showNotifications = true;
  bool reminders = true;
  String sound = "Pulse";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _NotificationBackground(
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

                    /// Company Name
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

                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const Profile()),
                        );
                      },
                      child: _circleIcon(Icons.share_outlined),
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                /// 🔔 Notifications Card
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    children: [
                      /// Show Notifications Toggle
                      SwitchListTile(
                        value: showNotifications,
                        onChanged: (val) {
                          setState(() => showNotifications = val);
                        },
                        title: const Text(
                          "Show Notifications",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        activeColor: CustColors.mainCol,
                      ),

                      /// Sound Tile
                      ListTile(
                        onTap: () {
                          /// Open sound picker later
                        },
                        title: const Text(
                          "Sound",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              sound,
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Icon(
                              Icons.chevron_right,
                              color: Colors.black54,
                            ),
                          ],
                        ),
                      ),

                      /// Reminders Toggle
                      SwitchListTile(
                        value: reminders,
                        onChanged: (val) {
                          setState(() => reminders = val);
                        },
                        title: const Text(
                          "Reminders",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        activeColor: CustColors.mainCol,
                      ),
                    ],
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

class _NotificationBackground extends StatelessWidget {
  final Widget child;
  const _NotificationBackground({required this.child});

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
