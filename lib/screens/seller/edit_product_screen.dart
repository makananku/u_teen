import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:u_teen/auth/auth_provider.dart';
import 'package:u_teen/providers/food_provider.dart';
import 'package:u_teen/models/product_model.dart';
import 'package:u_teen/providers/theme_notifier.dart';
import 'package:u_teen/utils/app_theme.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'dart:convert';

class SellerEditProductScreen extends StatefulWidget {
  final Product? product;

  const SellerEditProductScreen({super.key, this.product});

  @override
  State<SellerEditProductScreen> createState() => _SellerEditProductScreenState();
}

class _SellerEditProductScreenState extends State<SellerEditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _descriptionController;
  late String _tenantName;
  File? _imageFile;
  String? _imgBase64;
  int _preparationTime = 5;
  bool _isUploading = false;
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    debugPrint('Initializing SellerEditProductScreen');
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _tenantName = authProvider.tenantName ?? 'My Tenant';

    _isActive = widget.product?.isActive ?? true;

    _nameController = TextEditingController(text: widget.product?.title ?? '');
    _descriptionController = TextEditingController(
      text: widget.product?.subtitle ?? '',
    );

    _priceController = TextEditingController(
      text: widget.product?.price != null
          ? _formatPrice(widget.product!.price.replaceAll('.', ''))
          : '',
    );

    _priceController.addListener(_formatPriceInput);

    if (widget.product?.time != null) {
      _preparationTime = int.parse(
        widget.product!.time.replaceAll(' mins', ''),
      );
    }
    _imgBase64 = widget.product?.imgBase64;
    debugPrint('Initial imgBase64: ${_imgBase64 != null ? 'present' : 'null'}');
  }

  void _formatPriceInput() {
    String text = _priceController.text.replaceAll('.', '');
    if (text.isEmpty) return;

    String formatted = _formatPrice(text);
    if (formatted != _priceController.text) {
      int cursorPos = _priceController.selection.baseOffset;
      int dotsBeforeCursor = _priceController.text
          .substring(0, cursorPos)
          .replaceAll(RegExp(r'[^.]'), '')
          .length;
      int newDotsBeforeCursor = formatted
          .substring(0, cursorPos + (formatted.length - _priceController.text.length))
          .replaceAll(RegExp(r'[^.]'), '')
          .length;

      _priceController.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(
          offset: cursorPos + (newDotsBeforeCursor - dotsBeforeCursor),
        ),
      );
    }
  }

  String _formatPrice(String input) {
    if (input.isEmpty) return '';
    String digits = input.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return '';

    int number = int.parse(digits);
    String result = number.toString();
    List<String> parts = [];
    while (result.isNotEmpty) {
      if (result.length > 3) {
        parts.insert(0, result.substring(result.length - 3));
        result = result.substring(0, result.length - 3);
      } else {
        parts.insert(0, result);
        result = '';
      }
    }
    return parts.join('.');
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final isDarkMode = themeNotifier.isDarkMode;
    return Theme(
      data: themeNotifier.currentTheme,
      child: Scaffold(
        backgroundColor: AppTheme.getBackground(isDarkMode),
        appBar: AppBar(
          title: Text(
            widget.product == null ? 'Add New Product' : 'Edit Product',
            style: TextStyle(
              color: AppTheme.getPrimaryText(isDarkMode),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: AppTheme.getCard(isDarkMode),
          elevation: 0.5,
          centerTitle: false,
          iconTheme: IconThemeData(color: AppTheme.getPrimaryText(isDarkMode)),
          actions: [
            if (widget.product != null) // Delete button for existing products
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: IconButton(
                  icon: Icon(Icons.delete_rounded, size: 26, color: Colors.redAccent),
                  onPressed: _isUploading ? null : _deleteProduct,
                ),
              ),
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: IconButton(
                icon: _isUploading
                    ? SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.getPrimaryText(isDarkMode)),
                        ),
                      )
                    : Icon(Icons.save_rounded, size: 26, color: AppTheme.getPrimaryText(isDarkMode)),
                onPressed: _isUploading ? null : _saveProduct,
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildImageSection(isDarkMode),
                const SizedBox(height: 24),
                _buildStatusToggle(isDarkMode),
                const SizedBox(height: 20),
                _buildInputSection(
                  title: 'Product Name',
                  hintText: 'Enter product name',
                  controller: _nameController,
                  validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                  isDarkMode: isDarkMode,
                ),
                const SizedBox(height: 16),
                _buildInputSection(
                  title: 'Description',
                  hintText: 'Enter product description',
                  controller: _descriptionController,
                  maxLines: 3,
                  isDarkMode: isDarkMode,
                ),
                const SizedBox(height: 16),
                _buildInputSection(
                  title: 'Price',
                  hintText: 'Enter price',
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  prefixText: 'Rp ',
                  validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                  isDarkMode: isDarkMode,
                ),
                const SizedBox(height: 16),
                _buildTimeSection(isDarkMode),
                const SizedBox(height: 28),
                ElevatedButton(
                  onPressed: _isUploading ? null : _saveProduct,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.getButton(isDarkMode),
                    foregroundColor: AppTheme.getPrimaryText(!isDarkMode),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: isDarkMode ? 0 : 2,
                  ),
                  child: _isUploading
                      ? SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.getPrimaryText(!isDarkMode)),
                          ),
                        )
                      : Text(
                          widget.product == null ? 'ADD PRODUCT' : 'UPDATE PRODUCT',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                            color: AppTheme.getPrimaryText(!isDarkMode),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusToggle(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppTheme.getCard(isDarkMode),
        borderRadius: BorderRadius.circular(12),
        boxShadow: isDarkMode
            ? []
            : [
                BoxShadow(
                  color: AppTheme.getSecondaryText(isDarkMode).withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Product Status',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: AppTheme.getPrimaryText(isDarkMode),
            ),
          ),
          Transform.scale(
            scale: 1.2,
            child: Switch.adaptive(
              value: _isActive,
              onChanged: (value) => setState(() => _isActive = value),
              activeColor: AppTheme.getButton(isDarkMode),
              inactiveThumbColor: AppTheme.getSecondaryText(isDarkMode),
              inactiveTrackColor: AppTheme.getSecondaryText(isDarkMode).withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage() async {
    debugPrint('Picking image from gallery');
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _imageFile = File(pickedFile.path);
        _imgBase64 = base64Encode(bytes);
        debugPrint('Image picked and encoded to Base64');
      });
    } else {
      debugPrint('No image picked');
    }
  }

  Widget _buildImageSection(bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'Product Image',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: AppTheme.getPrimaryText(isDarkMode),
            ),
          ),
        ),
        GestureDetector(
          onTap: _isUploading ? null : _pickImage,
          child: Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppTheme.getCard(isDarkMode),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.getSecondaryText(isDarkMode).withOpacity(0.5),
                width: 1.5,
              ),
            ),
            child: _buildImageContent(isDarkMode),
          ),
        ),
      ],
    );
  }

  Widget _buildImageContent(bool isDarkMode) {
    if (_isUploading) {
      return Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.getButton(isDarkMode)),
        ),
      );
    }

    if (_imageFile != null) {
      debugPrint('Displaying image from local file');
      return ClipRRect(
        borderRadius: BorderRadius.circular(11),
        child: Image.file(_imageFile!, fit: BoxFit.cover),
      );
    }

    if (_imgBase64 != null && _imgBase64!.isNotEmpty) {
      try {
        debugPrint('Decoding and displaying Base64 image');
        final decodedBytes = base64Decode(_imgBase64!);
        return ClipRRect(
          borderRadius: BorderRadius.circular(11),
          child: Image.memory(
            decodedBytes,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              debugPrint('Image memory error: $error');
              return _buildPlaceholder(isDarkMode);
            },
          ),
        );
      } catch (e) {
        debugPrint('Base64 decode error: $e');
        return _buildPlaceholder(isDarkMode);
      }
    }

    debugPrint('No image available, showing placeholder');
    return _buildPlaceholder(isDarkMode);
  }

  Widget _buildPlaceholder(bool isDarkMode) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.add_photo_alternate_rounded,
          size: 48,
          color: AppTheme.getSecondaryText(isDarkMode),
        ),
        const SizedBox(height: 8),
        Text(
          'Tap to add image',
          style: TextStyle(
            color: AppTheme.getSecondaryText(isDarkMode),
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildInputSection({
    required String title,
    required String hintText,
    required TextEditingController controller,
    String? prefixText,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    required bool isDarkMode,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: AppTheme.getPrimaryText(isDarkMode),
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.getCard(isDarkMode),
            borderRadius: BorderRadius.circular(12),
            boxShadow: isDarkMode
                ? []
                : [
                    BoxShadow(
                      color: AppTheme.getSecondaryText(isDarkMode).withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            inputFormatters: keyboardType == TextInputType.number
                ? [FilteringTextInputFormatter.digitsOnly]
                : null,
            decoration: InputDecoration(
              hintText: hintText,
              prefixText: prefixText,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
              hintStyle: TextStyle(color: AppTheme.getSecondaryText(isDarkMode)),
            ),
            style: TextStyle(color: AppTheme.getPrimaryText(isDarkMode)),
            validator: validator,
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSection(bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'Preparation Time',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: AppTheme.getPrimaryText(isDarkMode),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppTheme.getCard(isDarkMode),
            borderRadius: BorderRadius.circular(12),
            boxShadow: isDarkMode
                ? []
                : [
                    BoxShadow(
                      color: AppTheme.getSecondaryText(isDarkMode).withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Column(
            children: [
              Text(
                '$_preparationTime mins',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.getButton(isDarkMode),
                ),
              ),
              const SizedBox(height: 12),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: AppTheme.getButton(isDarkMode),
                  inactiveTrackColor: AppTheme.getSecondaryText(isDarkMode).withOpacity(0.3),
                  thumbColor: AppTheme.getButton(isDarkMode),
                  overlayColor: AppTheme.getButton(isDarkMode).withOpacity(0.1),
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 10,
                    elevation: 0,
                  ),
                  overlayShape: const RoundSliderOverlayShape(
                    overlayRadius: 16,
                  ),
                  trackHeight: 4,
                ),
                child: Slider(
                  value: _preparationTime.toDouble(),
                  min: 1,
                  max: 30,
                  divisions: 29,
                  label: '$_preparationTime mins',
                  onChanged: (value) {
                    setState(() {
                      _preparationTime = value.toInt();
                    });
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '1 min',
                      style: TextStyle(color: AppTheme.getSecondaryText(isDarkMode)),
                    ),
                    Text(
                      '30 mins',
                      style: TextStyle(color: AppTheme.getSecondaryText(isDarkMode)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isUploading = true);
    debugPrint('Saving product');

    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);
    final isDarkMode = themeNotifier.isDarkMode;

    try {
      final foodProvider = Provider.of<FoodProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final sellerEmail = authProvider.sellerEmail ?? '';

      final price = _priceController.text.replaceAll('.', '');

      String? imgBase64 = _imgBase64;
      if (_imageFile != null) {
        final bytes = await _imageFile!.readAsBytes();
        imgBase64 = base64Encode(bytes);
        debugPrint('New image encoded to Base64');
      } else if (widget.product?.imgBase64 != null) {
        imgBase64 = widget.product!.imgBase64;
        debugPrint('Using existing imgBase64 from product');
      }

      final product = Product(
        id: widget.product?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: _nameController.text,
        subtitle: _descriptionController.text,
        price: price,
        //imgUrl: '', // Tidak digunakan, tapi tetap diisi kosong untuk kompatibilitas model
        time: '$_preparationTime mins',
        tenantName: _tenantName,
        sellerEmail: sellerEmail,
        isActive: _isActive,
        imgBase64: imgBase64 ?? '',
        category: widget.product?.category ?? '',
      );
      if (widget.product == null) {
        await foodProvider.addProduct(product);
        debugPrint('New product added');
      } else {
        await foodProvider.updateProduct(product);
        debugPrint('Product updated');
      }

      Navigator.of(context).pop();
    } catch (e) {
      debugPrint('Failed to save product: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save product: $e'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          backgroundColor: AppTheme.getSnackBarError(isDarkMode),
        ),
      );
    } finally {
      setState(() => _isUploading = false);
    }
  }

  Future<void> _deleteProduct() async {
    if (widget.product == null) return;

    debugPrint('Attempting to delete product: ${widget.product!.id}');
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: const Text('Are you sure you want to delete this product?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isUploading = true);

    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);
    final isDarkMode = themeNotifier.isDarkMode;

    try {
      final foodProvider = Provider.of<FoodProvider>(context, listen: false);
      await foodProvider.deleteProduct(widget.product!.id);
      debugPrint('Product deleted: ${widget.product!.id}');
      Navigator.of(context).pop();
    } catch (e) {
      debugPrint('Failed to delete product: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete product: $e'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          backgroundColor: AppTheme.getSnackBarError(isDarkMode),
        ),
      );
    } finally {
      setState(() => _isUploading = false);
    }
  }

  @override
  void dispose() {
    debugPrint('Disposing SellerEditProductScreen');
    _nameController.dispose();
    _priceController.removeListener(_formatPriceInput);
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}