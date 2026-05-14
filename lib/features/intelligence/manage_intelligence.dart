import 'package:autobus/barrel.dart';
import 'package:file_picker/file_picker.dart';

class ManageIntelligence extends StatefulWidget {
  const ManageIntelligence({super.key});

  @override
  State<ManageIntelligence> createState() => _ManageIntelligenceState();
}

class _ManageIntelligenceState extends State<ManageIntelligence> {
  Future<void> _handleUploadFiles() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      allowMultiple: true,
    );

    if (!mounted || result == null || result.files.isEmpty) return;

    final count = result.files.length;

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
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle_rounded,
                  color: Color(0xFF22C55E),
                  size: 44,
                ),
                const SizedBox(height: 12),
                Text(
                  count == 1 ? 'File uploaded' : '$count files uploaded',
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

    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    if (Navigator.of(context, rootNavigator: true).canPop()) {
      Navigator.of(context, rootNavigator: true).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0814),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Gradient Background
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.topCenter,
                radius: 1.5,
                colors: [
                  Color(0xFF1A1333),
                  Color(0xFF120D26),
                  Color(0xFF0A0814),
                ],
              ),
            ),
          ),
          // Content
          SafeArea(
            child: Column(
              children: [
                // Header with Back Button
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.2),
                              width: 1,
                            ),
                            color: Colors.white.withValues(alpha: 0.03),
                            backgroundBlendMode: BlendMode.overlay,
                          ),
                          child: Center(
                            child: Icon(
                              Icons.arrow_back,
                              color: Colors.white.withValues(alpha: 0.8),
                              size: 22,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'Manage Intelligence',
                        style: GoogleFonts.montserrat(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 0.5,
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
                              fontSize: 21,
                              fontWeight: FontWeight.w500,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Upload your business documents to create an AI assistant trained on your company\'s information. The AI can instantly answer customer questions, provide support, and deliver accurate responses based on your files — helping businesses automate communication and improve customer experience.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.montserrat(
                              color: Colors.white.withValues(alpha: 0.6),
                              fontSize: 14,
                              fontWeight: FontWeight.w300,
                              height: 1.6,
                            ),
                          ),
                          const SizedBox(height: 32),
                          // Alert Banner
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF581C87).withValues(alpha: 0.1),
                              border: Border.all(
                                color: const Color(0xFF9333EA).withValues(alpha: 0.5),
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
                                      color: Colors.white.withValues(alpha: 0.85),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
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
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const IntelligenceHistoryPage(),
                                    ),
                                  );
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
          color: Colors.white.withValues(alpha: 0.03),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.15),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(32),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 32,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: GoogleFonts.montserrat(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 15,
                fontWeight: FontWeight.w400,
                fontStyle: FontStyle.italic,
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
  State<IntelligenceHistoryPage> createState() => _IntelligenceHistoryPageState();
}

class _IntelligenceHistoryPageState extends State<IntelligenceHistoryPage> {
  // Mock document data
  final List<Map<String, String>> documents = [
    {
      'name': 'GreenLeafs.pdf',
      'date': '08 / 01 / 2026',
      'id': 'ID TRF 26342348264',
    },
    {
      'name': 'Organogram.txt',
      'date': '08 / 01 / 2026',
      'id': 'ID TRF 26342348265',
    },
    {
      'name': 'Company Policy.pdf',
      'date': '07 / 15 / 2026',
      'id': 'ID TRF 26342348266',
    },
  ];

  String? expandedDocIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0814),
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topLeft,
            radius: 1.8,
            colors: [
              Color(0xFF2A1B3D),
              Color(0xFF150E26),
              Color(0xFF0D0915),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(32),
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          height: 48,
                          width: 48,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.4),
                            ),
                          ),
                          child: Icon(
                            Icons.arrow_back_ios_new,
                            color: Colors.white.withValues(alpha: 0.8),
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 18),
                    Text(
                      'Manage Intelligence',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                // Document List
                Expanded(
                  child: documents.isEmpty
                      ? Center(
                          child: Text(
                            'No files uploaded yet',
                            style: GoogleFonts.outfit(
                              color: Colors.white.withValues(alpha: 0.6),
                              fontSize: 16,
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: documents.length,
                          itemBuilder: (context, index) {
                            final doc = documents[index];
                            final isExpanded = expandedDocIndex == index.toString();

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    expandedDocIndex = isExpanded ? null : index.toString();
                                  });
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  padding: EdgeInsets.all(isExpanded ? 32 : 24),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.03),
                                    border: Border.all(
                                      color: Colors.white.withValues(alpha: 0.4),
                                    ),
                                    borderRadius: BorderRadius.circular(
                                      isExpanded ? 48 : 40,
                                    ),
                                  ),
                                  child: isExpanded
                                      ? Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              doc['name']!,
                                              style: GoogleFonts.outfit(
                                                color: Colors.white,
                                                fontSize: 20,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                            const SizedBox(height: 16),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  doc['id']!,
                                                  style: GoogleFonts.outfit(
                                                    color: Colors.white.withValues(alpha: 0.8),
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w300,
                                                    letterSpacing: 0.5,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 12),
                                            Text(
                                              doc['date']!,
                                              style: GoogleFonts.outfit(
                                                color: Colors.white.withValues(alpha: 0.6),
                                                fontSize: 13,
                                                fontWeight: FontWeight.w300,
                                              ),
                                            ),
                                            const SizedBox(height: 16),
                                            Center(
                                              child: GestureDetector(
                                                onTap: () {
                                                  // Handle delete
                                                  setState(() {
                                                    documents.removeAt(index);
                                                    expandedDocIndex = null;
                                                  });
                                                },
                                                child: Text(
                                                  'Delete File',
                                                  style: GoogleFonts.outfit(
                                                    color: Colors.white.withValues(alpha: 0.7),
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w300,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        )
                                      : Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              doc['name']!,
                                              style: GoogleFonts.outfit(
                                                color: Colors.white,
                                                fontSize: 18,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              doc['date']!,
                                              style: GoogleFonts.outfit(
                                                color: Colors.white.withValues(alpha: 0.6),
                                                fontSize: 12,
                                                fontWeight: FontWeight.w300,
                                              ),
                                            ),
                                          ],
                                        ),
                                ),
                              ),
                            );
                          },
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
