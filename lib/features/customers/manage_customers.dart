import 'package:autobus/barrel.dart';
import 'package:autobus/common_design/light_screen_theme.dart';
import 'package:autobus/common_design/widgets/app_bottom_nav.dart';
import 'package:autobus/common_design/widgets/light_hub_card.dart';
import 'package:autobus/common_design/widgets/light_screen_scaffold.dart';
import 'package:autobus/icons/home_figma_icons.dart';

class ManageCustomers extends StatelessWidget {
  const ManageCustomers({super.key});

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.sizeOf(context).width / appShellDesignWidth;

    return LightScreenScaffold(
      title: 'Manage Customers',
      titleFontSize: 16,
      creditCategory: CreditCategory.server,
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20 * scale, 30 * scale, 20 * scale, 32 * scale),
        child: Column(
          children: [
            Text(
              'Welcome to Customers',
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
                  title: 'Add Customer',
                  subtitle: 'New customers',
                  icon: HomeFigmaIcons.addCustomer,
                  iconGradient: HomeFigmaIcons.addCustomerGradient,
                  onTap: () {
                    Navigator.push<void>(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => const AddCustomerPage(),
                      ),
                    );
                  },
                ),
                LightHubCard(
                  scale: scale,
                  title: 'View Customers',
                  subtitle: 'Added customers',
                  icon: HomeFigmaIcons.viewCustomers,
                  iconGradient: HomeFigmaIcons.viewCustomersGradient,
                  onTap: () {
                    Navigator.push<void>(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => const ViewCustomersPage(),
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
