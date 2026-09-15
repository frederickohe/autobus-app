import 'dart:io';

import 'package:autobus/barrel.dart';
import 'package:autobus/common_design/light_screen_theme.dart';
import 'package:autobus/common_design/widgets/app_bottom_nav.dart';
import 'package:autobus/common_design/widgets/light_list_card.dart';
import 'package:autobus/common_design/widgets/light_screen_scaffold.dart';
import 'package:autobus/features/products/product_chat_image_attachments.dart';
import 'package:autobus/features/products/product_form_images.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:share_plus/share_plus.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  static const _fieldFill = Color(0xFFFAFAFA);
  static const _labelColor = Color(0xFF4E4E4E);
  static const _hintColor = Color(0xFFB7B0B0);
  static const _buttonColor = Color(0xFF2D0C51);
  static const _lorem =
      'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod';

  static const _shareChannels = <OutletOption>[
    OutletOption(
      label: 'WhatsApp Status',
      icon: FontAwesomeIcons.whatsapp,
      iconColor: Color(0xFF3BBF77),
      tileColor: Color(0xFF3BBF77),
      linkSubtitle: 'Share from this phone',
    ),
    OutletOption(
      label: 'Instagram',
      icon: FontAwesomeIcons.instagram,
      iconColor: Color(0xFFE60B51),
      tileColor: Color(0xFFE60B51),
      linkSubtitle: 'Share from this phone',
    ),
    OutletOption(
      label: 'YouTube',
      icon: FontAwesomeIcons.youtube,
      iconColor: Color(0xFFED1F1F),
      tileColor: Color(0xFFED1F1F),
      linkSubtitle: 'Share from this phone',
    ),
  ];

  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _categoryCtrl = TextEditingController();
  final _conditionCtrl = TextEditingController();
  final _stockCtrl = TextEditingController();
  final _linkCtrl = TextEditingController();

  final List<ProductStagingSlot> _imageSlots = [];
  String _selectedChannel = 'Instagram';
  bool _saving = false;

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

  Future<void> _onImageSlotTap(int index) async {
    if (_saving) return;
    final slot = _imageSlots[index];
    if (slot.isEmpty) {
      await pickMultipleProductImages(context, _imageSlots, setState);
      return;
    }
    await showProductSlotActionsSheet(
      context,
      () => pickProductImageForSlot(context, _imageSlots, index, setState),
      () => removeProductStagingSlot(_imageSlots, index, setState),
    );
  }

  String get _shareCaption {
    final name = _nameCtrl.text.trim();
    final description = _descriptionCtrl.text.trim();
    final price = _priceCtrl.text.trim();
    final buffer = StringBuffer(name);
    if (price.isNotEmpty) {
      buffer.write('\nGHS $price');
    }
    if (description.isNotEmpty) {
      buffer.write('\n$description');
    }
    return buffer.toString();
  }

  Future<void> _shareCreatedProduct() async {
    final caption = _shareCaption;
    final files = <XFile>[];
    if (!kIsWeb) {
      for (final slot in _imageSlots) {
        final path = slot.localPath?.trim();
        if (path == null || path.isEmpty) continue;
        if (!File(path).existsSync()) continue;
        files.add(XFile(path));
      }
    }
    if (files.isNotEmpty) {
      await Share.shareXFiles(files, text: caption.isEmpty ? null : caption);
    } else if (caption.isNotEmpty) {
      await Share.share(caption);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final hasImages = _imageSlots.any((s) => !s.isEmpty);
    if (!hasImages) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Add at least one product photo',
            style: GoogleFonts.montserrat(),
          ),
        ),
      );
      return;
    }

    final price = double.tryParse(_priceCtrl.text.trim());
    if (price == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Enter a valid price',
            style: GoogleFonts.montserrat(),
          ),
        ),
      );
      return;
    }

    int? stock;
    final stockText = _stockCtrl.text.trim();
    if (stockText.isNotEmpty) {
      stock = int.tryParse(stockText);
      if (stock == null || stock < 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Stock must be a non-negative number',
              style: GoogleFonts.montserrat(),
            ),
          ),
        );
        return;
      }
    }

    setState(() => _saving = true);
    try {
      final api = context.read<ApiService>();
      final photoUrls = await uploadStagedProductImageUrls(api, _imageSlots);
      if (photoUrls.isEmpty) {
        throw Exception('Could not upload product images');
      }

      await api.createProduct(
        name: _nameCtrl.text.trim(),
        description: _descriptionCtrl.text,
        price: price,
        category: _categoryCtrl.text,
        condition: _conditionCtrl.text.trim().isEmpty
            ? 'New'
            : _conditionCtrl.text.trim(),
        numberInStock: stock,
        link: _linkCtrl.text,
        photos: photoUrls,
      );

      if (!mounted) return;
      try {
        await _shareCreatedProduct();
      } catch (_) {}
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Product created', style: GoogleFonts.montserrat()),
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.sizeOf(context).width / appShellDesignWidth;
    final fontSize = 14 * scale.clamp(0.9, 1.05);

    return LightScreenScaffold(
      title: 'Add Product',
      titleFontSize: 16,
      creditCategory: CreditCategory.storageMb,
      resizeToAvoidBottomInset: true,
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            21 * scale,
            20 * scale,
            21 * scale,
            32 * scale,
          ),
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 7 * scale),
              child: Text(
                'Product media',
                style: GoogleFonts.montserrat(
                  color: Colors.black,
                  fontSize: fontSize,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            SizedBox(height: 8 * scale),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 7 * scale),
              child: Text(
                _lorem,
                style: GoogleFonts.montserrat(
                  color: _labelColor,
                  fontSize: 13 * scale.clamp(0.9, 1.05),
                  height: 1.45,
                ),
              ),
            ),
            SizedBox(height: 16 * scale),
            _MediaDropZone(
              scale: scale,
              slots: _imageSlots,
              busy: _saving,
              onAdd: () => pickMultipleProductImages(
                context,
                _imageSlots,
                setState,
              ),
              onSlotTap: _onImageSlotTap,
            ),
            SizedBox(height: 20 * scale),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 14 * scale),
              child: Column(
                children: [
                  _LabeledField(
                    scale: scale,
                    label: 'Name',
                    hintText: 'Enter product name',
                    controller: _nameCtrl,
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Name is required'
                        : null,
                  ),
                  SizedBox(height: 8 * scale),
                  _LabeledField(
                    scale: scale,
                    label: 'Description',
                    hintText: 'Enter product description',
                    controller: _descriptionCtrl,
                    maxLines: 4,
                    minHeight: 100,
                    radius: 15,
                  ),
                  SizedBox(height: 8 * scale),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Currency',
                      style: GoogleFonts.montserrat(
                        color: _labelColor,
                        fontSize: fontSize,
                      ),
                    ),
                  ),
                  SizedBox(height: 8 * scale),
                  Row(
                    children: [
                      SizedBox(
                        width: 114 * scale,
                        child: _pillBox(
                          scale: scale,
                          radius: 20,
                          child: Text(
                            'GHS',
                            style: GoogleFonts.montserrat(
                              color: _hintColor,
                              fontSize: fontSize,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10 * scale),
                      Expanded(
                        child: TextFormField(
                          controller: _priceCtrl,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Price is required';
                            }
                            if (double.tryParse(v.trim()) == null) {
                              return 'Invalid price';
                            }
                            return null;
                          },
                          style: GoogleFonts.montserrat(
                            color: Colors.black87,
                            fontSize: fontSize,
                          ),
                          cursorColor: LightScreenTheme.accent,
                          decoration: _pillDecoration(
                            scale: scale,
                            hint: 'Price',
                            radius: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8 * scale),
                  _LabeledField(
                    scale: scale,
                    label: 'Category',
                    hintText: 'Product category',
                    controller: _categoryCtrl,
                  ),
                  SizedBox(height: 8 * scale),
                  _LabeledField(
                    scale: scale,
                    label: 'Condition',
                    hintText: 'New or used',
                    controller: _conditionCtrl,
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Condition is required'
                        : null,
                  ),
                  SizedBox(height: 8 * scale),
                  _LabeledField(
                    scale: scale,
                    label: 'Stock quantity',
                    hintText: 'Enter stock quantity',
                    controller: _stockCtrl,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                  ),
                ],
              ),
            ),
            SizedBox(height: 16 * scale),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 7 * scale),
              child: Text(
                'Post to social channels',
                style: GoogleFonts.montserrat(
                  color: Colors.black,
                  fontSize: fontSize,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            SizedBox(height: 6 * scale),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 7 * scale),
              child: Text(
                _lorem,
                style: GoogleFonts.montserrat(
                  color: _labelColor,
                  fontSize: 13 * scale.clamp(0.9, 1.05),
                  height: 1.45,
                ),
              ),
            ),
            SizedBox(height: 10 * scale),
            for (var i = 0; i < _shareChannels.length; i++) ...[
              if (i > 0) SizedBox(height: 8 * scale),
              _ChannelCard(
                scale: scale,
                outlet: _shareChannels[i],
                selected: _selectedChannel == _shareChannels[i].label,
                onTap: () => setState(
                  () => _selectedChannel = _shareChannels[i].label,
                ),
              ),
            ],
            SizedBox(height: 28 * scale),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 14 * scale),
              child: Material(
                color: _buttonColor,
                borderRadius: BorderRadius.circular(30 * scale),
                child: InkWell(
                  onTap: _saving ? null : _submit,
                  borderRadius: BorderRadius.circular(30 * scale),
                  child: SizedBox(
                    height: 64 * scale,
                    child: Center(
                      child: _saving
                          ? const AutobusLoadingIndicator(size: 22)
                          : Text(
                              'Create product',
                              style: GoogleFonts.montserrat(
                                color: Colors.white,
                                fontSize: 16 * scale.clamp(0.9, 1.05),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _pillDecoration({
    required double scale,
    required String hint,
    required double radius,
  }) {
    final fontSize = 14 * scale.clamp(0.9, 1.05);
    return InputDecoration(
      isDense: true,
      hintText: hint,
      hintStyle: GoogleFonts.montserrat(
        color: _hintColor,
        fontSize: fontSize,
      ),
      filled: true,
      fillColor: _fieldFill,
      contentPadding: EdgeInsets.symmetric(
        horizontal: 20 * scale,
        vertical: 18 * scale,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius * scale),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius * scale),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius * scale),
        borderSide: BorderSide(color: LightScreenTheme.accent, width: 1.2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius * scale),
        borderSide: BorderSide(color: Colors.red.shade400),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius * scale),
        borderSide: BorderSide(color: Colors.red.shade400, width: 1.2),
      ),
    );
  }

  Widget _pillBox({
    required double scale,
    required double radius,
    required Widget child,
  }) {
    return Container(
      height: 56 * scale,
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.symmetric(horizontal: 20 * scale),
      decoration: BoxDecoration(
        color: _fieldFill,
        borderRadius: BorderRadius.circular(radius * scale),
      ),
      child: child,
    );
  }
}

class _LabeledField extends StatelessWidget {
  final double scale;
  final String label;
  final String hintText;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final String? Function(String?)? validator;
  final int maxLines;
  final double minHeight;
  final double radius;

  const _LabeledField({
    required this.scale,
    required this.label,
    required this.hintText,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.validator,
    this.maxLines = 1,
    this.minHeight = 56,
    this.radius = 30,
  });

  @override
  Widget build(BuildContext context) {
    final fontSize = 14 * scale.clamp(0.9, 1.05);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.montserrat(
            color: _AddProductScreenState._labelColor,
            fontSize: fontSize,
          ),
        ),
        SizedBox(height: 8 * scale),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          validator: validator,
          maxLines: maxLines,
          style: GoogleFonts.montserrat(
            color: Colors.black87,
            fontSize: fontSize,
          ),
          cursorColor: LightScreenTheme.accent,
          decoration: InputDecoration(
            isDense: true,
            hintText: hintText,
            hintStyle: GoogleFonts.montserrat(
              color: _AddProductScreenState._hintColor,
              fontSize: fontSize,
            ),
            filled: true,
            fillColor: _AddProductScreenState._fieldFill,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 20 * scale,
              vertical: maxLines > 1 ? 18 * scale : 18 * scale,
            ),
            constraints: BoxConstraints(minHeight: minHeight * scale),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(radius * scale),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(radius * scale),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(radius * scale),
              borderSide: BorderSide(
                color: LightScreenTheme.accent,
                width: 1.2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(radius * scale),
              borderSide: BorderSide(color: Colors.red.shade400),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(radius * scale),
              borderSide: BorderSide(color: Colors.red.shade400, width: 1.2),
            ),
          ),
        ),
      ],
    );
  }
}

class _MediaDropZone extends StatelessWidget {
  final double scale;
  final List<ProductStagingSlot> slots;
  final bool busy;
  final VoidCallback onAdd;
  final ValueChanged<int> onSlotTap;

  const _MediaDropZone({
    required this.scale,
    required this.slots,
    required this.busy,
    required this.onAdd,
    required this.onSlotTap,
  });

  @override
  Widget build(BuildContext context) {
    final filled = [
      for (var i = 0; i < slots.length; i++)
        if (!slots[i].isEmpty) i,
    ];

    return GestureDetector(
      onTap: busy || filled.isNotEmpty ? null : onAdd,
      child: CustomPaint(
        painter: _DashedRRectPainter(
          color: const Color(0xFF888888),
          radius: 20 * scale,
        ),
        child: Container(
          width: double.infinity,
          constraints: BoxConstraints(minHeight: 125 * scale),
          padding: EdgeInsets.symmetric(
            horizontal: 16 * scale,
            vertical: 16 * scale,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFE6E6E6),
            borderRadius: BorderRadius.circular(20 * scale),
          ),
          child: filled.isEmpty
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.photo_library_outlined,
                          size: 20 * scale,
                          color: const Color(0xFF3F3E3E),
                        ),
                        SizedBox(width: 8 * scale),
                        Text(
                          'Upload media',
                          style: GoogleFonts.montserrat(
                            color: const Color(0xFF3F3E3E),
                            fontSize: 14 * scale.clamp(0.9, 1.05),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8 * scale),
                    Text(
                      'Upload your product image or video',
                      style: GoogleFonts.montserrat(
                            color: const Color(0xFF939292),
                            fontSize: 11 * scale.clamp(0.9, 1.05),
                          ),
                    ),
                  ],
                )
              : SizedBox(
                  height: 88 * scale,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      for (var j = 0; j < filled.length; j++) ...[
                        if (j > 0) SizedBox(width: 10 * scale),
                        GestureDetector(
                          onTap: busy ? null : () => onSlotTap(filled[j]),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12 * scale),
                            child: SizedBox(
                              width: 88 * scale,
                              height: 88 * scale,
                              child: _slotPreview(slots[filled[j]]),
                            ),
                          ),
                        ),
                      ],
                      if (filled.length < ProductFormImageSection.maxImages) ...[
                        SizedBox(width: 10 * scale),
                        GestureDetector(
                          onTap: busy ? null : onAdd,
                          child: Container(
                            width: 88 * scale,
                            height: 88 * scale,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.55),
                              borderRadius: BorderRadius.circular(12 * scale),
                            ),
                            child: Icon(
                              Icons.add,
                              color: const Color(0xFF3F3E3E),
                              size: 28 * scale,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _slotPreview(ProductStagingSlot slot) {
    final bytes = slot.previewBytes;
    if (bytes != null && bytes.isNotEmpty) {
      return Image.memory(bytes, fit: BoxFit.cover, gaplessPlayback: true);
    }
    final path = slot.localPath;
    if (!kIsWeb && path != null && path.isNotEmpty && File(path).existsSync()) {
      return Image.file(File(path), fit: BoxFit.cover, gaplessPlayback: true);
    }
    return const ColoredBox(color: Colors.white70);
  }
}

class _DashedRRectPainter extends CustomPainter {
  final Color color;
  final double radius;

  _DashedRRectPainter({required this.color, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );
    final path = Path()..addRRect(rrect);
    const dash = 7.0;
    const gap = 5.0;
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = (distance + dash).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(distance, next), paint);
        distance += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRRectPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.radius != radius;
}

class _ChannelCard extends StatelessWidget {
  final double scale;
  final OutletOption outlet;
  final bool selected;
  final VoidCallback onTap;

  const _ChannelCard({
    required this.scale,
    required this.outlet,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return LightListCard(
      scale: scale,
      borderColor: selected ? Colors.black : null,
      borderWidth: 2,
      padding: EdgeInsets.fromLTRB(
        16 * scale,
        18 * scale,
        16 * scale,
        18 * scale,
      ),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: outlet.tileColor,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: FaIcon(outlet.icon, size: 18, color: Colors.white),
          ),
          SizedBox(width: 12 * scale),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  outlet.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.montserrat(
                    color: Colors.black,
                    fontSize: 14 * scale.clamp(0.9, 1.05),
                    fontWeight: FontWeight.w600,
                    height: 1.25,
                  ),
                ),
                SizedBox(height: 4 * scale),
                Text(
                  'Share from this phone',
                  style: GoogleFonts.montserrat(
                    color: const Color(0xFF939292),
                    fontSize: 12 * scale.clamp(0.9, 1.05),
                  ),
                ),
              ],
            ),
          ),
          if (selected)
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black, width: 2),
              ),
              alignment: Alignment.center,
              child: Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: Colors.black,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
