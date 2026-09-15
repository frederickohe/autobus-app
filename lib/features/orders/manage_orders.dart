import 'package:autobus/barrel.dart';
import 'package:autobus/common_design/light_screen_theme.dart';
import 'package:autobus/common_design/widgets/app_bottom_nav.dart';
import 'package:autobus/common_design/widgets/light_hub_card.dart';
import 'package:autobus/common_design/widgets/light_screen_scaffold.dart';
import 'package:autobus/icons/home_figma_icons.dart';

class ManageOrders extends StatelessWidget {
  const ManageOrders({super.key});

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.sizeOf(context).width / appShellDesignWidth;

    return LightScreenScaffold(
      title: 'Manage Orders',
      creditCategory: CreditCategory.server,
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20 * scale, 28 * scale, 20 * scale, 32 * scale),
        child: Column(
          children: [
            Text(
              'Welcome to Orders',
              textAlign: TextAlign.center,
              style: LightScreenTheme.hubTitle(scale),
            ),
            SizedBox(height: 16 * scale),
            Text(
              'Track, manage, and automate order processing with smart AI assistance.',
              textAlign: TextAlign.center,
              style: LightScreenTheme.hubBody(scale),
            ),
            SizedBox(height: 32 * scale),
            LightHubGrid(
              scale: scale,
              children: [
                LightHubCard(
                  scale: scale,
                  title: 'Pending Orders',
                  icon: HomeFigmaIcons.pendingOrders,
                  iconGradient: HomeFigmaIcons.ordersGradient,
                  onTap: () {
                    Navigator.push<void>(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => const ActiveQueries(),
                      ),
                    );
                  },
                ),
                LightHubCard(
                  scale: scale,
                  title: 'All Orders',
                  icon: HomeFigmaIcons.allOrders,
                  iconGradient: HomeFigmaIcons.ordersGradient,
                  onTap: () {
                    Navigator.push<void>(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => const AllOrdersHistory(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
