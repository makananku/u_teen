import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:u_teen/auth/auth_provider.dart';
import 'package:u_teen/providers/food_provider.dart';
import 'package:u_teen/models/product_model.dart';
import 'dart:io';
import 'package:flutter/services.dart';

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
  int _preparationTime = 5;
  bool _isUploading = false;
  bool _isActive = true;

  // Time options for alternative selection
  final List<int> _timeOptions = [5, 10, 15, 20, 25, 30];
  final List<String> _timeLabels = [
    'Fast (5-10 min)',
    'Medium (15-20 min)',
    'Long (25-30 min)',
  ];

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _tenantName = authProvider.tenantName ?? 'My Tenant'; // Ambil dari tenantName, fallback ke 'My Tenant'

    _isActive = widget.product?.isActive ?? true;

    _nameController = TextEditingController(text: widget.product?.title ?? '');
    _descriptionController = TextEditingController(
      text: widget.product?.subtitle ?? '',
    );

    // Initialize price controller, removing any non-digits from existing price
    _priceController = TextEditingController(
      text: widget.product?.price != null
          ? _formatPrice(widget.product!.price.replaceAll('.', ''))
          : '',
    );

    // Add listener to format price input with thousand separators
    _priceController.addListener(_formatPriceInput);

    if (widget.product?.time != null) {
      _preparationTime = int.parse(
        widget.product!.time.replaceAll(' mins', ''),
      );
    }
  }

  // Format price input as the user types
  void _formatPriceInput() {
    String text = _priceController.text.replaceAll('.', '');
    if (text.isEmpty) return;

    String formatted = _formatPrice(text);
    if (formatted != _priceController.text) {
      // Calculate cursor position
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

  // Format number with thousand separators (dots)
  String _formatPrice(String input) {
    if (input.isEmpty) return '';
    // Remove any non-digits
    String digits = input.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return '';

    // Convert to number and format with dots
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.product == null ? 'Add Product' : 'Edit Product'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
        actions: [
          IconButton(
            icon: _isUploading
                ? const CircularProgressIndicator()
                : const Icon(Icons.save, color: Color(0xFF6C63FF)),
            onPressed: _isUploading ? null : _saveProduct,
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
              // Product Image Section
              _buildImageSection(),
              const SizedBox(height: 24),

              // Product Status Toggle
              _buildStatusToggle(),
              const SizedBox(height: 16),

              // Product Name
              _buildInputSection(
                title: 'Product Name',
                child: TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    hintText: 'Enter product name',
                    border: InputBorder.none,
                  ),
                  validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                ),
              ),
              const SizedBox(height: 20),

              // Description
              _buildInputSection(
                title: 'Description',
                child: TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    hintText: 'Enter product description',
                    border: InputBorder.none,
                  ),
                  maxLines: 2,
                ),
              ),
              const SizedBox(height: 20),

              // Price
              _buildInputSection(
                title: 'Price',
                child: TextFormField(
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  decoration: const InputDecoration(
                    hintText: 'Enter price',
                    prefixText: 'Rp ',
                    border: InputBorder.none,
                  ),
                  validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                ),
              ),
              const SizedBox(height: 20),

              // Preparation Time - Enhanced Slider
              _buildInputSection(
                title: 'Preparation Time',
                child: Column(
                  children: [
                    Text(
                      '$_preparationTime mins',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6C63FF),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: const Color(0xFF6C63FF),
                        inactiveTrackColor: const Color(0xFFD1CDFF),
                        thumbColor: const Color(0xFF6C63FF),
                        overlayColor: const Color(0x1A6C63FF),
                        valueIndicatorColor: const Color(0xFF6C63FF),
                        thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 10,
                        ),
                        overlayShape: const RoundSliderOverlayShape(
                          overlayRadius: 16,
                        ),
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
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text('1 min', style: TextStyle(color: Colors.grey)),
                        Text('30 mins', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Save Button
              ElevatedButton(
                onPressed: _isUploading ? null : _saveProduct,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C63FF),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                  shadowColor: const Color(0x806C63FF),
                ),
                child: _isUploading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'SAVE PRODUCT',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusToggle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Product Status',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
          ),
          Switch(
            value: _isActive,
            onChanged: (value) {
              setState(() {
                _isActive = value;
              });
            },
            activeColor: Colors.green,
            inactiveThumbColor: Colors.grey,
            inactiveTrackColor: Colors.grey.withOpacity(0.5),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Widget _buildImageSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Product Image',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: _isUploading ? null : _pickImage,
            child: Container(
              height: 160,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey.shade100,
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: _buildImageContent(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageContent() {
    if (_isUploading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_imageFile != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(_imageFile!, fit: BoxFit.cover),
      );
    }

    if (widget.product?.imgUrl != null &&
        widget.product!.imgUrl.startsWith('http')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          widget.product!.imgUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
        ),
      );
    }

    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.add_a_photo, size: 40, color: Colors.grey.shade400),
        const SizedBox(height: 8),
        Text(
          'Add Product Image',
          style: TextStyle(color: Colors.grey.shade500),
        ),
      ],
    );
  }

  Widget _buildInputSection({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.05),
                spreadRadius: 1,
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: child,
        ),
      ],
    );
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isUploading = true;
    });

    try {
      final foodProvider = Provider.of<FoodProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final sellerEmail = authProvider.sellerEmail ?? '';

      // Parse price to integer, removing dots
      final price = int.parse(_priceController.text.replaceAll('.', ''));

      final product = Product(
        id: widget.product?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: _nameController.text,
        subtitle: _descriptionController.text,
        price: price.toString(),
        imgUrl: _imageFile != null ? _imageFile!.path : widget.product?.imgUrl ?? '',
        time: '$_preparationTime mins',
        tenantName: _tenantName, // Diambil dari authProvider.tenantName
        sellerEmail: sellerEmail,
        isActive: _isActive,
      );

      if (widget.product == null) {
        await foodProvider.addProduct(product);
      } else {
        await foodProvider.updateProduct(product);
      }

      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save product: $e')),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.removeListener(_formatPriceInput);
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}