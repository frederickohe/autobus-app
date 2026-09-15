import 'package:autobus/barrel.dart';
import 'package:autobus/common_design/light_screen_theme.dart';
import 'package:autobus/common_design/widgets/app_bottom_nav.dart';
import 'package:autobus/common_design/widgets/app_screen_header.dart';
import 'package:autobus/common_design/widgets/light_hub_card.dart';
import 'package:autobus/icons/home_figma_icons.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ManageOutlets extends StatefulWidget {
  const ManageOutlets({super.key});

  @override
  State<ManageOutlets> createState() => _ManageOutletsState();
}

class _ManageOutletsState extends State<ManageOutlets> {
  var _loading = true;
  var _busy = false;
  String? _loadError;
  List<LinkedOutlet> _linked = [];
  List<OutletOption> _unlinked = OutletCatalog.all;

  @override
  void initState() {
    super.initState();
    _refreshIntegrations();
  }

  Future<void> _refreshIntegrations() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });

    try {
      final api = context.read<ApiService>();
      List<PostizIntegration> integrations = [];
      try {
        integrations = List<PostizIntegration>.from(
          await api.listPostizIntegrations(),
        );
      } catch (_) {
        integrations = [];
      }
      try {
        final igAccounts = await api.listInstagramAccounts();
        for (final row in igAccounts) {
          final username = (row['username'] ?? '').toString().trim();
          final name = (row['name'] ?? '').toString().trim();
          final dbId = (row['id'] ?? '').toString().trim();
          final igId = (row['ig_user_id'] ?? dbId).toString();
          final label = username.isNotEmpty
              ? '@$username'
              : (name.isNotEmpty ? name : igId);
          // Prefer Autobus DB id so DELETE /instagram/accounts/{id} works.
          final unlinkId = dbId.isNotEmpty ? dbId : igId;
          if (unlinkId.isEmpty) continue;
          integrations.add(
            PostizIntegration(
              id: 'autobus-ig-$unlinkId',
              name: label.isNotEmpty ? label : 'Instagram',
              identifier: 'instagram',
              picture: (row['profile_picture_url'] ?? '').toString(),
              disabled: false,
              profile: username.isNotEmpty ? username : null,
            ),
          );
        }
      } catch (_) {
        // Autobus Instagram accounts are optional alongside Postiz.
      }
      if (!mounted) return;
      final split = OutletCatalog.partition(integrations);
      setState(() {
        _linked = split.linked;
        _unlinked = split.unlinked;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadError = e.toString().replaceFirst('Exception: ', '');
        _linked = [];
        _unlinked = OutletCatalog.all;
        _loading = false;
      });
    }
  }

  Future<void> _linkOutlet(OutletOption outlet) async {
    final api = context.read<ApiService>();
    final connectSlug = outlet.connectSlug?.trim();
    // Meta / TikTok / Google block in-app WebViews; use the device browser
    // the same way Chatwoot WhatsApp Embedded Signup does.
    await openPlatformConnectInBrowser(
      context,
      label: outlet.label,
      fetchSession: () {
        if (connectSlug != null && connectSlug.isNotEmpty) {
          return api.initiateSocialConnect(connectSlug);
        }
        return api.postizAutoLogin();
      },
    );

    if (mounted) {
      await _refreshIntegrations();
    }
  }

  Future<void> _confirmUnlink(LinkedOutlet item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Unlink ${item.outlet.label}?',
            style: GoogleFonts.montserrat(
              color: Colors.black,
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
          content: Text(
            item.integrations.length == 1
                ? 'This removes ${item.subtitle} from Autobus. You can link it again later.'
                : 'This removes all ${item.integrations.length} linked ${item.outlet.label} accounts. You can link again later.',
            style: GoogleFonts.montserrat(
              color: LightScreenTheme.body,
              fontSize: 14,
              height: 1.45,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(
                'Cancel',
                style: GoogleFonts.montserrat(
                  color: LightScreenTheme.muted,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(
                'Unlink',
                style: GoogleFonts.montserrat(
                  color: const Color(0xFFEF4444),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
    if (confirmed == true && mounted) {
      await _unlinkOutlet(item);
    }
  }

  Future<void> _unlinkOutlet(LinkedOutlet item) async {
    final messenger = ScaffoldMessenger.of(context);
    final api = context.read<ApiService>();
    setState(() => _busy = true);
    try {
      for (final integration in item.integrations) {
        final id = integration.id.trim();
        if (id.startsWith('autobus-ig-')) {
          await api.deleteInstagramAccount(id.substring('autobus-ig-'.length));
        } else {
          await api.deletePostizIntegration(id);
        }
      }
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('${item.outlet.label} unlinked')),
      );
      await _refreshIntegrations();
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
        ),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _onLinkedTap(LinkedOutlet item) async {
    if (_busy) return;
    final action = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  item.outlet.label,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (item.subtitle.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    item.subtitle,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.montserrat(
                      color: LightScreenTheme.muted,
                      fontSize: 12,
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                ListTile(
                  leading: HomeSfIcon(
                    icon: HomeFigmaIcons.linkSocial,
                    color: LightScreenTheme.accent,
                    size: 22,
                  ),
                  title: Text(
                    'Link another account',
                    style: GoogleFonts.montserrat(color: Colors.black87),
                  ),
                  onTap: () => Navigator.of(ctx).pop('link'),
                ),
                ListTile(
                  leading: const HomeSfIcon(
                    icon: HomeFigmaIcons.unlink,
                    color: Color(0xFFEF4444),
                    size: 22,
                  ),
                  title: Text(
                    'Unlink',
                    style: GoogleFonts.montserrat(
                      color: const Color(0xFFEF4444),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onTap: () => Navigator.of(ctx).pop('unlink'),
                ),
              ],
            ),
          ),
        );
      },
    );
    if (!mounted || action == null) return;
    if (action == 'link') {
      await _linkOutlet(item.outlet);
    } else if (action == 'unlink') {
      await _confirmUnlink(item);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.sizeOf(context).width / appShellDesignWidth;

    return Scaffold(
      backgroundColor: LightScreenTheme.background,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppScreenHeader(
                scale: scale,
                title: 'Link Channel',
                titleFontSize: 16,
                leading: AppScreenBackButton(scale: scale),
                trailing: IconButton(
                  onPressed: _loading || _busy ? null : _refreshIntegrations,
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(
                    minWidth: 32 * scale,
                    minHeight: 32 * scale,
                  ),
                  icon: HomeSfIcon(
                    icon: HomeFigmaIcons.refresh,
                    color: Colors.black,
                    size: 22 * scale.clamp(0.9, 1.0),
                  ),
                ),
              ),
              Expanded(
                child: _loading
                    ? Center(
                        child: CircularProgressIndicator(
                          color: LightScreenTheme.accent,
                        ),
                      )
                    : RefreshIndicator(
                        color: LightScreenTheme.accent,
                        onRefresh: _refreshIntegrations,
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: EdgeInsets.fromLTRB(
                            20 * scale,
                            30 * scale,
                            20 * scale,
                            32 * scale,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (_loadError != null) ...[
                                Text(
                                  _loadError!,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.montserrat(
                                    color: LightScreenTheme.warning,
                                    fontSize: 12 * scale.clamp(0.9, 1.05),
                                  ),
                                ),
                                SizedBox(height: 16 * scale),
                              ],
                              Text(
                                'Select to Link a Channel',
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
                              if (_unlinked.isEmpty)
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    vertical: 12 * scale,
                                  ),
                                  child: Text(
                                    'All available outlets are linked.',
                                    textAlign: TextAlign.center,
                                    style: LightScreenTheme.emptyState(scale),
                                  ),
                                )
                              else
                                _OutletGrid(
                                  scale: scale,
                                  children: [
                                    for (final outlet in _unlinked)
                                      _brandHubCard(
                                        scale,
                                        outlet,
                                        onTap: _busy
                                            ? () {}
                                            : () => _linkOutlet(outlet),
                                      ),
                                  ],
                                ),
                              SizedBox(height: 40 * scale),
                              Text(
                                'Linked Outlets',
                                style: LightScreenTheme.hubTitle(scale),
                              ),
                              if (_linked.isEmpty)
                                Padding(
                                  padding: EdgeInsets.only(top: 16 * scale),
                                  child: Text(
                                    'No outlets linked yet. Connect a channel above.',
                                    textAlign: TextAlign.center,
                                    style: LightScreenTheme.emptyState(scale),
                                  ),
                                )
                              else ...[
                                SizedBox(height: 16 * scale),
                                _OutletGrid(
                                  scale: scale,
                                  children: [
                                    for (final item in _linked)
                                      _brandHubCard(
                                        scale,
                                        item.outlet,
                                        subtitle: 'Linked successfully',
                                        subtitleColor: const Color(0xFF659F0D),
                                        onTap: () => _onLinkedTap(item),
                                      ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
              ),
            ],
          ),
          if (_busy)
            ColoredBox(
              color: Colors.black.withValues(alpha: 0.25),
              child: Center(
                child: CircularProgressIndicator(color: LightScreenTheme.accent),
              ),
            ),
        ],
      ),
    );
  }

  Widget _brandHubCard(
    double scale,
    OutletOption outlet, {
    required VoidCallback onTap,
    String? subtitle,
    Color? subtitleColor,
  }) {
    return LightHubCard(
      scale: scale,
      title: outlet.label,
      subtitle: subtitle ?? outlet.linkSubtitle,
      subtitleColor: subtitleColor,
      icon: HomeFigmaIcons.linkChannel,
      iconTileColor: outlet.tileColor,
      iconWidget: FaIcon(
        outlet.icon,
        color: Colors.white,
        size: 22 * scale,
      ),
      onTap: onTap,
    );
  }
}

class _OutletGrid extends StatelessWidget {
  final double scale;
  final List<Widget> children;

  const _OutletGrid({required this.scale, required this.children});

  @override
  Widget build(BuildContext context) {
    return LightHubGrid(scale: scale, children: children);
  }
}
