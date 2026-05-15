import 'package:autobus/barrel.dart';

class LiveChatsPage extends StatelessWidget {
  const LiveChatsPage({super.key});

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
              padding: const EdgeInsets.fromLTRB(24, 18, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const ManageScreenBackButton(),
                      const SizedBox(width: 18),
                      Expanded(
                        child: Text(
                          'Live Chats',
                          style: ManageScreenStyle.headerTitleStyle(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Expanded(
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: const [
                        _LiveChatTile(
                          title: 'Bag of rice ..',
                          id: 'ID TRF 26342348264',
                          date: '08 / 01 /2026',
                        ),
                        SizedBox(height: 16),
                        _LiveChatTile(
                          title: 'Fruit Jar',
                          id: 'ID TRF 26342348264',
                          date: '08 / 01 /2026',
                        ),
                        SizedBox(height: 16),
                        _LiveChatFileTile(
                          title: 'Organogram.txt',
                          id: 'ID TRF 26342348264',
                          date: '08 / 01 /2026',
                        ),
                      ],
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

class _LiveChatTile extends StatelessWidget {
  final String title;
  final String id;
  final String date;

  const _LiveChatTile({
    required this.title,
    required this.id,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 83),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFF3F1163), width: 1),
      ),
      padding: const EdgeInsets.fromLTRB(22, 16, 22, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: Text(
                  id,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.outfit(
                    color: Colors.white.withValues(alpha: 0.45),
                    fontSize: 11,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                date,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.outfit(
                  color: Colors.white.withValues(alpha: 0.45),
                  fontSize: 11,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LiveChatFileTile extends StatelessWidget {
  final String title;
  final String id;
  final String date;

  const _LiveChatFileTile({
    required this.title,
    required this.id,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 202,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFF3F1163), width: 1),
      ),
      padding: const EdgeInsets.fromLTRB(22, 24, 22, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            id,
            style: GoogleFonts.outfit(
              color: Colors.white.withValues(alpha: 0.45),
              fontSize: 11,
              fontWeight: FontWeight.w300,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            date,
            style: GoogleFonts.outfit(
              color: Colors.white.withValues(alpha: 0.45),
              fontSize: 11,
              fontWeight: FontWeight.w300,
            ),
          ),
          const Spacer(),
          Center(
            child: Text(
              'Delete File',
              style: GoogleFonts.outfit(
                color: Colors.white.withValues(alpha: 0.75),
                fontSize: 13,
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
