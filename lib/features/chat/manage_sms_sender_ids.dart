import 'package:autobus/barrel.dart';
import 'package:autobus/common_design/light_screen_theme.dart';
import 'package:autobus/common_design/widgets/app_bottom_nav.dart';
import 'package:autobus/common_design/widgets/app_screen_header.dart';
import 'package:autobus/common_design/widgets/credits_pill.dart';
import 'package:autobus/common_design/widgets/light_list_card.dart';
import 'package:autobus/common_design/widgets/light_screen_scaffold.dart';
import 'package:autobus/icons/home_figma_icons.dart';

class ManageSmsSenderIds extends StatefulWidget {
  const ManageSmsSenderIds({super.key});

  @override
  State<ManageSmsSenderIds> createState() => _ManageSmsSenderIdsState();
}

class _ManageSmsSenderIdsState extends State<ManageSmsSenderIds> {
  var _loading = true;
  String? _loadError;
  List<Map<String, dynamic>> _rows = const [];

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    try {
      final rows = await context.read<ApiService>().listSmsSenderIds();
      if (!mounted) return;
      setState(() {
        _rows = rows;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadError = userFacingError(e);
        _rows = const [];
        _loading = false;
      });
    }
  }

  List<Map<String, dynamic>> get _approved => _rows
      .where((r) => (r['status'] ?? '').toString().toLowerCase() == 'approved')
      .toList();

  List<Map<String, dynamic>> get _notApproved => _rows
      .where((r) => (r['status'] ?? '').toString().toLowerCase() != 'approved')
      .toList();

  Future<void> _openRegisterDialog() async {
    final result =
        await showDialog<({String senderId, String? companyName, String? notes})>(
      context: context,
      builder: (_) => const _SmsSenderIdDialog(),
    );
    if (!mounted || result == null) return;

    try {
      await context.read<ApiService>().registerSmsSenderId(
            senderId: result.senderId,
            companyName: result.companyName,
            notes: result.notes,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Sender ID submitted for approval.',
            style: GoogleFonts.montserrat(),
          ),
        ),
      );
      await _refresh();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            userFacingError(e),
            style: GoogleFonts.montserrat(),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.sizeOf(context).width / appShellDesignWidth;

    return LightScreenScaffold(
      title: 'SMS Sender IDs',
      creditCategory: CreditCategory.llm,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!_loading)
            IconButton(
              onPressed: _refresh,
              icon: HomeSfIcon(
                icon: HomeFigmaIcons.refresh,
                color: AppScreenHeader.iconColor,
                size: 22 * scale,
              ),
              tooltip: 'Refresh',
            ),
          IconButton(
            onPressed: _openRegisterDialog,
            icon: HomeSfIcon(
              icon: HomeFigmaIcons.add,
              color: AppScreenHeader.iconColor,
              size: 24 * scale,
            ),
            tooltip: 'Register Sender ID',
          ),
          CreditsPill(scale: scale, creditCategory: CreditCategory.llm),
        ],
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator(color: LightScreenTheme.accent))
          : RefreshIndicator(
              onRefresh: _refresh,
              color: LightScreenTheme.accent,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.fromLTRB(20 * scale, 12 * scale, 20 * scale, 100 * scale),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Register a Sender ID for SMS. Approved IDs can be used after the Autobus team verifies them.',
                      style: LightScreenTheme.hubBody(scale).copyWith(fontSize: 12 * scale.clamp(0.9, 1.05)),
                    ),
                    SizedBox(height: 20 * scale),
                    if (_loadError != null) ...[
                      Text(
                        _loadError!,
                        textAlign: TextAlign.center,
                        style: LightScreenTheme.emptyState(scale).copyWith(
                          color: LightScreenTheme.warning,
                        ),
                      ),
                      SizedBox(height: 16 * scale),
                    ],
                    _SectionHeader(scale: scale, title: 'Approved', count: _approved.length),
                    SizedBox(height: 12 * scale),
                    if (_approved.isEmpty)
                      _EmptyHint(scale: scale, text: 'No approved Sender IDs yet.')
                    else
                      for (final row in _approved)
                        _SenderIdCard(scale: scale, row: row),
                    SizedBox(height: 28 * scale),
                    _SectionHeader(scale: scale, title: 'Not approved', count: _notApproved.length),
                    SizedBox(height: 12 * scale),
                    if (_notApproved.isEmpty)
                      _EmptyHint(
                        scale: scale,
                        text: 'No pending or rejected Sender IDs.',
                      )
                    else
                      for (final row in _notApproved)
                        _SenderIdCard(scale: scale, row: row),
                  ],
                ),
              ),
            ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final double scale;
  final String title;
  final int count;

  const _SectionHeader({
    required this.scale,
    required this.title,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title, style: LightScreenTheme.listTitle(scale)),
        SizedBox(width: 8 * scale),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8 * scale, vertical: 2 * scale),
          decoration: BoxDecoration(
            color: LightScreenTheme.surface,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            '$count',
            style: LightScreenTheme.listSubtitle(scale).copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptyHint extends StatelessWidget {
  final double scale;
  final String text;

  const _EmptyHint({required this.scale, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8 * scale),
      child: Text(text, style: LightScreenTheme.emptyState(scale)),
    );
  }
}

class _SenderIdCard extends StatelessWidget {
  final double scale;
  final Map<String, dynamic> row;

  const _SenderIdCard({required this.scale, required this.row});

  static String _statusLabel(String status) {
    switch (status) {
      case 'approved':
        return 'Approved';
      case 'rejected':
        return 'Rejected';
      default:
        return 'Pending approval';
    }
  }

  static Color _statusColor(String status) {
    switch (status) {
      case 'approved':
        return const Color(0xFF22C55E);
      case 'rejected':
        return const Color(0xFFEF4444);
      default:
        return LightScreenTheme.warning;
    }
  }

  @override
  Widget build(BuildContext context) {
    final senderId = (row['sender_id'] ?? '').toString();
    final status = (row['status'] ?? 'pending').toString().toLowerCase();
    final company = (row['company_name'] ?? '').toString().trim();
    final notes = (row['notes'] ?? '').toString().trim();
    final rejection = (row['rejection_reason'] ?? '').toString().trim();
    final statusColor = _statusColor(status);

    return Padding(
      padding: EdgeInsets.only(bottom: 12 * scale),
      child: LightListCard(
        scale: scale,
        padding: EdgeInsets.fromLTRB(16 * scale, 14 * scale, 16 * scale, 14 * scale),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(senderId, style: LightScreenTheme.listTitle(scale)),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10 * scale,
                    vertical: 4 * scale,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: statusColor.withValues(alpha: 0.5)),
                  ),
                  child: Text(
                    _statusLabel(status),
                    style: GoogleFonts.montserrat(
                      color: statusColor,
                      fontSize: 11 * scale.clamp(0.9, 1.05),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            if (company.isNotEmpty) ...[
              SizedBox(height: 8 * scale),
              Text(company, style: LightScreenTheme.listSubtitle(scale)),
            ],
            if (notes.isNotEmpty) ...[
              SizedBox(height: 6 * scale),
              Text(
                notes,
                style: LightScreenTheme.hubBody(scale).copyWith(fontSize: 12 * scale.clamp(0.9, 1.05)),
              ),
            ],
            if (rejection.isNotEmpty) ...[
              SizedBox(height: 8 * scale),
              Text(
                'Reason: $rejection',
                style: GoogleFonts.montserrat(
                  color: const Color(0xFFEF4444),
                  fontSize: 12 * scale.clamp(0.9, 1.05),
                  height: 1.4,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SmsSenderIdDialog extends StatefulWidget {
  const _SmsSenderIdDialog();

  @override
  State<_SmsSenderIdDialog> createState() => _SmsSenderIdDialogState();
}

class _SmsSenderIdDialogState extends State<_SmsSenderIdDialog> {
  final _senderIdController = TextEditingController();
  final _companyController = TextEditingController();
  final _notesController = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _senderIdController.dispose();
    _companyController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  InputDecoration _fieldDecoration({
    required String hint,
    String? errorText,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.montserrat(
        color: LightScreenTheme.hint,
        fontSize: 13,
      ),
      errorText: errorText,
      filled: true,
      fillColor: LightScreenTheme.field,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: LightScreenTheme.hint.withValues(alpha: 0.5)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: LightScreenTheme.hint.withValues(alpha: 0.4)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: LightScreenTheme.accent),
      ),
    );
  }

  void _submit() {
    final senderId = _senderIdController.text.trim();
    if (senderId.length < 3) {
      setState(() {
        _error = 'Enter a Sender ID (at least 3 characters).';
      });
      return;
    }
    Navigator.of(context).pop((
      senderId: senderId,
      companyName: _companyController.text.trim().isEmpty
          ? null
          : _companyController.text.trim(),
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final maxHeight =
        (media.size.height - media.viewInsets.bottom - 48).clamp(240.0, media.size.height * 0.85);
    return Dialog(
      backgroundColor: LightScreenTheme.surface,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: LightScreenTheme.hint.withValues(alpha: 0.4)),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 22, 24, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Register SMS Sender ID',
                style: GoogleFonts.montserrat(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Submit the name that appears as the SMS sender. The Autobus team will verify and approve it before it can be used.',
                style: GoogleFonts.montserrat(
                  color: LightScreenTheme.body,
                  fontSize: 12,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 18),
              TextField(
                controller: _senderIdController,
                autofocus: true,
                style: GoogleFonts.montserrat(color: Colors.black87, fontSize: 14),
                textCapitalization: TextCapitalization.characters,
                decoration: _fieldDecoration(
                  hint: 'Sender ID (e.g. AutoBus)',
                  errorText: _error,
                ),
                onChanged: (_) {
                  if (_error != null) setState(() => _error = null);
                },
                onSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _companyController,
                style: GoogleFonts.montserrat(color: Colors.black87, fontSize: 14),
                decoration: _fieldDecoration(hint: 'Company name (optional)'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _notesController,
                style: GoogleFonts.montserrat(color: Colors.black87, fontSize: 14),
                maxLines: 2,
                decoration: _fieldDecoration(hint: 'Notes (optional)'),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.montserrat(color: LightScreenTheme.muted),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: _submit,
                    style: FilledButton.styleFrom(
                      backgroundColor: LightScreenTheme.accent,
                    ),
                    child: Text(
                      'Submit',
                      style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
