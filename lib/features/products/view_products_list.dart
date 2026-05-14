import 'package:autobus/barrel.dart';

class ViewProductsPage extends StatefulWidget {
  const ViewProductsPage({super.key});

  @override
  State<ViewProductsPage> createState() => _ViewProductsPageState();
}

class _ViewProductsPageState extends State<ViewProductsPage> {
  // Mock product data
  final List<Map<String, String>> products = [
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
      'name': 'Inventory.pdf',
      'date': '07 / 20 / 2026',
      'id': 'ID TRF 26342348266',
    },
  ];

  String? expandedProdIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0718),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1D123D),
              Color(0xFF120B29),
              Color(0xFF0A0718),
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
                      'Manage Products',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w500,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                // Product List
                Expanded(
                  child: products.isEmpty
                      ? Center(
                          child: Text(
                            'No products added yet',
                            style: GoogleFonts.inter(
                              color: Colors.white.withValues(alpha: 0.6),
                              fontSize: 16,
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: products.length,
                          itemBuilder: (context, index) {
                            final prod = products[index];
                            final isExpanded = expandedProdIndex == index.toString();

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    expandedProdIndex = isExpanded ? null : index.toString();
                                  });
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  padding: EdgeInsets.all(isExpanded ? 32 : 24),
                                  decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    border: Border.all(
                                      color: Colors.white.withValues(alpha: 0.4),
                                    ),
                                    borderRadius: BorderRadius.circular(40),
                                  ),
                                  child: isExpanded
                                      ? Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              prod['name']!,
                                              style: GoogleFonts.inter(
                                                color: Colors.white,
                                                fontSize: 20,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            const SizedBox(height: 32),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  prod['id']!,
                                                  style: GoogleFonts.inter(
                                                    color: Colors.white.withValues(alpha: 0.9),
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w500,
                                                    letterSpacing: 0.5,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 32),
                                            Text(
                                              prod['date']!,
                                              style: GoogleFonts.inter(
                                                color: Colors.white.withValues(alpha: 0.85),
                                                fontSize: 16,
                                                fontWeight: FontWeight.w300,
                                                letterSpacing: 0.5,
                                              ),
                                            ),
                                            const SizedBox(height: 32),
                                            Center(
                                              child: GestureDetector(
                                                onTap: () {
                                                  // Handle delete
                                                  setState(() {
                                                    products.removeAt(index);
                                                    expandedProdIndex = null;
                                                  });
                                                },
                                                child: Text(
                                                  'Delete File',
                                                  style: GoogleFonts.inter(
                                                    color: Colors.white.withValues(alpha: 0.8),
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w500,
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
                                              prod['name']!,
                                              style: GoogleFonts.inter(
                                                color: Colors.white,
                                                fontSize: 20,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              prod['date']!,
                                              style: GoogleFonts.inter(
                                                color: Colors.white.withValues(alpha: 0.85),
                                                fontSize: 16,
                                                fontWeight: FontWeight.w300,
                                                letterSpacing: 0.5,
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
