import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:u_teen/auth/auth_provider.dart';
import 'package:u_teen/providers/food_provider.dart';
import 'package:u_teen/models/product_model.dart';
import 'dart:io';

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

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _tenantName = authProvider.user?.name ?? 'My Tenant';
    
    _nameController = TextEditingController(text: widget.product?.title ?? '');
    _priceController = TextEditingController(text: widget.product?.price ?? '');
    _descriptionController = TextEditingController(text: widget.product?.subtitle ?? '');
    
    if (widget.product?.time != null) {
      _preparationTime = int.parse(widget.product!.time.replaceAll(' mins', ''));
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      imageQuality: 85,
    );
    
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    // For demo purposes, we'll just use the existing image URL or a placeholder
    final imageUrl = widget.product?.imgUrl ?? 'https://via.placeholder.com/150?text=No+Image';

    final foodProvider = Provider.of<FoodProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final product = Product(
      id: widget.product?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: _nameController.text,
      subtitle: _descriptionController.text.isNotEmpty 
          ? _descriptionController.text 
          : _tenantName,
      price: _priceController.text,
      time: '$_preparationTime mins',
      imgUrl: imageUrl,
      sellerEmail: authProvider.user?.email ?? '', 
      String: null,
    );

    try {
      setState(() => _isUploading = true);
      
      if (widget.product == null) {
        await foodProvider.addProduct(product);
      } else {
        await foodProvider.updateProduct(product);
      }

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving product: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
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
                : const Icon(Icons.save, color: Colors.blue),
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
                  decoration: const InputDecoration(
                    hintText: 'Enter price',
                    prefixText: 'Rp ',
                    border: InputBorder.none,
                  ),
                  validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                ),
              ),
              const SizedBox(height: 20),

              // Preparation Time
              _buildInputSection(
                title: 'Preparation Time',
                child: Column(
                  children: [
                    Text(
                      '$_preparationTime mins',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    Slider(
                      value: _preparationTime.toDouble(),
                      min: 1,
                      max: 30,
                      divisions: 29,
                      onChanged: (value) {
                        setState(() {
                          _preparationTime = value.toInt();
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Save Button
              ElevatedButton(
                onPressed: _isUploading ? null : _saveProduct,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isUploading
                    ? const CircularProgressIndicator()
                    : const Text('SAVE PRODUCT'),
              ),
            ],
          ),
        ),
      ),
    );
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
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
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
        child: Image.file(
          _imageFile!,
          fit: BoxFit.cover,
        ),
      );
    }

    if (widget.product?.imgUrl != null && widget.product!.imgUrl.startsWith('http')) {
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
        Icon(
          Icons.add_a_photo,
          size: 40,
          color: Colors.grey.shade400,
        ),
        const SizedBox(height: 8),
        Text(
          'Add Product Image',
          style: TextStyle(
            color: Colors.grey.shade500,
          ),
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

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}