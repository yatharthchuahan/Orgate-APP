import 'package:flutter/material.dart';
import 'package:orangtre/Widgets/appbar.dart';
import 'package:orangtre/Widgets/drawer.dart';
import 'package:orangtre/Services/inventoryService.dart';
import 'package:orangtre/Widgets/customLoader.dart';
import 'package:orangtre/model/inventoryResponse.dart';

class EditProductScreen extends StatefulWidget {
  final Product product;

  const EditProductScreen({super.key, required this.product});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  bool _isLoading = false;

  // Form controllers
  final _productIDController = TextEditingController();
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
  void initState() {
    super.initState();
    _populateFields();
  }

  void _populateFields() {
    _productIDController.text = widget.product.productID.toString();
    _productNameController.text = widget.product.productName;
    _priceController.text = widget.product.price.toString();
    _stockQuantityController.text = widget.product.stock.toString();
    _groupController.text = widget.product.productGroup?.toString() ?? '';
    _shadeNameAndCodeController.text = widget.product.shadeNameAndShade?.toString() ?? '';
    _packSizeController.text = widget.product.packSize?.toString() ?? '';
    _fixedBar5DigitController.text = widget.product.fixedBar5Digit?.toString() ?? '';
    _barCodeHarshitController.text = widget.product.barCodeHarshit?.toString() ?? '';
    _skuController.text = widget.product.sku?.toString() ?? '';
    _barCode12DigitController.text = widget.product.barCode12Digit?.toString() ?? '';
    _totalNoOfDigitController.text = widget.product.totalNoOfDigit?.toString() ?? '';
    _productImageDriveLinkController.text = widget.product.productImageDriveLink?.toString() ?? '';
  }

  @override
  void dispose() {
    _productIDController.dispose();
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

  Future<void> _updateProduct() async {
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
      
      // Call the update product API with form data
      await inventoryService.addProduct(
        productName: _productNameController.text,
        price: _priceController.text,
        stockQuantity: _stockQuantityController.text,
        operation: "UPDATE", // Set operation to UPDATE for edit
        productID: _productIDController.text,
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
            content: Text('Product updated successfully!'),
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
            content: Text('Failed to update product: $e'),
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
      title: 'Edit Product',
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
                            color: Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.edit,
                            color: Colors.orange,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Edit Product',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2C3E50),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Editing: ${widget.product.productName}',
                                style: const TextStyle(
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        // Product ID Section (Read-only)
                        _buildSectionTitle('Product Information'),
                        const SizedBox(height: 16),
                        
                        _buildTextField(
                          controller: _productIDController,
                          label: 'Product ID',
                          hint: 'Product ID (Read-only)',
                          keyboardType: TextInputType.number,
                          isReadOnly: true,
                        ),
                        const SizedBox(height: 16),
                        
                        _buildTextField(
                          controller: _productNameController,
                          label: 'Product Name',
                          hint: 'Enter product name',
                          keyboardType: TextInputType.text,
                        ),
                        const SizedBox(height: 16),
                        
                        _buildTextField(
                          controller: _priceController,
                          label: 'Price',
                          hint: 'Enter price',
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 16),
                        
                        _buildTextField(
                          controller: _stockQuantityController,
                          label: 'Stock Quantity',
                          hint: 'Enter stock quantity',
                          keyboardType: TextInputType.number,
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
                        ),
                        const SizedBox(height: 16),
                        
                        _buildTextField(
                          controller: _shadeNameAndCodeController,
                          label: 'Shade Name and Code',
                          hint: 'Enter shade name and code',
                          keyboardType: TextInputType.text,
                        ),
                        const SizedBox(height: 16),
                        
                        _buildTextField(
                          controller: _packSizeController,
                          label: 'Pack Size',
                          hint: 'Enter pack size',
                          keyboardType: TextInputType.text,
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
                        ),
                        const SizedBox(height: 16),
                        
                        _buildTextField(
                          controller: _barCodeHarshitController,
                          label: 'Barcode (Harshit)',
                          hint: 'Enter Harshit barcode',
                          keyboardType: TextInputType.text,
                        ),
                        const SizedBox(height: 16),
                        
                        _buildTextField(
                          controller: _skuController,
                          label: 'SKU',
                          hint: 'Enter SKU',
                          keyboardType: TextInputType.text,
                        ),
                        const SizedBox(height: 16),
                        
                        _buildTextField(
                          controller: _barCode12DigitController,
                          label: 'Barcode (12 Digit)',
                          hint: 'Enter 12-digit barcode',
                          keyboardType: TextInputType.number,
                          maxLength: 12,
                        ),
                        const SizedBox(height: 16),
                        
                        _buildTextField(
                          controller: _totalNoOfDigitController,
                          label: 'Total No of Digits',
                          hint: 'Enter total number of digits',
                          keyboardType: TextInputType.number,
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
                        ),
                        const SizedBox(height: 32),
                        
                        // Submit Button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton.icon(
                            onPressed: _isLoading ? null : _updateProduct,
                            icon: _isLoading 
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : const Icon(Icons.save, size: 24),
                            label: Text(
                              _isLoading ? 'Updating Product...' : 'Update Product',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
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
    bool isReadOnly = false,
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
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLength: maxLength,
          readOnly: isReadOnly,
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
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            filled: true,
            fillColor: isReadOnly ? Colors.grey[100] : Colors.grey[50],
            counterText: maxLength != null ? null : '',
          ),
        ),
      ],
    );
  }
}
