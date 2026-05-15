import 'package:autobus/barrel.dart';

class UserAvatar extends StatelessWidget {
  final double size;
  final String? avatarUrl;
  final String? initials;
  final VoidCallback? onTap;

  /// When false, same circular border as the home header bell (no gradient, no fill).
  /// Initials use [initialsColor]; photo avatars are clipped to the inner circle.
  final bool showRingDecoration;
  final Color initialsColor;

  const UserAvatar({
    this.size = 48,
    this.avatarUrl,
    this.initials,
    this.onTap,
    this.showRingDecoration = true,
    this.initialsColor = Colors.white,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        String? url = avatarUrl;
        String chars = initials ?? 'U';

        if (url == null) {
          if (state is Authenticated) {
            final u = state.user;
            chars = (u['fullname'] ?? u['email'] ?? 'User')
                .toString()
                .trim()
                .split(' ')
                .first
                .substring(0, 1)
                .toUpperCase();
            url =
                (u['avatar'] ?? u['avatar_url'] ?? u['photo'] ?? u['photo_url'])
                    ?.toString();
            if (url != null && url.trim().isEmpty) url = null;
          }
        }

        final fontSize = (size * 0.35).clamp(12, 20).toDouble();
        final textStyle = GoogleFonts.montserrat(
          color: initialsColor,
          fontWeight: FontWeight.w600,
          fontSize: fontSize,
        );

        final Widget content = showRingDecoration
            ? Container(
                width: size,
                height: size,
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
                    border: Border.all(
                      color: const Color(0xFF0A051D),
                      width: 2,
                    ),
                  ),
                  child: CircleAvatar(
                    backgroundColor: const Color(0xFF0A051D),
                    backgroundImage: url != null ? NetworkImage(url) : null,
                    child: url == null ? Text(chars, style: textStyle) : null,
                  ),
                ),
              )
            : Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: CustColors.mainCol, width: 1),
                ),
                alignment: Alignment.center,
                child: CircleAvatar(
                  radius: (size / 2) - 1,
                  backgroundColor: Colors.transparent,
                  backgroundImage: url != null ? NetworkImage(url) : null,
                  child: url == null ? Text(chars, style: textStyle) : null,
                ),
              );

        final gesture = GestureDetector(
          onTap:
              onTap ??
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsPage()),
                );
              },
          child: content,
        );

        return gesture;
      },
    );
  }
}
