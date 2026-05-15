import 'package:autobus/barrel.dart';
import 'package:file_picker/file_picker.dart';

class ManageIntelligence extends StatefulWidget {
  const ManageIntelligence({super.key});

  @override
  State<ManageIntelligence> createState() => _ManageIntelligenceState();
}

class _ManageIntelligenceState extends State<ManageIntelligence> {
  bool _presenceRequested = false;
  bool _presenceLoading = true;
  bool _hasRagDocuments = false;
  String? _presenceError;

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
        _hasRagDocuments = files.isNotEmpty;
        _presenceLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _presenceError = e.toString();
        _presenceLoading = false;
        _hasRagDocuments = false;
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

    final navigator = Navigator.of(context, rootNavigator: true);
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
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
                const SizedBox(
                  width: 36,
                  height: 36,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(height: 16),
                Text(
                  'Uploading…',
                  style: GoogleFonts.montserrat(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    final api = context.read<ApiService>();
    try {
      for (final picked in result.files) {
        final name = picked.name.trim().isEmpty ? 'upload' : picked.name;
        final path = picked.path?.trim();
        if (path != null && path.isNotEmpty) {
          await api.uploadRagDocument(filename: name, filePath: path);
        } else if (picked.bytes != null && picked.bytes!.isNotEmpty) {
          await api.uploadRagDocument(
            filename: name,
            fileBytes: picked.bytes!.toList(),
          );
        } else {
          throw Exception(
            'Could not read "$name". On this device, try choosing the file again.',
          );
        }
      }
      if (!mounted) return;
      navigator.pop();
      await _loadRagPresence();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.files.length == 1
                ? 'Document uploaded and indexed.'
                : '${result.files.length} documents uploaded and indexed.',
            style: GoogleFonts.montserrat(),
          ),
        ),
      );
    } catch (e) {
      if (navigator.canPop()) navigator.pop();
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
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const DecoratedBox(
            decoration: ManageScreenStyle.homeDashboardBodyDecoration,
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                  child: Row(
                    children: [
                      const ManageScreenBackButton(),
                      const SizedBox(width: 18),
                      Expanded(
                        child: Text(
                          'Manage Intelligence',
                          style: ManageScreenStyle.headerTitleStyle(),
                        ),
                      ),
                    ],
                  ),
                ),
                // Welcome Section
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 60),
                          Text(
                            'Welcome to Business Chat Intelligence',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.montserrat(
                              color: Colors.white,
                              fontSize: 19,
                              fontWeight: FontWeight.w500,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Upload business information documents to train your AI assistant on your company\'s information. The AI can instantly answer customer questions, provide support, and deliver accurate responses based on your files — helping businesses automate communication and improve customer experience.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.montserrat(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 14,
                              fontWeight: FontWeight.w300,
                              height: 1.6,
                            ),
                          ),
                          const SizedBox(height: 32),
                          if (_presenceLoading) ...[
                            const SizedBox(height: 8),
                            const Center(
                              child: SizedBox(
                                width: 28,
                                height: 28,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            ),
                            const SizedBox(height: 24),
                          ] else if (_presenceError != null) ...[
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.amber.withValues(alpha: 0.12),
                                border: Border.all(
                                  color: Colors.amber.withValues(alpha: 0.45),
                                  width: 1.2,
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.cloud_off_outlined,
                                    color: Colors.amber.shade300,
                                    size: 22,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Could not verify your documents. Pull to refresh after opening the screen again, or check your connection.\n${_shortPresenceError(_presenceError!)}',
                                      style: GoogleFonts.montserrat(
                                        color: Colors.white.withValues(
                                          alpha: 0.88,
                                        ),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400,
                                        height: 1.45,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: _loadRagPresence,
                                    icon: Icon(
                                      Icons.refresh,
                                      color: Colors.white.withValues(
                                        alpha: 0.85,
                                      ),
                                      size: 22,
                                    ),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(
                                      minWidth: 32,
                                      minHeight: 32,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 32),
                          ] else if (!_hasRagDocuments) ...[
                            Container(
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFF581C87,
                                ).withValues(alpha: 0.1),
                                border: Border.all(
                                  color: const Color(
                                    0xFF9333EA,
                                  ).withValues(alpha: 0.5),
                                  width: 1.5,
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.warning_rounded,
                                    color: Colors.red.shade400,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'You have not uploaded any business data',
                                      style: GoogleFonts.montserrat(
                                        color: Colors.white.withValues(
                                          alpha: 0.85,
                                        ),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ] else
                            const SizedBox(height: 8),
                          const SizedBox(height: 40),
                          // Action Cards Grid
                          GridView.count(
                            crossAxisCount: 2,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            childAspectRatio: 1.0,
                            children: [
                              _IntelligenceCard(
                                icon: Icons.description_outlined,
                                title: 'Upload Files',
                                onTap: _handleUploadFiles,
                              ),
                              _IntelligenceCard(
                                icon: Icons.file_copy_outlined,
                                title: 'View Files',
                                onTap: () async {
                                  await Navigator.push<void>(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const IntelligenceHistoryPage(),
                                    ),
                                  );
                                  if (mounted) await _loadRagPresence();
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _IntelligenceCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _IntelligenceCard({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFF3F1163), width: 1),
          borderRadius: BorderRadius.circular(32),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(height: 14),
            Text(
              title,
              style: GoogleFonts.montserrat(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 13,
                fontWeight: FontWeight.w400,
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
        SnackBar(
          content: Text(
            'Deleted "$name"',
            style: GoogleFonts.outfit(),
          ),
        ),
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
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const DecoratedBox(
            decoration: ManageScreenStyle.homeDashboardBodyDecoration,
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const ManageScreenBackButton(),
                      const SizedBox(width: 18),
                      Expanded(
                        child: Text(
                          'Manage Intelligence',
                          style: ManageScreenStyle.headerTitleStyle(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Expanded(
                    child: _loading
                        ? const Center(
                            child: SizedBox(
                              width: 32,
                              height: 32,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : _loadError != null
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  child: Text(
                                    _loadError!,
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.outfit(
                                      color: Colors.white.withValues(
                                        alpha: 0.75,
                                      ),
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                TextButton(
                                  onPressed: _loadDocuments,
                                  child: Text(
                                    'Retry',
                                    style: GoogleFonts.outfit(
                                      color: const Color(0xFFA855F7),
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : _documents.isEmpty
                        ? Center(
                            child: Text(
                              'No files uploaded yet',
                              style: GoogleFonts.outfit(
                                color: Colors.white.withValues(alpha: 0.6),
                                fontSize: 16,
                              ),
                            ),
                          )
                        : RefreshIndicator(
                            color: const Color(0xFFA855F7),
                            onRefresh: _loadDocuments,
                            child: ListView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              itemCount: _documents.length,
                              itemBuilder: (context, index) {
                                final doc = _documents[index];
                                final name = _fileName(doc);
                                final key = _objectKey(doc);
                                final isExpanded = _expandedIndex == index;

                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _expandedIndex = isExpanded
                                            ? null
                                            : index;
                                      });
                                    },
                                    child: AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 300,
                                      ),
                                      padding: EdgeInsets.all(
                                        isExpanded ? 32 : 24,
                                      ),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: const Color(0xFF3F1163),
                                          width: 1,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          isExpanded ? 38 : 30,
                                        ),
                                      ),
                                      child: isExpanded
                                          ? Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  name,
                                                  style: GoogleFonts.outfit(
                                                    color: Colors.white,
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.w400,
                                                  ),
                                                ),
                                                if (key != null) ...[
                                                  const SizedBox(height: 12),
                                                  Text(
                                                    key,
                                                    style: GoogleFonts.outfit(
                                                      color: Colors.white
                                                          .withValues(
                                                            alpha: 0.65,
                                                          ),
                                                      fontSize: 11,
                                                      fontWeight:
                                                          FontWeight.w300,
                                                    ),
                                                  ),
                                                ],
                                                const SizedBox(height: 16),
                                                Center(
                                                  child: TextButton(
                                                    onPressed: () =>
                                                        _deleteAt(index),
                                                    child: Text(
                                                      'Delete file',
                                                      style:
                                                          GoogleFonts.outfit(
                                                            color: Colors.white
                                                                .withValues(
                                                                  alpha: 0.75,
                                                                ),
                                                            fontSize: 13,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w300,
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
                                                Text(
                                                  name,
                                                  style: GoogleFonts.outfit(
                                                    color: Colors.white,
                                                    fontSize: 18,
                                                    fontWeight:
                                                        FontWeight.w400,
                                                  ),
                                                ),
                                                if (key != null) ...[
                                                  const SizedBox(height: 6),
                                                  Text(
                                                    key,
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: GoogleFonts.outfit(
                                                      color: Colors.white
                                                          .withValues(
                                                            alpha: 0.45,
                                                          ),
                                                      fontSize: 11,
                                                      fontWeight:
                                                          FontWeight.w300,
                                                    ),
                                                  ),
                                                ],
                                              ],
                                            ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
