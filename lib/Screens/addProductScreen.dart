import 'package:flutter/material.dart';
import 'package:orangtre/Widgets/appbar.dart';
import 'package:orangtre/Widgets/drawer.dart';
import 'package:orangtre/Services/inventoryService.dart';
import 'package:orangtre/Widgets/customLoader.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();

  // Form controllers
  final _productNameController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockQuantityController = TextEditingController();
  final _groupController = TextEditingController();
  final _shadeNameAndCodeController = TextEditingController();
  final _packSizeController = TextEditingController();
  final _fixedBar5DigitController = TextEditingController();
  final _barCodeHarshitController = TextEditingController();
  final _skuController = TextEditingController();
  final _barCode12DigitController = TextEditingController();
  final _totalNoOfDigitController = TextEditingController();
  final _productImageDriveLinkController = TextEditingController();

  @override
  void dispose() {
    _productNameController.dispose();
    _priceController.dispose();
    _stockQuantityController.dispose();
    _groupController.dispose();
    _shadeNameAndCodeController.dispose();
    _packSizeController.dispose();
    _fixedBar5DigitController.dispose();
    _barCodeHarshitController.dispose();
    _skuController.dispose();
    _barCode12DigitController.dispose();
    _totalNoOfDigitController.dispose();
    _productImageDriveLinkController.dispose();
    super.dispose();
  }

  Future<void> _addProduct() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: LoaderOverlay()),
    );

    try {
      final inventoryService = Inventoryservice();
      
      // Call the add product API with form data
      await inventoryService.addProduct(
        productName: _productNameController.text,
        price: _priceController.text,
        stockQuantity: _stockQuantityController.text,
        group: _groupController.text,
        shadeNameAndCode: _shadeNameAndCodeController.text,
        packSize: _packSizeController.text,
        fixedBar5Digit: _fixedBar5DigitController.text,
        barCodeHarshit: _barCodeHarshitController.text,
        sku: _skuController.text,
        barCode12Digit: _barCode12DigitController.text,
        totalNoOfDigit: _totalNoOfDigitController.text,
        productImageDriveLink: _productImageDriveLinkController.text,
      );

      // Close loading dialog
      if (mounted) Navigator.pop(context);

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Product added successfully!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 3),
          ),
        );

        // Navigate back to inventory screen
        Navigator.pop(context, true); // Return true to indicate refresh needed
      }
    } catch (e) {
      // Close loading dialog if open
      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add product: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      title: 'Add Product',
      drawer: const OrangtreDrawer(),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [const Color(0xFF2C3E50), Colors.grey[100]!],
            stops: const [0.0, 0.3],
          ),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2C3E50).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.add_circle_outline,
                            color: Color(0xFF2C3E50),
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Add New Product',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2C3E50),
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Fill in the product details below',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Form
            Expanded(
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                      // Product Information Section
                      _buildSectionTitle('Product Information'),
                      const SizedBox(height: 16),
                      
                      _buildTextField(
                        controller: _productNameController,
                        label: 'Product Name',
                        hint: 'Enter product name',
                        keyboardType: TextInputType.text,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Product name is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      _buildTextField(
                        controller: _priceController,
                        label: 'Price',
                        hint: 'Enter price',
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Price is required';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Please enter a valid price';
                          }
                          if (double.parse(value) <= 0) {
                            return 'Price must be greater than 0';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      _buildTextField(
                        controller: _stockQuantityController,
                        label: 'Stock Quantity',
                        hint: 'Enter stock quantity',
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Stock quantity is required';
                          }
                          if (int.tryParse(value) == null) {
                            return 'Please enter a valid quantity';
                          }
                          if (int.parse(value) < 0) {
                            return 'Stock quantity cannot be negative';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      
                      // Product Details Section
                      _buildSectionTitle('Product Details'),
                      const SizedBox(height: 16),
                      
                      _buildTextField(
                        controller: _groupController,
                        label: 'Product Group',
                        hint: 'Enter product group',
                        keyboardType: TextInputType.text,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Product group is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      _buildTextField(
                        controller: _shadeNameAndCodeController,
                        label: 'Shade Name and Code',
                        hint: 'Enter shade name and code',
                        keyboardType: TextInputType.text,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Shade name and code is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      _buildTextField(
                        controller: _packSizeController,
                        label: 'Pack Size',
                        hint: 'Enter pack size',
                        keyboardType: TextInputType.text,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Pack size is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      
                      // Barcode Information Section
                      _buildSectionTitle('Barcode Information'),
                      const SizedBox(height: 16),
                      
                      _buildTextField(
                        controller: _fixedBar5DigitController,
                        label: 'Fixed Bar (5 Digit)',
                        hint: 'Enter 5-digit fixed bar code',
                        keyboardType: TextInputType.number,
                        maxLength: 5,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Fixed bar (5 digit) is required';
                          }
                          if (value.length != 5) {
                            return 'Must be exactly 5 digits';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      _buildTextField(
                        controller: _barCodeHarshitController,
                        label: 'Barcode (Harshit)',
                        hint: 'Enter Harshit barcode',
                        keyboardType: TextInputType.text,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Harshit barcode is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      _buildTextField(
                        controller: _skuController,
                        label: 'SKU',
                        hint: 'Enter SKU',
                        keyboardType: TextInputType.text,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'SKU is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      _buildTextField(
                        controller: _barCode12DigitController,
                        label: 'Barcode (12 Digit)',
                        hint: 'Enter 12-digit barcode',
                        keyboardType: TextInputType.number,
                        maxLength: 12,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Barcode (12 digit) is required';
                          }
                          if (value.length != 12) {
                            return 'Must be exactly 12 digits';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      _buildTextField(
                        controller: _totalNoOfDigitController,
                        label: 'Total No of Digits',
                        hint: 'Enter total number of digits',
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Total number of digits is required';
                          }
                          if (int.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          }
                          if (int.parse(value) <= 0) {
                            return 'Number of digits must be greater than 0';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      
                      // Additional Information Section
                      _buildSectionTitle('Additional Information'),
                      const SizedBox(height: 16),
                      
                      _buildTextField(
                        controller: _productImageDriveLinkController,
                        label: 'Product Image Drive Link',
                        hint: 'Enter image URL or drive link',
                        keyboardType: TextInputType.url,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Product image link is required';
                          }
                          // Basic URL validation
                          final uri = Uri.tryParse(value);
                          if (uri == null || !uri.hasAbsolutePath) {
                            return 'Please enter a valid URL';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 32),
                      
                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton.icon(
                          onPressed: _isLoading ? null : _addProduct,
                          icon: _isLoading 
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Icon(Icons.add_circle, size: 24),
                          label: Text(
                            _isLoading ? 'Adding Product...' : 'Add Product',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2C3E50),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            elevation: 5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ],
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

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFF2C3E50),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    int? maxLength,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2C3E50),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLength: maxLength,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400]),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFF2C3E50),
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            filled: true,
            fillColor: Colors.grey[50],
            counterText: maxLength != null ? null : '',
          ),
        ),
      ],
    );
  }
}