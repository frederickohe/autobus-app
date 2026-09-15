import 'package:autobus/barrel.dart';
import 'package:autobus/common_design/light_screen_theme.dart';
import 'package:autobus/common_design/widgets/app_bottom_nav.dart';
import 'package:autobus/common_design/widgets/light_list_card.dart';
import 'package:autobus/common_design/widgets/light_screen_scaffold.dart';

class Security extends StatelessWidget {
  const Security({super.key});

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.sizeOf(context).width / appShellDesignWidth;

    final List<SecurityMenuItem> menuItems = [
      SecurityMenuItem("Change Password", Icons.person_outline, () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const RecoverAccount()),
        );
      }),
      SecurityMenuItem("2FA", Icons.notifications_none, () {}),
    ];

    return LightScreenScaffold(
      title: 'Password & Security',
      creditCategory: CreditCategory.server,
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          20 * scale,
          20 * scale,
          20 * scale,
          32 * scale,
        ),
        child: LightListCard(
          scale: scale,
          padding: EdgeInsets.symmetric(vertical: 4 * scale),
          child: Column(
            children: menuItems
                .map(
                  (item) => _SecurityMenuTile(scale: scale, item: item),
                )
                .toList(),
          ),
        ),
      ),
    );
  }
}

class _SecurityMenuTile extends StatelessWidget {
  final double scale;
  final SecurityMenuItem item;

  const _SecurityMenuTile({required this.scale, required this.item});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: item.onTap,
      contentPadding: EdgeInsets.symmetric(horizontal: 8 * scale),
      leading: Icon(item.icon, color: Colors.black87, size: 22 * scale),
      title: Text(item.title, style: LightScreenTheme.listTitle(scale)),
      trailing: Icon(
        Icons.chevron_right,
        color: LightScreenTheme.muted,
        size: 20 * scale,
      ),
    );
  }
}

class SecurityMenuItem {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  SecurityMenuItem(this.title, this.icon, this.onTap);
}
