import 'package:autobus/barrel.dart';

class AllChatsPage extends StatelessWidget {
  const AllChatsPage({super.key});

  static const Color _backgroundStart = Color(0xFF2A1447);
  static const Color _backgroundEnd = Color(0xFF120721);
  static const Color _stroke = Color.fromRGBO(255, 255, 255, 0.95);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundEnd,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_backgroundStart, _backgroundEnd],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 428),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 18, 24, 24),
                child: Column(
                  children: [
                    SizedBox(
                      height: 64,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: GestureDetector(
                              onTap: () => Navigator.of(context).pop(),
                              child: Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color(0xFF2A1447),
                                  border: Border.all(color: Colors.white, width: 0.5),
                                ),
                                child: const Icon(
                                  Icons.arrow_back_ios_new,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            ),
                          ),
                          Text(
                            'All Chats',
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 317),
                            child: Column(
                              children: const [
                                _AllChatTile(
                                  title: 'Bag of rice ..',
                                  id: 'ID TRF 26342348264',
                                  date: '08 / 01 /2026',
                                ),
                                SizedBox(height: 19),
                                _AllChatTile(
                                  title: 'Fruit Jar',
                                  id: 'ID TRF 26342348264',
                                  date: '08 / 01 /2026',
                                ),
                                SizedBox(height: 19),
                                _AllChatFileTile(
                                  title: 'Organogram.txt',
                                  id: 'ID TRF 26342348264',
                                  date: '08 / 01 /2026',
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AllChatTile extends StatelessWidget {
  final String title;
  final String id;
  final String date;

  const _AllChatTile({
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
        border: Border.all(color: AllChatsPage._stroke, width: 0.5),
      ),
      padding: const EdgeInsets.fromLTRB(22, 16, 22, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Text(
                  id,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                date,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AllChatFileTile extends StatelessWidget {
  final String title;
  final String id;
  final String date;

  const _AllChatFileTile({
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
        border: Border.all(color: AllChatsPage._stroke, width: 0.5),
      ),
      padding: const EdgeInsets.fromLTRB(22, 34, 22, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            id,
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            date,
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
          ),
          const Spacer(),
          Center(
            child: Text(
              'Delete File',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
