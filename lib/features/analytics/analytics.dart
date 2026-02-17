import 'package:autobus/barrel.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  final double _growthPercentage = 63.0;
  final String _growthMonth = 'Jan';
  final int _rmaValue = 14;
  final int _valValue = 5;

  // Metrics data - Replace with dynamic data from your backend
  final List<MetricData> _metrics = [
    MetricData('Queries', 20312, -2.9),
    MetricData('Client Responses', 20312, 2.99),
    MetricData('Completed Orders', 20312, 73.99),
    MetricData('Payments', 20312, -5.9),
    MetricData('Metric 1', 20312, -29.9),
    MetricData('Bills', 20312, -59.9),
  ];

  @override
  void initState() {
    super.initState();
  }

  // Uncomment and implement this method to fetch real data
  // Future<void> _loadAnalyticsData() async {
  //   try {
  //     final data = await YourApiService.getAnalytics();
  //     setState(() {
  //       // Update state variables with fetched data
  //     });
  //   } catch (e) {
  //     // Handle error
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('Failed to load analytics: $e')),
  //       );
  //     }
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _AnalyticsBackground(
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),

              _buildTopBar(),

              const SizedBox(height: 30),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Column(
                    children: [
                      // Growth & Average Card
                      _buildGrowthAverageCard(),

                      const SizedBox(height: 20),

                      // Metrics Grid
                      _buildMetricsGrid(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back Button
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF2D2D44),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),

          // Reports Title
          Text(
            'Reports',
            style: GoogleFonts.roboto(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.w400,
            ),
          ),

          // Star Icon (Favorite/Export Action)
          GestureDetector(
            onTap: _handleStarAction,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF2D2D44), width: 2),
                color: Colors.white,
              ),
              child: const Icon(Icons.star, color: Color(0xFFE63946), size: 24),
            ),
          ),
        ],
      ),
    );
  }

  /// Combined Growth and Average metrics card
  Widget _buildGrowthAverageCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Growth Section
          Expanded(
            child: _GrowthWidget(
              percentage: _growthPercentage,
              month: _growthMonth,
            ),
          ),
          const SizedBox(width: 20),

          // Average Section
          Expanded(
            child: _AverageWidget(rmaValue: _rmaValue, valValue: _valValue),
          ),
        ],
      ),
    );
  }

  /// Metrics grid displaying all KPIs
  Widget _buildMetricsGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.4,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: _metrics.length,
      itemBuilder: (context, index) {
        return _MetricCard(metric: _metrics[index]);
      },
    );
  }

  /// Handle star icon tap (export, favorite, etc.)
  void _handleStarAction() {
    // TODO: Implement your star action
    // Examples: Export report, mark as favorite, share, etc.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Star action triggered',
          style: GoogleFonts.imprima(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF2D2D44),
      ),
    );
  }
}

class _GrowthWidget extends StatelessWidget {
  final double percentage;
  final String month;

  const _GrowthWidget({required this.percentage, required this.month});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            'Growth',
            style: GoogleFonts.roboto(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),

          // Progress Indicator Row
          Row(
            children: [
              // Circular Progress
              SizedBox(
                width: 50,
                height: 50,
                child: Stack(
                  children: [
                    CircularProgressIndicator(
                      value: percentage / 100,
                      strokeWidth: 5,
                      backgroundColor: Colors.grey.shade300,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFF4CAF50),
                      ),
                    ),
                    Center(
                      child: Text(
                        '${percentage.toInt()}%',
                        style: GoogleFonts.roboto(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              // Progress Label
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Progress',
                    style: GoogleFonts.roboto(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    month,
                    style: GoogleFonts.roboto(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AverageWidget extends StatelessWidget {
  final int rmaValue;
  final int valValue;

  const _AverageWidget({required this.rmaValue, required this.valValue});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            'Average',
            style: GoogleFonts.roboto(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),

          // Bar and Values Row
          Row(
            children: [
              // Green Bar Indicator
              Container(
                width: 6,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: 16),

              // Values Column
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Labels (RMA, VAL)
                  Row(
                    children: [
                      Text(
                        'RMA',
                        style: GoogleFonts.roboto(
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'VAL',
                        style: GoogleFonts.roboto(
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Values
                  Row(
                    children: [
                      Text(
                        rmaValue.toString(),
                        style: GoogleFonts.roboto(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 24),
                      Text(
                        valValue.toString(),
                        style: GoogleFonts.roboto(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final MetricData metric;

  const _MetricCard({required this.metric});

  @override
  Widget build(BuildContext context) {
    final isPositive = metric.percentageChange >= 0;
    final changeColor = isPositive
        ? const Color(0xFF4CAF50)
        : const Color(0xFFE63946);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Title
          Text(
            metric.title,
            style: GoogleFonts.roboto(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),

          // Value and Change Indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Main Value
              Text(
                metric.value.toString(),
                style: GoogleFonts.roboto(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),

              // Percentage Change Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: changeColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${isPositive ? '+' : ''}${metric.percentageChange.toStringAsFixed(2)}%',
                      style: GoogleFonts.roboto(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: changeColor,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Icon(
                      isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                      size: 12,
                      color: changeColor,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class MetricData {
  final String title;
  final int value;
  final double percentageChange;

  MetricData(this.title, this.value, this.percentageChange);

  // Factory constructor for creating from JSON
  factory MetricData.fromJson(Map<String, dynamic> json) {
    return MetricData(
      json['title'] as String,
      json['value'] as int,
      (json['percentageChange'] as num).toDouble(),
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'value': value,
      'percentageChange': percentageChange,
    };
  }
}

class _AnalyticsBackground extends StatelessWidget {
  final Widget child;

  const _AnalyticsBackground({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFE8E8E8), Color(0xFFE0E0E0), Color(0xFFD8D8D8)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: child,
    );
  }
}
