import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:orangtre/Widgets/appbar.dart';
import 'package:orangtre/Widgets/customLoader.dart';
import 'package:orangtre/Widgets/drawer.dart';
import 'package:orangtre/model/updateSales_response.dart';
import 'package:orangtre/model/inventoryResponse.dart';
import 'package:orangtre/Services/update_Sale_services.dart';
import 'package:orangtre/Services/inventoryService.dart';
import 'package:orangtre/utils/auth_handler.dart';

class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  List<SaleData> sales = [];
  bool isLoading = true;
  String? errorMessage;
  DateTime? startDate;
  DateTime? endDate;

  @override
  void initState() {
    super.initState();
    _loadSalesData();
  }

  Future<void> _loadSalesData() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final service = UpdateSaleServices();
      
      // Format dates to YYYY-MM-DD if selected
      String fromDate = '';
      String toDate = '';
      
      if (startDate != null) {
        fromDate = '${startDate!.year}-${startDate!.month.toString().padLeft(2, '0')}-${startDate!.day.toString().padLeft(2, '0')}';
      }
      
      if (endDate != null) {
        toDate = '${endDate!.year}-${endDate!.month.toString().padLeft(2, '0')}-${endDate!.day.toString().padLeft(2, '0')}';
      }
      
      final response = await service.getUpdatedSalesList(
        fromDate: fromDate,
        toDate: toDate,
      );

      setState(() {
        sales = response.data;
        isLoading = false;
      });
    } catch (e) {
      // Don't show error if it's UnauthorizedException - user is already being logged out
      if (e is UnauthorizedException) {
        return;
      }

      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading sales: $e'),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: _loadSalesData,
            ),
          ),
        );
      }
    }
  }

  Future<void> _selectStartDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: startDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF2C3E50),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != startDate) {
      setState(() {
        startDate = picked;
      });
      _loadSalesData(); // Reload with new filter
    }
  }

  Future<void> _selectEndDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: endDate ?? DateTime.now(),
      firstDate: startDate ?? DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF2C3E50),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != endDate) {
      setState(() {
        endDate = picked;
      });
      _loadSalesData(); // Reload with new filter
    }
  }

  void _clearFilters() {
    setState(() {
      startDate = null;
      endDate = null;
    });
    _loadSalesData(); // Reload all data
  }

  void _showUploadSalesDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return _AddNewSaleDialog(
          onSave: (saleData) async {
            await _processSaleSave(saleData);
          },
        );
      },
    );
  }

  Future<void> _processSaleSave(Map<String, dynamic> saleData) async {
    try {
      final service = UpdateSaleServices();

      final quantity = saleData['quantity'] as double;
      final salePrice = saleData['salePrice'] as double;
      final discount = saleData['discount'] as double;

      await service.updateSales(
        stockId: saleData['stockId'].toString(),
        quantitySold: quantity.toInt().toString(),
        salePrice: salePrice.toStringAsFixed(0),
        discountPrice: discount.toStringAsFixed(0),
        paymentMethod: saleData['paymentMethod'] ?? 'Cash',
        saleDate: _formatDateForAPI(saleData['saleDate']),
        saleTime: _formatTimeForAPI(saleData['saleTime']),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sale saved successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
        // Reload sales data
        _loadSalesData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving sale: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  String _formatDateForAPI(String dateString) {
    // Convert DD/MM/YYYY to YYYY-MM-DD
    final parts = dateString.split('/');
    if (parts.length == 3) {
      return '${parts[2]}-${parts[1].padLeft(2, '0')}-${parts[0].padLeft(2, '0')}';
    }
    return dateString;
  }

  String _formatTimeForAPI(String timeString) {
    // Time is already in HH:MM format, just return as is
    return timeString;
  }

  String _formatDate(String dateString) {
    try {
      final dateTime = DateTime.parse(dateString);
      final day = dateTime.day.toString().padLeft(2, '0');
      final year = dateTime.year;

      const monthNames = [
        'January',
        'February',
        'March',
        'April',
        'May',
        'June',
        'July',
        'August',
        'September',
        'October',
        'November',
        'December'
      ];
      final monthName = monthNames[dateTime.month - 1];

      return '$day-$monthName-$year';
    } catch (e) {
      return dateString;
    }
  }

  void _showSaleDetails(SaleData sale) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            constraints: const BoxConstraints(maxHeight: 700, maxWidth: 500),
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
                        Icons.receipt_long,
                        color: Colors.white,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Sale #${sale.saleId}',
                          style: const TextStyle(
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
                        // Product Information
                        _buildSectionTitle('Product Information'),
                        _buildDetailRow('Product Name', sale.productName),
                        _buildDetailRow('Product ID', sale.productId.toString()),
                        _buildDetailRow(
                            'Product Price', '₹${sale.productPrice.toStringAsFixed(2)}'),

                        const SizedBox(height: 15),

                        // Sale Information
                        _buildSectionTitle('Sale Information'),
                        _buildDetailRow('Sale ID', sale.saleId.toString()),
                        _buildDetailRow('Quantity Sold', sale.quantitySold.toString()),
                        _buildDetailRow(
                            'Sale Price', '₹${sale.salePrice.toStringAsFixed(2)}'),
                        _buildDetailRow('Total Amount',
                            '₹${sale.totalSaleAmount.toStringAsFixed(2)}'),
                        _buildDetailRow(
                            'Net Amount', '₹${sale.netAmount.toStringAsFixed(2)}'),
                        if (sale.paymentMethod != null)
                          _buildDetailRow('Payment Method', sale.paymentMethod!),

                        const SizedBox(height: 15),

                        // Seller Information
                        _buildSectionTitle('Seller Information'),
                        _buildDetailRow('Sold By', sale.soldBy),
                        _buildDetailRow('User Role', sale.userRole),
                        _buildDetailRow('User ID', sale.userId.toString()),

                        const SizedBox(height: 15),

                        // Distributor Information
                        _buildSectionTitle('Distributor Information'),
                        _buildDetailRow('Distributor Name', sale.distributorName),
                        _buildDetailRow(
                            'Distributor ID', sale.distributorId.toString()),

                        const SizedBox(height: 15),

                        // Date Information
                        _buildSectionTitle('Date Information'),
                        _buildDetailRow('Sale Date', _formatDate(sale.saleDate)),
                        _buildDetailRow('Created Date', _formatDate(sale.createdDate)),

                        const SizedBox(height: 15),

                        // Additional Information
                        _buildSectionTitle('Additional Information'),
                        _buildDetailRow(
                            'Retailer Stock ID', sale.retailerStockId.toString()),
                        if (sale.discountAmount != null)
                          _buildDetailRow('Discount Amount', '₹${sale.discountAmount}'),
                        if (sale.discountPrice != null)
                          _buildDetailRow('Discount Price', '₹${sale.discountPrice}'),
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
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2C3E50),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Close',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Color(0xFF2C3E50),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
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

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      title: 'Sales',
      drawer: const OrangtreDrawer(),
      backgroundColor: Colors.grey[50],
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showUploadSalesDialog,
        backgroundColor: const Color(0xFF2C3E50),
        icon: const Icon(Icons.upload, color: Colors.white),
        label: const Text('Upload Sales', style: TextStyle(color: Colors.white)),
      ),
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
            // Date Filter Section
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: _selectStartDate,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today, color: Colors.white70, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    startDate != null
                                        ? '${startDate!.day.toString().padLeft(2, '0')}-${startDate!.month.toString().padLeft(2, '0')}-${startDate!.year}'
                                        : 'Start Date',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: InkWell(
                          onTap: _selectEndDate,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today, color: Colors.white70, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    endDate != null
                                        ? '${endDate!.day.toString().padLeft(2, '0')}-${endDate!.month.toString().padLeft(2, '0')}-${endDate!.year}'
                                        : 'End Date',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (startDate != null || endDate != null) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _clearFilters,
                        icon: const Icon(Icons.clear, size: 18),
                        label: const Text('Clear Filters'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.2),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            // Summary Cards
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: _buildSummaryCard(
                      'Total Sales',
                      sales.length.toString(),
                      Icons.receipt_long,
                      Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildSummaryCard(
                      'Total Amount',
                      '₹${sales.fold<double>(0, (sum, sale) => sum + sale.totalSaleAmount).toStringAsFixed(0)}',
                      Icons.currency_rupee,
                      Colors.green,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Sales List
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
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                           LoaderOverlay(),
                            SizedBox(height: 16),
                            Text(
                              'Loading sales...',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      )
                    : sales.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.receipt_long_outlined,
                                  size: 64,
                                  color: Colors.grey,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  errorMessage != null
                                      ? 'Error loading sales'
                                      : 'No sales found',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey,
                                  ),
                                ),
                                if (errorMessage != null) ...[
                                  const SizedBox(height: 16),
                                  ElevatedButton.icon(
                                    onPressed: _loadSalesData,
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
                            onRefresh: _loadSalesData,
                            color: const Color(0xFF2C3E50),
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: sales.length,
                              itemBuilder: (context, index) {
                                return _buildSaleCard(sales[index]);
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

  Widget _buildSaleCard(SaleData sale) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sale Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.receipt, color: Color(0xFF2C3E50)),
                    const SizedBox(width: 8),
                    Text(
                      'Sale #${sale.saleId}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    sale.userRole,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Sale Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Info
                Row(
                  children: [
                    const Icon(Icons.inventory_2, size: 20, color: Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        sale.productName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Quantity and Price
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Quantity',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          Text(
                            '${sale.quantitySold} units',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Sale Price',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          Text(
                            '₹${sale.salePrice.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Total Amount
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Amount',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '₹${sale.totalSaleAmount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Seller and Date
                Row(
                  children: [
                    const Icon(Icons.person, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        sale.soldBy,
                        style: const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      _formatDate(sale.saleDate),
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // View Details Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _showSaleDetails(sale);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF2C3E50),
                      side: const BorderSide(color: Color(0xFF2C3E50)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.visibility, size: 18),
                        SizedBox(width: 8),
                        Text('View Details'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AddNewSaleDialog extends StatefulWidget {
  final Function(Map<String, dynamic>) onSave;

  const _AddNewSaleDialog({required this.onSave});

  @override
  State<_AddNewSaleDialog> createState() => _AddNewSaleDialogState();
}

class _AddNewSaleDialogState extends State<_AddNewSaleDialog> {
  final _formKey = GlobalKey<FormState>();
  final _saleDateController = TextEditingController();
  final _saleTimeController = TextEditingController();
  final _quantityController = TextEditingController();
  final _discountController = TextEditingController();
  final _customerNameController = TextEditingController();
  final _notesController = TextEditingController();
  final _unitPriceController = TextEditingController();
  final _totalPriceController = TextEditingController();
  final _salePriceController = TextEditingController();

  String? _selectedProduct;
  String? _selectedPaymentMethod;
  double _unitPrice = 0.0;
  double _totalPrice = 0.0;
  double _salePrice = 0.0;
  bool _isLoadingProducts = true;
  List<Product> _products = [];

  final List<String> _paymentMethods = [
    'Cash',
    'Credit Card',
    'Debit Card',
    'UPI',
    'Net Banking',
    'Wallet',
  ];

  @override
  void initState() {
    super.initState();
    _saleDateController.text = _formatDate(DateTime.now());
    _saleTimeController.text = _formatTime(DateTime.now());
    
    // Listen to quantity and discount changes for auto-calculation
    _quantityController.addListener(_calculateAmounts);
    _discountController.addListener(_calculateAmounts);
    
    // Initialize computed fields
    _unitPriceController.text = '';
    _totalPriceController.text = '';
    _salePriceController.text = '';

    // Load products from inventory
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      final inventoryService = Inventoryservice();
      final response = await inventoryService.inventory();
      
      setState(() {
        _products = response.data;
        _isLoadingProducts = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingProducts = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading products: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _saleDateController.dispose();
    _saleTimeController.dispose();
    _quantityController.dispose();
    _discountController.dispose();
    _customerNameController.dispose();
    _notesController.dispose();
    _unitPriceController.dispose();
    _totalPriceController.dispose();
    _salePriceController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  void _calculateAmounts() {
    print('=== CALCULATING AMOUNTS ===');
    print('Selected Product ID: $_selectedProduct');
    print('Products count: ${_products.length}');
    
    if (_products.isNotEmpty) {
      print('Available products:');
      for (var product in _products) {
        print('  - ID: ${product.productID}, Name: ${product.productName}, Price: ${product.price}');
      }
    }
    
    if (_selectedProduct != null && _products.isNotEmpty) {
      try {
        final product = _products.firstWhere((p) => p.productID.toString() == _selectedProduct);
        print('✅ Found product: ${product.productName}');
        print('✅ Product Price: ${product.price}');
        print('✅ Product ID: ${product.productID}');
        
        _unitPrice = product.price;
        print('✅ Unit Price set to: $_unitPrice');
        
        if (_quantityController.text.isNotEmpty) {
          final quantity = double.tryParse(_quantityController.text) ?? 0;
          final discount = double.tryParse(_discountController.text) ?? 0;
          
          _totalPrice = _unitPrice * quantity;
          _salePrice = _totalPrice - (_totalPrice * discount / 100);
          
          print('With quantity: Unit Price: $_unitPrice, Total: $_totalPrice, Sale: $_salePrice');
        } else {
          _totalPrice = 0.0;
          _salePrice = 0.0;
          print('No quantity - Unit Price: $_unitPrice, Total: $_totalPrice, Sale: $_salePrice');
        }
        
        // Reflect computed values in the read-only fields
        _unitPriceController.text = _unitPrice > 0 ? _unitPrice.toStringAsFixed(2) : '';
        _totalPriceController.text = _totalPrice > 0 ? _totalPrice.toStringAsFixed(2) : '';
        _salePriceController.text = _salePrice > 0 ? _salePrice.toStringAsFixed(2) : '';

        setState(() {});
        print('✅ setState() called');
      } catch (e) {
        print('❌ Error finding product: $e');
        _unitPrice = 0.0;
        _totalPrice = 0.0;
        _salePrice = 0.0;
        _unitPriceController.text = '';
        _totalPriceController.text = '';
        _salePriceController.text = '';
        setState(() {});
      }
    } else {
      print('❌ No product selected or products not loaded');
    }
    print('=== END CALCULATION ===\n');
  }

  void _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _saleDateController.text = _formatDate(picked);
      });
    }
  }

  void _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _saleTimeController.text = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      });
    }
  }

  String? _onProductChanged(String? value) {
    print('Product selected: $value');
    setState(() {
      _selectedProduct = value;
      // Reset calculations when product changes
      _totalPrice = 0.0;
      _salePrice = 0.0;
    });
    // Clear shown values until recalculated
    _unitPriceController.text = '';
    _totalPriceController.text = '';
    _salePriceController.text = '';
    _calculateAmounts();
    return value;
  }

  Widget _buildResponsiveRow(List<Widget> children) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
    
    if (isSmallScreen) {
      // On small screens, stack widgets vertically
      return Column(
        children: children.map((child) => Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: child,
        )).toList(),
      );
    } else {
      // On larger screens, use horizontal layout
      return Row(
        children: [
          Expanded(child: children[0]),
          const SizedBox(width: 16),
          Expanded(child: children[1]),
        ],
      );
    }
  }

  Widget _buildResponsiveButtons() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
    
    final cancelButton = TextButton(
      onPressed: () => Navigator.pop(context),
      style: TextButton.styleFrom(
        foregroundColor: Colors.grey[600],
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.close, size: 18),
          SizedBox(width: 8),
          Text('Cancel'),
        ],
      ),
    );
    
    final saveButton = ElevatedButton(
      onPressed: () {
        if (_formKey.currentState!.validate() && _selectedProduct != null) {
          final selectedProduct = _products.firstWhere((p) => p.productID.toString() == _selectedProduct);
          final saleData = {
            'saleDate': _saleDateController.text,
            'saleTime': _saleTimeController.text,
            'stockId': selectedProduct.productID.toString(), // Using productID as stockId
            'productId': _selectedProduct,
            'productName': selectedProduct.productName,
            'quantity': double.parse(_quantityController.text),
            'unitPrice': _unitPrice,
            'totalPrice': _totalPrice,
            'salePrice': _salePrice, // This is the final amount after discount
            'discount': double.tryParse(_discountController.text) ?? 0,
            'customerName': _customerNameController.text,
            'paymentMethod': _selectedPaymentMethod ?? 'Cash',
            'notes': _notesController.text,
          };
          widget.onSave(saleData);
          Navigator.pop(context);
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF2C3E50),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.save, size: 18),
          SizedBox(width: 8),
          Text('Save Sale'),
        ],
      ),
    );
    
    if (isSmallScreen) {
      // On small screens, stack buttons vertically
      return Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: saveButton,
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: cancelButton,
          ),
        ],
      );
    } else {
      // On larger screens, use horizontal layout
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          cancelButton,
          const SizedBox(width: 16),
          saveButton,
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenWidth < 600;
    
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: isSmallScreen ? screenWidth * 0.98 : screenWidth * 0.95,
        height: screenHeight * 0.9,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFF2C3E50),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.shopping_cart, color: Colors.white, size: 24),
                  const SizedBox(width: 12),
                  const Text(
                    'Add New Sale',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),
            // Form Content
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Sale Date and Time Row
                        _buildResponsiveRow([
                          _buildTextField(
                            controller: _saleDateController,
                            label: 'Sale Date',
                            isRequired: true,
                            readOnly: true,
                            onTap: _selectDate,
                            suffixIcon: Icons.calendar_today,
                          ),
                          _buildTextField(
                            controller: _saleTimeController,
                            label: 'Sale Time',
                            readOnly: true,
                            onTap: _selectTime,
                            suffixIcon: Icons.access_time,
                          ),
                        ]),
                        const SizedBox(height: 20),
                        
                        // Product Selection and Quantity Row
                        _buildResponsiveRow([
                          _isLoadingProducts 
                            ? _buildTextField(
                                label: 'Select Product',
                                readOnly: true,
                                value: 'Loading products...',
                              )
                            : _buildDropdownField(
                                label: 'Select Product',
                                isRequired: true,
                                value: _selectedProduct,
                                items: _products.map((product) => DropdownMenuItem<String>(
                                  value: product.productID.toString(),
                                  child: Text(product.productName),
                                )).toList(),
                                onChanged: _onProductChanged,
                                suffixIcon: Icons.keyboard_arrow_down,
                              ),
                          _buildTextField(
                            controller: _quantityController,
                            label: '# Quantity',
                            isRequired: true,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            suffixText: 'units',
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                            ],
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Required';
                              }
                              if (double.tryParse(value) == null || double.parse(value) <= 0) {
                                return 'Invalid quantity';
                              }
                              return null;
                            },
                          ),
                        ]),
                        const SizedBox(height: 20),
                        
                        // Price Row
                        _buildResponsiveRow([
                          _buildTextField(
                            label: 'Unit Price',
                            controller: _unitPriceController,
                            readOnly: true,
                            prefixText: '₹',
                          ),
                          _buildTextField(
                            label: 'Total Price',
                            controller: _totalPriceController,
                            readOnly: true,
                            prefixText: '₹',
                          ),
                        ]),
                        const SizedBox(height: 20),
                        
                        // Discount Row
                        _buildResponsiveRow([
                          _buildTextField(
                            controller: _discountController,
                            label: '% Discount %',
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            suffixText: '%',
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                            ],
                            validator: (value) {
                              if (value != null && value.isNotEmpty) {
                                final discount = double.tryParse(value);
                                if (discount == null || discount < 0 || discount > 100) {
                                  return 'Invalid discount';
                                }
                              }
                              return null;
                            },
                          ),
                          _buildTextField(
                            label: 'Sale Price (Final)',
                            controller: _salePriceController,
                            readOnly: true,
                            prefixText: '₹',
                            isProminent: true,
                          ),
                        ]),
                        const SizedBox(height: 20),
                        
                        // Customer Name and Payment Method Row
                        _buildResponsiveRow([
                          _buildTextField(
                            controller: _customerNameController,
                            label: 'Customer Name',
                          ),
                          _buildDropdownField(
                            label: 'Payment Method',
                            value: _selectedPaymentMethod,
                            items: _paymentMethods.map((method) => DropdownMenuItem<String>(
                              value: method,
                              child: Text(method),
                            )).toList(),
                            onChanged: (value) {
                              setState(() => _selectedPaymentMethod = value);
                              return value;
                            },
                            suffixIcon: Icons.keyboard_arrow_down,
                          ),
                        ]),
                        const SizedBox(height: 20),
                        
                        // Notes Field
                        _buildTextField(
                          controller: _notesController,
                          label: 'Notes (Optional)',
                          maxLines: 3,
                          hintText: 'Add any notes about this sale...',
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Footer Buttons
            Container(
              padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: _buildResponsiveButtons(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    TextEditingController? controller,
    String? value,
    String? hintText,
    bool isRequired = false,
    bool readOnly = false,
    TextInputType? keyboardType,
    String? suffixText,
    String? prefixText,
    IconData? suffixIcon,
    int maxLines = 1,
    String? Function(String?)? validator,
    VoidCallback? onTap,
    bool isProminent = false,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            children: [
              if (isRequired)
                const TextSpan(
                  text: ' *',
                  style: TextStyle(color: Colors.red),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          initialValue: value,
          readOnly: readOnly,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
          onTap: onTap,
          inputFormatters: inputFormatters,
          style: TextStyle(
            fontSize: isProminent ? 16 : 14,
            fontWeight: isProminent ? FontWeight.bold : FontWeight.normal,
            color: isProminent ? const Color(0xFF2C3E50) : Colors.black87,
          ),
          decoration: InputDecoration(
            hintText: hintText ?? (readOnly ? null : 'Enter ${label.toLowerCase()}'),
            prefixText: prefixText,
            suffixText: suffixText,
            suffixIcon: suffixIcon != null ? Icon(suffixIcon, size: 20) : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF2C3E50), width: 2),
            ),
            filled: true,
            fillColor: readOnly ? Colors.grey[100] : Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required String? Function(String?)? onChanged,
    IconData? suffixIcon,
    bool isRequired = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            children: [
              if (isRequired)
                const TextSpan(
                  text: ' *',
                  style: TextStyle(color: Colors.red),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          items: items,
          onChanged: onChanged,
          isExpanded: true, // Make dropdown expand to fill available width
          validator: isRequired ? (value) {
            if (value == null || value.isEmpty) {
              return 'Required';
            }
            return null;
          } : null,
          decoration: InputDecoration(
            hintText: 'Choose ${label.toLowerCase()}...',
            suffixIcon: suffixIcon != null ? Icon(suffixIcon, size: 20) : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF2C3E50), width: 2),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
        ),
      ],
    );
  }
}

