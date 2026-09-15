import 'dart:io';
import 'dart:typed_data';

import 'package:autobus/barrel.dart';
import 'package:autobus/common_design/light_screen_theme.dart';
import 'package:autobus/common_design/widgets/app_bottom_nav.dart';
import 'package:autobus/common_design/widgets/ai_sparkle_icon.dart';
import 'package:autobus/common_design/widgets/light_list_card.dart';
import 'package:autobus/common_design/widgets/light_screen_scaffold.dart';
import 'package:autobus/features/marketing/marketing_media_download.dart';
import 'package:autobus/features/marketing/platform_post_details.dart';
import 'package:autobus/icons/home_figma_icons.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_player/video_player.dart';

const _kSelectGreen = Color(0xFF22C55E);
const _kAutobusIgPrefix = 'autobus-ig-';
const _kComposerHint = Color(0xFF94A3B8);
const _kComposerDivider = Color(0xFFE2E8F0);
const _kSuggestionStroke = Color(0xFFDFDFDF);
const _kSuggestionText = Color(0xFF898888);
const _kCreatePurple = Color(0xFF7F03B9);
const _kNextDisabled = Color(0xFFCFCFCF);
const _kNextEnabled = Color(0xFF2D0851);
const _kAssistantBubble = Color(0xFFF8FAFC);
const _kAssistantText = Color(0xFF475569);
const _kComposerSendGradient = LinearGradient(
  begin: Alignment.centerLeft,
  end: Alignment.centerRight,
  colors: [Color(0xFF6366F1), Color(0xFFA855F7)],
);

const _kComposerSuggestions = [
  'Product photo for instagram that catches the eye',
  '15 seconds promo video of product A and B for tiktok',
  'Caption for a weekend sale',
];

enum MarketingContentType { pictures, videos, text }

enum MediaGenState { idle, generating, ready }

bool _marketingContentIsReady(MarketingContent content) {
  if (content.type == MarketingContentType.text) {
    final text = (content.manualText ?? content.generatedResult ?? '').trim();
    return text.isNotEmpty;
  }
  if (content.genState != MediaGenState.ready) return false;
  if (content.type == MarketingContentType.pictures) {
    final hasBytes = content.generatedBytes != null;
    final localPath = content.localFilePath;
    final hasLocalFile = !kIsWeb &&
        localPath != null &&
        localPath.isNotEmpty &&
        File(localPath).existsSync();
    return hasBytes || hasLocalFile;
  }
  final hasRemote = (content.generatedResult ?? '').trim().startsWith('http');
  final hasBytes =
      content.generatedBytes != null && content.generatedBytes!.isNotEmpty;
  final localPath = content.localFilePath;
  final hasLocalFile = !kIsWeb &&
      localPath != null &&
      localPath.isNotEmpty &&
      File(localPath).existsSync();
  return hasRemote || hasLocalFile || hasBytes;
}

class MarketingContent {
  final MarketingContentType type;
  String? prompt;
  String? manualText;
  String? generatedResult;
  Uint8List? generatedBytes;
  String? localFilePath;
  MediaGenState genState = MediaGenState.idle;

  MarketingContent(this.type);

  String get label {
    switch (type) {
      case MarketingContentType.pictures:
        return 'Pictures';
      case MarketingContentType.videos:
        return 'Videos';
      case MarketingContentType.text:
        return 'Text';
    }
  }

  String get pageTitle {
    switch (type) {
      case MarketingContentType.pictures:
        return 'Generate or Add Image';
      case MarketingContentType.videos:
        return 'Generate or Add Video';
      case MarketingContentType.text:
        return 'Generate or Add Text';
    }
  }

  String get promptHint {
    switch (type) {
      case MarketingContentType.pictures:
        return 'Describe the image content to generate';
      case MarketingContentType.videos:
        return 'Describe the video content to generate';
      case MarketingContentType.text:
        return 'Describe the text content to generate';
    }
  }
}

class DigitalMarketingCampaign {
  final List<MarketingContent> contents;
  DateTime? scheduledDate;
  bool postRightAway = false;
  final Set<String> selectedOutlets = {};
  final Set<int> selectedContentIndexes = {};
  bool aiWriteCaptions = true;

  /// Per-outlet supporting details (title, privacy, tags, …), keyed by integration id.
  final Map<String, PlatformPostDetails> outletDetails = {};

  DigitalMarketingCampaign(this.contents);

  Iterable<MarketingContent> get selectedContents {
    if (selectedContentIndexes.isEmpty) return contents;
    return [
      for (var i = 0; i < contents.length; i++)
        if (selectedContentIndexes.contains(i)) contents[i],
    ];
  }

  String get campaignCaption {
    return selectedContents
        .where((c) => c.type == MarketingContentType.text)
        .map((c) => c.manualText ?? c.generatedResult ?? '')
        .where((s) => s.isNotEmpty)
        .join('\n\n');
  }
}

class _MarketingScaffold extends StatelessWidget {
  final Widget child;
  final double contentHorizontalPadding;
  final Widget? trailing;

  const _MarketingScaffold({
    required this.child,
    this.contentHorizontalPadding = 18,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return LightScreenScaffold(
      title: 'Digital Marketing',
      titleFontSize: 16,
      creditCategory: trailing == null ? CreditCategory.imageGen : null,
      trailing: trailing,
      resizeToAvoidBottomInset: true,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: contentHorizontalPadding),
        child: child,
      ),
    );
  }
}

class _HeaderNextPill extends StatelessWidget {
  final bool enabled;
  final VoidCallback? onTap;

  const _HeaderNextPill({required this.enabled, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 67,
        height: 37,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: enabled ? _kNextEnabled : _kNextDisabled,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Text(
          'Next',
          style: GoogleFonts.montserrat(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class _DarkButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  /// Narrower pill used on the generate-media step.
  final bool compact;

  /// Figma marketing CTA: 64pt, radius 30, no arrow.
  final bool figmaCta;

  const _DarkButton({
    required this.label,
    this.onTap,
    this.compact = false,
    this.figmaCta = false,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    final height = figmaCta ? 64.0 : (compact ? 48.0 : 74.0);
    final fontSize = figmaCta ? 16.0 : (compact ? 14.0 : 16.0);
    final showArrow = !figmaCta;
    final arrowSize = compact ? 14.0 : 18.0;
    final labelArrowGap = compact ? 8.0 : 12.0;
    final hPad = compact ? 18.0 : 22.0;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: height,
        padding: EdgeInsets.symmetric(horizontal: hPad),
        decoration: BoxDecoration(
          color: enabled
              ? (figmaCta ? _kNextEnabled : LightScreenTheme.button)
              : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(
            figmaCta ? 30 : (compact ? 36 : 50),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            Text(
              label,
              style: GoogleFonts.montserrat(
                fontSize: fontSize,
                fontWeight: FontWeight.w500,
                color: enabled ? Colors.white : Colors.white70,
              ),
            ),
            if (showArrow) ...[
              SizedBox(width: labelArrowGap),
              HomeSfIcon(
                icon: HomeFigmaIcons.arrowForward,
                size: arrowSize,
                color: Colors.white.withValues(alpha: enabled ? 1.0 : 0.7),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PromptBar extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final VoidCallback? onAttach;
  final VoidCallback? onGenerate;

  const _PromptBar({
    required this.controller,
    required this.hint,
    this.onAttach,
    this.onGenerate,
  });

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;
    final canSend = onGenerate != null;

    return Padding(
      padding: EdgeInsets.fromLTRB(12, 0, 12, 8 + bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Divider(height: 1, thickness: 0.5, color: _kComposerDivider),
          const SizedBox(height: 12),
          Row(
            children: [
              GestureDetector(
                onTap: onAttach,
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: HomeSfIcon(
                    icon: HomeFigmaIcons.add,
                    color: _kComposerHint,
                    size: 24,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: controller,
                  minLines: 1,
                  maxLines: 4,
                  textInputAction: TextInputAction.send,
                  onSubmitted: canSend ? (_) => onGenerate!() : null,
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    color: const Color(0xFF475569),
                  ),
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: GoogleFonts.montserrat(
                      fontSize: 14,
                      color: _kComposerHint,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(4),
                child: HomeSfIcon(
                  icon: HomeFigmaIcons.microphone,
                  color: _kComposerHint,
                  size: 24,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onGenerate,
                child: Opacity(
                  opacity: canSend ? 1 : 0.45,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: _kComposerSendGradient,
                    ),
                    alignment: Alignment.center,
                    child: HomeSfIcon(
                      icon: HomeFigmaIcons.sendMail,
                      color: Colors.white,
                      size: 18,
                      fontWeight: FontWeight.w600,
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

class DigitalMarketingPage extends StatefulWidget {
  final Set<MarketingContentType> initialSelected;

  const DigitalMarketingPage({
    super.key,
    Set<MarketingContentType>? initialSelected,
  }) : initialSelected = initialSelected ?? const <MarketingContentType>{};

  @override
  State<DigitalMarketingPage> createState() => _DigitalMarketingPageState();
}

class _DigitalMarketingPageState extends State<DigitalMarketingPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final selected = widget.initialSelected.isNotEmpty
          ? widget.initialSelected
          : <MarketingContentType>{MarketingContentType.pictures};

      final contents = MarketingContentType.values
          .where(selected.contains)
          .map((t) => MarketingContent(t))
          .toList();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => _GenerateMediaPage(
            campaign: DigitalMarketingCampaign(contents),
            segmentStartIndex: 0,
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return _MarketingScaffold(
      child: const Center(child: AutobusLoadingIndicator()),
    );
  }
}

class _TypeCard extends StatelessWidget {
  final MarketingContentType type;
  final String label;
  final IconData icon;
  final Color iconColor;
  final bool selected;
  final VoidCallback onTap;

  const _TypeCard({
    required this.type,
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 148,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: LightScreenTheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? LightScreenTheme.accent : LightScreenTheme.border,
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            HomeSfIcon(icon: icon, size: 40, color: iconColor),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.montserrat(
                fontSize: 12,
                color: iconColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GenerateMediaPage extends StatefulWidget {
  final DigitalMarketingCampaign campaign;

  /// Index of the first item in this step’s contiguous block (pictures, videos, or text).
  final int segmentStartIndex;

  const _GenerateMediaPage({
    required this.campaign,
    required this.segmentStartIndex,
  });

  @override
  State<_GenerateMediaPage> createState() => _GenerateMediaPageState();
}

class _MarketingChatTurn {
  final bool isUser;
  final String text;
  final DateTime at;
  final Uint8List? imageBytes;
  final String? localPath;
  final String? videoUrl;
  final bool pending;
  final int? slotIndex;

  const _MarketingChatTurn({
    required this.isUser,
    required this.text,
    required this.at,
    this.imageBytes,
    this.localPath,
    this.videoUrl,
    this.pending = false,
    this.slotIndex,
  });
}

class _GenerateMediaPageState extends State<_GenerateMediaPage> {
  final TextEditingController _promptCtrl = TextEditingController();
  final TextEditingController _textBodyCtrl = TextEditingController();
  final FocusNode _textBodyFocus = FocusNode();
  final ScrollController _chatScroll = ScrollController();
  final List<_MarketingChatTurn> _turns = [];

  final ApiService _apiService = ApiService(
    httpClient: SessionAwareHttpClient(tokenService: TokenService()),
  );

  late int _selectedSlotIndex;

  MarketingContentType get _segmentType =>
      widget.campaign.contents[widget.segmentStartIndex].type;

  MarketingContent get _activeContent =>
      widget.campaign.contents[_selectedSlotIndex];

  bool get _isText => _segmentType == MarketingContentType.text;

  List<int> _segmentIndices() {
    final t = _segmentType;
    final out = <int>[];
    for (
      var i = widget.segmentStartIndex;
      i < widget.campaign.contents.length &&
          widget.campaign.contents[i].type == t;
      i++
    ) {
      out.add(i);
    }
    return out;
  }

  /// First index after this segment’s block (pictures / videos / text).
  int _segmentEndExclusive() {
    return widget.segmentStartIndex + _segmentIndices().length;
  }

  bool get _isMultiSlotMedia =>
      !_isText &&
      (_segmentType == MarketingContentType.pictures ||
          _segmentType == MarketingContentType.videos);

  /// Text step: unchanged. Picture/video: every slot in this segment must have
  /// uploaded or generated media, and nothing may still be generating.
  bool get _canGoNext {
    if (_isText) return true;
    final indices = _segmentIndices();
    final anyGenerating = indices.any(
      (i) => widget.campaign.contents[i].genState == MediaGenState.generating,
    );
    if (anyGenerating) return false;
    for (final i in indices) {
      if (!_slotHasViewableMedia(widget.campaign.contents[i])) return false;
    }
    return true;
  }

  @override
  void initState() {
    super.initState();
    _selectedSlotIndex = widget.segmentStartIndex;
    _promptCtrl.addListener(() => setState(() {}));
    _textBodyCtrl.addListener(() {
      if (_isText) _activeContent.manualText = _textBodyCtrl.text;
    });
    _textBodyFocus.addListener(() => setState(() {}));

    if (_activeContent.manualText != null) {
      _textBodyCtrl.text = _activeContent.manualText!;
    }
    if (_promptCtrl.text.isEmpty &&
        (_activeContent.prompt?.isNotEmpty ?? false)) {
      _promptCtrl.text = _activeContent.prompt!;
    }
  }

  @override
  void dispose() {
    _textBodyFocus.dispose();
    _promptCtrl.dispose();
    _textBodyCtrl.dispose();
    _chatScroll.dispose();
    super.dispose();
  }

  String _relativeTime(DateTime at) {
    final diff = DateTime.now().difference(at);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) {
      final m = diff.inMinutes;
      return m == 1 ? '1 min ago' : '$m min ago';
    }
    if (diff.inHours < 24) {
      final h = diff.inHours;
      return h == 1 ? '1 hr ago' : '$h hr ago';
    }
    return '${at.day}/${at.month}/${at.year}';
  }

  void _scrollChat() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_chatScroll.hasClients) return;
      _chatScroll.animateTo(
        _chatScroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  String _creatingLabel() {
    switch (_segmentType) {
      case MarketingContentType.pictures:
        return 'Creating your image…';
      case MarketingContentType.videos:
        return 'Creating your video…';
      case MarketingContentType.text:
        return 'Writing your caption…';
    }
  }

  void _completeLastAssistant({
    required String text,
    Uint8List? imageBytes,
    String? localPath,
    String? videoUrl,
    int? slotIndex,
  }) {
    final turn = _MarketingChatTurn(
      isUser: false,
      text: text,
      at: DateTime.now(),
      imageBytes: imageBytes,
      localPath: localPath,
      videoUrl: videoUrl,
      slotIndex: slotIndex,
    );
    final i = _turns.lastIndexWhere((t) => !t.isUser && t.pending);
    if (i >= 0) {
      _turns[i] = turn;
    } else {
      _turns.add(turn);
    }
  }

  void _recordUploadChat(MarketingContent slot) {
    final isPicture = slot.type == MarketingContentType.pictures;
    _turns.add(
      _MarketingChatTurn(
        isUser: true,
        text: isPicture ? 'I uploaded a photo' : 'I uploaded a video',
        at: DateTime.now(),
      ),
    );
    _turns.add(
      _MarketingChatTurn(
        isUser: false,
        text: isPicture
            ? 'Here is the photo you added.'
            : 'Here is the video you added.',
        at: DateTime.now(),
        imageBytes: slot.generatedBytes,
        localPath: slot.localFilePath,
        slotIndex: _selectedSlotIndex,
      ),
    );
    _scrollChat();
  }

  Future<void> _generate() async {
    final prompt = _promptCtrl.text.trim();
    if (prompt.isEmpty) return;

    final slot = _activeContent;
    setState(() {
      slot.prompt = prompt;
      slot.genState = MediaGenState.generating;
      slot.generatedBytes = null;
      slot.localFilePath = null;
      if (!_isText) slot.generatedResult = null;
      _turns.add(
        _MarketingChatTurn(isUser: true, text: prompt, at: DateTime.now()),
      );
      _turns.add(
        _MarketingChatTurn(
          isUser: false,
          text: _creatingLabel(),
          at: DateTime.now(),
          pending: true,
        ),
      );
    });
    _promptCtrl.clear();
    _scrollChat();

    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('user');
      String userId = '';
      if (userJson != null) {
        final user = jsonDecode(userJson) as Map<String, dynamic>;
        userId = (user['id'] ?? user['phone'] ?? '').toString();
      }

      String result = '';

      if (slot.type == MarketingContentType.pictures) {
        final response = await _apiService.generateImageMedia(
          userId: userId,
          prompt: prompt,
        );
        final rawBase64 = (response['image_base64'] ?? '').toString().trim();
        if (rawBase64.isEmpty) {
          throw Exception('Image generation returned no image data');
        }
        final cleanedBase64 = rawBase64.contains(',')
            ? rawBase64.substring(rawBase64.indexOf(',') + 1)
            : rawBase64;
        slot.generatedBytes = await compute(base64Decode, cleanedBase64);
        slot.generatedResult = response['mime_type']?.toString();
      } else if (slot.type == MarketingContentType.videos) {
        // store=true: server saves MP4 to object storage so ExoPlayer can stream it.
        // Raw Google Veo URLs often fail on Android (ExoPlaybackException / source error).
        final response = await _apiService.generateVideoMedia(
          userId: userId,
          prompt: prompt,
          store: true,
        );
        result = (response['stored_url'] ?? response['video_url'] ?? '')
            .toString()
            .trim();
        if (result.isEmpty) {
          throw Exception('Video generation returned no video URL');
        }
        slot.generatedResult = result;
      } else {
        result = await _apiService.generateAgentContent(
          userId: userId,
          prompt: prompt,
          agentName: 'marketing',
        );
        slot.generatedResult = result;
        _textBodyCtrl.text = result;
      }

      if (!mounted) return;
      setState(() {
        slot.genState = MediaGenState.ready;
        if (_isText) _textBodyCtrl.text = result;
        if (_isText) {
          _completeLastAssistant(text: result);
        } else if (slot.type == MarketingContentType.pictures) {
          _completeLastAssistant(
            text: 'Here is the image I created.',
            imageBytes: slot.generatedBytes,
            slotIndex: _selectedSlotIndex,
          );
        } else {
          _completeLastAssistant(
            text: 'Here is the video I created.',
            localPath: slot.localFilePath,
            videoUrl: slot.generatedResult,
            slotIndex: _selectedSlotIndex,
          );
        }
      });
      _scrollChat();
    } catch (e) {
      if (!mounted) return;
      final message = e is Exception ? e.toString() : 'Media generation failed';
      setState(() {
        slot.genState = MediaGenState.idle;
        _completeLastAssistant(
          text: message.contains('GOOGLE_API_KEY')
              ? 'Image/Video generation is unavailable: server missing configuration.'
              : 'I could not create that. Please try again.',
        );
      });
      _scrollChat();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message.contains('GOOGLE_API_KEY')
                ? 'Image/Video generation is unavailable: server missing configuration.'
                : 'Media generation failed: $message',
          ),
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  Future<ImageSource?> _chooseMediaSource({required bool isPicture}) {
    return showModalBottomSheet<ImageSource>(
      context: context,
      showDragHandle: true,
      backgroundColor: LightScreenTheme.surface,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: HomeSfIcon(
                icon: isPicture
                    ? HomeFigmaIcons.camera
                    : HomeFigmaIcons.marketingVideos,
                size: 22,
                color: LightScreenTheme.accent,
              ),
              title: Text(isPicture ? 'Take photo' : 'Record video'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: HomeSfIcon(
                icon: HomeFigmaIcons.photoLibrary,
                size: 22,
                color: LightScreenTheme.accent,
              ),
              title: const Text('Choose from gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
  }

  String _mediaExtension(String nameOrPath, {required String fallback}) {
    final dot = nameOrPath.lastIndexOf('.');
    if (dot <= 0 || dot == nameOrPath.length - 1) return fallback;
    final ext = nameOrPath.substring(dot).toLowerCase();
    if (ext.length > 5) return fallback;
    return ext;
  }

  /// Gallery picks can return a path before the native copy finishes. Wait for
  /// a readable file, then fall back to copying bytes into a temp file.
  Future<String?> _ensureLocalMediaFile(
    String path, {
    required String preferredName,
    required String fallbackExt,
  }) async {
    final file = File(path);
    for (var i = 0; i < 40; i++) {
      try {
        if (await file.exists() && await file.length() > 0) {
          return path;
        }
      } catch (_) {}
      await Future<void>.delayed(const Duration(milliseconds: 125));
    }

    try {
      final bytes = await XFile(path).readAsBytes();
      if (bytes.isEmpty) return null;
      final ext = _mediaExtension(preferredName, fallback: fallbackExt);
      final dest = File(
        '${Directory.systemTemp.path}/autobus_media_'
        '${DateTime.now().millisecondsSinceEpoch}$ext',
      );
      await dest.writeAsBytes(bytes, flush: true);
      if (await dest.exists() && await dest.length() > 0) {
        return dest.path;
      }
    } catch (_) {}
    return null;
  }

  Future<void> _pickAndAttachMedia() async {
    if (_isText) return;
    if (_activeContent.genState == MediaGenState.generating) return;

    final isPicture = _activeContent.type == MarketingContentType.pictures;

    // Web has no reliable camera/gallery filesystem paths — keep FilePicker.
    if (kIsWeb) {
      await _pickAndAttachMediaWithFilePicker(isPicture: isPicture);
      return;
    }

    final source = await _chooseMediaSource(isPicture: isPicture);
    if (source == null || !mounted) return;

    final slot = _activeContent;
    final previousState = slot.genState;
    final previousBytes = slot.generatedBytes;
    final previousPath = slot.localFilePath;
    final previousResult = slot.generatedResult;

    setState(() {
      slot.genState = MediaGenState.generating;
    });

    try {
      final picker = ImagePicker();
      if (isPicture) {
        final picked = await picker.pickImage(
          source: source,
          imageQuality: 85,
          maxWidth: 2000,
        );
        if (picked == null) {
          if (!mounted) return;
          setState(() {
            slot.genState = previousState;
            slot.generatedBytes = previousBytes;
            slot.localFilePath = previousPath;
            slot.generatedResult = previousResult;
          });
          return;
        }

        final bytes = await picked.readAsBytes();
        if (bytes.isEmpty) {
          throw Exception('Selected image was empty.');
        }

        final stablePath = await _ensureLocalMediaFile(
          picked.path,
          preferredName: picked.name,
          fallbackExt: '.jpg',
        );

        if (!mounted) return;
        setState(() {
          slot.generatedBytes = bytes;
          slot.localFilePath = stablePath ?? picked.path;
          slot.generatedResult = picked.name;
          slot.genState = MediaGenState.ready;
          _recordUploadChat(slot);
        });
        return;
      }

      final picked = await picker.pickVideo(source: source);
      if (picked == null) {
        if (!mounted) return;
        setState(() {
          slot.genState = previousState;
          slot.generatedBytes = previousBytes;
          slot.localFilePath = previousPath;
          slot.generatedResult = previousResult;
        });
        return;
      }

      String? stablePath;
      final pickedPath = picked.path.trim();
      if (pickedPath.isNotEmpty) {
        stablePath = await _ensureLocalMediaFile(
          pickedPath,
          preferredName: picked.name,
          fallbackExt: '.mp4',
        );
      }
      if (stablePath == null) {
        final bytes = await picked.readAsBytes();
        if (bytes.isEmpty) {
          throw Exception('Unable to open selected video.');
        }
        final ext = _mediaExtension(picked.name, fallback: '.mp4');
        final dest = File(
          '${Directory.systemTemp.path}/autobus_media_'
          '${DateTime.now().millisecondsSinceEpoch}$ext',
        );
        await dest.writeAsBytes(bytes, flush: true);
        if (!await dest.exists() || await dest.length() == 0) {
          throw Exception('Unable to open selected video.');
        }
        stablePath = dest.path;
      }

      if (!mounted) return;
      setState(() {
        slot.generatedBytes = null;
        slot.localFilePath = stablePath;
        // Keep generatedResult for remote/AI URLs only — local path lives in
        // localFilePath so publish/view checks don't treat a path as an URL.
        slot.generatedResult = null;
        slot.genState = MediaGenState.ready;
        _recordUploadChat(slot);
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        slot.genState = previousState;
        slot.generatedBytes = previousBytes;
        slot.localFilePath = previousPath;
        slot.generatedResult = previousResult;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isPicture
                ? 'Unable to load selected image. Please try again.'
                : 'Unable to open selected video. Please try again.',
          ),
        ),
      );
    }
  }

  Future<void> _pickAndAttachMediaWithFilePicker({
    required bool isPicture,
  }) async {
    final allowedExtensions = isPicture
        ? <String>['jpg', 'jpeg', 'png', 'webp', 'gif', 'bmp']
        : <String>['mp4', 'mov', 'avi', 'mkv', 'webm', 'm4v'];

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: allowedExtensions,
      allowMultiple: false,
      withData: true,
    );

    if (!mounted || result == null || result.files.isEmpty) return;

    final file = result.files.single;
    final path = file.path?.trim();
    Uint8List? bytes = file.bytes;

    if (isPicture) {
      if ((bytes == null || bytes.isEmpty) &&
          path != null &&
          path.isNotEmpty &&
          !kIsWeb) {
        try {
          bytes = await File(path).readAsBytes();
        } catch (_) {
          bytes = null;
        }
      }

      if (bytes == null || bytes.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to load selected image. Please try again.'),
          ),
        );
        return;
      }

      if (!mounted) return;
      setState(() {
        _activeContent.generatedBytes = bytes;
        _activeContent.localFilePath = path;
        _activeContent.generatedResult = file.name;
        _activeContent.genState = MediaGenState.ready;
        _recordUploadChat(_activeContent);
      });
      return;
    }

    if ((bytes == null || bytes.isEmpty) &&
        path != null &&
        path.isNotEmpty &&
        !kIsWeb) {
      final stablePath = await _ensureLocalMediaFile(
        path,
        preferredName: file.name,
        fallbackExt: '.mp4',
      );
      if (stablePath != null) {
        if (!mounted) return;
        setState(() {
          _activeContent.generatedBytes = null;
          _activeContent.localFilePath = stablePath;
          _activeContent.generatedResult = null;
          _activeContent.genState = MediaGenState.ready;
          _recordUploadChat(_activeContent);
        });
        return;
      }
    }

    if (bytes != null && bytes.isNotEmpty) {
      if (!mounted) return;
      setState(() {
        _activeContent.generatedBytes = bytes;
        _activeContent.localFilePath = path;
        _activeContent.generatedResult = null;
        _activeContent.genState = MediaGenState.ready;
        _recordUploadChat(_activeContent);
      });
      return;
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Unable to open selected video. Please try again.'),
      ),
    );
  }

  void _selectSlot(int index) {
    if (!_isMultiSlotMedia) return;
    final busy = _segmentIndices().any(
      (i) => widget.campaign.contents[i].genState == MediaGenState.generating,
    );
    if (busy) return;
    setState(() {
      _selectedSlotIndex = index;
      _promptCtrl.text = _activeContent.prompt ?? '';
    });
  }

  bool _isSlotEmpty(MarketingContent content) {
    if (content.genState == MediaGenState.idle) return true;
    if (content.genState == MediaGenState.ready &&
        !_slotHasViewableMedia(content)) {
      return true;
    }
    return false;
  }

  int? _firstEmptySlotIndex() {
    for (final i in _segmentIndices()) {
      if (_isSlotEmpty(widget.campaign.contents[i])) return i;
    }
    return null;
  }

  void _addAnotherMediaSlot() {
    if (!_isMultiSlotMedia) return;
    final busy = _segmentIndices().any(
      (i) => widget.campaign.contents[i].genState == MediaGenState.generating,
    );
    if (busy) return;

    final emptyIndex = _firstEmptySlotIndex();
    if (emptyIndex != null) {
      setState(() {
        _selectedSlotIndex = emptyIndex;
        _promptCtrl.text = _activeContent.prompt ?? '';
      });
      return;
    }

    setState(() {
      final insertAt = _segmentEndExclusive();
      widget.campaign.contents.insert(insertAt, MarketingContent(_segmentType));
      _selectedSlotIndex = insertAt;
      _promptCtrl.clear();
    });
  }

  bool _isRemoteMediaUrl(String? value) {
    final v = value?.trim() ?? '';
    return v.startsWith('http://') || v.startsWith('https://');
  }

  bool _slotHasViewableMedia(MarketingContent content) {
    if (content.genState != MediaGenState.ready) return false;
    if (content.type == MarketingContentType.pictures) {
      final hasBytes = content.generatedBytes != null;
      final localPath = content.localFilePath;
      final hasLocalFile =
          !kIsWeb &&
          localPath != null &&
          localPath.isNotEmpty &&
          File(localPath).existsSync();
      return hasBytes || hasLocalFile;
    }
    if (content.type == MarketingContentType.videos) {
      final hasRemote = _isRemoteMediaUrl(content.generatedResult);
      final hasBytes =
          content.generatedBytes != null && content.generatedBytes!.isNotEmpty;
      final localPath = content.localFilePath;
      final hasLocalFile =
          !kIsWeb &&
          localPath != null &&
          localPath.isNotEmpty &&
          File(localPath).existsSync();
      return hasRemote || hasLocalFile || hasBytes;
    }
    return false;
  }

  void _onSlotTap(int index) {
    _selectSlot(index);
    if (_slotHasViewableMedia(widget.campaign.contents[index])) {
      _showMediaPreview(index);
    }
  }

  Future<void> _showMediaPreview(int index) async {
    final content = widget.campaign.contents[index];
    await showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.85),
      builder: (dialogContext) => _MediaSlotPreviewDialog(
        content: content,
        onDelete: () {
          Navigator.of(dialogContext).pop();
          _deleteSlot(index);
        },
      ),
    );
  }

  void _clearSlotMedia(MarketingContent slot) {
    slot.genState = MediaGenState.idle;
    slot.generatedBytes = null;
    slot.localFilePath = null;
    slot.generatedResult = null;
    slot.prompt = null;
  }

  void _deleteSlot(int index) {
    if (!_isMultiSlotMedia) return;
    final busy = _segmentIndices().any(
      (i) => widget.campaign.contents[i].genState == MediaGenState.generating,
    );
    if (busy) return;

    final indices = _segmentIndices();
    if (!indices.contains(index)) return;

    setState(() {
      final slot = widget.campaign.contents[index];
      if (indices.length == 1 || slot.genState == MediaGenState.idle) {
        _clearSlotMedia(slot);
        if (_selectedSlotIndex == index) {
          _promptCtrl.clear();
        }
        return;
      }

      widget.campaign.contents.removeAt(index);
      final newIndices = _segmentIndices();
      if (newIndices.isEmpty) {
        _selectedSlotIndex = widget.segmentStartIndex;
      } else if (!newIndices.contains(_selectedSlotIndex)) {
        final fallback = index < _selectedSlotIndex
            ? _selectedSlotIndex - 1
            : newIndices.last;
        _selectedSlotIndex = newIndices.contains(fallback)
            ? fallback
            : newIndices.first;
      }
      _promptCtrl.text = _activeContent.prompt ?? '';
    });
  }

  void _goNext() {
    if (_isText) {
      _activeContent.manualText = _textBodyCtrl.text;
    }

    final nextStart = _segmentEndExclusive();
    if (nextStart < widget.campaign.contents.length) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => _GenerateMediaPage(
            campaign: widget.campaign,
            segmentStartIndex: nextStart,
          ),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => _SchedulePage(campaign: widget.campaign),
        ),
      );
    }
  }

  bool get _showEmptyComposer => _turns.isEmpty;

  @override
  Widget build(BuildContext context) {
    final canGenerate =
        _promptCtrl.text.trim().isNotEmpty &&
        _activeContent.genState != MediaGenState.generating;

    return _MarketingScaffold(
      contentHorizontalPadding: 0,
      trailing: _HeaderNextPill(enabled: _canGoNext, onTap: _goNext),
      child: Column(
        children: [
          Expanded(
            child: _showEmptyComposer
                ? _ComposerEmptyState(
                    onSuggestion: (text) {
                      setState(() => _promptCtrl.text = text);
                    },
                  )
                : _MarketingChatThread(
                    turns: _turns,
                    scrollController: _chatScroll,
                    formatTime: _relativeTime,
                    onMediaTap: (index) => _showMediaPreview(index),
                  ),
          ),
          _PromptBar(
            controller: _promptCtrl,
            hint: 'Type your message...',
            onAttach: _isText ? null : _pickAndAttachMedia,
            onGenerate: canGenerate ? _generate : null,
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewBox() {
    return Stack(
      fit: StackFit.expand,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _textBodyCtrl,
            focusNode: _textBodyFocus,
            maxLines: null,
            expands: true,
            style: GoogleFonts.montserrat(fontSize: 14, color: Colors.black87),
            decoration: InputDecoration(
              hintText: 'Type Text Here...',
              hintStyle: GoogleFonts.montserrat(
                fontSize: 14,
                color: Colors.black38,
              ),
              border: InputBorder.none,
            ),
          ),
        ),
        if (_activeContent.genState == MediaGenState.generating)
          _GeneratingOverlay(label: _activeContent.label),
      ],
    );
  }

  Widget _buildMediaSlotsRow() {
    final indices = _segmentIndices();
    final hasEmptySlot = indices.any(
      (i) => _isSlotEmpty(widget.campaign.contents[i]),
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _segmentType == MarketingContentType.pictures
              ? 'Tap a slot to select. Tap an image to view or delete it.'
              : 'Tap a slot to select. Tap a video to view or delete it.',
          textAlign: TextAlign.center,
          style: GoogleFonts.montserrat(fontSize: 11, color: Colors.black38),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: Center(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var i = 0; i < indices.length; i++) ...[
                    if (i > 0) const SizedBox(width: 10),
                    _MediaSlotThumbCard(
                      content: widget.campaign.contents[indices[i]],
                      selected: indices[i] == _selectedSlotIndex,
                      onTap: () => _onSlotTap(indices[i]),
                    ),
                  ],
                  if (!hasEmptySlot) ...[
                    if (indices.isNotEmpty) const SizedBox(width: 10),
                    _AddAnotherMediaSlotCard(
                      type: _segmentType,
                      onTap: _addAnotherMediaSlot,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MarketingChatThread extends StatelessWidget {
  final List<_MarketingChatTurn> turns;
  final ScrollController scrollController;
  final String Function(DateTime) formatTime;
  final ValueChanged<int> onMediaTap;

  const _MarketingChatThread({
    required this.turns,
    required this.scrollController,
    required this.formatTime,
    required this.onMediaTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
          child: Text(
            'Create with Autobus',
            textAlign: TextAlign.center,
            style: GoogleFonts.montserrat(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: _kCreatePurple,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(14, 12, 12, 16),
            itemCount: turns.length,
            itemBuilder: (context, index) {
              final turn = turns[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _MarketingChatBubble(
                  turn: turn,
                  timestamp: turn.pending ? 'Sending…' : formatTime(turn.at),
                  onMediaTap: turn.slotIndex == null
                      ? null
                      : () => onMediaTap(turn.slotIndex!),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _MarketingChatBubble extends StatelessWidget {
  final _MarketingChatTurn turn;
  final String timestamp;
  final VoidCallback? onMediaTap;

  const _MarketingChatBubble({
    required this.turn,
    required this.timestamp,
    this.onMediaTap,
  });

  @override
  Widget build(BuildContext context) {
    final bubble = ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 310),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onMediaTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: turn.isUser ? null : _kAssistantBubble,
              gradient: turn.isUser ? _kComposerSendGradient : null,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (turn.text.isNotEmpty)
                  Text(
                    turn.text,
                    style: GoogleFonts.montserrat(
                      color: turn.isUser ? Colors.white : _kAssistantText,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                if (turn.pending) ...[
                  if (turn.text.isNotEmpty) const SizedBox(height: 8),
                  const SizedBox(
                    height: 18,
                    width: 18,
                    child: AutobusLoadingIndicator(size: 18),
                  ),
                ],
                if (turn.imageBytes != null) ...[
                  if (turn.text.isNotEmpty) const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.memory(
                      turn.imageBytes!,
                      width: 220,
                      fit: BoxFit.cover,
                    ),
                  ),
                ] else if ((turn.localPath != null &&
                        turn.localPath!.isNotEmpty) ||
                    (turn.videoUrl != null && turn.videoUrl!.isNotEmpty)) ...[
                  if (turn.text.isNotEmpty) const SizedBox(height: 8),
                  Container(
                    width: 220,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.black12,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: HomeSfIcon(
                      icon: HomeFigmaIcons.play,
                      size: 36,
                      color: _kCreatePurple,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );

    final time = Text(
      timestamp,
      textAlign: turn.isUser ? TextAlign.right : TextAlign.left,
      style: GoogleFonts.montserrat(
        color: _kComposerHint,
        fontSize: 12,
      ),
    );

    if (turn.isUser) {
      return Align(
        alignment: Alignment.centerRight,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            bubble,
            const SizedBox(height: 4),
            time,
          ],
        ),
      );
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          bubble,
          const SizedBox(height: 4),
          time,
        ],
      ),
    );
  }
}

class _ComposerEmptyState extends StatelessWidget {
  final ValueChanged<String> onSuggestion;

  const _ComposerEmptyState({required this.onSuggestion});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(38, 24, 38, 16),
      child: Column(
        children: [
          Text(
            'Create with Autobus',
            textAlign: TextAlign.center,
            style: GoogleFonts.montserrat(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: _kCreatePurple,
            ),
          ),
          const SizedBox(height: 86),
          const AiSparkleIcon(size: 50),
          const SizedBox(height: 12),
          Text(
            'What would you like to create?',
            textAlign: TextAlign.center,
            style: GoogleFonts.montserrat(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Describe an image, video or caption. Send a follow-up to refine it.',
            textAlign: TextAlign.center,
            style: GoogleFonts.montserrat(
              fontSize: 14,
              height: 1.4,
              color: const Color(0xFF4E4E4E),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Suggestions',
            style: GoogleFonts.montserrat(
              fontSize: 14,
              color: const Color(0xFF4E4E4E),
            ),
          ),
          const SizedBox(height: 16),
          for (final suggestion in _kComposerSuggestions) ...[
            _SuggestionChip(
              label: suggestion,
              onTap: () => onSuggestion(suggestion),
            ),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

class _SuggestionChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _SuggestionChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(30),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: _kSuggestionStroke),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.montserrat(
              fontSize: 12,
              height: 1.35,
              color: _kSuggestionText,
            ),
          ),
        ),
      ),
    );
  }
}

class _MediaSlotThumbCard extends StatelessWidget {
  final MarketingContent content;
  final bool selected;
  final VoidCallback onTap;

  static const _w = 96.0;
  static const _h = 112.0;

  const _MediaSlotThumbCard({
    required this.content,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: _w,
        height: _h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? LightScreenTheme.accent
                : LightScreenTheme.border,
            width: selected ? 2 : 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: _thumbFill(),
      ),
    );
  }

  Widget _thumbFill() {
    final isPicture = content.type == MarketingContentType.pictures;
    switch (content.genState) {
      case MediaGenState.idle:
        return ColoredBox(
          color: LightScreenTheme.field,
          child: Center(
            child: HomeSfIcon(
              icon: isPicture
                  ? HomeFigmaIcons.photoOnRectangle
                  : HomeFigmaIcons.marketingVideos,
              color: LightScreenTheme.accent.withValues(alpha: 0.7),
              size: 34,
            ),
          ),
        );
      case MediaGenState.generating:
        return ColoredBox(
          color: LightScreenTheme.field,
          child: Center(child: const AutobusLoadingIndicator(size: 26)),
        );
      case MediaGenState.ready:
        if (isPicture) {
          final hasBytes = content.generatedBytes != null;
          final localPath = content.localFilePath;
          final hasLocalFile =
              !kIsWeb &&
              localPath != null &&
              localPath.isNotEmpty &&
              File(localPath).existsSync();
          if (hasBytes || hasLocalFile) {
            return hasBytes
                ? Image.memory(
                    content.generatedBytes!,
                    fit: BoxFit.cover,
                    gaplessPlayback: true,
                  )
                : Image.file(
                    File(localPath!),
                    fit: BoxFit.cover,
                    gaplessPlayback: true,
                  );
          }
        }
        if (!isPicture) {
          final remote = content.generatedResult?.trim() ?? '';
          final hasRemote =
              remote.startsWith('http://') || remote.startsWith('https://');
          final hasLocal = content.localFilePath?.trim().isNotEmpty ?? false;
          final hasBytes = content.generatedBytes?.isNotEmpty ?? false;
          if (hasRemote || hasLocal || hasBytes) {
            return ColoredBox(
              color: LightScreenTheme.accent.withValues(alpha: 0.1),
              child: Center(
                child: HomeSfIcon(
                  icon: HomeFigmaIcons.play,
                  size: 40,
                  color: LightScreenTheme.accent,
                ),
              ),
            );
          }
        }
        return ColoredBox(
          color: LightScreenTheme.accent.withValues(alpha: 0.1),
          child: Center(
            child: HomeSfIcon(
              icon: HomeFigmaIcons.checkmark,
              color: LightScreenTheme.accent,
              size: 34,
            ),
          ),
        );
    }
  }
}

/// Plays a generated (remote) or uploaded (local) video inside the app.
class _MarketingInlineVideoPlayer extends StatefulWidget {
  final String videoRef;

  const _MarketingInlineVideoPlayer({required this.videoRef});

  @override
  State<_MarketingInlineVideoPlayer> createState() =>
      _MarketingInlineVideoPlayerState();
}

class _MarketingInlineVideoPlayerState
    extends State<_MarketingInlineVideoPlayer> {
  VideoPlayerController? _controller;
  bool _failed = false;
  String _errorDetail = '';

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final ref = widget.videoRef.trim();
    if (ref.isEmpty) {
      if (mounted) {
        setState(() {
          _failed = true;
          _errorDetail = 'No video reference.';
        });
      }
      return;
    }

    final isNetwork = ref.startsWith('http://') || ref.startsWith('https://');

    late final VideoPlayerController c;
    if (isNetwork) {
      c = VideoPlayerController.networkUrl(
        Uri.parse(ref),
        httpHeaders: const {
          // Some CDNs / storage endpoints reject requests with no User-Agent.
          'User-Agent': 'Autobus/1.0',
        },
      );
    } else {
      if (kIsWeb) {
        if (mounted) {
          setState(() {
            _failed = true;
            _errorDetail = 'Local file playback is not supported on web.';
          });
        }
        return;
      }
      c = VideoPlayerController.file(File(ref));
    }

    try {
      await c.initialize();
      if (!mounted) {
        await c.dispose();
        return;
      }
      setState(() => _controller = c);
      await c.setLooping(true);
      await c.play();
    } catch (e) {
      await c.dispose();
      if (!mounted) return;
      setState(() {
        _failed = true;
        _errorDetail = e.toString();
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_failed) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Could not load video.\n$_errorDetail',
            textAlign: TextAlign.center,
            style: GoogleFonts.montserrat(color: Colors.white70, fontSize: 13),
          ),
        ),
      );
    }

    final c = _controller;
    if (c == null || !c.value.isInitialized) {
      return const Center(
        child: SizedBox(
          width: 36,
          height: 36,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.white54,
          ),
        ),
      );
    }

    final ar = c.value.aspectRatio;
    final ratio = ar > 0 ? ar : 16 / 9;

    return LayoutBuilder(
      builder: (context, constraints) {
        var maxW = constraints.maxWidth;
        var maxH = constraints.maxHeight;
        if (!maxW.isFinite || maxW <= 0) maxW = 320;
        final hasBoundedH = maxH.isFinite && maxH > 0 && maxH < double.infinity;
        if (!hasBoundedH) maxH = maxW / ratio;

        var w = maxW;
        var h = w / ratio;
        if (h > maxH) {
          h = maxH;
          w = h * ratio;
        }

        return Center(
          child: SizedBox(
            width: w,
            height: h,
            child: Stack(
              alignment: Alignment.center,
              children: [
                VideoPlayer(c),
                ValueListenableBuilder<VideoPlayerValue>(
                  valueListenable: c,
                  builder: (context, value, _) {
                    return GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        if (value.isPlaying) {
                          c.pause();
                        } else {
                          c.play();
                        }
                      },
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(
                                alpha: value.isPlaying ? 0.0 : 0.35,
                              ),
                              Colors.black.withValues(
                                alpha: value.isPlaying ? 0.0 : 0.45,
                              ),
                            ],
                          ),
                        ),
                        child: value.isPlaying
                            ? const SizedBox.expand()
                            : HomeSfIcon(
                                icon: HomeFigmaIcons.play,
                                size: 72,
                                color: Colors.white,
                              ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _MediaSlotPreviewDialog extends StatefulWidget {
  final MarketingContent content;
  final VoidCallback onDelete;

  const _MediaSlotPreviewDialog({
    required this.content,
    required this.onDelete,
  });

  @override
  State<_MediaSlotPreviewDialog> createState() =>
      _MediaSlotPreviewDialogState();
}

class _MediaSlotPreviewDialogState extends State<_MediaSlotPreviewDialog> {
  bool _downloading = false;

  MarketingContent get content => widget.content;

  bool get _canDownload {
    if (content.genState != MediaGenState.ready) return false;
    if (content.type == MarketingContentType.pictures) {
      final hasBytes = content.generatedBytes != null;
      final localPath = content.localFilePath;
      final hasLocalFile = !kIsWeb &&
          localPath != null &&
          localPath.isNotEmpty &&
          File(localPath).existsSync();
      return hasBytes || hasLocalFile;
    }
    if (content.type == MarketingContentType.videos) {
      final remote = content.generatedResult?.trim() ?? '';
      final hasRemote =
          remote.startsWith('http://') || remote.startsWith('https://');
      final localPath = content.localFilePath;
      final hasLocalFile = !kIsWeb &&
          localPath != null &&
          localPath.isNotEmpty &&
          File(localPath).existsSync();
      final hasBytes = content.generatedBytes?.isNotEmpty ?? false;
      return hasRemote || hasLocalFile || hasBytes;
    }
    return false;
  }

  Future<void> _download() async {
    if (_downloading || !_canDownload) return;
    setState(() => _downloading = true);
    try {
      final isPicture = content.type == MarketingContentType.pictures;
      final mimeType = isPicture &&
              (content.generatedResult?.startsWith('image/') ?? false)
          ? content.generatedResult
          : null;
      final suggestedName = isPicture
          ? (content.localFilePath ?? content.generatedResult)
          : null;
      final ok = isPicture
          ? await MarketingMediaDownloader.downloadPicture(
              bytes: content.generatedBytes,
              localPath: content.localFilePath,
              mimeType: mimeType,
              suggestedName: suggestedName,
            )
          : await MarketingMediaDownloader.downloadVideo(
              remoteUrl: content.generatedResult,
              localPath: content.localFilePath,
            );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ok
                ? (kIsWeb
                    ? 'Download started'
                    : 'Saved to your device')
                : 'Could not download file',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Download failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _downloading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPicture = content.type == MarketingContentType.pictures;
    final deleteLabel = isPicture ? 'Delete image' : 'Delete video';
    final downloadLabel = isPicture ? 'Download image' : 'Download video';

    final maxPreviewHeight = MediaQuery.sizeOf(context).height * 0.55;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.topRight,
            child: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: HomeSfIcon(
                icon: HomeFigmaIcons.close,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: maxPreviewHeight),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Material(
                color: Colors.black,
                child: isPicture
                    ? _buildImagePreview()
                    : _buildVideoPreview(context),
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (_canDownload) ...[
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _downloading ? null : _download,
                icon: _downloading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : HomeSfIcon(
                        icon: HomeFigmaIcons.download,
                        size: 18,
                        color: Colors.white,
                      ),
                label: Text(
                  downloadLabel,
                  style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: LightScreenTheme.button,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: widget.onDelete,
              icon: HomeSfIcon(
                icon: HomeFigmaIcons.delete,
                size: 20,
                color: CustColors.accentRed,
              ),
              label: Text(
                deleteLabel,
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.w600,
                  color: CustColors.accentRed,
                ),
              ),
              style: OutlinedButton.styleFrom(
                backgroundColor: LightScreenTheme.surface,
                side: const BorderSide(color: CustColors.accentRed),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreview() {
    final hasBytes = content.generatedBytes != null;
    final localPath = content.localFilePath;
    final hasLocalFile =
        !kIsWeb &&
        localPath != null &&
        localPath.isNotEmpty &&
        File(localPath).existsSync();

    final image = hasBytes
        ? Image.memory(content.generatedBytes!, fit: BoxFit.contain)
        : Image.file(File(localPath!), fit: BoxFit.contain);

    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 420),
      child: InteractiveViewer(
        minScale: 0.5,
        maxScale: 4,
        child: hasBytes || hasLocalFile
            ? image
            : Center(
                child: HomeSfIcon(
                  icon: HomeFigmaIcons.brokenImage,
                  color: Colors.white54,
                  size: 48,
                ),
              ),
      ),
    );
  }

  Widget _buildVideoPreview(BuildContext context) {
    final videoRef = content.localFilePath ?? content.generatedResult ?? '';
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 420, minWidth: 280),
      child: _MarketingInlineVideoPlayer(videoRef: videoRef),
    );
  }
}

class _AddAnotherMediaSlotCard extends StatelessWidget {
  final MarketingContentType type;
  final VoidCallback onTap;

  const _AddAnotherMediaSlotCard({required this.type, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isPicture = type == MarketingContentType.pictures;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: _MediaSlotThumbCard._w,
        height: _MediaSlotThumbCard._h,
        decoration: BoxDecoration(
          color: LightScreenTheme.field,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: LightScreenTheme.border,
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            HomeSfIcon(
              icon: HomeFigmaIcons.addCircle,
              size: 36,
              color: LightScreenTheme.accent,
            ),
            const SizedBox(height: 6),
            Text(
              isPicture ? 'Add image' : 'Add video',
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: LightScreenTheme.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IdlePreview extends StatelessWidget {
  final MarketingContent content;
  final VoidCallback? onUpload;
  final bool compact;

  const _IdlePreview({
    required this.content,
    this.onUpload,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final isPicture = content.type == MarketingContentType.pictures;
    final iconSize = compact ? 48.0 : 80.0;
    return GestureDetector(
      onTap: onUpload,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          HomeSfIcon(
            icon: isPicture
                ? HomeFigmaIcons.marketingPictures
                : HomeFigmaIcons.film,
            size: iconSize,
            color: LightScreenTheme.accent,
          ),
          SizedBox(height: compact ? 8 : 12),
          Text(
            content.label,
            style: GoogleFonts.montserrat(
              fontSize: compact ? 12 : 13,
              color: LightScreenTheme.accent,
            ),
          ),
          if (onUpload != null) ...[
            SizedBox(height: compact ? 6 : 10),
            Text(
              isPicture
                  ? 'Tap to upload your image'
                  : 'Tap to upload your video',
              style: GoogleFonts.montserrat(
                fontSize: compact ? 11 : 12,
                color: Colors.black45,
              ),
            ),
            if (!compact) ...[
              const SizedBox(height: 4),
              Text(
                'or use + below',
                style: GoogleFonts.montserrat(
                  fontSize: 11,
                  color: Colors.black26,
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _GeneratingOverlay extends StatefulWidget {
  final String label;
  final bool compact;

  const _GeneratingOverlay({required this.label, this.compact = false});

  @override
  State<_GeneratingOverlay> createState() => _GeneratingOverlayState();
}

class _GeneratingOverlayState extends State<_GeneratingOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  late final Animation<double> _fade = Tween<double>(
    begin: 0.35,
    end: 1.0,
  ).animate(CurvedAnimation(parent: _anim, curve: Curves.easeInOut));

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.compact;
    return Container(
      color: LightScreenTheme.surface.withValues(alpha: 0.93),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FadeTransition(
              opacity: _fade,
              child: Container(
                padding: EdgeInsets.all(c ? 14 : 22),
                decoration: BoxDecoration(
                  color: LightScreenTheme.accent.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: HomeSfIcon(
                  icon: HomeFigmaIcons.ai,
                  size: c ? 30 : 44,
                  color: LightScreenTheme.accent,
                ),
              ),
            ),
            SizedBox(height: c ? 12 : 22),
            FadeTransition(
              opacity: _fade,
              child: Text(
                'Generating...',
                style: GoogleFonts.montserrat(
                  fontSize: c ? 15 : 18,
                  fontWeight: FontWeight.w600,
                  color: LightScreenTheme.button,
                ),
              ),
            ),
            SizedBox(height: c ? 4 : 6),
            Text(
              'Creating your ${widget.label.toLowerCase()}',
              style: GoogleFonts.montserrat(
                fontSize: c ? 11 : 13,
                color: LightScreenTheme.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReadyPreview extends StatelessWidget {
  final MarketingContent content;
  final bool compact;

  const _ReadyPreview({required this.content, this.compact = false});

  @override
  Widget build(BuildContext context) {
    if (content.type == MarketingContentType.pictures) {
      final hasBytes = content.generatedBytes != null;
      final localPath = content.localFilePath;
      final hasLocalFile =
          !kIsWeb &&
          localPath != null &&
          localPath.isNotEmpty &&
          File(localPath).existsSync();

      if (hasBytes || hasLocalFile) {
        final caption = (content.prompt?.trim().isNotEmpty ?? false)
            ? content.prompt!
            : (content.generatedResult ?? 'Uploaded image');

        if (compact) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: AspectRatio(
                      aspectRatio: 16 / 10,
                      child: Container(
                        width: double.infinity,
                        color: Colors.black,
                        child: hasBytes
                            ? Image.memory(
                                content.generatedBytes!,
                                fit: BoxFit.cover,
                                gaplessPlayback: true,
                              )
                            : Image.file(
                                File(localPath!),
                                fit: BoxFit.cover,
                                gaplessPlayback: true,
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    caption,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.montserrat(
                      fontSize: 11,
                      color: Colors.black45,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Column(
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                color: Colors.black,
                child: hasBytes
                    ? Image.memory(
                        content.generatedBytes!,
                        fit: BoxFit.cover,
                        gaplessPlayback: true,
                      )
                    : Image.file(
                        File(localPath!),
                        fit: BoxFit.cover,
                        gaplessPlayback: true,
                      ),
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: LightScreenTheme.surface,
              child: Text(
                caption,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.montserrat(
                  fontSize: 12,
                  color: LightScreenTheme.muted,
                ),
              ),
            ),
          ],
        );
      }
    }

    if (content.type == MarketingContentType.videos) {
      final remote = content.generatedResult?.trim() ?? '';
      final hasRemote =
          remote.startsWith('http://') || remote.startsWith('https://');
      final localPath = content.localFilePath?.trim() ?? '';
      final hasLocal = localPath.isNotEmpty;
      if (!hasRemote && !hasLocal) {
        return const SizedBox.shrink();
      }
      final videoRef = hasLocal ? localPath : remote;
      final caption = (content.prompt?.trim().isNotEmpty ?? false)
          ? content.prompt!
          : (hasRemote ? 'Generated video' : 'Uploaded video');

      if (compact) {
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: AspectRatio(
                    aspectRatio: 16 / 10,
                    child: ColoredBox(
                      color: Colors.black,
                      child: _MarketingInlineVideoPlayer(videoRef: videoRef),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  caption,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(
                    fontSize: 11,
                    color: Colors.black45,
                  ),
                ),
              ],
            ),
          ),
        );
      }

      return Column(
        children: [
          Expanded(
            child: ColoredBox(
              color: Colors.black,
              child: Center(
                child: _MarketingInlineVideoPlayer(videoRef: videoRef),
              ),
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: LightScreenTheme.surface,
            child: Text(
              caption,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.montserrat(
                fontSize: 12,
                color: LightScreenTheme.muted,
              ),
            ),
          ),
        ],
      );
    }

    if (compact) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: _kSelectGreen.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: HomeSfIcon(
              icon: HomeFigmaIcons.check,
              size: 32,
              color: _kSelectGreen,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '${content.label} ready',
            style: GoogleFonts.montserrat(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: LightScreenTheme.button,
            ),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              content.prompt ?? '',
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(
                fontSize: 11,
                color: Colors.black45,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: _kSelectGreen.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: HomeSfIcon(
            icon: HomeFigmaIcons.check,
            size: 44,
            color: _kSelectGreen,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          '${content.label} Ready!',
          style: GoogleFonts.montserrat(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: LightScreenTheme.button,
          ),
        ),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            content.prompt ?? '',
            textAlign: TextAlign.center,
            style: GoogleFonts.montserrat(fontSize: 12, color: Colors.black45),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _SchedulePage extends StatefulWidget {
  final DigitalMarketingCampaign campaign;
  const _SchedulePage({required this.campaign});

  @override
  State<_SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<_SchedulePage> {
  DateTime _focusedMonth = DateTime(DateTime.now().year, DateTime.now().month);
  DateTime? _selectedDay;
  TimeOfDay _selectedTime = TimeOfDay.now();

  DateTime? get _combinedSchedule {
    final day = _selectedDay;
    if (day == null) return null;
    return DateTime(
      day.year,
      day.month,
      day.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (ctx, child) {
        return Theme(
          data: Theme.of(ctx).copyWith(
            colorScheme: const ColorScheme.light(
              primary: LightScreenTheme.button,
              onPrimary: Colors.white,
              surface: LightScreenTheme.surface,
              onSurface: Colors.black87,
            ),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
    if (picked != null && mounted) {
      setState(() => _selectedTime = picked);
    }
  }

  void _proceed({bool rightAway = false}) {
    if (!rightAway && _selectedDay == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Pick a date first, or choose Post Right Away',
            style: GoogleFonts.montserrat(fontSize: 13),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    widget.campaign.postRightAway = rightAway;
    widget.campaign.scheduledDate = rightAway ? null : _combinedSchedule;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _SelectOutletPage(campaign: widget.campaign),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final timeLabel = _selectedTime.format(context);
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    return _MarketingScaffold(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            primary: true,
            physics: const AlwaysScrollableScrollPhysics(),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: EdgeInsets.only(bottom: bottomInset + 12),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                    Text(
                      'Schedule Your Post',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: LightScreenTheme.title,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Pick a day and time, or publish immediately',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.montserrat(
                        fontSize: 12,
                        color: LightScreenTheme.muted,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _CompactCalendar(
                      focusedMonth: _focusedMonth,
                      selectedDay: _selectedDay,
                      onDaySelected: (d) => setState(() => _selectedDay = d),
                      onMonthChanged: (m) => setState(() => _focusedMonth = m),
                    ),
                    const SizedBox(height: 12),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _pickTime,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          height: 44,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: LightScreenTheme.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: LightScreenTheme.border),
                          ),
                          child: Row(
                            children: [
                              HomeSfIcon(
                                icon: HomeFigmaIcons.schedule,
                                size: 18,
                                color: LightScreenTheme.accent,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Time  ·  $timeLabel',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: LightScreenTheme.title,
                                  ),
                                ),
                              ),
                              Text(
                                'Change',
                                style: GoogleFonts.montserrat(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: LightScreenTheme.accent,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 44,
                      child: OutlinedButton(
                        onPressed: () => _proceed(rightAway: true),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: LightScreenTheme.button,
                          side: const BorderSide(
                            color: LightScreenTheme.button,
                            width: 1.2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                        ),
                        child: Text(
                          'Post Right Away',
                          style: GoogleFonts.montserrat(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    _DarkButton(
                      label: 'Next',
                      compact: true,
                      onTap: () => _proceed(),
                    ),
                  ],
                ),
            ),
          );
        },
      ),
    );
  }
}

class _CompactCalendar extends StatelessWidget {
  final DateTime focusedMonth;
  final DateTime? selectedDay;
  final ValueChanged<DateTime> onDaySelected;
  final ValueChanged<DateTime> onMonthChanged;

  const _CompactCalendar({
    required this.focusedMonth,
    required this.selectedDay,
    required this.onDaySelected,
    required this.onMonthChanged,
  });

  static const _months = [
    '',
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  static const _days = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

  @override
  Widget build(BuildContext context) {
    final y = focusedMonth.year;
    final m = focusedMonth.month;
    final daysInMonth = DateUtils.getDaysInMonth(y, m);
    final firstWeekday = DateTime(y, m, 1).weekday % 7;
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    return Container(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
      decoration: BoxDecoration(
        color: LightScreenTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: LightScreenTheme.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                '${_months[m]} $y',
                style: GoogleFonts.montserrat(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              _CalNavBtn(
                icon: HomeFigmaIcons.chevronLeft,
                onTap: () => onMonthChanged(DateTime(y, m - 1)),
              ),
              const SizedBox(width: 4),
              _CalNavBtn(
                icon: HomeFigmaIcons.chevronRight,
                onTap: () => onMonthChanged(DateTime(y, m + 1)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              for (final d in _days)
                Expanded(
                  child: Text(
                    d,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.montserrat(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.black38,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1.15,
              mainAxisSpacing: 2,
              crossAxisSpacing: 2,
            ),
            itemCount: firstWeekday + daysInMonth,
            itemBuilder: (_, i) {
              if (i < firstWeekday) return const SizedBox.shrink();
              final day = i - firstWeekday + 1;
              final date = DateTime(y, m, day);
              final isPast = date.isBefore(todayDate);
              final isToday = DateUtils.isSameDay(date, today);
              final isSel = selectedDay != null &&
                  DateUtils.isSameDay(date, selectedDay!);

              return GestureDetector(
                onTap: isPast ? null : () => onDaySelected(date),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  decoration: BoxDecoration(
                    color: isSel
                        ? _kSelectGreen
                        : isToday
                            ? _kSelectGreen.withValues(alpha: 0.12)
                            : null,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '$day',
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      fontWeight:
                          isToday || isSel ? FontWeight.w700 : FontWeight.w500,
                      color: isSel
                          ? Colors.white
                          : isPast
                              ? Colors.black26
                              : isToday
                                  ? _kSelectGreen
                                  : Colors.black87,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _CalNavBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CalNavBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: LightScreenTheme.surface,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: 28,
          height: 28,
          child: Center(
            child: HomeSfIcon(
              icon: icon,
              size: 18,
              color: LightScreenTheme.accent,
            ),
          ),
        ),
      ),
    );
  }
}

class _SelectOutletPage extends StatefulWidget {
  final DigitalMarketingCampaign campaign;
  const _SelectOutletPage({required this.campaign});

  @override
  State<_SelectOutletPage> createState() => _SelectOutletPageState();
}

class _SelectOutletPageState extends State<_SelectOutletPage> {
  static const _figmaPlatformOrder = [
    'WhatsApp Status',
    'Instagram',
    'YouTube',
    'Tiktok',
  ];

  final ApiService _apiService = ApiService(
    httpClient: SessionAwareHttpClient(tokenService: TokenService()),
  );

  /// Blotato-backed accounts from `GET /social/accounts`.
  List<Map<String, dynamic>> _blotatoAccounts = [];

  /// Postiz channels + Autobus Instagram (merged for selection).
  List<PostizIntegration> _postizIntegrations = [];
  bool _loadingAccounts = true;
  final Set<String> _unlinkedSelected = {};

  @override
  void initState() {
    super.initState();
    _seedSelectedContent();
    _loadAccounts();
  }

  void _seedSelectedContent() {
    final campaign = widget.campaign;
    if (campaign.selectedContentIndexes.isNotEmpty) return;
    for (var i = 0; i < campaign.contents.length; i++) {
      if (_marketingContentIsReady(campaign.contents[i])) {
        campaign.selectedContentIndexes.add(i);
      }
    }
  }

  Future<void> _loadAccounts() async {
    List<PostizIntegration> postiz = [];
    List<Map<String, dynamic>> blotato = [];
    try {
      postiz = List<PostizIntegration>.from(
        await _apiService.listPostizIntegrations(),
      );
    } catch (_) {
      // Postiz-only flow: do not fail the whole screen if this call errors.
    }
    try {
      final igAccounts = await _apiService.listInstagramAccounts();
      for (final row in igAccounts) {
        final username = (row['username'] ?? '').toString().trim();
        final name = (row['name'] ?? '').toString().trim();
        final dbId = (row['id'] ?? '').toString().trim();
        final igId = (row['ig_user_id'] ?? dbId).toString();
        final label = username.isNotEmpty
            ? '@$username'
            : (name.isNotEmpty ? name : igId);
        final unlinkId = dbId.isNotEmpty ? dbId : igId;
        if (unlinkId.isEmpty) continue;
        postiz.add(
          PostizIntegration(
            id: '$_kAutobusIgPrefix$unlinkId',
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
    try {
      blotato = await _apiService.getSocialAccounts();
    } catch (_) {
      // Blotato is optional when Postiz channels exist.
    }
    if (mounted) {
      setState(() {
        _postizIntegrations = postiz.where((p) => p.isActive).toList();
        _blotatoAccounts = blotato;
        _loadingAccounts = false;
        _applyUnlinkedToLinked();
      });
    }
  }

  void _applyUnlinkedToLinked() {
    for (final label in _unlinkedSelected.toList()) {
      OutletOption? outlet;
      for (final o in OutletCatalog.all) {
        if (o.label == label) {
          outlet = o;
          break;
        }
      }
      if (outlet == null) continue;
      final ids = _idsForOutlet(outlet);
      if (ids.isEmpty) continue;
      widget.campaign.selectedOutlets.addAll(ids);
      _unlinkedSelected.remove(label);
    }
  }

  bool get _usePostiz => _postizIntegrations.isNotEmpty;

  bool get _useBlotato => !_usePostiz && _blotatoAccounts.isNotEmpty;

  List<String> _idsForOutlet(OutletOption outlet) {
    if (_usePostiz) {
      return _postizIntegrations
          .where(outlet.matchesIntegration)
          .map((p) => p.id)
          .toList();
    }
    if (_useBlotato) {
      final keys = outlet.postizIdentifiers
          .map((id) => id.toLowerCase())
          .toList();
      final labelKey = outlet.label.toLowerCase().split(' ').first;
      return [
        for (final acct in _blotatoAccounts)
          if (_blotatoMatches(acct, keys, labelKey))
            (acct['id'] ?? '').toString(),
      ].where((id) => id.isNotEmpty).toList();
    }
    return [];
  }

  bool _blotatoMatches(
    Map<String, dynamic> acct,
    List<String> keys,
    String labelKey,
  ) {
    final plat = (acct['platform'] ?? '').toString().toLowerCase();
    if (plat.contains(labelKey)) return true;
    return keys.any((k) => plat.contains(k));
  }

  bool _isOutletSelected(OutletOption outlet) {
    final ids = _idsForOutlet(outlet);
    if (ids.isEmpty) return _unlinkedSelected.contains(outlet.label);
    return ids.any(widget.campaign.selectedOutlets.contains);
  }

  void _toggleOutlet(OutletOption outlet) {
    final ids = _idsForOutlet(outlet);
    setState(() {
      if (ids.isEmpty) {
        if (!_unlinkedSelected.add(outlet.label)) {
          _unlinkedSelected.remove(outlet.label);
        }
        return;
      }
      _unlinkedSelected.remove(outlet.label);
      final allSelected = ids.every(widget.campaign.selectedOutlets.contains);
      if (allSelected) {
        widget.campaign.selectedOutlets.removeAll(ids);
      } else {
        widget.campaign.selectedOutlets.addAll(ids);
      }
    });
  }

  List<OutletOption> get _platformRows {
    final byLabel = {for (final o in OutletCatalog.all) o.label: o};
    final rows = <OutletOption>[
      for (final label in _figmaPlatformOrder)
        if (byLabel[label] != null) byLabel[label]!,
    ];
    for (final outlet in OutletCatalog.all) {
      if (_figmaPlatformOrder.contains(outlet.label)) continue;
      if (_idsForOutlet(outlet).isNotEmpty) rows.add(outlet);
    }
    return rows;
  }

  List<(int, MarketingContent)> get _readyContents {
    final items = <(int, MarketingContent)>[];
    for (var i = 0; i < widget.campaign.contents.length; i++) {
      final content = widget.campaign.contents[i];
      if (_marketingContentIsReady(content)) {
        items.add((i, content));
      }
    }
    return items;
  }

  String _contentPreview(MarketingContent content) {
    if (content.type == MarketingContentType.text) {
      final text =
          (content.manualText ?? content.generatedResult ?? '').trim();
      return text.isEmpty ? 'Generated text' : text;
    }
    final prompt = (content.prompt ?? '').trim();
    if (prompt.isNotEmpty) return prompt;
    return content.type == MarketingContentType.pictures
        ? 'Generated image'
        : 'Generated video';
  }

  Widget _contentLeading(MarketingContent content) {
    final FaIconData icon;
    switch (content.type) {
      case MarketingContentType.pictures:
        icon = FontAwesomeIcons.image;
      case MarketingContentType.videos:
        icon = FontAwesomeIcons.video;
      case MarketingContentType.text:
        icon = FontAwesomeIcons.alignLeft;
    }
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: FaIcon(icon, size: 16, color: Colors.white),
    );
  }

  Widget _platformLeading(OutletOption outlet) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: outlet.tileColor,
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: FaIcon(outlet.icon, size: 18, color: Colors.white),
    );
  }

  Future<void> _openLinkSocial() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const ManageOutlets()),
    );
    if (mounted) {
      setState(() => _loadingAccounts = true);
      await _loadAccounts();
    }
  }

  void _goToPostDetails() {
    if (widget.campaign.selectedContentIndexes.isEmpty) return;
    if (widget.campaign.selectedOutlets.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _unlinkedSelected.isEmpty
                ? 'Choose a platform to continue'
                : 'Link those platforms in Link Social Media before publishing.',
            style: GoogleFonts.montserrat(fontSize: 13),
          ),
          behavior: SnackBarBehavior.floating,
          action: _unlinkedSelected.isEmpty
              ? null
              : SnackBarAction(label: 'Link', onPressed: _openLinkSocial),
        ),
      );
      return;
    }
    final caption = widget.campaign.campaignCaption;
    for (final id in widget.campaign.selectedOutlets) {
      final details = widget.campaign.outletDetails.putIfAbsent(
        id,
        () => PlatformPostDetails.fromCampaignCaption(caption),
      );
      if (!widget.campaign.aiWriteCaptions) {
        details.caption = '';
      } else if (details.caption.trim().isEmpty) {
        details.caption = caption;
      }
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _PostDetailsPage(
          campaign: widget.campaign,
          postizIntegrations: _postizIntegrations,
          blotatoAccounts: _blotatoAccounts,
          usePostiz: _usePostiz,
          useBlotato: _useBlotato,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.sizeOf(context).width / appShellDesignWidth;
    final ready = _readyContents;
    final canNext = widget.campaign.selectedContentIndexes.isNotEmpty &&
        (widget.campaign.selectedOutlets.isNotEmpty ||
            _unlinkedSelected.isNotEmpty);

    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return _MarketingScaffold(
      trailing: const SizedBox.shrink(),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            primary: true,
            physics: const AlwaysScrollableScrollPhysics(),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: EdgeInsets.only(bottom: bottomInset + 12),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                Text(
                  'Choose what to post',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF323232),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Select generated content, platforms and captions',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    color: const Color(0xFF898888),
                  ),
                ),
                const SizedBox(height: 22),
                _chooseSectionLabel('Generated Content'),
                const SizedBox(height: 8),
                if (ready.isEmpty)
                  LightListCard(
                    scale: scale,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 18,
                    ),
                    child: Text(
                      'Generate text, an image, or a video first.',
                      style: GoogleFonts.montserrat(
                        fontSize: 12,
                        color: const Color(0xFF898888),
                      ),
                    ),
                  )
                else
                  for (var i = 0; i < ready.length; i++) ...[
                    if (i > 0) const SizedBox(height: 8),
                    Builder(
                      builder: (_) {
                        final (index, content) = ready[i];
                        final selected = widget
                            .campaign.selectedContentIndexes
                            .contains(index);
                        return _ChooseSelectCard(
                          scale: scale,
                          selected: selected,
                          leading: _contentLeading(content),
                          title: content.label == 'Pictures'
                              ? 'Image'
                              : content.label == 'Videos'
                                  ? 'Video'
                                  : 'Text',
                          subtitle: _contentPreview(content),
                          subtitleMaxLines: 3,
                          radioOnRight: true,
                          onTap: () => setState(() {
                            if (selected) {
                              widget.campaign.selectedContentIndexes
                                  .remove(index);
                            } else {
                              widget.campaign.selectedContentIndexes.add(index);
                            }
                          }),
                        );
                      },
                    ),
                  ],
                const SizedBox(height: 20),
                _chooseSectionLabel('Platforms'),
                const SizedBox(height: 8),
                if (_loadingAccounts)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: AutobusLoadingIndicator()),
                  )
                else ...[
                  for (var i = 0; i < _platformRows.length; i++) ...[
                    if (i > 0) const SizedBox(height: 8),
                    Builder(
                      builder: (_) {
                        final outlet = _platformRows[i];
                        return _ChooseSelectCard(
                          scale: scale,
                          selected: _isOutletSelected(outlet),
                          leading: _platformLeading(outlet),
                          title: outlet.label,
                          subtitle: 'Share from this phone',
                          radioOnRight: true,
                          onTap: () => _toggleOutlet(outlet),
                        );
                      },
                    ),
                  ],
                ],
                const SizedBox(height: 20),
                _chooseSectionLabel('Captions and metadata'),
                const SizedBox(height: 8),
                _ChooseSelectCard(
                  scale: scale,
                  selected: widget.campaign.aiWriteCaptions,
                  title: 'Let AI write captions',
                  subtitle:
                      'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor',
                  radioOnRight: false,
                  onTap: () => setState(
                    () => widget.campaign.aiWriteCaptions = true,
                  ),
                ),
                const SizedBox(height: 8),
                _ChooseSelectCard(
                  scale: scale,
                  selected: !widget.campaign.aiWriteCaptions,
                  title: 'I will write them',
                  subtitle:
                      'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor',
                  radioOnRight: false,
                  onTap: () => setState(
                    () => widget.campaign.aiWriteCaptions = false,
                  ),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: _DarkButton(
                    label: 'Next',
                    figmaCta: true,
                    onTap: canNext ? _goToPostDetails : null,
                  ),
                ),
              ],
            ),
            ),
          );
        },
      ),
    );
  }
}

Widget _chooseSectionLabel(String text) {
  return Align(
    alignment: Alignment.centerLeft,
    child: Text(
      text,
      style: GoogleFonts.montserrat(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF323232),
      ),
    ),
  );
}

class _ChooseSelectCard extends StatelessWidget {
  final double scale;
  final bool selected;
  final String title;
  final String subtitle;
  final Widget? leading;
  final bool radioOnRight;
  final int subtitleMaxLines;
  final VoidCallback onTap;

  const _ChooseSelectCard({
    required this.scale,
    required this.selected,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.leading,
    this.radioOnRight = true,
    this.subtitleMaxLines = 2,
  });

  @override
  Widget build(BuildContext context) {
    final radio = selected ? const _FigmaRadio(selected: true) : null;
    return LightListCard(
      scale: scale,
      borderColor: selected ? Colors.black : null,
      borderWidth: 2,
      padding: EdgeInsets.fromLTRB(
        radioOnRight ? 18 : 16,
        14,
        16,
        14,
      ),
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (!radioOnRight) ...[
            radio ?? const SizedBox(width: 20),
            const SizedBox(width: 12),
          ],
          if (leading != null) ...[
            leading!,
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.montserrat(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  maxLines: subtitleMaxLines,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.montserrat(
                    fontSize: 11,
                    height: 1.35,
                    color: const Color(0xFF4E4E4E),
                  ),
                ),
              ],
            ),
          ),
          if (radioOnRight && radio != null) ...[
            const SizedBox(width: 8),
            radio,
          ],
        ],
      ),
    );
  }
}

class _FigmaRadio extends StatelessWidget {
  final bool selected;

  const _FigmaRadio({required this.selected});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.black, width: 2),
      ),
      alignment: Alignment.center,
      child: selected
          ? Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
              ),
            )
          : null,
    );
  }
}

/// Collect platform-specific supporting info, then publish.
class _PostDetailsPage extends StatefulWidget {
  final DigitalMarketingCampaign campaign;
  final List<PostizIntegration> postizIntegrations;
  final List<Map<String, dynamic>> blotatoAccounts;
  final bool usePostiz;
  final bool useBlotato;

  const _PostDetailsPage({
    required this.campaign,
    required this.postizIntegrations,
    required this.blotatoAccounts,
    required this.usePostiz,
    required this.useBlotato,
  });

  @override
  State<_PostDetailsPage> createState() => _PostDetailsPageState();
}

class _PostDetailsPageState extends State<_PostDetailsPage> {
  final ApiService _apiService = ApiService(
    httpClient: SessionAwareHttpClient(tokenService: TokenService()),
  );

  bool _publishing = false;
  String _publishStatus = '';
  final Map<String, bool> _expanded = {};

  List<PostizIntegration> get _selectedPostiz {
    final ids = widget.campaign.selectedOutlets;
    return widget.postizIntegrations.where((p) => ids.contains(p.id)).toList();
  }

  List<Map<String, dynamic>> get _selectedBlotato {
    final ids = widget.campaign.selectedOutlets;
    return widget.blotatoAccounts
        .where((a) => ids.contains((a['id'] ?? '').toString()))
        .toList();
  }

  OutletOption? _outletFor(PostizIntegration p) {
    for (final o in OutletCatalog.all) {
      if (o.matchesIntegration(p)) return o;
    }
    return null;
  }

  PlatformPostDetails _detailsFor(String id) {
    return widget.campaign.outletDetails.putIfAbsent(
      id,
      () => PlatformPostDetails.fromCampaignCaption(
        widget.campaign.campaignCaption,
      ),
    );
  }

  InputDecoration _fieldDecoration(String label, {String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: GoogleFonts.montserrat(
        fontSize: 12,
        color: LightScreenTheme.muted,
      ),
      hintStyle: GoogleFonts.montserrat(
        fontSize: 12,
        color: LightScreenTheme.hint,
      ),
      filled: true,
      fillColor: LightScreenTheme.field,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: LightScreenTheme.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: LightScreenTheme.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: LightScreenTheme.accent, width: 1.4),
      ),
    );
  }

  Widget _captionField(PlatformPostDetails d) {
    return TextFormField(
      initialValue: d.caption,
      minLines: 3,
      maxLines: 6,
      style: GoogleFonts.montserrat(fontSize: 13, height: 1.4),
      decoration: _fieldDecoration(
        'Caption',
        hint: 'Post caption / description',
      ),
      onChanged: (v) => d.caption = v,
    );
  }

  Widget _youtubeFields(PlatformPostDetails d) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          initialValue: d.youtubeTitle,
          style: GoogleFonts.montserrat(fontSize: 13),
          decoration: _fieldDecoration('Title', hint: '2–100 characters'),
          onChanged: (v) => d.youtubeTitle = v,
        ),
        const SizedBox(height: 10),
        _captionField(d),
        const SizedBox(height: 10),
        DropdownButtonFormField<String>(
          value: d.youtubeVisibility,
          decoration: _fieldDecoration('Visibility'),
          style: GoogleFonts.montserrat(fontSize: 13, color: Colors.black87),
          items: const [
            DropdownMenuItem(value: 'public', child: Text('Public')),
            DropdownMenuItem(value: 'unlisted', child: Text('Unlisted')),
            DropdownMenuItem(value: 'private', child: Text('Private')),
          ],
          onChanged: (v) {
            if (v != null) setState(() => d.youtubeVisibility = v);
          },
        ),
        const SizedBox(height: 10),
        TextFormField(
          initialValue: d.youtubeTagsCsv,
          style: GoogleFonts.montserrat(fontSize: 13),
          decoration: _fieldDecoration(
            'Tags',
            hint: 'Comma-separated, e.g. marketing, tips',
          ),
          onChanged: (v) => d.youtubeTagsCsv = v,
        ),
        const SizedBox(height: 10),
        DropdownButtonFormField<String>(
          value: d.madeForKids,
          decoration: _fieldDecoration('Made for kids'),
          style: GoogleFonts.montserrat(fontSize: 13, color: Colors.black87),
          items: const [
            DropdownMenuItem(value: 'no', child: Text('No')),
            DropdownMenuItem(value: 'yes', child: Text('Yes')),
          ],
          onChanged: (v) {
            if (v != null) setState(() => d.madeForKids = v);
          },
        ),
      ],
    );
  }

  Widget _tiktokFields(PlatformPostDetails d) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          initialValue: d.tiktokTitle,
          style: GoogleFonts.montserrat(fontSize: 13),
          decoration: _fieldDecoration('Title', hint: 'Max 90 characters'),
          onChanged: (v) => d.tiktokTitle = v,
        ),
        const SizedBox(height: 10),
        _captionField(d),
        const SizedBox(height: 10),
        DropdownButtonFormField<String>(
          value: d.tiktokPrivacy,
          decoration: _fieldDecoration('Who can view'),
          style: GoogleFonts.montserrat(fontSize: 13, color: Colors.black87),
          items: const [
            DropdownMenuItem(
              value: 'PUBLIC_TO_EVERYONE',
              child: Text('Everyone'),
            ),
            DropdownMenuItem(
              value: 'FOLLOWER_OF_CREATOR',
              child: Text('Followers'),
            ),
            DropdownMenuItem(
              value: 'MUTUAL_FOLLOW_FRIENDS',
              child: Text('Friends'),
            ),
            DropdownMenuItem(
              value: 'SELF_ONLY',
              child: Text('Only me'),
            ),
          ],
          onChanged: (v) {
            if (v != null) setState(() => d.tiktokPrivacy = v);
          },
        ),
        SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          title: Text('Allow comments', style: GoogleFonts.montserrat(fontSize: 13)),
          value: d.tiktokComment,
          activeColor: LightScreenTheme.accent,
          onChanged: (v) => setState(() => d.tiktokComment = v),
        ),
        SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          title: Text('Allow duet', style: GoogleFonts.montserrat(fontSize: 13)),
          value: d.tiktokDuet,
          activeColor: LightScreenTheme.accent,
          onChanged: (v) => setState(() => d.tiktokDuet = v),
        ),
        SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          title: Text('Allow stitch', style: GoogleFonts.montserrat(fontSize: 13)),
          value: d.tiktokStitch,
          activeColor: LightScreenTheme.accent,
          onChanged: (v) => setState(() => d.tiktokStitch = v),
        ),
        SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          title: Text(
            'Branded content',
            style: GoogleFonts.montserrat(fontSize: 13),
          ),
          value: d.tiktokBrandContent,
          activeColor: LightScreenTheme.accent,
          onChanged: (v) => setState(() => d.tiktokBrandContent = v),
        ),
        SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          title: Text(
            'Your brand',
            style: GoogleFonts.montserrat(fontSize: 13),
          ),
          value: d.tiktokBrandOrganic,
          activeColor: LightScreenTheme.accent,
          onChanged: (v) => setState(() => d.tiktokBrandOrganic = v),
        ),
        SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          title: Text(
            'Made with AI',
            style: GoogleFonts.montserrat(fontSize: 13),
          ),
          value: d.tiktokMadeWithAi,
          activeColor: LightScreenTheme.accent,
          onChanged: (v) => setState(() => d.tiktokMadeWithAi = v),
        ),
      ],
    );
  }

  Widget _instagramFields(PlatformPostDetails d, {required bool autobusOnly}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _captionField(d),
        if (!autobusOnly) ...[
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: d.instagramPostType,
            decoration: _fieldDecoration('Post type'),
            style: GoogleFonts.montserrat(fontSize: 13, color: Colors.black87),
            items: const [
              DropdownMenuItem(value: 'post', child: Text('Feed / Reel')),
              DropdownMenuItem(value: 'story', child: Text('Story')),
            ],
            onChanged: (v) {
              if (v != null) setState(() => d.instagramPostType = v);
            },
          ),
          const SizedBox(height: 10),
          TextFormField(
            initialValue: d.instagramCollaboratorsCsv,
            style: GoogleFonts.montserrat(fontSize: 13),
            decoration: _fieldDecoration(
              'Collaborators',
              hint: 'Usernames, comma-separated',
            ),
            onChanged: (v) => d.instagramCollaboratorsCsv = v,
          ),
        ] else ...[
          const SizedBox(height: 8),
          Text(
            'Autobus Instagram publishes caption + media only.',
            style: GoogleFonts.montserrat(fontSize: 11, color: Colors.black45),
          ),
        ],
      ],
    );
  }

  Widget _genericFields(PlatformPostDetails d) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _captionField(d),
        const SizedBox(height: 8),
        Text(
          'This channel uses caption and media. Extra options are not required.',
          style: GoogleFonts.montserrat(fontSize: 11, color: Colors.black45),
        ),
      ],
    );
  }

  Widget _outletCard({
    required String id,
    required String label,
    required String? subtitle,
    required FaIconData icon,
    required Color color,
    required PlatformDetailsKind kind,
    required bool autobusIg,
  }) {
    final expanded = _expanded[id] ?? true;
    final d = _detailsFor(id);
    return Container(
      decoration: BoxDecoration(
        color: LightScreenTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: LightScreenTheme.border),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _expanded[id] = !expanded),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: Row(
                children: [
                  FaIcon(icon, size: 18, color: color),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: GoogleFonts.montserrat(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (subtitle != null && subtitle.isNotEmpty)
                          Text(
                            subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.montserrat(
                              fontSize: 11,
                              color: Colors.black45,
                            ),
                          ),
                      ],
                    ),
                  ),
                  HomeSfIcon(
                    icon: expanded
                        ? HomeFigmaIcons.chevronUp
                        : HomeFigmaIcons.chevronDown,
                    size: 22,
                    color: LightScreenTheme.muted,
                  ),
                ],
              ),
            ),
          ),
          if (expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 14),
              child: kind == PlatformDetailsKind.youtube
                  ? _youtubeFields(d)
                  : kind == PlatformDetailsKind.tiktok
                      ? _tiktokFields(d)
                      : kind == PlatformDetailsKind.instagram
                          ? _instagramFields(d, autobusOnly: autobusIg)
                          : _genericFields(d),
            ),
        ],
      ),
    );
  }

  String get _sharePlatformSubtitle {
    final labels = <String>[];
    for (final p in _selectedPostiz) {
      final label = _outletFor(p)?.label ??
          (p.identifier.isNotEmpty ? p.identifier : '');
      if (label.isNotEmpty) labels.add(label);
    }
    if (!widget.usePostiz) {
      for (final acct in _selectedBlotato) {
        final label = (acct['platform'] ?? '').toString().trim();
        if (label.isNotEmpty) labels.add(label);
      }
    }
    if (labels.isEmpty) return 'This phone';
    return labels.toSet().join(', ');
  }

  Future<List<XFile>> _shareFiles() async {
    final files = <XFile>[];
    var index = 0;
    for (final content in widget.campaign.selectedContents) {
      if (content.type == MarketingContentType.text) continue;
      final localPath = content.localFilePath?.trim();
      if (!kIsWeb &&
          localPath != null &&
          localPath.isNotEmpty &&
          File(localPath).existsSync()) {
        files.add(XFile(localPath));
        index++;
        continue;
      }
      final bytes = content.generatedBytes;
      if (!kIsWeb && bytes != null && bytes.isNotEmpty) {
        final ext = content.type == MarketingContentType.videos ? 'mp4' : 'jpg';
        final path =
            '${Directory.systemTemp.path}/autobus-share-$index.$ext';
        await File(path).writeAsBytes(bytes, flush: true);
        files.add(XFile(path));
      }
      index++;
    }
    return files;
  }

  Future<void> _shareToApps() async {
    if (_publishing) return;
    final caption = widget.campaign.campaignCaption.trim();
    setState(() {
      _publishing = true;
      _publishStatus = 'Preparing share…';
    });
    try {
      final files = await _shareFiles();
      if (!mounted) return;
      setState(() {
        _publishing = false;
        _publishStatus = '';
      });
      if (files.isNotEmpty) {
        await Share.shareXFiles(
          files,
          text: caption.isEmpty ? null : caption,
        );
      } else if (caption.isNotEmpty) {
        await Share.share(caption);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Nothing to share yet. Generate content first.',
              style: GoogleFonts.montserrat(fontSize: 13),
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _publishing = false;
        _publishStatus = '';
      });
      if (!widget.usePostiz && !widget.useBlotato) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Could not open share sheet. $e',
              style: GoogleFonts.montserrat(fontSize: 13),
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
    }
    if (mounted && (widget.usePostiz || widget.useBlotato)) {
      await _publish();
    }
  }

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.sizeOf(context).width / appShellDesignWidth;
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return _MarketingScaffold(
      trailing: const SizedBox.shrink(),
      child: Stack(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                primary: true,
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.only(bottom: bottomInset + 12),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Post your campaign',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.montserrat(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF323232),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Select generated content, platforms and captions',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.montserrat(
                          fontSize: 12,
                          color: const Color(0xFF898888),
                        ),
                      ),
                      const SizedBox(height: 22),
                      LightListCard(
                        scale: scale,
                        padding: const EdgeInsets.fromLTRB(18, 14, 16, 14),
                        onTap: _publishing ? null : _shareToApps,
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: const Color(0xFFD8D8D8),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              alignment: Alignment.center,
                              child: HomeSfIcon(
                                icon: HomeFigmaIcons.share,
                                size: 20,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Share to Apps on this phone',
                                    style: GoogleFonts.montserrat(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _sharePlatformSubtitle,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.montserrat(
                                      fontSize: 11,
                                      color: const Color(0xFF938F8F),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            HomeSfIcon(
                              icon: HomeFigmaIcons.chevronRight,
                              size: 16,
                              color: const Color(0xFF14171A),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          if (_publishing)
            Positioned.fill(
              child: ColoredBox(
                color: LightScreenTheme.background.withValues(alpha: 0.88),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const AutobusLoadingIndicator(size: 36),
                      const SizedBox(height: 16),
                      Text(
                        _publishStatus.isEmpty
                            ? 'Preparing…'
                            : _publishStatus,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.montserrat(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _setStatus(String status) {
    if (!mounted) return;
    setState(() => _publishStatus = status);
  }

  String _captionForOutlet(String id, String fallback) {
    final d = widget.campaign.outletDetails[id];
    final c = d?.caption.trim();
    if (c != null && c.isNotEmpty) return c;
    return fallback;
  }

  Future<void> _publish() async {
    final selectedIds = widget.campaign.selectedOutlets.toList();
    if (selectedIds.isEmpty || _publishing) return;

    // YouTube requires a title (2–100 chars).
    for (final p in _selectedPostiz) {
      if (p.identifier.toLowerCase() != 'youtube') continue;
      if (p.id.startsWith(_kAutobusIgPrefix)) continue;
      final d = _detailsFor(p.id);
      final title = d.youtubeTitle.trim().isNotEmpty
          ? d.youtubeTitle.trim()
          : PlatformPostDetails.fromCampaignCaption(d.caption).youtubeTitle;
      if (title.trim().length < 2) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'YouTube needs a title (at least 2 characters).',
              style: GoogleFonts.montserrat(fontSize: 13),
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
      d.youtubeTitle = title;
    }

    setState(() {
      _publishing = true;
      _publishStatus = 'Preparing content…';
    });

    final messenger = ScaffoldMessenger.of(context);
    final textContent = widget.campaign.campaignCaption;

    try {
      _setStatus('Uploading media…');
      final mediaUrls = <String>[];
      for (final c in widget.campaign.selectedContents) {
        if (c.type == MarketingContentType.text) continue;

        final existing = c.generatedResult?.trim();
        if (existing != null &&
            existing.isNotEmpty &&
            (existing.startsWith('http://') ||
                existing.startsWith('https://'))) {
          mediaUrls.add(existing);
          continue;
        }

        final localPath = c.localFilePath?.trim();
        if (!kIsWeb && localPath != null && localPath.isNotEmpty) {
          try {
            final file = File(localPath);
            if (await file.exists() && await file.length() > 0) {
              final url = await _apiService.uploadFile(
                file: file,
                filename: file.uri.pathSegments.isNotEmpty
                    ? file.uri.pathSegments.last
                    : null,
              );
              mediaUrls.add(url);
              continue;
            }
          } catch (_) {
            // Fall through to bytes upload if available.
          }
        }

        final bytes = c.generatedBytes;
        if (bytes != null && bytes.isNotEmpty) {
          final filename = c.type == MarketingContentType.videos
              ? 'marketing-video.mp4'
              : (c.generatedResult?.trim().isNotEmpty == true
                    ? c.generatedResult!.trim()
                    : 'marketing-image.jpg');
          final url = await _apiService.uploadFileBytes(
            fileBytes: bytes,
            filename: filename,
          );
          mediaUrls.add(url);
        }
      }

      final igIds = selectedIds
          .where((id) => id.startsWith(_kAutobusIgPrefix))
          .map((id) => id.substring(_kAutobusIgPrefix.length))
          .where((id) => id.isNotEmpty)
          .toList();
      final postizIds =
          selectedIds.where((id) => !id.startsWith(_kAutobusIgPrefix)).toList();

      final scheduleTime =
          widget.campaign.scheduledDate?.toUtc().toIso8601String();

      var publishedCount = 0;
      final errors = <String>[];

      if (igIds.isNotEmpty) {
        if (mediaUrls.isEmpty) {
          throw Exception(
            'Instagram needs at least one uploaded image or video URL.',
          );
        }
        _setStatus(
          widget.campaign.postRightAway
              ? 'Publishing to Instagram…'
              : 'Publishing to Instagram (goes live now)…',
        );
        for (final accountId in igIds) {
          final outletKey = '$_kAutobusIgPrefix$accountId';
          try {
            await _apiService.publishInstagramPost(
              accountId: accountId,
              caption: _captionForOutlet(outletKey, textContent),
              mediaUrls: mediaUrls,
            );
            publishedCount++;
          } catch (e) {
            errors.add(
              'Instagram: ${e.toString().replaceFirst('Exception: ', '')}',
            );
          }
        }
      }

      if (postizIds.isNotEmpty && widget.usePostiz) {
        final selected = widget.postizIntegrations
            .where((p) => postizIds.contains(p.id))
            .toList();
        if (selected.isEmpty) {
          throw Exception('No matching Postiz channels for the selection.');
        }
        _setStatus(
          widget.campaign.postRightAway
              ? 'Publishing via Postiz…'
              : 'Scheduling via Postiz…',
        );
        final payload = buildPostizCreatePostPayload(
          selectedIntegrations: selected,
          content: textContent,
          mediaUrls: mediaUrls,
          postRightAway: widget.campaign.postRightAway,
          scheduledUtc: widget.campaign.scheduledDate,
          outletDetails: widget.campaign.outletDetails,
        );
        await _apiService.createPostizPost(
          payload,
          agentName: 'digital_marketing',
        );
        publishedCount += selected.length;
      } else if (postizIds.isNotEmpty && widget.useBlotato) {
        _setStatus('Publishing…');
        // Blotato has one content field — use first selected caption override if any.
        var blotatoContent = textContent;
        for (final id in postizIds) {
          final c = widget.campaign.outletDetails[id]?.caption.trim();
          if (c != null && c.isNotEmpty) {
            blotatoContent = c;
            break;
          }
        }
        await _apiService.publishSocialPost(
          accountIds: postizIds,
          content: blotatoContent.isEmpty ? ' ' : blotatoContent,
          mediaUrls: mediaUrls,
          scheduleTime: scheduleTime,
        );
        publishedCount += postizIds.length;
      } else if (igIds.isEmpty) {
        throw Exception(
          'Connect an outlet in Marketing → Link Social Media, then try again.',
        );
      }

      if (!mounted) return;

      if (publishedCount == 0 && errors.isNotEmpty) {
        throw Exception(errors.join('\n'));
      }

      final successMsg = errors.isEmpty
          ? (widget.campaign.postRightAway
                ? 'Published to $publishedCount channel(s)'
                : 'Scheduled / published for $publishedCount channel(s)')
          : 'Published to $publishedCount channel(s). Some failed: ${errors.join('; ')}';

      messenger.showSnackBar(
        SnackBar(
          content: Text(
            successMsg,
            style: GoogleFonts.montserrat(color: Colors.white, fontSize: 13),
          ),
          backgroundColor:
              errors.isEmpty ? Colors.green : Colors.orange.shade800,
          behavior: SnackBarBehavior.floating,
        ),
      );

      if (errors.isEmpty && mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            'Publish failed: ${e.toString().replaceFirst('Exception: ', '')}',
            style: GoogleFonts.montserrat(color: Colors.white, fontSize: 13),
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 6),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _publishing = false;
          _publishStatus = '';
        });
      }
    }
  }
}
