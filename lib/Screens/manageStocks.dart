import 'package:flutter/material.dart';
import 'package:orangtre/Widgets/appbar.dart';
import 'package:orangtre/Widgets/customLoader.dart';
import 'package:orangtre/Widgets/drawer.dart';
import 'package:orangtre/model/manage_Stock_request_response.dart';
import 'package:orangtre/Services/manageStock_request.dart';
import 'package:orangtre/utils/auth_handler.dart';
import 'package:orangtre/StoredData/LoginData.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:orangtre/utils/convert_base64.dart';

class Managestocks extends StatefulWidget {
  const Managestocks({super.key});

  @override
  State<Managestocks> createState() => _ManagestocksState();
}

class _ManagestocksState extends State<Managestocks>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      title: "Manage Stocks",
      drawer: const OrangtreDrawer(),
      body: Stack(
        children: [
          // Tab Bar View with swipeable screens
          TabBarView(
            controller: _tabController,
            children: const [
              RequestScreen(),
              TransferScreen(),
            ],
          ),
          // Floating Bottom Tab Bar Navigation
          Positioned(
            left: 20,
            right: 20,
            bottom: 20,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: TabBar(
                  controller: _tabController,
                  labelColor: const Color(0xFF2C3E50),
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: const Color(0xFF2C3E50),
                  indicatorWeight: 3,
                  indicatorSize: TabBarIndicatorSize.tab,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  tabs: const [
                    Tab(
                      icon: Icon(Icons.inbox, size: 28),
                      text: 'Request',
                    ),
                    Tab(
                      icon: Icon(Icons.swap_horiz, size: 28),
                      text: 'Transfer',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Request Screen
class RequestScreen extends StatefulWidget {
  const RequestScreen({super.key});

  @override
  State<RequestScreen> createState() => _RequestScreenState();
}

class _RequestScreenState extends State<RequestScreen> {
  List<StockRequest> requests = [];
  List<StockRequest> filteredRequests = [];
  bool isLoading = true;
  String? errorMessage;
  String loggedInUserType = '';
  final TextEditingController _searchController = TextEditingController();
  bool isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadUserType();
    _loadStockRequests();
    _searchController.addListener(_filterRequests);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUserType() async {
    final loginResponse = await LoginStorage.getLoginResponse();
    setState(() {
      loggedInUserType = loginResponse?.userData.userType ?? '';
    });
  }

  void _filterRequests() {
    final query = _searchController.text.toLowerCase();

    setState(() {
      if (query.isEmpty) {
        filteredRequests = requests;
        isSearching = false;
      } else {
        isSearching = true;
        filteredRequests = requests.where((request) {
          return request.productName.toLowerCase().contains(query) ||
              request.requestId.toString().contains(query) ||
              request.requesterName.toLowerCase().contains(query) ||
              request.requestedToUserName.toLowerCase().contains(query) ||
              request.status.toLowerCase().contains(query) ||
              request.requestType.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  Future<void> _loadStockRequests() async {
    setState (() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final service = ManagestockRequest();
      final response = await service.getStockRequests();

      setState(() {
        requests = response.data;
        filteredRequests = response.data;
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
            content: Text('Error loading requests: $e'),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: _loadStockRequests,
            ),
          ),
        );
      }
    }
  }

  void _showRequestDetails(BuildContext context, StockRequest request) {
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
                          'Request #${request.requestId}',
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
                        // Status Badge
                        Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor(request.status).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(
                                color: _getStatusColor(request.status),
                                width: 2,
                              ),
                            ),
                            child: Text(
                              request.status.toUpperCase(),
                              style: TextStyle(
                                color: _getStatusColor(request.status),
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Divider(),
                        const SizedBox(height: 10),

                        // Product Information
                        _buildSectionTitle('Product Information'),
                        _buildDetailRow('Product Name', request.productName),
                        _buildDetailRow('Product ID', request.productId.toString()),
                        _buildDetailRow('Quantity', request.quantity.toString()),

                        const SizedBox(height: 15),

                        // Request Information
                        _buildSectionTitle('Request Information'),
                        _buildDetailRow('Request Type', request.requestType),
                        _buildDetailRow('Request ID', request.requestId.toString()),
                        _buildDetailRow('Requested At', request.formattedRequestedAt),

                        const SizedBox(height: 15),

                        // User Information
                        _buildSectionTitle('User Information'),
                        _buildDetailRow('Requested By', request.requesterName),
                        _buildDetailRow('Requested To', request.requestedToUserName),
                        _buildDetailRow('Requested To User ID', request.requestedToUserId.toString()),

                        const SizedBox(height: 15),

                        // Additional Information
                        _buildSectionTitle('Additional Information'),
                        _buildDetailRow('Distributor ID', request.distributorId.toString()),
                        if (request.retailerId != null && request.retailerId.toString().isNotEmpty)
                          _buildDetailRow('Retailer ID', request.retailerId.toString()),

                        // Approval/Rejection Information
                        if (request.isApproved) ...[
                          const SizedBox(height: 15),
                          _buildSectionTitle('Approval Information'),
                          if (request.approvedAt != null && request.approvedAt.toString().isNotEmpty)
                            _buildDetailRow('Approved At', _formatDate(request.approvedAt.toString())),
                        ],

                        if (request.isRejected) ...[
                          const SizedBox(height: 15),
                          _buildSectionTitle('Rejection Information'),
                          if (request.rejectedAt != null && request.rejectedAt.toString().isNotEmpty)
                            _buildDetailRow('Rejected At', _formatDate(request.rejectedAt.toString())),
                          if (request.rejectionReason != null && request.rejectionReason.toString().isNotEmpty)
                            _buildDetailRow('Rejection Reason', request.displayRejectionReason, isHighlight: true),
                        ],
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

  Widget _buildDetailRow(String label, String value, {bool isHighlight = false}) {
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
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isHighlight ? Colors.red : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(String dateString) {
    try {
      final dateTime = DateTime.parse(dateString);
      final day = dateTime.day.toString().padLeft(2, '0');
      final year = dateTime.year;

      const monthNames = [
        'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December'
      ];
      final monthName = monthNames[dateTime.month - 1];

      return '$day-$monthName-$year';
    } catch (e) {
      return dateString;
    }
  }

  void _showApproveDialog(BuildContext context, StockRequest request) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return _RequestFormDialog(
          request: request,
          action: 'APPROVE',
          onSubmit: (remarks, approvedQuantity, attachmentFile) async {
            await _processRequest(
              'Approve',
              request.requestId,
              remarks,
              approvedQuantity: approvedQuantity,
              attachmentFileBase64: attachmentFile,
            );
          },
        );
      },
    );
  }

  void _showRejectDialog(BuildContext context, StockRequest request) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return _RequestFormDialog(
          request: request,
          action: 'REJECT',
          onSubmit: (remarks, approvedQuantity, attachmentFile) async {
            await _processRequest(
              'Reject',
              request.requestId,
              remarks,
              approvedQuantity: approvedQuantity,
              attachmentFileBase64: attachmentFile,
            );
          },
        );
      },
    );
  }

  Future<void> _processRequest(
    String action,
    int requestId,
    String remarks, {
    int? approvedQuantity,
    String? attachmentFileBase64,
  }) async {
    print('🔄 Processing request with action: $action, requestId: $requestId');

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
                  Text('Processing request...'),
                ],
              ),
            ),
          ),
        );
      },
    );

    try {
      final service = ManagestockRequest();
      await service.acceptOrRejectRequest(
        action: action,
        requestId: requestId,
        approvalNotes: remarks,
        approvedQuantity: approvedQuantity,
        attachmentFileBase64: attachmentFileBase64,
      );

      print('✅ Request processed successfully with action: $action');

      if (mounted) {
        Navigator.pop(context); // Close loading

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              action == 'Approve'
                  ? 'Request approved successfully!'
                  : 'Request rejected successfully!',
            ),
            backgroundColor: action == 'Approve' ? Colors.green : Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );

        // Reload requests
        _loadStockRequests();
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
    return Container(
      color: Colors.grey[100],
      child: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: const Color(0xfff5f5f5),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search requests...',
                prefixIcon: const Icon(Icons.search, color: Color(0xFF2C3E50)),
                suffixIcon: isSearching
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                  },
                )
                    : null,
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF2C3E50), width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          // Results
          Expanded(
            child: isLoading
                ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  LoaderOverlay(),
                  SizedBox(height: 16),
                  Text(
                    'Loading requests...',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            )
                : filteredRequests.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.inbox_outlined,
                    size: 80,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    errorMessage != null
                        ? 'Error loading requests'
                        : isSearching
                        ? 'No requests found matching "${_searchController.text}"'
                        : 'No requests found',
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (errorMessage != null) ...[
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _loadStockRequests,
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
              onRefresh: _loadStockRequests,
              color: const Color(0xFF2C3E50),
              child: ListView.builder(
                padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 100),
                itemCount: filteredRequests.length,
                itemBuilder: (context, index) {
                  return RequestCard(
                    request: filteredRequests[index],
                    loggedInUserType: loggedInUserType,
                    onApprove: () {
                      _showApproveDialog(context, filteredRequests[index]);
                    },
                    onReject: () {
                      _showRejectDialog(context, filteredRequests[index]);
                    },
                    onView: () {
                      _showRequestDetails(context, filteredRequests[index]);
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Request Card Widget
class RequestCard extends StatelessWidget {
  final StockRequest request;
  final String loggedInUserType;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final VoidCallback onView;

  const RequestCard({
    super.key,
    required this.request,
    required this.loggedInUserType,
    required this.onApprove,
    required this.onReject,
    required this.onView,
  });

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  // Check if approve/reject buttons should be shown
  bool _shouldShowActionButtons() {
    // If status is Approved or Rejected, don't show approve/reject buttons
    if (request.isApproved || request.isRejected) {
      return false;
    }

    // If status is Pending, check based on user type and request type
    if (request.isPending) {
      // Admin login (userType = A or S)
      if (loggedInUserType == 'A' || loggedInUserType == 'S') {
        // Show buttons for "DistributorToAdmin" requests
        if (request.requestType.contains('DistributorToAdmin') || 
            request.requestType.contains('Distributor Request')) {
          return true;
        }
        // Don't show for other request types
        return false;
      }

      // Distributor login (userType = D)
      if (loggedInUserType == 'D') {
        // Don't show for "DistributorToAdmin" (own requests)
        if (request.requestType.contains('DistributorToAdmin')) {
          return false;
        }
        // Show buttons for "RetailerToDistributor" or "Retailer Request"
        if (request.requestType.contains('RetailerToDistributor') || 
            request.requestType.contains('Retailer Request')) {
          return true;
        }
        return false;
      }

      // Retailer login (userType = R)
      if (loggedInUserType == 'R') {
        // Don't show for own requests to distributor
        return false;
      }
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: _getStatusColor(request.status),
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: ID and Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'REQ${request.requestId}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(request.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _getStatusColor(request.status),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    request.status,
                    style: TextStyle(
                      color: _getStatusColor(request.status),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Product Name
            Row(
              children: [
                const Icon(
                  Icons.inventory_2_outlined,
                  size: 20,
                  color: Colors.grey,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    request.productName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Quantity
            Row(
              children: [
                const Icon(
                  Icons.format_list_numbered,
                  size: 20,
                  color: Colors.grey,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                      children: [
                        const TextSpan(text: 'Requested: '),
                        TextSpan(
                          text: '${request.quantity}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        if (request.isApproved && request.approvedQuantity != null && request.approvedQuantity != request.quantity) ...[
                          const TextSpan(text: '\nApproved: '),
                          TextSpan(
                            text: '${request.approvedQuantity}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Requested By
            Row(
              children: [
                const Icon(
                  Icons.person_outline,
                  size: 20,
                  color: Colors.grey,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Requested by: ${request.requesterName}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Request Type
            Row(
              children: [
                const Icon(
                  Icons.category_outlined,
                  size: 20,
                  color: Colors.grey,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Type: ${request.requestType}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Requested To
            Row(
              children: [
                const Icon(
                  Icons.arrow_forward,
                  size: 20,
                  color: Colors.grey,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'To: ${request.approverUserName ?? (request.requestedToUserName.isNotEmpty ? request.requestedToUserName : 'Admin')}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
            if (request.isRejected && request.rejectionReason != null) ...[
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.info_outline,
                    size: 20,
                    color: Colors.red,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Reason: ${request.displayRejectionReason}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            // Time and Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      request.formattedRequestedAt,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
                // Show approve/reject buttons for pending requests based on user type
                if (_shouldShowActionButtons())
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: onApprove,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          minimumSize: Size.zero,
                        ),
                        child: const Text(
                          'Approve',
                          style: TextStyle(fontSize: 12, color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: onReject,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          minimumSize: Size.zero,
                        ),
                        child: const Text(
                          'Reject',
                          style: TextStyle(fontSize: 12, color: Colors.white),
                        ),
                      ),
                    ],
                  )
                // Show view button for approved/rejected requests
                else if (request.isApproved || request.isRejected)
                  ElevatedButton(
                    onPressed: onView,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2C3E50),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      minimumSize: Size.zero,
                    ),
                    child: const Text(
                      'View',
                      style: TextStyle(fontSize: 12, color: Colors.white),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Transfer Screen (Placeholder)
class TransferScreen extends StatelessWidget {
  const TransferScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[100],
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.swap_horiz_outlined,
              size: 80,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'Transfer Screen',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Coming soon...',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Request Form Dialog Widget (for both Approve and Reject)
class _RequestFormDialog extends StatefulWidget {
  final StockRequest request;
  final String action;
  final Function(String remarks, int? approvedQuantity, String? attachmentFile) onSubmit;

  const _RequestFormDialog({
    required this.request,
    required this.action,
    required this.onSubmit,
  });

  @override
  State<_RequestFormDialog> createState() => _RequestFormDialogState();
}

class _RequestFormDialogState extends State<_RequestFormDialog> {
  final TextEditingController _remarksController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  String? _selectedFilePath;
  String? _attachmentFileBase64;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _quantityController.text = widget.request.quantity.toString();
  }

  @override
  void dispose() {
    _remarksController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    try {
      final ImagePicker picker = ImagePicker();
      final ImageSource? source = await showDialog<ImageSource>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Select Image Source'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('Camera'),
                  onTap: () => Navigator.pop(context, ImageSource.camera),
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Gallery'),
                  onTap: () => Navigator.pop(context, ImageSource.gallery),
                ),
              ],
            ),
          );
        },
      );

      if (source == null) return;

      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        final File imageFile = File(image.path);
        final String base64String = await fileToBase64(imageFile);
        
        setState(() {
          _selectedFilePath = image.path;
          _attachmentFileBase64 = base64String;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking file: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _removeFile() {
    setState(() {
      _selectedFilePath = null;
      _attachmentFileBase64 = null;
    });
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (widget.action == 'REJECT' && _remarksController.text.trim().isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter a rejection reason'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // Check if file is attached
    if (_attachmentFileBase64 == null || _attachmentFileBase64!.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please attach a file'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    final remarks = _remarksController.text.trim();
    final approvedQuantity = int.tryParse(_quantityController.text.trim());

    Navigator.pop(context);
    await widget.onSubmit(remarks, approvedQuantity, _attachmentFileBase64);
  }

  @override
  Widget build(BuildContext context) {
    final isApprove = widget.action == 'APPROVE';
    final isReject = widget.action == 'REJECT';

    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      contentPadding: EdgeInsets.zero,
      titlePadding: const EdgeInsets.all(20),
      title: Row(
        children: [
          Icon(
            isApprove ? Icons.check_circle : Icons.cancel,
            color: isApprove ? Colors.green : Colors.red,
            size: 28,
          ),
          const SizedBox(width: 12),
          Text(isApprove ? 'Approve Request' : 'Reject Request'),
        ],
      ),
      content: Container(
        width: MediaQuery.of(context).size.width * 0.85,
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                        'Request ID: ${widget.request.requestId}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text('Product: ${widget.request.productName}'),
                      Text('Requested Quantity: ${widget.request.quantity}'),
                      Text('Requester: ${widget.request.requesterName}'),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _quantityController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Approved Quantity *',
                    hintText: 'Enter approved quantity',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter approved quantity';
                    }
                    final intValue = int.tryParse(value);
                    if (intValue == null || intValue < 0) {
                      return 'Please enter a valid positive number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _remarksController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: isReject ? 'Remarks *' : 'Remarks',
                    hintText: isReject ? 'Enter rejection reason...' : 'Enter any additional notes...',
                    border: const OutlineInputBorder(),
                    helperText: isReject ? 'Required for rejection' : 'Optional',
                    helperStyle: TextStyle(
                      color: isReject ? Colors.red : Colors.grey,
                    ),
                  ),
                  validator: (value) {
                    if (isReject && (value == null || value.trim().isEmpty)) {
                      return 'Please enter a rejection reason';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                const Row(
                  children: [
                    Text(
                      'Attachment',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      ' *',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _pickFile,
                        icon: const Icon(Icons.attach_file),
                        label: const Text('Attach File'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    if (_selectedFilePath != null) ...[
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.close),
                        color: Colors.red,
                        onPressed: _removeFile,
                      ),
                    ],
                  ],
                ),
                if (_selectedFilePath != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'Selected: ${_selectedFilePath!.split('/').last}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.green,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submitForm,
          style: ElevatedButton.styleFrom(
            backgroundColor: isApprove ? Colors.green : Colors.red,
            foregroundColor: Colors.white,
          ),
          child: Text(isApprove ? 'Approve' : 'Reject'),
        ),
      ],
    );
  }
}