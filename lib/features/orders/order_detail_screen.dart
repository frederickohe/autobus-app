import 'package:autobus/barrel.dart';
import 'package:autobus/common_design/light_screen_theme.dart';
import 'package:autobus/common_design/widgets/app_bottom_nav.dart';
import 'package:autobus/common_design/widgets/light_list_card.dart';
import 'package:autobus/common_design/widgets/light_screen_scaffold.dart';
import 'package:autobus/icons/home_figma_icons.dart';

const List<String> kOrderStatuses = [
  'pending',
  'processing',
  'confirmed',
  'cancelled',
  'completed',
];

String orderDisplayTitle(Map<String, dynamic> o) {
  final name = (o['item_name'] ?? '').toString().trim();
  if (name.isNotEmpty) return name;
  return (o['order_number'] ?? o['order_id'] ?? 'Order').toString();
}

class OrderDetailScreen extends StatefulWidget {
  final String orderId;
  final String? initialTitle;

  const OrderDetailScreen({
    super.key,
    required this.orderId,
    this.initialTitle,
  });

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  Map<String, dynamic>? _order;
  bool _loading = true;
  String? _loadError;
  bool _actionBusy = false;
  bool _invoiceBusy = false;
  String? _selectedOrderStatus;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    try {
      final api = context.read<ApiService>();
      final order = await api.getOrder(widget.orderId);
      if (!mounted) return;
      final status = (order['order_status'] ?? 'pending')
          .toString()
          .trim()
          .toLowerCase();
      setState(() {
        _order = order;
        _selectedOrderStatus = kOrderStatuses.contains(status)
            ? status
            : 'pending';
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadError = userFacingError(e);
        _loading = false;
      });
    }
  }

  Future<void> _updateOrderStatus() async {
    final status = _selectedOrderStatus?.trim();
    if (status == null || status.isEmpty) return;

    setState(() => _actionBusy = true);
    try {
      final api = context.read<ApiService>();
      final updated = await api.updateOrder(
        widget.orderId,
        orderStatus: status,
      );
      if (!mounted) return;
      setState(() {
        _order = updated;
        _actionBusy = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Order updated to $status')));
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _actionBusy = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(userFacingError(e))),
      );
    }
  }

  String _formatMoney(dynamic amount, String currency) {
    if (amount == null) return '—';
    final n = amount is num ? amount.toDouble() : double.tryParse('$amount');
    if (n == null) return '—';
    final value = n == n.roundToDouble()
        ? n.toStringAsFixed(0)
        : n.toStringAsFixed(2);
    return '$currency $value';
  }

  String _formatDate(dynamic raw) {
    final dt = DateTime.tryParse(raw?.toString() ?? '');
    if (dt == null) return '—';
    final d = dt.toLocal();
    final mm = d.month.toString().padLeft(2, '0');
    final dd = d.day.toString().padLeft(2, '0');
    return '$dd / $mm / ${d.year}';
  }

  Widget _infoRow(double scale, String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10 * scale),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120 * scale,
            child: Text(label, style: LightScreenTheme.listSubtitle(scale)),
          ),
          Expanded(
            child: Text(value, style: LightScreenTheme.hubBody(scale)),
          ),
        ],
      ),
    );
  }

  Widget _section(double scale, String title, List<Widget> children) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16 * scale),
      child: LightListCard(
        scale: scale,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: LightScreenTheme.listTitle(scale).copyWith(
                color: LightScreenTheme.accent,
              ),
            ),
            SizedBox(height: 12 * scale),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _statusControls(double scale) {
    final current = (_order?['order_status'] ?? '').toString().toLowerCase();
    if (current != 'pending') return const SizedBox.shrink();

    return _section(scale, 'Update status', [
      DropdownButtonFormField<String>(
        initialValue: kOrderStatuses.contains(_selectedOrderStatus)
            ? _selectedOrderStatus
            : 'pending',
        dropdownColor: LightScreenTheme.surface,
        decoration: InputDecoration(
          filled: true,
          fillColor: LightScreenTheme.field,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14 * scale),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 14 * scale,
            vertical: 10 * scale,
          ),
        ),
        style: GoogleFonts.montserrat(
          color: Colors.black87,
          fontSize: 14 * scale.clamp(0.9, 1.05),
        ),
        items: kOrderStatuses
            .map(
              (s) => DropdownMenuItem(
                value: s,
                child: Text(s[0].toUpperCase() + s.substring(1)),
              ),
            )
            .toList(),
        onChanged: _actionBusy
            ? null
            : (v) => setState(() => _selectedOrderStatus = v),
      ),
      SizedBox(height: 12 * scale),
      OutlinedButton.icon(
        onPressed: _actionBusy ? null : _updateOrderStatus,
        icon: _actionBusy
            ? SizedBox(
                width: 18 * scale,
                height: 18 * scale,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: LightScreenTheme.accent,
                ),
              )
            : HomeSfIcon(
                icon: HomeFigmaIcons.checkmark,
                size: 20 * scale,
              ),
        label: Text(
          'Apply status',
          style: GoogleFonts.montserrat(
            fontSize: 15 * scale.clamp(0.9, 1.05),
            fontWeight: FontWeight.w500,
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: LightScreenTheme.accent,
          side: BorderSide(color: LightScreenTheme.accent.withValues(alpha: 0.5)),
          padding: EdgeInsets.symmetric(vertical: 12 * scale, horizontal: 16 * scale),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16 * scale),
          ),
        ),
      ),
    ]);
  }

  Future<void> _sendOrderInvoice() async {
    setState(() => _invoiceBusy = true);
    try {
      final api = context.read<ApiService>();
      final result = await api.sendOrderInvoice(widget.orderId);
      if (!mounted) return;
      setState(() => _invoiceBusy = false);
      final msg = (result['message'] ?? 'Invoice sent').toString();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } catch (e) {
      if (!mounted) return;
      setState(() => _invoiceBusy = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(userFacingError(e))),
      );
    }
  }

  Widget _invoiceControls(double scale) {
    return _section(scale, 'Invoice', [
      Text(
        'Create a Paystack payment link for this order and send it to the customer in chat.',
        style: LightScreenTheme.hubBody(scale).copyWith(fontSize: 13 * scale.clamp(0.9, 1.05)),
      ),
      SizedBox(height: 14 * scale),
      OutlinedButton.icon(
        onPressed: _invoiceBusy ? null : _sendOrderInvoice,
        icon: _invoiceBusy
            ? SizedBox(
                width: 18 * scale,
                height: 18 * scale,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: LightScreenTheme.accent,
                ),
              )
            : HomeSfIcon(
                icon: HomeFigmaIcons.analyticsInvoices,
                size: 20 * scale,
              ),
        label: Text(
          'Send invoice to customer',
          style: GoogleFonts.montserrat(
            fontSize: 15 * scale.clamp(0.9, 1.05),
            fontWeight: FontWeight.w500,
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: LightScreenTheme.accent,
          side: BorderSide(color: LightScreenTheme.accent.withValues(alpha: 0.5)),
          padding: EdgeInsets.symmetric(vertical: 12 * scale, horizontal: 16 * scale),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16 * scale),
          ),
        ),
      ),
    ]);
  }

  Widget _buildContent(double scale) {
    final o = _order!;
    final currency = (o['currency_code'] ?? 'GHS').toString();
    final notes = (o['notes'] ?? '').toString().trim();

    return ListView(
      padding: EdgeInsets.fromLTRB(20 * scale, 8 * scale, 20 * scale, 32 * scale),
      children: [
        _section(scale, 'Order', [
          _infoRow(scale, 'Number', (o['order_number'] ?? '—').toString()),
          _infoRow(scale, 'Status', (o['order_status'] ?? '—').toString()),
          _infoRow(scale, 'Payment', (o['payment_status'] ?? '—').toString()),
          _infoRow(scale, 'Fulfillment', (o['fulfillment_status'] ?? '—').toString()),
          _infoRow(scale, 'Date', _formatDate(o['order_date'] ?? o['created_at'])),
          if ((o['order_source'] ?? '').toString().isNotEmpty)
            _infoRow(scale, 'Source', (o['order_source'] ?? '').toString()),
        ]),
        _section(scale, 'Item', [
          _infoRow(scale, 'Product', (o['item_name'] ?? '—').toString()),
          _infoRow(
            scale,
            'Quantity',
            '${o['quantity'] ?? o['total_quantity'] ?? '—'}',
          ),
          _infoRow(scale, 'Total', _formatMoney(o['total_amount'], currency)),
          if (o['subtotal_amount'] != null)
            _infoRow(scale, 'Subtotal', _formatMoney(o['subtotal_amount'], currency)),
        ]),
        _section(scale, 'Customer', [
          _infoRow(scale, 'Name', (o['customer_name'] ?? '—').toString()),
          _infoRow(scale, 'Phone', (o['customer_phone'] ?? '—').toString()),
          if ((o['customer_email'] ?? '').toString().isNotEmpty)
            _infoRow(scale, 'Email', (o['customer_email'] ?? '').toString()),
          if ((o['customer_location'] ?? '').toString().isNotEmpty)
            _infoRow(scale, 'Location', (o['customer_location'] ?? '').toString()),
        ]),
        if (notes.isNotEmpty)
          _section(scale, 'Notes', [
            Text(
              notes,
              style: LightScreenTheme.hubBody(scale),
            ),
          ]),
        _invoiceControls(scale),
        _statusControls(scale),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.sizeOf(context).width / appShellDesignWidth;
    final title = widget.initialTitle?.trim().isNotEmpty == true
        ? widget.initialTitle!
        : (_order != null ? orderDisplayTitle(_order!) : 'Order');

    return LightScreenScaffold(
      title: title,
      creditCategory: CreditCategory.server,
      body: _loading
          ? Center(child: CircularProgressIndicator(color: LightScreenTheme.accent))
          : _loadError != null
          ? Center(
              child: Padding(
                padding: EdgeInsets.all(24 * scale),
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
                      onPressed: _load,
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
          : _buildContent(scale),
    );
  }
}
