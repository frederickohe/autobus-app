import 'package:autobus/barrel.dart';
import 'package:autobus/common_design/light_screen_theme.dart';
import 'package:autobus/common_design/widgets/app_bottom_nav.dart';
import 'package:autobus/common_design/widgets/light_screen_scaffold.dart';

/// How the conversation screen was opened (controls which actions appear).
enum ConversationScreenMode {
  /// Completed / all chats — history only.
  historyOnly,

  /// Live chat with active intervention — history + agent messaging.
  liveChat,
}

class ConversationDetailScreen extends StatefulWidget {
  final String title;
  final ConversationScreenMode mode;

  /// Daily conversation session id (`DailyConversation.id` from list API).
  final int? sessionId;

  const ConversationDetailScreen({
    super.key,
    required this.title,
    required this.mode,
    this.sessionId,
  });

  @override
  State<ConversationDetailScreen> createState() =>
      _ConversationDetailScreenState();
}

class _ConversationDetailScreenState extends State<ConversationDetailScreen> {
  final _messageCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  Map<String, dynamic>? _detail;
  bool _loading = true;
  String? _loadError;
  bool _actionBusy = false;
  bool _sending = false;
  Timer? _livePollTimer;
  bool _polling = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _stopLivePolling();
    _messageCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _startLivePolling() {
    _stopLivePolling();
    if (widget.mode != ConversationScreenMode.liveChat) return;
    _livePollTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      unawaited(_pollLiveSession());
    });
  }

  void _stopLivePolling() {
    _livePollTimer?.cancel();
    _livePollTimer = null;
  }

  Future<void> _pollLiveSession() async {
    if (!mounted || _loading || _sending || _polling || _actionBusy) return;
    if (widget.mode != ConversationScreenMode.liveChat) return;
    final sid = _resolvedSessionId;
    if (sid == null) return;

    _polling = true;
    try {
      final api = context.read<ApiService>();
      final detail = await api.getConversationSession(sid);
      if (!mounted) return;

      final prevLen = _history.length;
      final raw = detail['conversation_history'];
      final nextLen = raw is List ? raw.length : 0;

      setState(() => _detail = detail);

      final active = detail['intervention_active'];
      final isActive =
          active is bool ? active : active?.toString().toLowerCase() == 'true';
      if (!isActive) {
        _stopLivePolling();
      } else if (nextLen > prevLen) {
        _scrollToBottom();
      }
    } catch (_) {
      // Polling is best-effort; ignore transient errors.
    } finally {
      _polling = false;
    }
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    try {
      final api = context.read<ApiService>();
      final sid = widget.sessionId;
      if (sid == null) {
        throw Exception('Missing conversation session');
      }
      final detail = await api.getConversationSession(sid);
      if (!mounted) return;
      setState(() {
        _detail = detail;
        _loading = false;
      });
      _scrollToBottom();
      if (widget.mode == ConversationScreenMode.liveChat) {
        final active = detail['intervention_active'];
        final isActive =
            active is bool ? active : active?.toString().toLowerCase() == 'true';
        if (isActive) {
          _startLivePolling();
        }
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadError = e.toString().replaceFirst('Exception: ', '');
        _loading = false;
      });
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollCtrl.hasClients) return;
      _scrollCtrl.animateTo(
        _scrollCtrl.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    });
  }

  List<Map<String, dynamic>> get _history {
    final raw = _detail?['conversation_history'];
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  int? get _resolvedSessionId {
    final fromDetail = _detail?['id'];
    if (fromDetail is int) return fromDetail;
    if (fromDetail is num) return fromDetail.toInt();
    return widget.sessionId;
  }

  bool get _interventionActive {
    final v = _detail?['intervention_active'];
    if (v is bool) return v;
    return v?.toString().toLowerCase() == 'true';
  }

  bool get _showComposer =>
      widget.mode == ConversationScreenMode.liveChat && _interventionActive;

  Future<void> _deactivateIntervention() async {
    final sid = _resolvedSessionId;
    if (sid == null) return;
    setState(() => _actionBusy = true);
    try {
      final api = context.read<ApiService>();
      final updated = await api.deactivateConversationIntervention(sid);
      if (!mounted) return;
      setState(() {
        _detail = updated;
        _actionBusy = false;
      });
      _stopLivePolling();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Intervention turned off')),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _actionBusy = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageCtrl.text.trim();
    final sid = _resolvedSessionId;
    if (text.isEmpty || sid == null || _sending) return;

    setState(() => _sending = true);
    try {
      final api = context.read<ApiService>();
      final updated = await api.sendInterventionHumanMessage(
        text,
        sessionId: sid,
      );
      if (!mounted) return;
      _messageCtrl.clear();
      final hasHistory = updated.containsKey('conversation_history');
      setState(() {
        if (hasHistory || updated.containsKey('id')) {
          _detail = updated;
        }
        _sending = false;
      });
      if (hasHistory) {
        _scrollToBottom();
      } else {
        await _load();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _sending = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  Widget _buildControls(double scale) {
    if (widget.mode == ConversationScreenMode.liveChat &&
        _interventionActive) {
      return Padding(
        padding: EdgeInsets.fromLTRB(20 * scale, 12 * scale, 20 * scale, 0),
        child: SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: _actionBusy ? null : _deactivateIntervention,
            style: FilledButton.styleFrom(
              backgroundColor: LightScreenTheme.accent,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 14 * scale),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20 * scale),
              ),
            ),
            icon: _actionBusy
                ? SizedBox(
                    width: 18 * scale,
                    height: 18 * scale,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Icon(Icons.smart_toy_outlined, size: 20 * scale),
            label: Text(
              'Turn off intervention',
              style: GoogleFonts.montserrat(
                fontSize: 15 * scale.clamp(0.9, 1.05),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildComposer(double scale) {
    final canSend = _messageCtrl.text.trim().isNotEmpty && !_sending;

    return Padding(
      padding: EdgeInsets.fromLTRB(16 * scale, 8 * scale, 16 * scale, 12 * scale),
      child: Container(
        padding: EdgeInsets.fromLTRB(16 * scale, 12 * scale, 8 * scale, 8 * scale),
        decoration: BoxDecoration(
          color: LightScreenTheme.surface,
          borderRadius: BorderRadius.circular(24 * scale),
          border: Border.all(color: LightScreenTheme.hint.withValues(alpha: 0.5)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _messageCtrl,
              enabled: !_sending,
              cursorColor: LightScreenTheme.accent,
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.newline,
              minLines: 1,
              maxLines: 4,
              onChanged: (_) => setState(() {}),
              onSubmitted: canSend ? (_) => _sendMessage() : null,
              style: GoogleFonts.montserrat(
                color: Colors.black87,
                fontSize: 14 * scale.clamp(0.9, 1.05),
              ),
              decoration: InputDecoration(
                hintText: 'Reply as agent…',
                hintStyle: GoogleFonts.montserrat(
                  color: LightScreenTheme.hint,
                  fontSize: 14 * scale.clamp(0.9, 1.05),
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
            Row(
              children: [
                const Spacer(),
                IconButton(
                  onPressed: canSend ? _sendMessage : null,
                  icon: _sending
                      ? SizedBox(
                          width: 22 * scale,
                          height: 22 * scale,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: LightScreenTheme.accent,
                          ),
                        )
                      : Icon(
                          Icons.send_rounded,
                          color: canSend
                              ? LightScreenTheme.accent
                              : LightScreenTheme.hint,
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(double scale) {
    if (_loading) {
      return Center(child: CircularProgressIndicator(color: LightScreenTheme.accent));
    }
    if (_loadError != null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(24 * scale),
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
                onPressed: _load,
                child: Text(
                  'Retry',
                  style: LightScreenTheme.listTitle(scale).copyWith(
                    color: LightScreenTheme.accent,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final history = _history;
    if (history.isEmpty) {
      return Center(
        child: Text(
          _showComposer
              ? 'No messages yet — send a reply below'
              : 'No messages in this conversation',
          textAlign: TextAlign.center,
          style: LightScreenTheme.emptyState(scale),
        ),
      );
    }

    return ListView.builder(
      controller: _scrollCtrl,
      padding: EdgeInsets.fromLTRB(20 * scale, 16 * scale, 20 * scale, 24 * scale),
      itemCount: history.length,
      itemBuilder: (context, index) {
        final msg = history[index];
        final role = (msg['role'] ?? '').toString().toLowerCase();
        final content = (msg['content'] ?? '').toString();
        final isUser = role == 'user';
        return Padding(
          padding: EdgeInsets.only(bottom: 12 * scale),
          child: Align(
            alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
            child: _messageBubble(scale, content, isUser: isUser, role: role),
          ),
        );
      },
    );
  }

  Widget _messageBubble(
    double scale,
    String text, {
    required bool isUser,
    required String role,
  }) {
    final bg = isUser ? LightScreenTheme.accent : LightScreenTheme.surface;
    final fg = isUser ? Colors.white : LightScreenTheme.body;

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.sizeOf(context).width * 0.78,
      ),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14 * scale, vertical: 10 * scale),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(isUser ? 16 * scale : 4 * scale),
            topRight: Radius.circular(isUser ? 4 * scale : 16 * scale),
            bottomLeft: Radius.circular(16 * scale),
            bottomRight: Radius.circular(16 * scale),
          ),
          border: isUser
              ? null
              : Border.all(color: LightScreenTheme.hint.withValues(alpha: 0.4)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (role == 'human')
              Padding(
                padding: EdgeInsets.only(bottom: 4 * scale),
                child: Text(
                  'Agent',
                  style: GoogleFonts.montserrat(
                    color: LightScreenTheme.accent,
                    fontSize: 10 * scale.clamp(0.9, 1.05),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            Text(
              text,
              style: GoogleFonts.montserrat(
                color: fg,
                fontSize: 14 * scale.clamp(0.9, 1.05),
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.sizeOf(context).width / appShellDesignWidth;

    return LightScreenScaffold(
      title: widget.title,
      creditCategory: CreditCategory.llm,
      resizeToAvoidBottomInset: true,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!_loading && _loadError == null) _buildControls(scale),
          Expanded(child: _buildBody(scale)),
          if (_showComposer) _buildComposer(scale),
        ],
      ),
    );
  }
}
