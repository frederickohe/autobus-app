import 'package:autobus/barrel.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  late final ApiService _apiService;

  bool _loading = true;
  bool _saving = false;
  String? _error;

  bool showNotifications = true; // in_app_notifications
  bool smsNotifications = true; // sms_notifications
  String sound = "Pulse";

  @override
  void initState() {
    super.initState();
    _apiService = context.read<ApiService>();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final user = await _apiService.getUserProfile();
      if (!mounted) return;

      final inApp =
          user['in_app_notification'] ??
          user['in_app_notifications']; // legacy fallback
      final sms =
          user['sms_notification'] ??
          user['sms_notifications'] ??
          user['sms_nofiticaitons']; // legacy fallback

      setState(() {
        showNotifications = inApp is bool ? inApp : true;
        smsNotifications = sms is bool ? sms : true;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _persist({
    bool? inAppNotifications,
    bool? smsNotifications,
    required VoidCallback rollback,
  }) async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      await _apiService.patchMyNotificationSettings(
        inAppNotification: inAppNotifications,
        smsNotification: smsNotifications,
      );

      // Fetch fresh user profile so local cache stays consistent
      final updated = await _apiService.getUserProfile();

      // Keep local cached user in sync (used by AuthBloc on next session check)
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user', jsonEncode(updated));
      } catch (_) {}
    } catch (e) {
      rollback();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update notification settings: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

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
                          style: GoogleFonts.montserrat(
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
                    color: Colors.white.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    children: [
                      if (_loading)
                        const Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          child: LinearProgressIndicator(minHeight: 2),
                        ),
                      if (_error != null && _error!.trim().isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: Text(
                            _error!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                            ),
                          ),
                        ),

                      /// Show Notifications Toggle
                      SwitchListTile(
                        value: showNotifications,
                        onChanged: (_loading || _saving)
                            ? null
                            : (val) {
                                final prev = showNotifications;
                                setState(() => showNotifications = val);
                                _persist(
                                  inAppNotifications: val,
                                  rollback: () => setState(
                                    () => showNotifications = prev,
                                  ),
                                );
                              },
                        title: const Text(
                          "Show Notifications",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        activeThumbColor: CustColors.mainCol,
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

                      /// SMS Notifications Toggle
                      SwitchListTile(
                        value: smsNotifications,
                        onChanged: (_loading || _saving)
                            ? null
                            : (val) {
                                final prev = smsNotifications;
                                setState(() => smsNotifications = val);
                                _persist(
                                  smsNotifications: val,
                                  rollback: () => setState(
                                    () => smsNotifications = prev,
                                  ),
                                );
                              },
                        title: const Text(
                          "SMS Notifications",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        activeThumbColor: CustColors.mainCol,
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
