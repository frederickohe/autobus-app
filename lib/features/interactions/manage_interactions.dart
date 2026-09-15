import 'package:autobus/barrel.dart';
import 'package:autobus/common_design/light_screen_theme.dart';
import 'package:autobus/common_design/widgets/app_bottom_nav.dart';
import 'package:autobus/common_design/widgets/light_hub_card.dart';
import 'package:autobus/common_design/widgets/light_list_card.dart';
import 'package:autobus/common_design/widgets/light_screen_scaffold.dart';
import 'package:autobus/icons/home_figma_icons.dart';

class ManageInteractions extends StatelessWidget {
  const ManageInteractions({super.key});

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.sizeOf(context).width / appShellDesignWidth;

    return LightScreenScaffold(
      title: 'Manage Interactions',
      creditCategory: CreditCategory.llm,
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20 * scale, 28 * scale, 20 * scale, 32 * scale),
        child: Column(
          children: [
            Text(
              'Welcome to Interactions',
              textAlign: TextAlign.center,
              style: LightScreenTheme.hubTitle(scale),
            ),
            SizedBox(height: 16 * scale),
            Text(
              'Interact with AI-driven analytics to gain insights, monitor performance, and support decision-making.',
              textAlign: TextAlign.center,
              style: LightScreenTheme.hubBody(scale),
            ),
            SizedBox(height: 32 * scale),
            LightHubGrid(
              scale: scale,
              children: [
                LightHubCard(
                  scale: scale,
                  title: 'Start Interaction',
                  icon: HomeFigmaIcons.startInteraction,
                  iconGradient: HomeFigmaIcons.interactionsGradient,
                  onTap: () {
                    Navigator.push<void>(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => const AutoBus(
                          title: 'My Ai',
                          webhookContext: 'interactions_agent',
                        ),
                      ),
                    );
                  },
                ),
                LightHubCard(
                  scale: scale,
                  title: 'View Interactions',
                  icon: HomeFigmaIcons.viewInteractions,
                  iconGradient: HomeFigmaIcons.interactionsGradient,
                  onTap: () {
                    Navigator.push<void>(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => const InteractionHistoryPage(),
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

class InteractionHistoryPage extends StatelessWidget {
  const InteractionHistoryPage({super.key});

  Widget _historyListTile(double scale, {
    required String title,
    required String id,
    required String date,
  }) {
    return LightListCard(
      scale: scale,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: LightScreenTheme.listTitle(scale)),
          SizedBox(height: 12 * scale),
          Row(
            children: [
              Expanded(
                child: Text(
                  id,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: LightScreenTheme.listSubtitle(scale),
                ),
              ),
              SizedBox(width: 12 * scale),
              Text(date, style: LightScreenTheme.listSubtitle(scale)),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.sizeOf(context).width / appShellDesignWidth;

    return LightScreenScaffold(
      title: 'Interaction History',
      creditCategory: CreditCategory.llm,
      body: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(20 * scale, 28 * scale, 20 * scale, 32 * scale),
        children: [
          _historyListTile(
            scale,
            title: 'Bag of rice ..',
            id: 'ID TRF 26342348264',
            date: '08 / 01 /2026',
          ),
          SizedBox(height: 12 * scale),
          _historyListTile(
            scale,
            title: 'Fruit Jar',
            id: 'ID TRF 26342348264',
            date: '08 / 01 /2026',
          ),
        ],
      ),
    );
  }
}
