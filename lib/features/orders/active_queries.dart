import 'package:autobus/barrel.dart';

class ActiveQueries extends StatefulWidget {
  const ActiveQueries({super.key});

  @override
  State<ActiveQueries> createState() => _ActiveQueriesState();
}

class _ActiveQueriesState extends State<ActiveQueries> {
  // Mock data - replace with actual API call
  final List<QueryItem> queries = [
    QueryItem(
      title: 'Bag of rice ..',
      id: 'ID TRF 26342348264',
      date: '08 / 01 / 2026',
    ),
    QueryItem(
      title: 'Fruit Jar',
      id: 'ID TRF 26342348264',
      date: '08 / 01 / 2026',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withOpacity(0.5),
              width: 1.5,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => Navigator.of(context).pop(),
              borderRadius: BorderRadius.circular(100),
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ),
        title: Text(
          'Active Queries',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF180d31), // Top
              Color(0xFF11091f), // Middle
              Color(0xFF0d0718), // Bottom
            ],
            stops: [0.0, 0.4, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: queries.length,
                  itemBuilder: (context, index) {
                    final query = queries[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: _buildQueryCard(query),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQueryCard(QueryItem query) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(45),
        color: Colors.white.withOpacity(0.05),
        border: Border.all(
          color: Colors.white.withOpacity(0.4),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                query.title,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                query.id,
                style: GoogleFonts.inter(
                  color: Colors.grey[400],
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.8,
                ),
              ),
              Text(
                query.date,
                style: GoogleFonts.inter(
                  color: Colors.grey[400],
                  fontSize: 12,
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

class QueryItem {
  final String title;
  final String id;
  final String date;

  QueryItem({
    required this.title,
    required this.id,
    required this.date,
  });
}
