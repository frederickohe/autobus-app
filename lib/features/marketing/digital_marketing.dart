import 'package:autobus/barrel.dart';

const _kPrimary = Color(0xFF1A1A2E);
const _kPurple = Color(0xFF6C63FF);
const _kRed = Color(0xFFE63946);

enum MarketingContentType { pictures, videos, text }

enum MediaGenState { idle, generating, ready }

class MarketingContent {
  final MarketingContentType type;
  String? prompt;
  String? manualText;
  String? generatedResult;
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

  DigitalMarketingCampaign(this.contents);
}

class _MarketingScaffold extends StatelessWidget {
  final Widget child;
  final bool showStar;

  const _MarketingScaffold({required this.child, this.showStar = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: _kPrimary,
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                  Text(
                    'Digital Marketing',
                    style: GoogleFonts.roboto(
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                      color: Colors.black87,
                    ),
                  ),
                  if (showStar)
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: _kPrimary, width: 2),
                        color: Colors.white,
                      ),
                      child: const Icon(Icons.star, color: _kRed, size: 24),
                    )
                  else
                    const SizedBox(width: 48),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DarkButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool showArrows;

  const _DarkButton({required this.label, this.onTap, this.showArrows = true});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: onTap != null ? _kPrimary : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: GoogleFonts.roboto(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
            if (showArrows) ...[
              const SizedBox(width: 12),
              const Text(
                '›  ›  ›',
                style: TextStyle(color: Colors.white, fontSize: 13),
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
  final VoidCallback? onSend;
  final VoidCallback? onMic;

  const _PromptBar({
    required this.controller,
    required this.hint,
    this.onSend,
    this.onMic,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onSend,
            child: Icon(
              Icons.add,
              color: onSend != null ? Colors.black87 : Colors.black38,
              size: 22,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              style: GoogleFonts.roboto(fontSize: 14),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: GoogleFonts.roboto(
                  fontSize: 14,
                  color: Colors.black38,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: onMic,
            child: const Icon(Icons.mic_outlined, color: _kPrimary, size: 22),
          ),
        ],
      ),
    );
  }
}

class DigitalMarketingPage extends StatefulWidget {
  const DigitalMarketingPage({super.key});

  @override
  State<DigitalMarketingPage> createState() => _DigitalMarketingPageState();
}

class _DigitalMarketingPageState extends State<DigitalMarketingPage> {
  final Set<MarketingContentType> _selected = {};

  void _onGetStarted() {
    if (_selected.isEmpty) return;
    final contents = MarketingContentType.values
        .where(_selected.contains)
        .map((t) => MarketingContent(t))
        .toList();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _GenerateMediaPage(
          campaign: DigitalMarketingCampaign(contents),
          contentIndex: 0,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _MarketingScaffold(
      showStar: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              'Select Marketing Content',
              style: GoogleFonts.roboto(fontSize: 16, color: Colors.black87),
            ),
          ),
          const SizedBox(height: 32),

          _TypeCard(
            type: MarketingContentType.pictures,
            label: 'Pictures',
            icon: Icons.image_rounded,
            iconColor: const Color(0xFF9B59B6),
            selected: _selected.contains(MarketingContentType.pictures),
            onTap: () => setState(
              () => _selected.contains(MarketingContentType.pictures)
                  ? _selected.remove(MarketingContentType.pictures)
                  : _selected.add(MarketingContentType.pictures),
            ),
          ),
          const SizedBox(height: 20),
          _TypeCard(
            type: MarketingContentType.videos,
            label: 'Videos',
            icon: Icons.videocam_rounded,
            iconColor: const Color(0xFFE74C3C),
            selected: _selected.contains(MarketingContentType.videos),
            onTap: () => setState(
              () => _selected.contains(MarketingContentType.videos)
                  ? _selected.remove(MarketingContentType.videos)
                  : _selected.add(MarketingContentType.videos),
            ),
          ),
          const SizedBox(height: 20),
          _TypeCard(
            type: MarketingContentType.text,
            label: 'Text',
            icon: Icons.article_rounded,
            iconColor: const Color(0xFFE67E22),
            selected: _selected.contains(MarketingContentType.text),
            onTap: () => setState(
              () => _selected.contains(MarketingContentType.text)
                  ? _selected.remove(MarketingContentType.text)
                  : _selected.add(MarketingContentType.text),
            ),
          ),

          const Spacer(),

          _DarkButton(
            label: 'Get Started',
            onTap: _selected.isNotEmpty ? _onGetStarted : null,
          ),
          const SizedBox(height: 20),
        ],
      ),
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? _kPrimary : Colors.grey.shade200,
            width: selected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 40, color: iconColor),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.roboto(
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
  final int contentIndex;

  const _GenerateMediaPage({
    required this.campaign,
    required this.contentIndex,
  });

  @override
  State<_GenerateMediaPage> createState() => _GenerateMediaPageState();
}

class _GenerateMediaPageState extends State<_GenerateMediaPage> {
  final TextEditingController _promptCtrl = TextEditingController();
  final TextEditingController _textBodyCtrl = TextEditingController();

  final ApiService _apiService = ApiService(
    httpClient: SessionAwareHttpClient(tokenService: TokenService()),
  );

  MarketingContent get _content =>
      widget.campaign.contents[widget.contentIndex];
  bool get _isText => _content.type == MarketingContentType.text;

  @override
  void initState() {
    super.initState();
    _promptCtrl.addListener(() => setState(() {}));
    _textBodyCtrl.addListener(() => _content.manualText = _textBodyCtrl.text);

    if (_content.manualText != null) _textBodyCtrl.text = _content.manualText!;
  }

  @override
  void dispose() {
    _promptCtrl.dispose();
    _textBodyCtrl.dispose();
    super.dispose();
  }

  Future<void> _generate() async {
    final prompt = _promptCtrl.text.trim();
    if (prompt.isEmpty) return;

    setState(() {
      _content.prompt = prompt;
      _content.genState = MediaGenState.generating;
    });
    _promptCtrl.clear();

    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('user');
      String userId = '';
      if (userJson != null) {
        final user = jsonDecode(userJson) as Map<String, dynamic>;
        userId = (user['id'] ?? user['phone'] ?? '').toString();
      }

      final result = await _apiService.generateAgentContent(
        userId: userId,
        prompt: prompt,
        agentName: 'marketing',
      );

      if (!mounted) return;
      setState(() {
        _content.genState = MediaGenState.ready;
        _content.generatedResult = _isText ? result : 'https://your-cdn.com/generated-asset';
        if (_isText) _textBodyCtrl.text = result;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _content.genState = MediaGenState.idle);
    }
  }

  void _goNext() {
    _content.manualText = _isText ? _textBodyCtrl.text : null;

    final nextIdx = widget.contentIndex + 1;
    if (nextIdx < widget.campaign.contents.length) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => _GenerateMediaPage(
            campaign: widget.campaign,
            contentIndex: nextIdx,
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

  @override
  Widget build(BuildContext context) {
    final canGenerate =
        _promptCtrl.text.trim().isNotEmpty &&
        _content.genState != MediaGenState.generating;

    return _MarketingScaffold(
      child: Column(
        children: [
          Text(
            _content.pageTitle,
            style: GoogleFonts.roboto(fontSize: 16, color: Colors.black87),
          ),
          const SizedBox(height: 20),

          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: _buildPreviewBox(),
              ),
            ),
          ),

          const SizedBox(height: 16),
          _PromptBar(
            controller: _promptCtrl,
            hint: _content.promptHint,
            onSend: canGenerate ? _generate : null,
            onMic: () {
              /* TODO: voice input */
            },
          ),

          const SizedBox(height: 16),
          _DarkButton(label: 'Next', onTap: _goNext),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildPreviewBox() {
    if (_isText) {
      return Stack(
        fit: StackFit.expand,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _textBodyCtrl,
              maxLines: null,
              expands: true,
              style: GoogleFonts.roboto(fontSize: 14, color: Colors.black87),
              decoration: InputDecoration(
                hintText: 'Type Text Here...',
                hintStyle: GoogleFonts.roboto(
                  fontSize: 14,
                  color: Colors.black38,
                ),
                border: InputBorder.none,
              ),
            ),
          ),
          if (_content.genState == MediaGenState.generating)
            _GeneratingOverlay(label: _content.label),
        ],
      );
    }

    switch (_content.genState) {
      case MediaGenState.idle:
        return _IdlePreview(content: _content);
      case MediaGenState.generating:
        return _GeneratingOverlay(label: _content.label);
      case MediaGenState.ready:
        return _ReadyPreview(content: _content);
    }
  }
}

class _IdlePreview extends StatelessWidget {
  final MarketingContent content;
  const _IdlePreview({required this.content});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          content.type == MarketingContentType.pictures
              ? Icons.image_rounded
              : Icons.movie_rounded,
          size: 80,
          color: _kPurple,
        ),
        const SizedBox(height: 12),
        Text(
          content.label,
          style: GoogleFonts.roboto(fontSize: 13, color: _kPurple),
        ),
      ],
    );
  }
}

class _GeneratingOverlay extends StatefulWidget {
  final String label;
  const _GeneratingOverlay({required this.label});

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
    return Container(
      color: Colors.white.withOpacity(0.93),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FadeTransition(
              opacity: _fade,
              child: Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: _kPurple.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  size: 44,
                  color: _kPurple,
                ),
              ),
            ),
            const SizedBox(height: 22),
            FadeTransition(
              opacity: _fade,
              child: Text(
                'Generating...',
                style: GoogleFonts.roboto(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: _kPrimary,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Creating your ${widget.label.toLowerCase()}',
              style: GoogleFonts.roboto(fontSize: 13, color: Colors.black45),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReadyPreview extends StatelessWidget {
  final MarketingContent content;
  const _ReadyPreview({required this.content});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_circle_rounded,
            size: 44,
            color: Colors.green,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          '${content.label} Ready!',
          style: GoogleFonts.roboto(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: _kPrimary,
          ),
        ),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            content.prompt ?? '',
            textAlign: TextAlign.center,
            style: GoogleFonts.roboto(fontSize: 12, color: Colors.black45),
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

  void _proceed({bool rightAway = false}) {
    widget.campaign.postRightAway = rightAway;
    widget.campaign.scheduledDate = rightAway ? null : _selectedDay;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _SelectOutletPage(campaign: widget.campaign),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _MarketingScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              'Schedule Your Post',
              style: GoogleFonts.roboto(fontSize: 16, color: Colors.black87),
            ),
          ),
          const SizedBox(height: 20),

          _InlineCalendar(
            focusedMonth: _focusedMonth,
            selectedDay: _selectedDay,
            onDaySelected: (d) => setState(() => _selectedDay = d),
            onMonthChanged: (m) => setState(() => _focusedMonth = m),
          ),

          const Spacer(),

          GestureDetector(
            onTap: () => _proceed(rightAway: true),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: _kPrimary,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Center(
                child: Text(
                  'Post Right Away',
                  style: GoogleFonts.roboto(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          _DarkButton(label: 'Next', onTap: () => _proceed()),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _InlineCalendar extends StatelessWidget {
  final DateTime focusedMonth;
  final DateTime? selectedDay;
  final ValueChanged<DateTime> onDaySelected;
  final ValueChanged<DateTime> onMonthChanged;

  const _InlineCalendar({
    required this.focusedMonth,
    required this.selectedDay,
    required this.onDaySelected,
    required this.onMonthChanged,
  });

  static const _months = [
    '',
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  static const _days = ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'];

  @override
  Widget build(BuildContext context) {
    final y = focusedMonth.year;
    final m = focusedMonth.month;
    final daysInMonth = DateUtils.getDaysInMonth(y, m);
    final firstWeekday = DateTime(y, m, 1).weekday % 7;
    final today = DateTime.now();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '${_months[m]} $y',
                    style: GoogleFonts.roboto(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  const TextSpan(
                    text: '  ›',
                    style: TextStyle(
                      color: _kRed,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () => onMonthChanged(DateTime(y, m - 1)),
              child: const Icon(Icons.chevron_left, color: _kRed, size: 28),
            ),
            const SizedBox(width: 4),
            GestureDetector(
              onTap: () => onMonthChanged(DateTime(y, m + 1)),
              child: const Icon(Icons.chevron_right, color: _kRed, size: 28),
            ),
          ],
        ),
        const SizedBox(height: 12),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: _days
              .map(
                (d) => SizedBox(
                  width: 36,
                  child: Text(
                    d,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.roboto(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.black38,
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 8),

        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            childAspectRatio: 1.0,
          ),
          itemCount: firstWeekday + daysInMonth,
          itemBuilder: (_, i) {
            if (i < firstWeekday) return const SizedBox();
            final day = i - firstWeekday + 1;
            final date = DateTime(y, m, day);
            final isToday = DateUtils.isSameDay(date, today);
            final isSel =
                selectedDay != null && DateUtils.isSameDay(date, selectedDay!);

            return GestureDetector(
              onTap: () => onDaySelected(date),
              child: Container(
                margin: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: isSel
                      ? _kRed
                      : isToday
                      ? _kRed.withOpacity(0.12)
                      : null,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  '$day',
                  style: GoogleFonts.roboto(
                    fontSize: 13,
                    fontWeight: isToday || isSel
                        ? FontWeight.w700
                        : FontWeight.w400,
                    color: isSel
                        ? Colors.white
                        : isToday
                        ? _kRed
                        : Colors.black87,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _OutletItem {
  final String label;
  final IconData icon;
  final Color color;
  const _OutletItem(this.label, this.icon, this.color);
}

class _SelectOutletPage extends StatefulWidget {
  final DigitalMarketingCampaign campaign;
  const _SelectOutletPage({required this.campaign});

  @override
  State<_SelectOutletPage> createState() => _SelectOutletPageState();
}

class _SelectOutletPageState extends State<_SelectOutletPage> {
  final ApiService _apiService = ApiService(
    httpClient: SessionAwareHttpClient(tokenService: TokenService()),
  );

  List<Map<String, dynamic>> _connectedAccounts = [];
  bool _loadingAccounts = true;

  // Fallback static outlets when no accounts are connected
  static final _outlets = [
    _OutletItem('Email List', Icons.email_outlined, const Color(0xFF546E7A)),
    _OutletItem('LinkedIn', Icons.work_outline, const Color(0xFF0077B5)),
    _OutletItem('Facebook', Icons.facebook, const Color(0xFF1877F2)),
    _OutletItem('WhatsApp Status', Icons.chat_bubble_outline, const Color(0xFF25D366)),
    _OutletItem('Instagram', Icons.camera_alt_outlined, const Color(0xFFE1306C)),
    _OutletItem('X', Icons.close, const Color(0xFF000000)),
    _OutletItem('YouTube', Icons.play_circle_outline, const Color(0xFFFF0000)),
  ];

  @override
  void initState() {
    super.initState();
    _loadAccounts();
  }

  Future<void> _loadAccounts() async {
    try {
      final accounts = await _apiService.getSocialAccounts();
      if (mounted) setState(() { _connectedAccounts = accounts; _loadingAccounts = false; });
    } catch (_) {
      if (mounted) setState(() => _loadingAccounts = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use connected accounts if available, otherwise fall back to static outlets
    final useConnected = !_loadingAccounts && _connectedAccounts.isNotEmpty;
    final itemCount = useConnected ? _connectedAccounts.length : _outlets.length;

    return _MarketingScaffold(
      showStar: true,
      child: Column(
        children: [
          Text(
            'Select Your Digital Outlet',
            style: GoogleFonts.roboto(fontSize: 16, color: Colors.black87),
          ),
          const SizedBox(height: 24),

          if (_loadingAccounts)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.5,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: itemCount,
                itemBuilder: (_, i) {
                  final String id;
                  final String label;
                  final IconData icon;
                  final Color color;

                  if (useConnected) {
                    final acct = _connectedAccounts[i];
                    id = acct['id'] as String? ?? '';
                    label = (acct['account_name'] ?? acct['platform'] ?? 'Account').toString();
                    icon = Icons.link;
                    color = _kPurple;
                  } else {
                    final o = _outlets[i];
                    id = o.label;
                    label = o.label;
                    icon = o.icon;
                    color = o.color;
                  }

                  final sel = widget.campaign.selectedOutlets.contains(id);

                  return GestureDetector(
                    onTap: () => setState(
                      () => sel
                          ? widget.campaign.selectedOutlets.remove(id)
                          : widget.campaign.selectedOutlets.add(id),
                    ),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: sel ? _kPrimary : Colors.grey.shade200,
                          width: sel ? 2 : 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(icon, size: 30, color: color),
                          const SizedBox(height: 6),
                          Text(
                            label,
                            style: GoogleFonts.roboto(fontSize: 11, color: Colors.black54),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

          const SizedBox(height: 16),

          _DarkButton(
            label: 'Publish',
            onTap: widget.campaign.selectedOutlets.isNotEmpty ? _publish : null,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Future<void> _publish() async {
    final selectedIds = widget.campaign.selectedOutlets.toList();
    final textContent = widget.campaign.contents
        .where((c) => c.type == MarketingContentType.text)
        .map((c) => c.manualText ?? c.generatedResult ?? '')
        .where((s) => s.isNotEmpty)
        .join('\n\n');

    final mediaUrls = widget.campaign.contents
        .where((c) => c.type != MarketingContentType.text && c.generatedResult != null)
        .map((c) => c.generatedResult!)
        .toList();

    final scheduleTime = widget.campaign.scheduledDate?.toUtc().toIso8601String();

    // Only call the API if we have connected accounts (IDs that are UUIDs)
    final useApi = _connectedAccounts.isNotEmpty;

    try {
      if (useApi) {
        await _apiService.publishSocialPost(
          accountIds: selectedIds,
          content: textContent,
          mediaUrls: mediaUrls,
          scheduleTime: scheduleTime,
        );
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            useApi
                ? 'Published successfully to ${selectedIds.length} account(s)'
                : 'Scheduled for: ${selectedIds.join(', ')}',
            style: GoogleFonts.roboto(color: Colors.white),
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Publish failed: $e', style: GoogleFonts.roboto(color: Colors.white)),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
