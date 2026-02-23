class ManageStockRequestResponse {
  final int code;
  final String message;
  final List<StockRequest> data;

  ManageStockRequestResponse({
    required this.code,
    required this.message,
    required this.data,
  });

  factory ManageStockRequestResponse.fromJson(Map<String, dynamic> json) {
    return ManageStockRequestResponse(
      code: json['code'] ?? 0,
      message: json['message'] ?? '',
      data: ((json['data'] ?? []) as List<dynamic>)
          .map((item) => StockRequest.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'message': message,
      'data': data.map((request) => request.toJson()).toList(),
    };
  }
}

class StockRequest {
  final int requestId;
  final int distributorId;
  final dynamic retailerId;
  final int productId;
  final int quantity;
  final String status;
  final String requestedAt;
  final dynamic approvedAt;
  final dynamic rejectedAt;
  final dynamic rejectionReason;
  final int requestedToUserId;
  final String requestType;
  final String productName;
  final String requestedToUserName;
  final String requesterName;
  final int code;
  final String message;
  // Additional fields from API response
  final String? requestorUserName;
  final String? requestorRole;
  final String? requestorUserType;
  final double? productPrice;
  final int? productStock;
  final String? approvedBy;
  final String? approverName;
  final String? approverUserName;
  final String? approvalNotes;
  final String? requestContext;
  final String? attachmentPath;
  final int? approvedQuantity;
  final bool? isQuantityEdited;

  StockRequest({
    required this.requestId,
    required this.distributorId,
    this.retailerId,
    required this.productId,
    required this.quantity,
    required this.status,
    required this.requestedAt,
    this.approvedAt,
    this.rejectedAt,
    this.rejectionReason,
    required this.requestedToUserId,
    required this.requestType,
    required this.productName,
    required this.requestedToUserName,
    required this.requesterName,
    required this.code,
    required this.message,
    this.requestorUserName,
    this.requestorRole,
    this.requestorUserType,
    this.productPrice,
    this.productStock,
    this.approvedBy,
    this.approverName,
    this.approverUserName,
    this.approvalNotes,
    this.requestContext,
    this.attachmentPath,
    this.approvedQuantity,
    this.isQuantityEdited,
  });

  factory StockRequest.fromJson(Map<String, dynamic> json) {
    // Handle distributorId as string or int
    int parseDistributorId(dynamic value) {
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    return StockRequest(
      requestId: json['requestID'] ?? json['RequestId'] ?? 0,
      distributorId: parseDistributorId(json['requestorID'] ?? json['DistributorId'] ?? 0),
      retailerId: json['RetailerId'] ?? json['retailerId'],
      productId: json['productID'] ?? json['ProductId'] ?? 0,
      quantity: json['requestedQuantity'] ?? json['Quantity'] ?? 0,
      status: json['status'] ?? json['Status'] ?? '',
      requestedAt: json['requestDate'] ?? json['RequestedAt'] ?? '',
      approvedAt: json['approvedDate'] ?? json['ApprovedAt'],
      rejectedAt: json['RejectedAt'] ?? json['rejectedAt'],
      rejectionReason: json['RejectionReason'] ?? json['rejectionReason'],
      requestedToUserId: json['RequestedToUserId'] ?? json['requestedToUserId'] ?? 0,
      requestType: json['requestType'] ?? json['RequestType'] ?? '',
      productName: json['productName'] ?? json['ProductName'] ?? '',
      requestedToUserName: json['approverUserName'] ?? json['ApproverUserName'] ?? json['RequestedToUserName'] ?? json['requestedToUserName'] ?? '',
      requesterName: json['requestorName'] ?? json['RequesterName'] ?? '',
      code: json['code'] is String ? int.tryParse(json['code']) ?? 0 : (json['code'] ?? json['Code'] ?? 0),
      message: json['message'] ?? json['Message'] ?? '',
      requestorUserName: json['requestorUserName'] ?? json['RequestorUserName'],
      requestorRole: json['requestorRole'] ?? json['RequestorRole'],
      requestorUserType: json['requestorUserType'] ?? json['RequestorUserType'],
      productPrice: json['productPrice'] != null ? (json['productPrice'] as num).toDouble() : null,
      productStock: json['productStock'] ?? json['ProductStock'],
      approvedBy: json['approvedBy'] ?? json['ApprovedBy'],
      approverName: json['approverName'] ?? json['ApproverName'],
      approverUserName: json['approverUserName'] ?? json['ApproverUserName'],
      approvalNotes: json['approvalNotes'] ?? json['ApprovalNotes'],
      requestContext: json['requestContext'] ?? json['RequestContext'],
      attachmentPath: json['attachmentPath'] ?? json['AttachmentPath'],
      approvedQuantity: json['approvedQuantity'] ?? json['ApprovedQuantity'],
      isQuantityEdited: json['isQuantityEdited'] ?? json['IsQuantityEdited'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'RequestId': requestId,
      'DistributorId': distributorId,
      'RetailerId': retailerId,
      'ProductId': productId,
      'Quantity': quantity,
      'Status': status,
      'RequestedAt': requestedAt,
      'ApprovedAt': approvedAt,
      'RejectedAt': rejectedAt,
      'RejectionReason': rejectionReason,
      'RequestedToUserId': requestedToUserId,
      'RequestType': requestType,
      'ProductName': productName,
      'RequestedToUserName': requestedToUserName,
      'RequesterName': requesterName,
      'Code': code,
      'Message': message,
      'RequestorUserName': requestorUserName,
      'RequestorRole': requestorRole,
      'RequestorUserType': requestorUserType,
      'ProductPrice': productPrice,
      'ProductStock': productStock,
      'ApprovedBy': approvedBy,
      'ApproverName': approverName,
      'ApproverUserName': approverUserName,
      'ApprovalNotes': approvalNotes,
      'RequestContext': requestContext,
      'AttachmentPath': attachmentPath,
      'ApprovedQuantity': approvedQuantity,
      'IsQuantityEdited': isQuantityEdited,
    };
  }

  // Helper getter for status color
  String get statusColor {
    switch (status.toLowerCase()) {
      case 'approved':
        return 'green';
      case 'rejected':
        return 'red';
      case 'pending':
        return 'orange';
      default:
        return 'grey';
    }
  }

  // Helper getter to check if pending
  bool get isPending => status.toLowerCase() == 'pending';

  // Helper getter to check if approved
  bool get isApproved => status.toLowerCase() == 'approved';

  // Helper getter to check if rejected
  bool get isRejected => status.toLowerCase() == 'rejected';

  // Helper getter for formatted date (DD-Month Name-YYYY)
  String get formattedRequestedAt {
    try {
      final dateTime = DateTime.parse(requestedAt);
      final day = dateTime.day.toString().padLeft(2, '0');
      final year = dateTime.year;
      
      // Get month name
      const monthNames = [
        'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December'
      ];
      final monthName = monthNames[dateTime.month - 1];
      
      return '$day-$monthName-$year';
    } catch (e) {
      return requestedAt;
    }
  }

  // Helper getter for rejection reason display
  String get displayRejectionReason {
    if (approvalNotes != null && approvalNotes!.isNotEmpty) {
      return approvalNotes!;
    }
    if (rejectionReason != null && rejectionReason.toString().isNotEmpty) {
      return rejectionReason.toString();
    }
    return 'N/A';
  }
}

