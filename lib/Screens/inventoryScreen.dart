import 'package:flutter/material.dart';
import '../Widgets/appbar.dart';
import '../Widgets/customLoader.dart';
import '../Widgets/drawer.dart';
import '../model/inventoryResponse.dart';
import '../Services/inventoryService.dart';
import '../StoredData/LoginData.dart';
import '../utils/auth_handler.dart';
import 'addProductScreen.dart';
import 'editProductScreen.dart';

class Inventoryscreen extends StatefulWidget {
  const Inventoryscreen({super.key});

  @override
  State<Inventoryscreen> createState() => _InventoryscreenState();
}

class _InventoryscreenState extends State<Inventoryscreen> {
  List<Product> products = [];
  List<Product> filteredProducts = [];
  bool isLoading = true;
  String? errorMessage;
  bool isAdmin = false; // Will be set based on user type
  final TextEditingController _searchController = TextEditingController();
  bool isSearching = false;
  bool isSelectionMode = false;
  Product? selectedProduct;

  @override
  void initState() {
    super.initState();
    _loadInventoryData();
    _checkAdminStatus();
    _searchController.addListener(_filterProducts);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _checkAdminStatus() async {
    final loginResponse = await LoginStorage.getLoginResponse();
    final userType = loginResponse?.userData.userType ?? '';
    
    setState(() {
      isAdmin = userType == 'A'; // 'A' means Admin
    });
  }

  void _filterProducts() {
    final query = _searchController.text.toLowerCase();
    
    setState(() {
      if (query.isEmpty) {
        filteredProducts = products;
        isSearching = false;
      } else {
        isSearching = true;
        filteredProducts = products.where((product) {
          return product.productName.toLowerCase().contains(query) ||
              product.productID.toString().contains(query) ||
              (product.sku?.toString().toLowerCase().contains(query) ?? false) ||
              (product.productGroup?.toString().toLowerCase().contains(query) ?? false) ||
              product.price.toString().contains(query);
        }).toList();
      }
    });
  }

  Future<void> _loadInventoryData() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      // Fetch data directly from API
      final inventoryService = Inventoryservice();
      final data = await inventoryService.inventory();
      
      // Update UI with data
      setState(() {
        products = data.data;
        filteredProducts = data.data;
        isLoading = false;
      });
    } catch (e) {
      // Don't show error if it's UnauthorizedException - user is already being logged out
      if (e is UnauthorizedException) {
        // User is being logged out automatically, no need to show error
        return;
      }

      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });

      // Show error message for other errors
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading inventory: $e'),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: _loadInventoryData,
            ),
          ),
        );
      }
    }
  }

  void _showAddMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Menu title
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Text(
                  'Add New',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
              ),
              const Divider(),
              // Menu items
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.inventory_2,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                title: const Text(
                  'Add Product',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                subtitle: const Text(
                  'Add a new product to inventory',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                onTap: () {
                  Navigator.pop(context);
                  // Navigate to Add Product screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddProductScreen(),
                    ),
                  ).then((refreshNeeded) {
                    // Refresh inventory if a product was added
                    if (refreshNeeded == true) {
                      _loadInventoryData();
                    }
                  });
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.add_circle_outline,
                    color: Colors.green,
                  ),
                ),
                title: const Text(
                  'Add Stock',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                subtitle: const Text(
                  'Add Stock of Product',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    isSelectionMode = true;
                    selectedProduct = null;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Select a product to add stock'),
                      backgroundColor: Colors.green,
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void _showProductDetails(BuildContext context, Product product) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            constraints: const BoxConstraints(maxHeight: 600),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Color(0xFF2C3E50),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.inventory_2,
                        color: Colors.white,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Product Details',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                // Content
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Product Image
                        Center(
                          child: Container(
                            width: 150,
                            height: 150,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: product.productImageDriveLink != null &&
                                    product.productImageDriveLink
                                        .toString()
                                        .isNotEmpty
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(15),
                                    child: Image.network(
                                      product.productImageDriveLink.toString(),
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return const Icon(
                                          Icons.image,
                                          size: 64,
                                          color: Colors.grey,
                                        );
                                      },
                                    ),
                                  )
                                : const Icon(
                                    Icons.image,
                                    size: 64,
                                    color: Colors.grey,
                                  ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Product Name
                        Center(
                          child: Text(
                            product.productName,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2C3E50),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Divider(),
                        const SizedBox(height: 10),
                        // Details List
                        _buildDetailRow('Product ID', product.productID.toString()),
                        _buildDetailRow('Code', product.code.toString()),
                        _buildDetailRow('Price', '₹${product.price.toStringAsFixed(2)}'),
                        if (product.mrp != null && product.mrp.toString().isNotEmpty)
                          _buildDetailRow('MRP', '₹${product.mrp}'),
                        _buildDetailRow('Stock', '${product.stock} units'),
                        _buildDetailRow('Stock Status', product.stockStatus),
                        _buildDetailRow('Status', product.statusText),
                        if (product.sku != null && product.sku.toString().isNotEmpty)
                          _buildDetailRow('SKU', product.sku.toString()),
                        if (product.productGroup != null &&
                            product.productGroup.toString().isNotEmpty)
                          _buildDetailRow('Product Group', product.productGroup.toString()),
                        if (product.shadeNameAndShade != null &&
                            product.shadeNameAndShade.toString().isNotEmpty)
                          _buildDetailRow('Shade', product.shadeNameAndShade.toString()),
                        if (product.packSize != null &&
                            product.packSize.toString().isNotEmpty)
                          _buildDetailRow('Pack Size', product.packSize.toString()),
                        if (product.fixedBar5Digit != null &&
                            product.fixedBar5Digit.toString().isNotEmpty)
                          _buildDetailRow('Fixed Bar (5 Digit)', product.fixedBar5Digit.toString()),
                        if (product.barCodeHarshit != null &&
                            product.barCodeHarshit.toString().isNotEmpty)
                          _buildDetailRow('Barcode (Harshit)', product.barCodeHarshit.toString()),
                        if (product.barCode12Digit != null &&
                            product.barCode12Digit.toString().isNotEmpty)
                          _buildDetailRow('Barcode (12 Digit)', product.barCode12Digit.toString()),
                        if (product.totalNoOfDigit != null &&
                            product.totalNoOfDigit.toString().isNotEmpty)
                          _buildDetailRow('Total Digits', product.totalNoOfDigit.toString()),
                        
                      ],
                    ),
                  ),
                ),
                // Footer
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            // TODO: Implement edit functionality
                          },
                          icon: const Icon(Icons.edit),
                          label: const Text('Edit Product'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2C3E50),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }


void _addProduct(Product product) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return _AddStockDialog(
          product: product,
          onAddStock: (qty) async {
            await _processAddStock(product.productID, qty);
          },
        );
      },
    );
  }

  Future<void> _processAddStock(int productID, String qty) async {
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: Color(0xFF2C3E50)),
                  SizedBox(height: 16),
                  Text('Adding stock...'),
                ],
              ),
            ),
          ),
        );
      },
    );

    try {
      final inventoryService = Inventoryservice();
      await inventoryService.addStock(
        productID: productID.toString(),
        qty: qty,
      );

      if (mounted) {
        Navigator.pop(context); // Close loading
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Stock added successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        // Reload inventory
        _loadInventoryData();
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      title: 'Inventory',
      drawer: const OrangtreDrawer(),
      backgroundColor: Colors.grey[50],
      floatingActionButton: isAdmin ? FloatingActionButton(
        onPressed: () {
          _showAddMenu(context);
        },
        backgroundColor: const Color(0xFF2C3E50),
        child: const Icon(Icons.add, color: Colors.white),
      ) : null,
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
            // Selection Mode Banner
            if (isSelectionMode)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.green,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.touch_app, color: Colors.white),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Tap a product to add stock',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () {
                        setState(() {
                          isSelectionMode = false;
                          selectedProduct = null;
                        });
                      },
                    ),
                  ],
                ),
              ),
            // Search Bar
            Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search products...',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  prefixIcon: const Icon(Icons.search, color: Colors.white70),
                  suffixIcon: isSearching
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.white70),
                          onPressed: () {
                            _searchController.clear();
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.2),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.white, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
                style: const TextStyle(color: Colors.white),
              ),
            ),
            // Summary Cards
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: _buildSummaryCard(
                      isSearching ? 'Found' : 'Total ',
                      filteredProducts.length.toString(),
                      Icons.inventory,
                      Colors.green,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildSummaryCard(
                      'In Stock',
                      filteredProducts.where((p) => p.stock > 0).length.toString(),
                      Icons.check_circle,
                      Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildSummaryCard(
                      'Out of Stock',
                      filteredProducts.where((p) => p.stock == 0).length.toString(),
                      Icons.cancel,
                      Colors.red,
                    ),
                  ),
                ],
              ),
            ),
            // Products List
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: isLoading
                    ?  const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            LoaderOverlay(),
                            SizedBox(height: 16),
                            Text(
                              'Loading inventory...',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      )
                    : filteredProducts.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              isSearching ? Icons.search_off : Icons.inventory_2_outlined,
                              size: 64,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              errorMessage != null
                                  ? 'Error loading products'
                                  : isSearching
                                      ? 'No products found matching "${_searchController.text}"'
                                      : 'No products found',
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            if (errorMessage != null) ...[
                              const SizedBox(height: 8),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32,
                                ),
                                child: Text(
                                  errorMessage!,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: _loadInventoryData,
                                icon: const Icon(Icons.refresh),
                                label: const Text('Retry'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF2C3E50),
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ],
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadInventoryData,
                        color: const Color(0xFF2C3E50),
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: filteredProducts.length,
                          itemBuilder: (context, index) {
                            return _buildProductCard(filteredProducts[index]);
                          },
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    final isSelected = isSelectionMode && selectedProduct?.productID == product.productID;
    
    return GestureDetector(
      onTap: isSelectionMode
          ? () {
              setState(() {
                selectedProduct = product;
              });
              // Show add stock dialog immediately after selection
              _addProduct(product);
              // Exit selection mode
              setState(() {
                isSelectionMode = false;
                selectedProduct = null;
              });
            }
          : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: isSelected
              ? Border.all(color: Colors.green, width: 3)
              : null,
          boxShadow: [
            BoxShadow(
              color: isSelected 
                  ? Colors.green.withOpacity(0.3)
                  : Colors.black.withOpacity(0.1),
              blurRadius: isSelected ? 15 : 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image and Basic Info
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Image
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child:
                      product.productImageDriveLink != null &&
                          product.productImageDriveLink.toString().isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            product.productImageDriveLink.toString(),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.image,
                                size: 32,
                                color: Colors.grey,
                              );
                            },
                          ),
                        )
                      : const Icon(Icons.image, size: 32, color: Colors.grey),
                ),
                const SizedBox(width: 16),
                // Product Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.productName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            '₹${product.price.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2C3E50),
                            ),
                          ),
                          if (product.mrp != null &&
                              product.mrp.toString().isNotEmpty) ...[
                            const SizedBox(width: 8),
                            Text(
                              '₹${product.mrp}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: product.stock > 0
                                  ? Colors.green[100]
                                  : Colors.red[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              product.stockStatus,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: product.stock > 0
                                    ? Colors.green[700]
                                    : Colors.red[700],
                              ),
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: product.status
                                  ? Colors.blue[100]
                                  : Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              product.statusText,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: product.status
                                    ? Colors.blue[700]
                                    : Colors.grey[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Additional Details
          Container(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: [
                // Stock Information
                Row(
                  children: [
                    const Icon(Icons.inventory, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(
                      'Stock: ${product.stock} units',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    if (product.sku != null &&
                        product.sku.toString().isNotEmpty) ...[
                      const Spacer(),
                      const Icon(Icons.qr_code, size: 16, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text(
                        'SKU: ${product.sku}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ],
                ),
                if (product.productGroup != null &&
                    product.productGroup.toString().isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.category, size: 16, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text(
                        'Group: ${product.productGroup}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
                if (product.packSize != null &&
                    product.packSize.toString().isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.scale, size: 16, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text(
                        'Pack Size: ${product.packSize}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
                // Action Buttons
                const SizedBox(height: 12),
                if (isAdmin) ...[
                  // Admin buttons: Add Product
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            _addProduct(product);
                          },
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text('Add Stock'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:  Color(0xFF2C3E50),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      
                      
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Additional View and Edit buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            _showProductDetails(context, product);
                          },
                          icon: const Icon(Icons.visibility, size: 16),
                          label: const Text('View'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF2C3E50),
                            side: const BorderSide(color: Color(0xFF2C3E50)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditProductScreen(product: product),
                              ),
                            ).then((refreshNeeded) {
                              // Refresh inventory if product was updated
                              if (refreshNeeded == true) {
                                _loadInventoryData();
                              }
                            });
                          },
                          icon: const Icon(Icons.edit, size: 16),
                          label: const Text('Edit'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.grey[700],
                            side: BorderSide(color: Colors.grey[400]!),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  // Non-admin buttons: View only
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            _showProductDetails(context, product);
                          },
                          icon: const Icon(Icons.visibility, size: 16),
                          label: const Text('View'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF2C3E50),
                            side: const BorderSide(color: Color(0xFF2C3E50)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }
}

// Add Stock Dialog Widget
class _AddStockDialog extends StatefulWidget {
  final Product product;
  final Function(String) onAddStock;

  const _AddStockDialog({
    required this.product,
    required this.onAddStock,
  });

  @override
  State<_AddStockDialog> createState() => _AddStockDialogState();
}

class _AddStockDialogState extends State<_AddStockDialog> {
  final TextEditingController _qtyController = TextEditingController();

  @override
  void dispose() {
    _qtyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: Row(
        children: [
          const Icon(Icons.add_shopping_cart, color: Colors.green, size: 28),
          const SizedBox(width: 12),
          const Text('Add Stock'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Add stock quantity for:',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.product.productName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text('Product ID: ${widget.product.productID}'),
                  Text('Current Stock: ${widget.product.stock} units'),
                  Text('Price: ₹${widget.product.price.toStringAsFixed(2)}'),
                ],
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _qtyController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Quantity to Add *',
                hintText: 'Enter quantity...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.format_list_numbered),
                helperText: 'Required',
                helperStyle: TextStyle(color: Colors.green),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            final qty = _qtyController.text.trim();
            
            if (qty.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please enter quantity'),
                  backgroundColor: Colors.red,
                ),
              );
              return;
            }

            // Validate if it's a valid number
            if (int.tryParse(qty) == null || int.parse(qty) <= 0) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please enter a valid positive number'),
                  backgroundColor: Colors.red,
                ),
              );
              return;
            }
            
            Navigator.pop(context);
            await widget.onAddStock(qty);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
          child: const Text('Add Stock'),
        ),
      ],
    );
  }
}
