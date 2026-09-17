import 'package:autobus/barrel.dart';
import 'package:autobus/common_design/light_screen_theme.dart';
import 'package:autobus/common_design/widgets/app_bottom_nav.dart';
import 'package:autobus/common_design/widgets/light_screen_scaffold.dart';
import 'package:autobus/features/products/product_existing_gallery.dart';
class ProductDetailScreen extends StatefulWidget {
  final String productId;
  final String? initialName;

  const ProductDetailScreen({
    super.key,
    required this.productId,
    this.initialName,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _descriptionCtrl;
  late final TextEditingController _priceCtrl;
  late final TextEditingController _categoryCtrl;
  late final TextEditingController _conditionCtrl;
  late final TextEditingController _stockCtrl;
  late final TextEditingController _linkCtrl;

  bool _loading = true;
  bool _saving = false;
  bool _photoBusy = false;
  String? _loadError;
  String? _inventoryId;
  List<ProductGalleryPhoto> _photos = const [];

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
    _descriptionCtrl = TextEditingController();
    _priceCtrl = TextEditingController();
    _categoryCtrl = TextEditingController();
    _conditionCtrl = TextEditingController();
    _stockCtrl = TextEditingController();
    _linkCtrl = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descriptionCtrl.dispose();
    _priceCtrl.dispose();
    _categoryCtrl.dispose();
    _conditionCtrl.dispose();
    _stockCtrl.dispose();
    _linkCtrl.dispose();
    super.dispose();
  }

  void _populateForm(Map<String, dynamic> p) {
    _inventoryId = (p['inventory_id'] ?? '').toString();
    _nameCtrl.text = (p['name'] ?? '').toString();
    _descriptionCtrl.text = (p['description'] ?? '').toString();
    final price = p['price'];
    if (price is num) {
      _priceCtrl.text = price == price.roundToDouble()
          ? price.toStringAsFixed(0)
          : price.toString();
    } else {
      _priceCtrl.text = price?.toString() ?? '';
    }
    _categoryCtrl.text = (p['category'] ?? '').toString();
    _conditionCtrl.text = (p['condition'] ?? '').toString();
    final stock = p['number_in_stock'];
    _stockCtrl.text = stock == null ? '' : stock.toString();
    _linkCtrl.text = (p['link'] ?? '').toString();
  }

  List<ProductGalleryPhoto> _photosFromProduct(Map<String, dynamic> p) {
    final rawPhotos = p['photos'];
    if (rawPhotos is List && rawPhotos.isNotEmpty) {
      return rawPhotos
          .map((e) => e.toString())
          .where((url) => url.trim().isNotEmpty)
          .toList()
          .asMap()
          .entries
          .map(
            (entry) => ProductGalleryPhoto(
              imageId: 'legacy-${entry.key}',
              url: entry.value,
              isPrimary: entry.key == 0,
            ),
          )
          .toList();
    }
    final single = (p['photo'] ?? '').toString().trim();
    if (single.isNotEmpty) {
      return [
        ProductGalleryPhoto(imageId: 'legacy-0', url: single, isPrimary: true),
      ];
    }
    return const [];
  }

  Future<void> _load({bool photosOnly = false}) async {
    if (!photosOnly) {
      setState(() {
        _loading = true;
        _loadError = null;
      });
    }
    try {
      final api = context.read<ApiService>();
      final p = photosOnly
          ? null
          : await api.getProduct(widget.productId);
      List<ProductGalleryPhoto> photos = const [];
      try {
        final photoRows = await api.listProductPhotos(widget.productId);
        photos = photoRows
            .map(ProductGalleryPhoto.fromJson)
            .where((photo) => photo.url.trim().isNotEmpty)
            .toList();
      } catch (_) {
        if (p != null) {
          photos = _photosFromProduct(p);
        }
      }
      if (!mounted) return;
      if (p != null) {
        _populateForm(p);
      }
      setState(() {
        _photos = photos;
        _loading = false;
        _photoBusy = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        if (!photosOnly) {
          _loadError = userFacingError(e);
        }
        _loading = false;
        _photoBusy = false;
      });
    }
  }

  InputDecoration _fieldDecoration(double scale, String label, {String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: GoogleFonts.montserrat(
        color: LightScreenTheme.muted,
        fontSize: 13 * scale.clamp(0.9, 1.05),
      ),
      hintStyle: GoogleFonts.montserrat(
        color: LightScreenTheme.hint,
        fontSize: 13 * scale.clamp(0.9, 1.05),
      ),
      filled: true,
      fillColor: LightScreenTheme.field,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16 * scale),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16 * scale),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16 * scale),
        borderSide: BorderSide(color: LightScreenTheme.accent, width: 1.2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16 * scale),
        borderSide: BorderSide(color: Colors.red.shade400),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16 * scale),
        borderSide: BorderSide(color: Colors.red.shade400, width: 1.2),
      ),
      contentPadding: EdgeInsets.symmetric(
        horizontal: 14 * scale,
        vertical: 12 * scale,
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final price = double.tryParse(_priceCtrl.text.trim());
    if (price == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid price')),
      );
      return;
    }

    int? stock;
    final stockText = _stockCtrl.text.trim();
    if (stockText.isNotEmpty) {
      stock = int.tryParse(stockText);
      if (stock == null || stock < 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Stock must be a non-negative number')),
        );
        return;
      }
    }

    setState(() => _saving = true);
    try {
      final api = context.read<ApiService>();
      await api.updateProduct(
        widget.productId,
        name: _nameCtrl.text.trim(),
        description: _descriptionCtrl.text,
        price: price,
        category: _categoryCtrl.text,
        condition: _conditionCtrl.text.trim(),
        numberInStock: stock,
        link: _linkCtrl.text,
      );
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Product saved', style: GoogleFonts.montserrat()),
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(userFacingError(e)),
        ),
      );
    }
  }

  Future<void> _addPhotos() async {
    if (_photoBusy) return;
    setState(() => _photoBusy = true);
    try {
      final api = context.read<ApiService>();
      await pickAndUploadProductPhotos(
        context: context,
        api: api,
        productId: widget.productId,
        currentCount: _photos.length,
      );
      if (!mounted) return;
      await _load(photosOnly: true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(userFacingError(e)),
        ),
      );
      setState(() => _photoBusy = false);
    }
  }

  Future<void> _onPhotoTap(ProductGalleryPhoto photo) async {
    if (_photoBusy) return;
    final action = await showProductPhotoActionsSheet(
      context,
      photo,
      canDelete: _photos.length > 1,
    );
    if (!mounted || action == null) return;

    setState(() => _photoBusy = true);
    try {
      final api = context.read<ApiService>();
      if (action == 'primary') {
        await api.setPrimaryProductPhoto(widget.productId, photo.imageId);
      } else if (action == 'delete') {
        await api.deleteProductPhoto(widget.productId, photo.imageId);
      }
      if (!mounted) return;
      await _load(photosOnly: true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _photoBusy = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(userFacingError(e)),
        ),
      );
    }
  }

  Future<void> _confirmDelete() async {
    final name = _nameCtrl.text.trim().isNotEmpty
        ? _nameCtrl.text.trim()
        : 'this product';
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: LightScreenTheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'Delete product?',
          style: GoogleFonts.montserrat(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Remove "$name" permanently? This cannot be undone.',
          style: GoogleFonts.montserrat(
            color: LightScreenTheme.muted,
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Cancel',
              style: GoogleFonts.montserrat(color: LightScreenTheme.muted),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'Delete',
              style: GoogleFonts.montserrat(color: const Color(0xFFE11D48)),
            ),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;

    setState(() => _saving = true);
    try {
      final api = context.read<ApiService>();
      await api.deleteProduct(widget.productId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Product deleted', style: GoogleFonts.montserrat()),
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(userFacingError(e)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.sizeOf(context).width / appShellDesignWidth;
    final title = widget.initialName?.trim().isNotEmpty == true
        ? widget.initialName!.trim()
        : 'Product';

    return LightScreenScaffold(
      title: title,
      creditCategory: CreditCategory.storageMb,
      resizeToAvoidBottomInset: true,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: _buildBody(scale)),
          if (!_loading && _loadError == null) _buildActions(scale),
        ],
      ),
    );
  }

  Widget _buildBody(double scale) {
    if (_loading) {
      return const Center(child: AutobusLoadingIndicator(size: 32));
    }
    if (_loadError != null) {
      return Center(
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
                  style: GoogleFonts.montserrat(color: LightScreenTheme.accent),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Form(
      key: _formKey,
      child: ListView(
        padding: EdgeInsets.fromLTRB(
          20 * scale,
          20 * scale,
          20 * scale,
          16 * scale,
        ),
        children: [
          if (_inventoryId != null && _inventoryId!.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(bottom: 16 * scale),
              child: Text(
                'SKU: $_inventoryId',
                style: LightScreenTheme.listSubtitle(scale),
              ),
            ),
          ProductExistingGallery(
            photos: _photos,
            busy: _photoBusy,
            onAddPhotos: _addPhotos,
            onPhotoTap: _onPhotoTap,
          ),
          SizedBox(height: 20 * scale),
          _textField(
            scale: scale,
            controller: _nameCtrl,
            label: 'Name',
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Name is required' : null,
          ),
          SizedBox(height: 14 * scale),
          _textField(
            scale: scale,
            controller: _descriptionCtrl,
            label: 'Description',
            maxLines: 3,
          ),
          SizedBox(height: 14 * scale),
          _textField(
            scale: scale,
            controller: _priceCtrl,
            label: 'Price',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Price is required';
              if (double.tryParse(v.trim()) == null) return 'Invalid price';
              return null;
            },
          ),
          SizedBox(height: 14 * scale),
          _textField(
            scale: scale,
            controller: _categoryCtrl,
            label: 'Category',
          ),
          SizedBox(height: 14 * scale),
          _textField(
            scale: scale,
            controller: _conditionCtrl,
            label: 'Condition',
            validator: (v) => (v == null || v.trim().isEmpty)
                ? 'Condition is required'
                : null,
          ),
          SizedBox(height: 14 * scale),
          _textField(
            scale: scale,
            controller: _stockCtrl,
            label: 'Stock quantity',
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: 14 * scale),
          _textField(
            scale: scale,
            controller: _linkCtrl,
            label: 'Product link',
          ),
        ],
      ),
    );
  }

  Widget _textField({
    required double scale,
    required TextEditingController controller,
    required String label,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
    void Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
      onChanged: onChanged,
      style: GoogleFonts.montserrat(
        color: Colors.black,
        fontSize: 14 * scale.clamp(0.9, 1.05),
      ),
      cursorColor: LightScreenTheme.button,
      decoration: _fieldDecoration(scale, label),
    );
  }

  Widget _buildActions(double scale) {
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        20 * scale,
        0,
        20 * scale,
        24 * scale + bottomInset,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FilledButton(
            onPressed: _saving ? null : _save,
            style: FilledButton.styleFrom(
              backgroundColor: LightScreenTheme.button,
              disabledBackgroundColor:
                  LightScreenTheme.button.withValues(alpha: 0.5),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 14 * scale),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20 * scale),
              ),
              elevation: 0,
            ),
            child: _saving
                ? const AutobusLoadingIndicator(size: 22)
                : Text(
                    'Save changes',
                    style: GoogleFonts.montserrat(
                      fontSize: 15 * scale.clamp(0.9, 1.05),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
          SizedBox(height: 12 * scale),
          OutlinedButton(
            onPressed: _saving ? null : _confirmDelete,
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFE11D48),
              side: BorderSide(
                color: const Color(0xFFE11D48).withValues(alpha: 0.7),
              ),
              padding: EdgeInsets.symmetric(vertical: 14 * scale),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20 * scale),
              ),
            ),
            child: Text(
              'Delete product',
              style: GoogleFonts.montserrat(
                fontSize: 15 * scale.clamp(0.9, 1.05),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
