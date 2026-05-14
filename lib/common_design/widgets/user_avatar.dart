import 'package:autobus/barrel.dart';

class UserAvatar extends StatelessWidget {
  final double size;
  final String? avatarUrl;
  final String? initials;
  final VoidCallback? onTap;

  const UserAvatar({
    this.size = 48,
    this.avatarUrl,
    this.initials,
    this.onTap,
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
            url = (u['avatar'] ?? u['avatar_url'] ?? u['photo'] ?? u['photo_url'])
                ?.toString();
            if (url != null && url.trim().isEmpty) url = null;
          }
        }

        final content = Container(
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
              border: Border.all(color: const Color(0xFF0A051D), width: 2),
            ),
            child: CircleAvatar(
              backgroundColor: const Color(0xFF0A051D),
              backgroundImage: url != null ? NetworkImage(url) : null,
              child: url == null
                  ? Text(
                      chars,
                      style: GoogleFonts.montserrat(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: (size * 0.35).clamp(12, 20).toDouble(),
                      ),
                    )
                  : null,
            ),
          ),
        );

        final gesture = GestureDetector(
          onTap: onTap ?? () {
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
