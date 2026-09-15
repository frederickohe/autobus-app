import 'package:autobus/barrel.dart';
import 'package:autobus/common_design/light_screen_theme.dart';
import 'package:autobus/common_design/widgets/app_bottom_nav.dart';
import 'package:autobus/common_design/widgets/light_list_card.dart';
import 'package:autobus/common_design/widgets/light_screen_scaffold.dart';

String _orderHistoryTitle(Map<String, dynamic> o) {
  final name = (o['item_name'] ?? '').toString().trim();
  if (name.isNotEmpty) return name;
  return (o['order_number'] ?? o['order_id'] ?? 'Order').toString();
}

String _orderHistorySubtitleId(Map<String, dynamic> o) {
  final num = (o['order_number'] ?? '').toString().trim();
  if (num.isNotEmpty) return num;
  return (o['order_id'] ?? '').toString();
}

String _formatOrderHistoryDate(Map<String, dynamic> o) {
  final raw = o['order_date']?.toString() ?? o['created_at']?.toString();
  final dt = DateTime.tryParse(raw ?? '');
  if (dt == null) return '—';
  final d = dt.toLocal();
  final mm = d.month.toString().padLeft(2, '0');
  final dd = d.day.toString().padLeft(2, '0');
  return '$dd / $mm / ${d.year}';
}

class AllOrdersHistory extends StatefulWidget {
  const AllOrdersHistory({super.key});

  @override
  State<AllOrdersHistory> createState() => _AllOrdersHistoryState();
}

class _AllOrdersHistoryState extends State<AllOrdersHistory> {
  List<Map<String, dynamic>> _orders = const [];
  bool _loading = true;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadOrders());
  }

  Future<void> _loadOrders() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    try {
      final api = context.read<ApiService>();
      final list = await api.listOrders(skip: 0, limit: 200);
      if (!mounted) return;
      setState(() {
        _orders = list;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadError = e.toString().replaceFirst('Exception: ', '');
        _loading = false;
        _orders = const [];
      });
    }
  }

  void _openOrder(BuildContext context, Map<String, dynamic> o) {
    final orderId = (o['order_id'] ?? '').toString().trim();
    if (orderId.isEmpty) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OrderDetailScreen(
          orderId: orderId,
          initialTitle: _orderHistoryTitle(o),
        ),
      ),
    );
  }

  Widget _orderTile(double scale, Map<String, dynamic> o) {
    return LightListCard(
      scale: scale,
      onTap: () => _openOrder(context, o),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _orderHistoryTitle(o),
            style: LightScreenTheme.listTitle(scale),
          ),
          SizedBox(height: 8 * scale),
          Text(
            (o['order_status'] ?? '').toString(),
            style: LightScreenTheme.listSubtitle(scale),
          ),
          SizedBox(height: 12 * scale),
          Row(
            children: [
              Expanded(
                child: Text(
                  _orderHistorySubtitleId(o),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: LightScreenTheme.listSubtitle(scale),
                ),
              ),
              SizedBox(width: 12 * scale),
              Text(
                _formatOrderHistoryDate(o),
                style: LightScreenTheme.listSubtitle(scale),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.sizeOf(context).width / appShellDesignWidth;

    return LightScreenScaffold(
      title: 'All Orders',
      creditCategory: CreditCategory.server,
      body: _loading
          ? Center(child: CircularProgressIndicator(color: LightScreenTheme.accent))
          : _loadError != null
          ? Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 28 * scale),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _loadError!,
                      textAlign: TextAlign.center,
                      style: LightScreenTheme.emptyState(scale),
                    ),
                    SizedBox(height: 16 * scale),
                    TextButton(
                      onPressed: _loadOrders,
                      child: Text(
                        'Retry',
                        style: LightScreenTheme.listTitle(scale).copyWith(
                          color: LightScreenTheme.accent,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : RefreshIndicator(
              color: LightScreenTheme.accent,
              onRefresh: _loadOrders,
              child: _orders.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(height: MediaQuery.sizeOf(context).height * 0.32),
                        Center(
                          child: Text(
                            'No orders yet',
                            style: LightScreenTheme.emptyState(scale),
                          ),
                        ),
                      ],
                    )
                  : ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.fromLTRB(20 * scale, 20 * scale, 20 * scale, 32 * scale),
                      itemCount: _orders.length,
                      separatorBuilder: (_, __) => SizedBox(height: 12 * scale),
                      itemBuilder: (context, index) => _orderTile(scale, _orders[index]),
                    ),
            ),
    );
  }
}
