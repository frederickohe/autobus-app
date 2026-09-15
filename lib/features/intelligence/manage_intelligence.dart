import 'dart:io';

import 'package:autobus/barrel.dart';
import 'package:autobus/common_design/light_screen_theme.dart';
import 'package:autobus/common_design/widgets/ai_sparkle_icon.dart';
import 'package:autobus/common_design/widgets/app_bottom_nav.dart';
import 'package:autobus/common_design/widgets/app_screen_header.dart';
import 'package:autobus/common_design/widgets/app_shell_navigation.dart';
import 'package:autobus/common_design/widgets/credits_pill.dart';
import 'package:autobus/common_design/widgets/light_list_card.dart';
import 'package:autobus/common_design/widgets/light_screen_scaffold.dart';
import 'package:autobus/features/intelligence/intelligence_files_page.dart';
import 'package:autobus/features/intelligence/intelligence_intro_modal.dart';
import 'package:autobus/features/intelligence/intelligence_my_ai_page.dart';
import 'package:autobus/features/intelligence/intelligence_websites_page.dart';
import 'package:autobus/icons/home_figma_icons.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

String? _ragDocSourceUrl(Map<String, dynamic> doc) {
  final url = doc['source_url'] ?? doc['sourceUrl'];
  if (url == null) return null;
  final s = url.toString().trim();
  return s.isEmpty ? null : s;
}

bool _ragDocIsWebsite(Map<String, dynamic> doc) {
  final type = (doc['source_type'] ?? doc['sourceType'] ?? '')
      .toString()
      .toLowerCase();
  if (type == 'website') return true;
  return _ragDocSourceUrl(doc) != null;
}

bool _ragFileLooksLikePlainText(String fileName) {
  final lower = fileName.trim().toLowerCase();
  return lower.endsWith('.txt') || lower.endsWith('.csv');
}

/// Returns a full http(s) URL for the RAG indexer, or null if invalid.
String? _normalizeWebsiteUrlForApi(String raw) {
  var s = raw.trim();
  if (s.isEmpty) return null;
  final lower = s.toLowerCase();
  if (!lower.startsWith('http://') && !lower.startsWith('https://')) {
    s = 'https://$s';
  }
  final uri = Uri.tryParse(s);
  if (uri == null || !uri.hasScheme) return null;
  if (uri.scheme != 'http' && uri.scheme != 'https') return null;
  if (!uri.hasAuthority || uri.host.isEmpty) return null;
  return uri.toString();
}

class ManageIntelligence extends StatefulWidget {
  const ManageIntelligence({super.key});

  @override
  State<ManageIntelligence> createState() => _ManageIntelligenceState();
}

class _ManageIntelligenceState extends State<ManageIntelligence> {
  static const _surfaceColor = Color(0xFFF8FAFC);
  static const _accentColor = Color(0xFF7F03B9);
  static const _mutedColor = Color(0xFF64748B);
  static const _valueColor = Color(0xFF6366F1);
  static const _introSeenKey = 'intelligence.introSeen';

  bool _presenceRequested = false;
  bool _presenceLoading = true;
  bool _hasRagDocuments = false;
  List<Map<String, dynamic>> _ragFiles = const [];
  String? _presenceError;
  bool _introRequested = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeShowIntro());
  }

  Future<void> _maybeShowIntro() async {
    if (_introRequested) return;
    _introRequested = true;
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_introSeenKey) == true) return;
    if (!mounted) return;
    await IntelligenceIntroModal.show(context);
    await prefs.setBool(_introSeenKey, true);
  }

  void _openMyAi() {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => const IntelligenceMyAiPage(),
      ),
    );
  }

  Future<void> _showFilesSheet() async {
    final action = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(21, 16, 21, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Files',
                  style: GoogleFonts.montserrat(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: HomeSfIcon(
                    icon: HomeFigmaIcons.files,
                    size: 22,
                    color: _accentColor,
                  ),
                  title: Text(
                    'Upload files',
                    style: GoogleFonts.montserrat(fontWeight: FontWeight.w500),
                  ),
                  onTap: () => Navigator.pop(context, 'upload'),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: HomeSfIcon(
                    icon: HomeFigmaIcons.files,
                    size: 22,
                    color: _mutedColor,
                  ),
                  title: Text(
                    'View files',
                    style: GoogleFonts.montserrat(fontWeight: FontWeight.w500),
                  ),
                  onTap: () => Navigator.pop(context, 'view'),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (!mounted || action == null) return;
    if (action == 'upload') {
      await _handleUploadFiles();
    } else if (action == 'view') {
      await Navigator.push<void>(
        context,
        MaterialPageRoute<void>(
          builder: (_) => const IntelligenceFilesPage(),
        ),
      );
      if (mounted) await _loadRagPresence();
    }
  }

  Future<void> _showWebsitesSheet() async {
    final action = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(21, 16, 21, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Websites',
                  style: GoogleFonts.montserrat(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: HomeSfIcon(
                    icon: HomeFigmaIcons.website,
                    size: 22,
                    color: _accentColor,
                  ),
                  title: Text(
                    'Index website',
                    style: GoogleFonts.montserrat(fontWeight: FontWeight.w500),
                  ),
                  onTap: () => Navigator.pop(context, 'index'),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: HomeSfIcon(
                    icon: HomeFigmaIcons.website,
                    size: 22,
                    color: _mutedColor,
                  ),
                  title: Text(
                    'View websites',
                    style: GoogleFonts.montserrat(fontWeight: FontWeight.w500),
                  ),
                  onTap: () => Navigator.pop(context, 'view'),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (!mounted || action == null) return;
    if (action == 'index') {
      await _handleIndexWebsite();
    } else if (action == 'view') {
      await Navigator.push<void>(
        context,
        MaterialPageRoute<void>(
          builder: (_) => const IntelligenceWebsitesPage(),
        ),
      );
      if (mounted) await _loadRagPresence();
    }
  }

  Future<void> _loadRagPresence() async {
    if (!mounted) return;
    setState(() {
      _presenceLoading = true;
      _presenceError = null;
    });
    try {
      final api = context.read<ApiService>();
      final files = await api.listMyStorageFiles(
        folder: ApiService.chatbotStorageFolder,
      );
      if (!mounted) return;
      setState(() {
        _ragFiles = files;
        _hasRagDocuments = files.isNotEmpty;
        _presenceLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _presenceError = e.toString();
        _presenceLoading = false;
        _hasRagDocuments = false;
        _ragFiles = const [];
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_presenceRequested) return;
    _presenceRequested = true;
    _loadRagPresence();
  }

  Future<void> _handleUploadFiles() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['txt', 'pdf', 'docx', 'csv', 'xlsx'],
      allowMultiple: true,
    );

    if (!mounted || result == null || result.files.isEmpty) return;

    final api = context.read<ApiService>();
    var successCount = 0;

    try {
      for (final picked in result.files) {
        final name = picked.name.trim().isEmpty ? 'upload' : picked.name;
        final path = picked.path?.trim();

        Future<Map<String, dynamic>> startJob() async {
          if (path != null && path.isNotEmpty) {
            return api.uploadRagDocument(
              filename: name,
              filePath: path,
              asyncMode: true,
            );
          }
          if (picked.bytes != null && picked.bytes!.isNotEmpty) {
            return api.uploadRagDocument(
              filename: name,
              fileBytes: picked.bytes!.toList(),
              asyncMode: true,
            );
          }
          throw Exception(
            'Could not read "$name". On this device, try choosing the file again.',
          );
        }

        await _runRagIndexWithProgress(
          title: result.files.length > 1 ? 'Indexing ($name)' : 'Indexing document',
          startJob: startJob,
        );
        successCount++;
      }

      if (!mounted) return;
      await _loadRagPresence();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            successCount == 1
                ? 'Document uploaded and indexed.'
                : '$successCount documents uploaded and indexed.',
            style: GoogleFonts.montserrat(),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _uploadErrorMessage(e),
            style: GoogleFonts.montserrat(),
          ),
        ),
      );
    }
  }

  Future<void> _handleIndexWebsite() async {
    final url = await showDialog<String>(
      context: context,
      builder: (dialogContext) => const _WebsiteUrlDialog(),
    );

    if (!mounted || url == null || url.trim().isEmpty) return;

    final api = context.read<ApiService>();
    try {
      await _runRagIndexWithProgress(
        title: 'Indexing website',
        startJob: () => api.uploadRagUrl(url: url.trim()),
      );
      if (!mounted) return;
      await _loadRagPresence();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Website content scraped and indexed.',
            style: GoogleFonts.montserrat(),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _uploadErrorMessage(e),
            style: GoogleFonts.montserrat(),
          ),
        ),
      );
    }
  }

  Future<void> _runRagIndexWithProgress({
    required String title,
    required Future<Map<String, dynamic>> Function() startJob,
  }) async {
    final api = context.read<ApiService>();
    final error = await showDialog<Object?>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return _RagIndexProgressDialog(
          api: api,
          title: title,
          startJob: startJob,
        );
      },
    );
    if (error != null) throw error;
  }

  String _shortPresenceError(String raw, {int max = 160}) {
    final t = raw.trim();
    if (t.length <= max) return t;
    return '${t.substring(0, max)}…';
  }

  String _uploadErrorMessage(Object e) {
    final raw = e.toString();
    if (raw.contains('403')) {
      return 'Upload blocked: an active subscription is required for RAG documents.';
    }
    if (raw.contains('Session expired') || raw.contains('401')) {
      return 'Session expired. Please sign in again.';
    }
    return raw.replaceFirst('Exception: ', '');
  }

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.sizeOf(context).width / appShellDesignWidth;
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;

    return AppShellScaffold(
      destination: AppShellDestination.intelligence,
      showAiFab: false,
      onTabSelected: (tab) => AppShellNavigation.onTabSelected(context, tab),
      onCenterNavTap: () => AppShellNavigation.openIntelligence(context),
      onAiTap: () => AppShellNavigation.openChatbot(context),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppScreenHeader(
            scale: scale,
            title: 'Manage Intelligence',
            leading: IntelligenceInfoButton(
              scale: scale,
              onTap: () => IntelligenceIntroModal.show(context),
            ),
            trailing: CreditsPill(
              scale: scale,
              creditCategory: CreditCategory.llm,
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              color: _accentColor,
              onRefresh: _loadRagPresence,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  21 * scale,
                  16 * scale,
                  21 * scale,
                  120 * scale + bottomInset,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        final user = state is Authenticated ? state.user : const {};
                        final industry =
                            (user['industry'] ?? 'Not set').toString();
                        final serviceArea = (user['location'] ??
                                user['address'] ??
                                'Not set')
                            .toString();
                        final businessName = (user['company'] ??
                                user['fullname'] ??
                                'Not set')
                            .toString();

                        return _IndexedFromOnboardingCard(
                          scale: scale,
                          industry: industry,
                          serviceArea: serviceArea,
                          businessName: businessName,
                          onUpdate: () {
                            Navigator.push<void>(
                              context,
                              MaterialPageRoute<void>(
                                builder: (_) => const SettingsPage(),
                              ),
                            );
                          },
                        );
                      },
                    ),
                    SizedBox(height: 16 * scale),
                    if (_presenceLoading)
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 8 * scale),
                        child: Center(
                          child: CircularProgressIndicator(color: _accentColor),
                        ),
                      )
                    else if (_presenceError != null)
                      _IntelligenceStatusBanner(
                        scale: scale,
                        message:
                            'Could not verify your documents. Pull to refresh.\n${_shortPresenceError(_presenceError!)}',
                        onRetry: _loadRagPresence,
                      )
                    else if (!_hasRagDocuments)
                      _IntelligenceStatusBanner(
                        scale: scale,
                        message: 'You have not uploaded any business data yet.',
                        icon: HomeFigmaIcons.warning,
                        iconColor: const Color(0xFFE11D48),
                      ),
                    SizedBox(height: 12 * scale),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 10 * scale,
                      crossAxisSpacing: 10 * scale,
                      childAspectRatio: 149 / 148,
                      children: [
                        _IntelligenceToolCard(
                          scale: scale,
                          title: 'Files',
                          subtitle: 'Upload/view files',
                          icon: HomeFigmaIcons.files,
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF22D3EE), Color(0xFF0891B2)],
                          ),
                          onTap: _showFilesSheet,
                        ),
                        _IntelligenceToolCard(
                          scale: scale,
                          title: 'Websites',
                          subtitle: 'View/index websites',
                          icon: HomeFigmaIcons.website,
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFFA3E635), Color(0xFF65A30D)],
                          ),
                          onTap: _showWebsitesSheet,
                        ),
                      ],
                    ),
                    SizedBox(height: 10 * scale),
                    _MyAiWideCard(scale: scale, onTap: _openMyAi),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IndexedFromOnboardingCard extends StatelessWidget {
  final double scale;
  final String industry;
  final String serviceArea;
  final String businessName;
  final VoidCallback onUpdate;

  const _IndexedFromOnboardingCard({
    required this.scale,
    required this.industry,
    required this.serviceArea,
    required this.businessName,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20 * scale),
        border: Border.all(color: Colors.black, width: 1),
      ),
      padding: EdgeInsets.all(16 * scale),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AiSparkleIcon(size: 28 * scale.clamp(0.9, 1.05)),
              const Spacer(),
              TextButton(
                onPressed: onUpdate,
                style: TextButton.styleFrom(
                  foregroundColor: _ManageIntelligenceState._accentColor,
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Update',
                  style: GoogleFonts.montserrat(
                    fontSize: 13 * scale.clamp(0.9, 1.05),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8 * scale),
          Text(
            'Indexed from onboarding',
            style: GoogleFonts.montserrat(
              color: Colors.black,
              fontSize: 14 * scale.clamp(0.9, 1.05),
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 12 * scale),
          _ProfileField(scale: scale, label: 'Industry', value: industry),
          SizedBox(height: 6 * scale),
          _ProfileField(scale: scale, label: 'Service Area', value: serviceArea),
          SizedBox(height: 6 * scale),
          _ProfileField(scale: scale, label: 'Business Name', value: businessName),
        ],
      ),
    );
  }
}

class _ProfileField extends StatelessWidget {
  final double scale;
  final String label;
  final String value;

  const _ProfileField({
    required this.scale,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final baseStyle = GoogleFonts.montserrat(
      fontSize: 12 * scale.clamp(0.85, 1.05),
      fontWeight: FontWeight.w500,
      height: 1.45,
    );

    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: '$label : ',
            style: baseStyle.copyWith(color: Colors.black.withValues(alpha: 0.85)),
          ),
          TextSpan(
            text: value,
            style: baseStyle.copyWith(color: _ManageIntelligenceState._valueColor),
          ),
        ],
      ),
    );
  }
}

class _IntelligenceStatusBanner extends StatelessWidget {
  final double scale;
  final String message;
  final VoidCallback? onRetry;
  final IconData icon;
  final Color iconColor;

  const _IntelligenceStatusBanner({
    required this.scale,
    required this.message,
    this.onRetry,
    this.icon = HomeFigmaIcons.cloudOff,
    this.iconColor = const Color(0xFFD97706),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14 * scale, vertical: 12 * scale),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16 * scale),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HomeSfIcon(icon: icon, color: iconColor, size: 22 * scale),
          SizedBox(width: 10 * scale),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.montserrat(
                color: _ManageIntelligenceState._valueColor,
                fontSize: 12 * scale.clamp(0.85, 1.05),
                height: 1.45,
              ),
            ),
          ),
          if (onRetry != null)
            IconButton(
              onPressed: onRetry,
              icon: HomeSfIcon(
                icon: HomeFigmaIcons.refresh,
                size: 20 * scale,
                color: _ManageIntelligenceState._mutedColor,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            ),
        ],
      ),
    );
  }
}

class _IntelligenceToolCard extends StatelessWidget {
  final double scale;
  final String title;
  final String subtitle;
  final IconData icon;
  final Gradient gradient;
  final VoidCallback onTap;

  const _IntelligenceToolCard({
    required this.scale,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.06),
      borderRadius: BorderRadius.circular(20 * scale),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20 * scale),
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            14 * scale,
            14 * scale,
            14 * scale,
            12 * scale,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40 * scale,
                height: 40 * scale,
                decoration: BoxDecoration(
                  gradient: gradient,
                  borderRadius: BorderRadius.circular(12 * scale),
                ),
                alignment: Alignment.center,
                child: HomeSfIcon(
                  icon: icon,
                  size: 20 * scale.clamp(0.9, 1.05),
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 10 * scale),
              Expanded(
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.montserrat(
                          color: Colors.black,
                          fontSize: 14 * scale.clamp(0.9, 1.05),
                          fontWeight: FontWeight.w600,
                          height: 1.25,
                        ),
                      ),
                      SizedBox(height: 4 * scale),
                      Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.montserrat(
                          color: _ManageIntelligenceState._mutedColor,
                          fontSize: 11 * scale.clamp(0.85, 1.05),
                          fontWeight: FontWeight.w400,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MyAiWideCard extends StatelessWidget {
  final double scale;
  final VoidCallback onTap;

  const _MyAiWideCard({required this.scale, required this.onTap});

  static const _gradientBorder = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF7F03B9), Color(0xFFEC4899)],
  );

  @override
  Widget build(BuildContext context) {
    final radius = 20 * scale;
    final height = 56 * scale;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            gradient: _gradientBorder,
          ),
          child: Container(
            margin: const EdgeInsets.all(1),
            height: height,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(radius - 1),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AiSparkleIcon(size: 22 * scale.clamp(0.9, 1.05)),
                SizedBox(width: 8 * scale),
                Text(
                  'My AI',
                  style: GoogleFonts.montserrat(
                    color: Colors.black,
                    fontSize: 14 * scale.clamp(0.9, 1.05),
                    fontWeight: FontWeight.w600,
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

class _WebsiteUrlDialog extends StatefulWidget {
  const _WebsiteUrlDialog();

  @override
  State<_WebsiteUrlDialog> createState() => _WebsiteUrlDialogState();
}

class _WebsiteUrlDialogState extends State<_WebsiteUrlDialog> {
  final _controller = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final value = _controller.text.trim();
    final normalized = _normalizeWebsiteUrlForApi(value);
    if (normalized == null) {
      setState(() {
        _error =
            'Enter a valid website URL (e.g. https://example.com or www.example.com)';
      });
      return;
    }
    Navigator.of(context).pop(normalized);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF1A1333),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: Colors.white.withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 22, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Index website',
              style: GoogleFonts.montserrat(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'We will scrape the public page and add its text to your business knowledge base.',
              style: GoogleFonts.montserrat(
                color: Colors.white.withValues(alpha: 0.75),
                fontSize: 12,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 18),
            TextField(
              controller: _controller,
              autofocus: true,
              keyboardType: TextInputType.url,
              style: GoogleFonts.montserrat(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'https://example.com or www.example.com',
                hintStyle: GoogleFonts.montserrat(
                  color: Colors.white.withValues(alpha: 0.4),
                  fontSize: 13,
                ),
                errorText: _error,
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.06),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: const Color(0xFF9333EA).withValues(alpha: 0.45),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: const Color(0xFF9333EA).withValues(alpha: 0.35),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFF9333EA)),
                ),
              ),
              onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.montserrat(
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: _submit,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF9333EA),
                  ),
                  child: Text(
                    'Index',
                    style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RagIndexProgressDialog extends StatefulWidget {
  final ApiService api;
  final String title;
  final Future<Map<String, dynamic>> Function() startJob;

  const _RagIndexProgressDialog({
    required this.api,
    required this.title,
    required this.startJob,
  });

  @override
  State<_RagIndexProgressDialog> createState() => _RagIndexProgressDialogState();
}

class _RagIndexProgressDialogState extends State<_RagIndexProgressDialog> {
  int _progress = 0;
  String _message = 'Starting…';
  String? _sourceLabel;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _run();
  }

  Future<void> _run() async {
    try {
      final started = await widget.startJob();
      final jobId = ApiService.ragIndexJobId(started);
      if (jobId == null) {
        if (!mounted) return;
        Navigator.of(context).pop();
        return;
      }

      while (mounted) {
        final status = await widget.api.getRagIndexJobStatus(jobId);
        if (!mounted) return;

        final progress = status['progress'];
        final message = (status['message'] ?? '').toString();
        final label = (status['source_label'] ?? '').toString();

        setState(() {
          if (progress is int) {
            _progress = progress.clamp(0, 100);
          } else if (progress is num) {
            _progress = progress.round().clamp(0, 100);
          }
          if (message.isNotEmpty) _message = message;
          if (label.isNotEmpty) _sourceLabel = label;
        });

        if (ApiService.ragIndexJobTerminal(status)) {
          if (!ApiService.ragIndexJobSucceeded(status)) {
            final err =
                (status['error'] ?? status['message'] ?? 'Indexing failed')
                    .toString();
            throw Exception(err);
          }
          if (!mounted) return;
          Navigator.of(context).pop();
          return;
        }

        await Future<void>.delayed(const Duration(milliseconds: 750));
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _failed = true;
        _message = e.toString().replaceFirst('Exception: ', '');
        _progress = 100;
      });
      await Future<void>.delayed(const Duration(milliseconds: 900));
      if (!mounted) return;
      Navigator.of(context).pop(e);
    }
  }

  String _statusHeadline() {
    final lower = _message.toLowerCase();
    if (lower.contains('scrap')) return 'Fetching website';
    if (lower.contains('upload')) return 'Uploading';
    if (lower.contains('extract')) return 'Extracting text';
    if (lower.contains('chunk')) return 'Preparing content';
    if (lower.contains('index')) return 'Indexing';
    if (lower.contains('validat')) return 'Validating';
    if (_failed) return 'Failed';
    return widget.title;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF1A1333),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: Colors.white.withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 26),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _statusHeadline(),
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (_sourceLabel != null) ...[
              const SizedBox(height: 8),
              Text(
                _sourceLabel!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(
                  color: Colors.white.withValues(alpha: 0.55),
                  fontSize: 11,
                ),
              ),
            ],
            const SizedBox(height: 20),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: _progress > 0 ? _progress / 100 : null,
                minHeight: 6,
                backgroundColor: Colors.white.withValues(alpha: 0.12),
                color: _failed ? Colors.red.shade400 : const Color(0xFF9333EA),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '$_progress% · $_message',
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class IntelligenceHistoryPage extends StatefulWidget {
  const IntelligenceHistoryPage({super.key});

  @override
  State<IntelligenceHistoryPage> createState() =>
      _IntelligenceHistoryPageState();
}

class _IntelligenceHistoryPageState extends State<IntelligenceHistoryPage> {
  List<Map<String, dynamic>> _documents = const [];
  bool _loading = true;
  String? _loadError;
  int? _expandedIndex;

  String _fileName(Map<String, dynamic> doc) =>
      (doc['file_name'] ?? '').toString();

  String? _objectKey(Map<String, dynamic> doc) {
    final k = doc['object_key'];
    if (k == null) return null;
    final s = k.toString();
    return s.isEmpty ? null : s;
  }

  String _displayTitle(Map<String, dynamic> doc) {
    final url = _ragDocSourceUrl(doc);
    if (url != null) return url;
    return _fileName(doc);
  }

  String _subtitle(Map<String, dynamic> doc) {
    if (_ragDocIsWebsite(doc)) {
      final name = _fileName(doc);
      return name.isEmpty ? 'Indexed website' : 'Saved as $name';
    }
    final key = _objectKey(doc);
    return key ?? '';
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) {
      _showSnack('Invalid URL');
      return;
    }
    try {
      final ok = await launchUrl(
        uri,
        mode: LaunchMode.platformDefault,
        webOnlyWindowName: '_blank',
      );
      if (!ok) _showSnack('Could not open website');
    } catch (_) {
      _showSnack('Could not open website');
    }
  }

  Future<void> _openFileUrl(Map<String, dynamic> doc) async {
    final raw = (doc['file_url'] ?? '').toString().trim();
    if (raw.isNotEmpty) {
      final uri = Uri.tryParse(raw);
      if (uri != null) {
        try {
          final ok = await launchUrl(
            uri,
            mode: LaunchMode.platformDefault,
            webOnlyWindowName: '_blank',
          );
          if (ok) return;
        } catch (_) {}
      }
    }

    // Fallback: authenticated download then open a local temp copy.
    final name = _fileName(doc);
    if (name.isEmpty) {
      _showSnack('No download link for this file');
      return;
    }
    if (kIsWeb) {
      _showSnack(
        'Could not open this file in the browser. The download link may have expired — try again from history.',
      );
      return;
    }
    try {
      _showSnack('Preparing file…');
      final api = context.read<ApiService>();
      final bytes = await api.downloadMyStorageFileBytes(
        folder: ApiService.chatbotStorageFolder,
        fileName: name,
      );
      final dest = File(
        '${Directory.systemTemp.path}${Platform.pathSeparator}$name',
      );
      await dest.writeAsBytes(bytes, flush: true);
      final fileUri = Uri.file(dest.path);
      final ok = await launchUrl(
        fileUri,
        mode: LaunchMode.platformDefault,
      );
      if (!ok) {
        _showSnack(
          'Downloaded "$name", but no app could open it on this device.',
        );
      }
    } catch (e) {
      _showSnack(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> _viewScrapedContent(Map<String, dynamic> doc) async {
    final isWebsite = _ragDocIsWebsite(doc);
    final name = _fileName(doc);
    final rawUrl = (doc['file_url'] ?? '').toString().trim();

    if (!isWebsite && name.isEmpty && rawUrl.isEmpty) {
      _showSnack('No content link available');
      return;
    }

    if (!mounted) return;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A0A2E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Color(0xFF3F1163)),
          ),
          title: Text(
            isWebsite ? 'Indexed content' : 'Indexed text preview',
            style: GoogleFonts.outfit(color: Colors.white, fontSize: 18),
          ),
          content: SizedBox(
            width: double.maxFinite,
            height: 320,
            child: FutureBuilder<String>(
              future: _loadPreviewText(doc),
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(
                    child: AutobusLoadingIndicator(size: 28),
                  );
                }
                if (snapshot.hasError) {
                  return Text(
                    snapshot.error.toString().replaceFirst('Exception: ', ''),
                    style: GoogleFonts.outfit(
                      color: Colors.white.withValues(alpha: 0.75),
                      fontSize: 13,
                    ),
                  );
                }
                final text = snapshot.data ?? '';
                if (text.trim().isEmpty) {
                  return Text(
                    'No preview available.',
                    style: GoogleFonts.outfit(
                      color: Colors.white.withValues(alpha: 0.75),
                      fontSize: 13,
                    ),
                  );
                }
                return Scrollbar(
                  thumbVisibility: true,
                  child: SingleChildScrollView(
                    child: SelectableText(
                      text,
                      style: GoogleFonts.outfit(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 13,
                        height: 1.45,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          actions: [
            if (!isWebsite)
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  _openFileUrl(doc);
                },
                child: Text(
                  'Open original',
                  style: GoogleFonts.outfit(color: Colors.white70),
                ),
              ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                'Close',
                style: GoogleFonts.outfit(color: const Color(0xFFA855F7)),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<String> _loadPreviewText(Map<String, dynamic> doc) async {
    final isWebsite = _ragDocIsWebsite(doc);
    final name = _fileName(doc);
    final rawUrl = (doc['file_url'] ?? '').toString().trim();

    // Websites and plain text can be shown from the stored object URL.
    if (isWebsite || _ragFileLooksLikePlainText(name)) {
      if (rawUrl.isEmpty) {
        throw Exception('No content link available');
      }
      return _fetchTextPreview(rawUrl);
    }

    // Word/PDF/spreadsheet: never render binary as text — use extracted index text.
    if (name.isEmpty) {
      throw Exception('No file name available for preview');
    }
    final api = context.read<ApiService>();
    return api.previewMyRagFileText(
      folder: ApiService.chatbotStorageFolder,
      fileName: name,
    );
  }

  Future<String> _fetchTextPreview(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to load content (${response.statusCode})');
    }
    // Guard against accidentally treating binary as UTF-8 text.
    final contentType = response.headers['content-type']?.toLowerCase() ?? '';
    if (contentType.contains('application/pdf') ||
        contentType.contains('officedocument') ||
        contentType.contains('msword') ||
        contentType.contains('octet-stream')) {
      throw Exception(
        'This file cannot be previewed as plain text. Use Open original.',
      );
    }
    final body = response.body.trim();
    if (body.contains('\u0000')) {
      throw Exception(
        'This file cannot be previewed as plain text. Use Open original.',
      );
    }
    const maxChars = 12000;
    if (body.length <= maxChars) return body;
    return '${body.substring(0, maxChars)}\n\n…';
  }

  Future<void> _clearIntelligence() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A0A2E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Color(0xFF3F1163)),
          ),
          title: Text(
            'Clear intelligence?',
            style: GoogleFonts.outfit(color: Colors.white, fontSize: 18),
          ),
          content: Text(
            'This removes all uploaded documents and websites from storage '
            'and from the search index. Chat history is kept. '
            'You can upload your data again afterwards.',
            style: GoogleFonts.outfit(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 14,
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(
                'Cancel',
                style: GoogleFonts.outfit(color: Colors.white70),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(
                'Clear all',
                style: GoogleFonts.outfit(color: const Color(0xFFFF6B6B)),
              ),
            ),
          ],
        );
      },
    );
    if (confirmed != true || !mounted) return;

    try {
      final api = context.read<ApiService>();
      final message = await api.clearMyIntelligence();
      if (!mounted) return;
      await _loadDocuments();
      _showSnack(message);
    } catch (e) {
      if (!mounted) return;
      _showSnack(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message, style: GoogleFonts.outfit())),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadDocuments());
  }

  Future<void> _loadDocuments() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    try {
      final api = context.read<ApiService>();
      final list = await api.listMyStorageFiles(
        folder: ApiService.chatbotStorageFolder,
      );
      if (!mounted) return;
      setState(() {
        _documents = list;
        _loading = false;
        _expandedIndex = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadError = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _deleteAt(int index) async {
    final doc = _documents[index];
    final name = _fileName(doc);
    if (name.isEmpty) return;
    try {
      final api = context.read<ApiService>();
      await api.deleteMyStorageFile(
        folder: ApiService.chatbotStorageFolder,
        fileName: name,
      );
      if (!mounted) return;
      setState(() {
        _documents = List<Map<String, dynamic>>.from(_documents)
          ..removeAt(index);
        _expandedIndex = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Deleted "$name"', style: GoogleFonts.outfit())),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst('Exception: ', ''),
            style: GoogleFonts.outfit(),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.sizeOf(context).width / appShellDesignWidth;

    return LightScreenScaffold(
      title: 'Manage Intelligence',
      creditCategory: CreditCategory.llm,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!_loading && _loadError == null && _documents.isNotEmpty)
            Padding(
              padding: EdgeInsets.fromLTRB(20 * scale, 4 * scale, 20 * scale, 0),
              child: Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: _clearIntelligence,
                  icon: HomeSfIcon(
                    icon: HomeFigmaIcons.delete,
                    color: Colors.red.shade400,
                    size: 18 * scale.clamp(0.9, 1.05),
                  ),
                  label: Text(
                    'Clear intelligence',
                    style: GoogleFonts.montserrat(
                      color: Colors.red.shade400,
                      fontSize: 13 * scale.clamp(0.9, 1.05),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          Expanded(
            child: _loading
                ? Center(
                    child: CircularProgressIndicator(color: LightScreenTheme.accent),
                  )
                : _loadError != null
                    ? Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 28 * scale),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _loadError!,
                                textAlign: TextAlign.center,
                                style: LightScreenTheme.emptyState(scale),
                              ),
                              SizedBox(height: 16 * scale),
                              TextButton(
                                onPressed: _loadDocuments,
                                child: Text(
                                  'Retry',
                                  style: GoogleFonts.montserrat(
                                    color: LightScreenTheme.accent,
                                    fontSize: 14 * scale.clamp(0.9, 1.05),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : _documents.isEmpty
                        ? Center(
                            child: Text(
                              'No documents or websites indexed yet',
                              style: LightScreenTheme.emptyState(scale),
                            ),
                          )
                        : RefreshIndicator(
                            color: LightScreenTheme.accent,
                            onRefresh: _loadDocuments,
                            child: ListView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: EdgeInsets.fromLTRB(
                                20 * scale,
                                8 * scale,
                                20 * scale,
                                24 * scale,
                              ),
                              itemCount: _documents.length,
                              itemBuilder: (context, index) {
                                final doc = _documents[index];
                                final isWebsite = _ragDocIsWebsite(doc);
                                final title = _displayTitle(doc);
                                final subtitle = _subtitle(doc);
                                final sourceUrl = _ragDocSourceUrl(doc);
                                final isExpanded = _expandedIndex == index;

                                return Padding(
                                  padding: EdgeInsets.only(bottom: 12 * scale),
                                  child: LightListCard(
                                    scale: scale,
                                    padding: EdgeInsets.all(
                                      isExpanded ? 24 * scale : 20 * scale,
                                    ),
                                    onTap: () {
                                      setState(() {
                                        _expandedIndex =
                                            isExpanded ? null : index;
                                      });
                                    },
                                    child: isExpanded
                                        ? Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  HomeSfIcon(
                                                    icon: isWebsite
                                                        ? HomeFigmaIcons.website
                                                        : HomeFigmaIcons.files,
                                                    color: LightScreenTheme.accent,
                                                    size: 20 * scale.clamp(0.9, 1.05),
                                                  ),
                                                  SizedBox(width: 8 * scale),
                                                  Expanded(
                                                    child: Text(
                                                      isWebsite
                                                          ? 'Website'
                                                          : 'Document',
                                                      style: LightScreenTheme
                                                          .listSubtitle(scale),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 10 * scale),
                                              Text(
                                                title,
                                                style: LightScreenTheme.listTitle(
                                                  scale,
                                                ).copyWith(
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              if (subtitle.isNotEmpty) ...[
                                                SizedBox(height: 12 * scale),
                                                Text(
                                                  subtitle,
                                                  style: LightScreenTheme
                                                      .listSubtitle(scale),
                                                ),
                                              ],
                                              SizedBox(height: 16 * scale),
                                              if (isWebsite && sourceUrl != null)
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                    bottom: 8 * scale,
                                                  ),
                                                  child: SizedBox(
                                                    width: double.infinity,
                                                    child: TextButton(
                                                      onPressed: () =>
                                                          _openUrl(sourceUrl),
                                                      child: Text(
                                                        'Open website',
                                                        style: GoogleFonts
                                                            .montserrat(
                                                          color: LightScreenTheme
                                                              .accent,
                                                          fontSize: 13 *
                                                              scale.clamp(
                                                                0.9,
                                                                1.05,
                                                              ),
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              SizedBox(
                                                width: double.infinity,
                                                child: TextButton(
                                                  onPressed: () =>
                                                      _viewScrapedContent(doc),
                                                  child: Text(
                                                    isWebsite
                                                        ? 'View indexed content'
                                                        : 'View indexed text',
                                                    style: GoogleFonts.montserrat(
                                                      color: LightScreenTheme.body,
                                                      fontSize: 13 *
                                                          scale.clamp(0.9, 1.05),
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              if (!isWebsite)
                                                SizedBox(
                                                  width: double.infinity,
                                                  child: TextButton(
                                                    onPressed: () =>
                                                        _openFileUrl(doc),
                                                    child: Text(
                                                      'Open original',
                                                      style: GoogleFonts
                                                          .montserrat(
                                                        color: LightScreenTheme
                                                            .muted,
                                                        fontSize: 13 *
                                                            scale.clamp(
                                                              0.9,
                                                              1.05,
                                                            ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              SizedBox(height: 4 * scale),
                                              Center(
                                                child: TextButton(
                                                  onPressed: () =>
                                                      _deleteAt(index),
                                                  child: Text(
                                                    isWebsite
                                                        ? 'Remove website'
                                                        : 'Delete file',
                                                    style: GoogleFonts.montserrat(
                                                      color: LightScreenTheme.muted,
                                                      fontSize: 13 *
                                                          scale.clamp(0.9, 1.05),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          )
                                        : Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  HomeSfIcon(
                                                    icon: isWebsite
                                                        ? HomeFigmaIcons.website
                                                        : HomeFigmaIcons.files,
                                                    color: LightScreenTheme.accent,
                                                    size: 18 * scale.clamp(0.9, 1.05),
                                                  ),
                                                  SizedBox(width: 8 * scale),
                                                  Expanded(
                                                    child: Text(
                                                      title,
                                                      maxLines: 2,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: LightScreenTheme
                                                          .listTitle(scale)
                                                          .copyWith(
                                                            fontSize: 16 *
                                                                scale.clamp(
                                                                  0.9,
                                                                  1.05,
                                                                ),
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              if (subtitle.isNotEmpty) ...[
                                                SizedBox(height: 6 * scale),
                                                Text(
                                                  subtitle,
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: LightScreenTheme
                                                      .listSubtitle(scale),
                                                ),
                                              ],
                                            ],
                                          ),
                                  ),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}
