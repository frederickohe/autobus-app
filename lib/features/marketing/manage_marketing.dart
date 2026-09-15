import 'package:autobus/barrel.dart';
import 'package:autobus/common_design/light_screen_theme.dart';
import 'package:autobus/common_design/widgets/app_bottom_nav.dart';
import 'package:autobus/common_design/widgets/light_hub_card.dart';
import 'package:autobus/common_design/widgets/light_screen_scaffold.dart';
import 'package:autobus/icons/home_figma_icons.dart';

class ManageMarketing extends StatelessWidget {
  const ManageMarketing({super.key});

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.sizeOf(context).width / appShellDesignWidth;

    return LightScreenScaffold(
      title: 'Manage Marketing',
      titleFontSize: 16,
      creditCategory: CreditCategory.imageGen,
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20 * scale, 30 * scale, 20 * scale, 32 * scale),
        child: Column(
          children: [
            Text(
              'Welcome to Marketing',
              textAlign: TextAlign.center,
              style: LightScreenTheme.hubTitle(scale),
            ),
            SizedBox(height: 16 * scale),
            Text(
              'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
              textAlign: TextAlign.center,
              style: LightScreenTheme.hubBody(scale).copyWith(
                color: const Color(0xFF4E4E4E),
              ),
            ),
            SizedBox(height: 30 * scale),
            LightHubGrid(
              scale: scale,
              children: [
                LightHubCard(
                  scale: scale,
                  title: 'Create campaigns',
                  subtitle: 'Start creating',
                  icon: HomeFigmaIcons.createCampaign,
                  iconGradient: HomeFigmaIcons.liveChatsGradient,
                  onTap: () {
                    Navigator.push<void>(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => const DigitalMarketingSelection(),
                      ),
                    );
                  },
                ),
                LightHubCard(
                  scale: scale,
                  title: 'Link Social Media',
                  subtitle: 'Connect socials',
                  icon: HomeFigmaIcons.linkSocial,
                  iconGradient: HomeFigmaIcons.linkChannelGradient,
                  onTap: () {
                    Navigator.push<void>(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => const ManageOutlets(),
                      ),
                    );
                  },
                ),
                LightHubCard(
                  scale: scale,
                  title: 'Recent Campaigns',
                  subtitle: 'View campaigns',
                  icon: HomeFigmaIcons.recentCampaigns,
                  iconGradient: HomeFigmaIcons.allChatsGradient,
                  onTap: () {
                    Navigator.push<void>(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => const RecentCampaignsPage(),
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
