import 'package:autobus/barrel.dart';
import 'models/app_notification.dart';

class NotificationsInboxPage extends StatefulWidget {
  const NotificationsInboxPage({super.key});

  @override
  State<NotificationsInboxPage> createState() => _NotificationsInboxPageState();
}

class _NotificationsInboxPageState extends State<NotificationsInboxPage> {
  late Future<List<AppNotification>> _future;

  @override
  void initState() {
    super.initState();
    _future = context.read<ApiService>().getNotifications();
  }

  Future<void> _refresh() async {
    setState(() {
      _future = context.read<ApiService>().getNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _GradientBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Column(
              children: [
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
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
                    Text(
                      'Notifications',
                      style: GoogleFonts.montserrat(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    const SizedBox(width: 48, height: 48),
                  ],
                ),
                const SizedBox(height: 18),
                Expanded(
                  child: FutureBuilder<List<AppNotification>>(
                    future: _future,
                    builder: (context, snap) {
                      if (snap.connectionState != ConnectionState.done) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snap.hasError) {
                        return Center(
                          child: Text(
                            'Failed to load notifications',
                            style: GoogleFonts.montserrat(
                              color: Colors.white,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        );
                      }

                      final items = snap.data ?? const [];
                      if (items.isEmpty) {
                        return Center(
                          child: Text(
                            'No notifications yet',
                            style: GoogleFonts.montserrat(
                              color: Colors.white,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        );
                      }

                      return RefreshIndicator(
                        onRefresh: _refresh,
                        child: ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: items.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (context, i) {
                            final n = items[i];
                            final created = n.createdAt;
                            final subtitle = [
                              if (n.body.trim().isNotEmpty) n.body.trim(),
                              if (created != null)
                                '${created.toLocal()}'.split('.').first,
                            ].join('\n');

                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: const Color(0xFFA92FEB),
                                  width: 0.5,
                                ),
                                color: Colors.white.withValues(
                                  alpha: n.read ? 0.03 : 0.06,
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 10,
                                    height: 10,
                                    margin: const EdgeInsets.only(top: 6),
                                    decoration: BoxDecoration(
                                      color: n.read
                                          ? Colors.transparent
                                          : const Color(0xFFE53935),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          n.title,
                                          style: GoogleFonts.montserrat(
                                            color: Colors.white,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                        if (subtitle.isNotEmpty) ...[
                                          const SizedBox(height: 6),
                                          Text(
                                            subtitle,
                                            style: GoogleFonts.montserrat(
                                              color: Colors.white70,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w300,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      );
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

