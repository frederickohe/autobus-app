import 'package:autobus/features/reports/report_period.dart';

class ReportsSnapshot {
  final ReportPeriod period;
  final double revenue;
  final List<Map<String, dynamic>> financials;
  final List<Map<String, dynamic>> orders;
  final List<Map<String, dynamic>> products;
  final List<Map<String, dynamic>> lowStock;
  final int conversationsCompleted;
  final int conversationsActive;
  final int interventions;
  final int marketingAssets;
  final int sentEmails;
  final String? error;

  const ReportsSnapshot({
    required this.period,
    this.revenue = 0,
    this.financials = const [],
    this.orders = const [],
    this.products = const [],
    this.lowStock = const [],
    this.conversationsCompleted = 0,
    this.conversationsActive = 0,
    this.interventions = 0,
    this.marketingAssets = 0,
    this.sentEmails = 0,
    this.error,
  });

  List<Map<String, dynamic>> get filteredFinancials => financials
      .where((t) => period.includes(ReportPeriod.parseDate(t['created_at'])))
      .toList();

  List<Map<String, dynamic>> get filteredOrders => orders
      .where((o) => period.includes(
            ReportPeriod.parseDate(o['order_date'] ?? o['created_at']),
          ))
      .toList();

  int countOrdersByStatus(String status) => filteredOrders
      .where((o) =>
          (o['order_status'] ?? '').toString().toLowerCase() ==
          status.toLowerCase())
      .length;

  double get ordersValue => filteredOrders.fold<double>(
        0,
        (sum, o) => sum + asReportDouble(o['total_amount']),
      );

  double get financialVolume => filteredFinancials.fold<double>(
        0,
        (sum, t) => sum + asReportDouble(t['amount']),
      );

  int get completedTransactions => filteredFinancials
      .where((t) =>
          (t['status'] ?? '').toString().toLowerCase() == 'completed')
      .length;

  int get pendingTransactions => filteredFinancials
      .where((t) => (t['status'] ?? '').toString().toLowerCase() == 'pending')
      .length;

  int get failedTransactions => filteredFinancials
      .where((t) => (t['status'] ?? '').toString().toLowerCase() == 'failed')
      .length;

}

double asReportDouble(dynamic v) {
  if (v is num) return v.toDouble();
  return double.tryParse(v?.toString() ?? '') ?? 0;
}
