import 'package:autobus/barrel.dart';
import 'package:autobus/common_design/widgets/app_bottom_nav.dart';
import 'package:autobus/common_design/widgets/app_screen_header.dart';
import 'package:autobus/common_design/widgets/credits_pill.dart';
import 'package:autobus/features/autochat/chat_bloc.dart';
import 'package:autobus/icons/home_figma_icons.dart';
import 'package:autobus/features/autochat/chat_event.dart';
import 'package:autobus/features/autochat/chat_state.dart';
import 'package:autobus/features/autochat/models/chat_message.dart';
import 'package:autobus/features/autochat/services/autochat_repository.dart';
import 'package:flutter_sficon/flutter_sficon.dart';
import 'package:http/http.dart' as http;

/// My AI chat — Figma INTELLIGENCE frame 3237:2750.
class IntelligenceMyAiPage extends StatelessWidget {
  const IntelligenceMyAiPage({super.key});

  static const webhookContext = 'interactions_agent';

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is! Authenticated) {
          return const Scaffold(
            backgroundColor: Color(0xFFF3F3F7),
            body: Center(child: AutobusLoadingIndicator()),
          );
        }

        return BlocProvider(
          create: (_) => ChatBloc(AutoChatRepository(client: http.Client())),
          child: _IntelligenceMyAiChatBody(user: authState.user),
        );
      },
    );
  }
}

class _IntelligenceMyAiChatBody extends StatefulWidget {
  final Map<String, dynamic> user;

  const _IntelligenceMyAiChatBody({required this.user});

  @override
  State<_IntelligenceMyAiChatBody> createState() =>
      _IntelligenceMyAiChatBodyState();
}

class _IntelligenceMyAiChatBodyState extends State<_IntelligenceMyAiChatBody> {
  static const _backgroundColor = Color(0xFFF3F3F7);

  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      if (mounted) setState(() {});
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _sendHiddenHello();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  String _userPhone() {
    final phone = widget.user['phone'] ?? widget.user['phoneNumber'];
    if (phone != null) return phone.toString();
    return 'unknown';
  }

  String _userCompanyNumber() {
    final id = widget.user['id'];
    if (id == null) return '';
    return id.toString().trim();
  }

  void _sendHiddenHello() {
    if (!mounted) return;
    context.read<ChatBloc>().add(
      SendMessage(
        phone: _userPhone(),
        message: 'hello',
        companyNumber: _userCompanyNumber(),
        context: IntelligenceMyAiPage.webhookContext,
        hidden: true,
      ),
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    context.read<ChatBloc>().add(
      SendMessage(
        phone: _userPhone(),
        message: text,
        companyNumber: _userCompanyNumber(),
        context: IntelligenceMyAiPage.webhookContext,
      ),
    );
    _controller.clear();
    _scrollToBottom();
  }

  String _formatTimestamp(DateTime timestamp) {
    final diff = DateTime.now().difference(timestamp);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) {
      final m = diff.inMinutes;
      return m == 1 ? '1 min ago' : '$m min ago';
    }
    if (diff.inHours < 24) {
      final h = diff.inHours;
      return h == 1 ? '1 hr ago' : '$h hr ago';
    }
    return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
  }

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.sizeOf(context).width / appShellDesignWidth;

    return Scaffold(
      backgroundColor: _backgroundColor,
      resizeToAvoidBottomInset: true,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppScreenHeader(
            scale: scale,
            title: 'My AI',
            titleFontSize: 16,
            leading: _MyAiBackButton(scale: scale),
            trailing: CreditsPill(
              scale: scale,
              creditCategory: CreditCategory.llm,
            ),
          ),
          Expanded(
            child: BlocConsumer<ChatBloc, ChatState>(
              listener: (_, __) => _scrollToBottom(),
              builder: (context, state) {
                if (state is ChatLoadInProgress) {
                  return const Center(child: AutobusLoadingIndicator(size: 28));
                }

                if (state is ChatLoadFailure) {
                  return ListView(
                    controller: _scrollController,
                    padding: EdgeInsets.fromLTRB(
                      20 * scale,
                      20 * scale,
                      20 * scale,
                      20 * scale,
                    ),
                    children: [
                      _MyAiMessageRow(
                        scale: scale,
                        isUser: false,
                        text:
                            'Unable to start the conversation. Please try again.',
                        timestamp: 'Just now',
                        user: widget.user,
                      ),
                    ],
                  );
                }

                final messages = state is ChatLoadSuccess
                    ? state.messages
                    : <ChatMessage>[];

                if (messages.isEmpty) {
                  return const Center(child: AutobusLoadingIndicator(size: 28));
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.fromLTRB(
                    20 * scale,
                    20 * scale,
                    20 * scale,
                    12 * scale,
                  ),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    return Padding(
                      padding: EdgeInsets.only(bottom: 20 * scale),
                      child: _MyAiMessageRow(
                        scale: scale,
                        isUser: message.sender == Sender.user,
                        text: message.text,
                        timestamp: _formatTimestamp(message.timestamp),
                        user: widget.user,
                        pending: message.status == MessageStatus.pending,
                      ),
                    );
                  },
                );
              },
            ),
          ),
          _MyAiInputBar(
            scale: scale,
            controller: _controller,
            canSend: _controller.text.trim().isNotEmpty,
            onSend: _sendMessage,
          ),
        ],
      ),
    );
  }
}

class _MyAiBackButton extends StatelessWidget {
  final double scale;

  const _MyAiBackButton({required this.scale});

  @override
  Widget build(BuildContext context) {
    final headerScale = scale.clamp(0.9, 1.0);
    final size = 36 * headerScale;
    return Material(
      color: AppScreenHeader.infoCircleColor,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.of(context).maybePop(),
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: size,
          height: size,
          child: Center(
            child: HomeSfIcon(
              icon: SFIcons.sf_chevron_left,
              color: AppScreenHeader.iconColor,
              size: 18 * headerScale,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _MyAiMessageRow extends StatelessWidget {
  final double scale;
  final bool isUser;
  final String text;
  final String timestamp;
  final Map<String, dynamic> user;
  final bool pending;

  const _MyAiMessageRow({
    required this.scale,
    required this.isUser,
    required this.text,
    required this.timestamp,
    required this.user,
    this.pending = false,
  });

  static const _surfaceColor = Color(0xFFF8FAFC);
  static const _timestampColor = Color(0xFF94A3B8);
  static const _bubbleTextColor = Color(0xFF475569);
  static const _accentColor = Color(0xFF7F03B9);

  static const _userGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color(0xFF6366F1),
      Color(0xFFA855F7),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final avatarSize = 40 * scale;
    final bubble = Container(
      constraints: BoxConstraints(maxWidth: 310 * scale),
      padding: EdgeInsets.symmetric(
        horizontal: 20 * scale,
        vertical: 12 * scale,
      ),
      decoration: BoxDecoration(
        color: isUser ? null : _surfaceColor,
        gradient: isUser ? _userGradient : null,
        borderRadius: BorderRadius.circular(16 * scale),
      ),
      child: Text(
        text,
        style: GoogleFonts.montserrat(
          color: isUser ? Colors.white : _bubbleTextColor,
          fontSize: 14 * scale.clamp(0.9, 1.05),
          fontWeight: FontWeight.w400,
          height: 1.4,
        ),
      ),
    );

    final timestampWidget = Text(
      pending ? 'Sending…' : timestamp,
      style: GoogleFonts.montserrat(
        color: _timestampColor,
        fontSize: 12 * scale.clamp(0.85, 1.0),
        fontWeight: FontWeight.w400,
      ),
    );

    if (isUser) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                bubble,
                SizedBox(height: 4 * scale),
                timestampWidget,
              ],
            ),
          ),
          SizedBox(width: 12 * scale),
          UserAvatar(
            size: avatarSize,
            avatarUrl: _avatarUrl(user),
            initials: _initials(user),
            onLightBackground: true,
          ),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          width: avatarSize,
          height: avatarSize,
          decoration: const BoxDecoration(
            color: _accentColor,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: HomeSfIcon(
            icon: HomeFigmaIcons.ai,
            color: Colors.white,
            size: 20 * scale.clamp(0.9, 1.05),
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(width: 12 * scale),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              bubble,
              SizedBox(height: 4 * scale),
              timestampWidget,
            ],
          ),
        ),
      ],
    );
  }

  String? _avatarUrl(Map<String, dynamic> user) {
    final url = (user['avatar'] ??
            user['avatar_url'] ??
            user['photo'] ??
            user['photo_url'])
        ?.toString();
    if (url == null || url.trim().isEmpty) return null;
    return url;
  }

  String _initials(Map<String, dynamic> user) {
    final name = (user['fullname'] ?? user['email'] ?? 'User').toString();
    return name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : 'U';
  }
}

class _MyAiInputBar extends StatelessWidget {
  final double scale;
  final TextEditingController controller;
  final bool canSend;
  final VoidCallback onSend;

  const _MyAiInputBar({
    required this.scale,
    required this.controller,
    required this.canSend,
    required this.onSend,
  });

  static const _timestampColor = Color(0xFF94A3B8);
  static const _dividerColor = Color(0xFFE2E8F0);

  static const _sendGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color(0xFF6366F1),
      Color(0xFFA855F7),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;

    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(
        12 * scale,
        0,
        12 * scale,
        12 * scale + bottomInset,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Divider(height: 1, thickness: 0.5, color: _dividerColor),
          SizedBox(height: 12 * scale),
          Row(
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {},
                  customBorder: const CircleBorder(),
                  child: Padding(
                    padding: EdgeInsets.all(4 * scale),
                    child: HomeSfIcon(
                      icon: SFIcons.sf_plus,
                      color: _timestampColor,
                      size: 24 * scale.clamp(0.9, 1.05),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12 * scale),
              Expanded(
                child: TextField(
                  controller: controller,
                  minLines: 1,
                  maxLines: 4,
                  textInputAction: TextInputAction.send,
                  onSubmitted: canSend ? (_) => onSend() : null,
                  style: GoogleFonts.montserrat(
                    color: const Color(0xFF475569),
                    fontSize: 14 * scale.clamp(0.9, 1.05),
                  ),
                  decoration: InputDecoration(
                    hintText: 'Type your message...',
                    hintStyle: GoogleFonts.montserrat(
                      color: _timestampColor,
                      fontSize: 14 * scale.clamp(0.9, 1.05),
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 8 * scale),
                  ),
                ),
              ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {},
                  customBorder: const CircleBorder(),
                  child: Padding(
                    padding: EdgeInsets.all(4 * scale),
                    child: HomeSfIcon(
                      icon: SFIcons.sf_microphone,
                      color: _timestampColor,
                      size: 24 * scale.clamp(0.9, 1.05),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8 * scale),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: canSend ? onSend : null,
                  customBorder: const CircleBorder(),
                  child: Opacity(
                    opacity: canSend ? 1 : 0.45,
                    child: Container(
                      width: 40 * scale,
                      height: 40 * scale,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: _sendGradient,
                      ),
                      alignment: Alignment.center,
                      child: HomeSfIcon(
                        icon: SFIcons.sf_paperplane_fill,
                        color: Colors.white,
                        size: 18 * scale.clamp(0.9, 1.05),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
