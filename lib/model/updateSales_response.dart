class SalesResponse {
  final int code;
  final String message;
  final List<SaleData> data;
  final int recordCount;
  final String userRole;
  final int userId;
  final Filters filters;
  final String timestamp;

  SalesResponse({
    required this.code,
    required this.message,
    required this.data,
    required this.recordCount,
    required this.userRole,
    required this.userId,
    required this.filters,
    required this.timestamp,
  });

  factory SalesResponse.fromJson(Map<String, dynamic> json) {
    return SalesResponse(
      code: _asInt(json['code']),
      message: (json['message'] ?? '').toString(),
      data: (json['data'] is List)
          ? (json['data'] as List)
              .whereType<Map<String, dynamic>>()
              .map((e) => SaleData.fromJson(e))
              .toList()
          : <SaleData>[],
      recordCount: _asInt(json['recordCount']),
      userRole: (json['userRole'] ?? '').toString(),
      userId: _asInt(json['userId']),
      filters: (json['filters'] is Map<String, dynamic>)
          ? Filters.fromJson(json['filters'] as Map<String, dynamic>)
          : Filters.fromJson(const {}),
      timestamp: (json['timestamp'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'code': code,
    'message': message,
    'data': data.map((e) => e.toJson()).toList(),
    'recordCount': recordCount,
    'userRole': userRole,
    'userId': userId,
    'filters': filters.toJson(),
    'timestamp': timestamp,
  };
}

class SaleData {
  final int code;
  final String message;
  final int saleId;
  final int retailerStockId;
  final int userId;
  final String soldBy;
  final String userRole;
  final String productName;
  final double productPrice;
  final int quantitySold;
  final double salePrice;
  final double totalSaleAmount;
  final String saleDate;
  final String createdDate;
  final String? paymentMethod;
  final dynamic status;
  final double netAmount;
  final dynamic discountAmount;
  final dynamic discountPrice;
  final int productId;
  final bool productStatus;
  final int distributorId;
  final String distributorName;

  SaleData({
    required this.code,
    required this.message,
    required this.saleId,
    required this.retailerStockId,
    required this.userId,
    required this.soldBy,
    required this.userRole,
    required this.productName,
    required this.productPrice,
    required this.quantitySold,
    required this.salePrice,
    required this.totalSaleAmount,
    required this.saleDate,
    required this.createdDate,
    required this.paymentMethod,
    required this.status,
    required this.netAmount,
    required this.discountAmount,
    required this.discountPrice,
    required this.productId,
    required this.productStatus,
    required this.distributorId,
    required this.distributorName,
  });

  factory SaleData.fromJson(Map<String, dynamic> json) {
    return SaleData(
      code: _asInt(json['Code']),
      message: (json['Message'] ?? '').toString(),
      saleId: _asInt(json['SaleID']),
      retailerStockId: _asInt(json['RetailerStockID']),
      userId: _asInt(json['UserID']),
      soldBy: (json['SoldBy'] ?? '').toString(),
      userRole: (json['UserRole'] ?? json['SaleRole'] ?? '').toString(),
      productName: (json['ProductName'] ?? '').toString(),
      productPrice: _asDouble(json['ProductPrice']),
      quantitySold: _asInt(json['QuantitySold']),
      // API sends TotalSalePrice; fall back to SalePrice if present
      salePrice: _asDouble(json['TotalSalePrice'] ?? json['SalePrice']),
      totalSaleAmount: _asDouble(json['TotalSalePrice'] ?? json['TotalSaleAmount'] ?? json['NetAmount']),
      saleDate: (json['SaleDate'] ?? '').toString(),
      createdDate: (json['CreatedDate'] ?? '').toString(),
      paymentMethod: json['PaymentMethod'] != null ? json['PaymentMethod'].toString() : null,
      status: json['Status'],
      netAmount: _asDouble(json['NetAmount']),
      // Keep whatever the API provides; also surface DiscountPercentage as amount if DiscountAmount missing
      discountAmount: json['DiscountAmount'] ?? json['DiscountPercentage'],
      discountPrice: json['DiscountPrice'],
      productId: _asInt(json['ProductID']),
      productStatus: _asBool(json['ProductStatus']),
      distributorId: _asInt(json['DistributorID']),
      distributorName: (json['DistributorName'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'Code': code,
    'Message': message,
    'SaleID': saleId,
    'RetailerStockID': retailerStockId,
    'UserID': userId,
    'SoldBy': soldBy,
    'UserRole': userRole,
    'ProductName': productName,
    'ProductPrice': productPrice,
    'QuantitySold': quantitySold,
    'SalePrice': salePrice,
    'TotalSaleAmount': totalSaleAmount,
    'SaleDate': saleDate,
    'CreatedDate': createdDate,
    'PaymentMethod': paymentMethod,
    'Status': status,
    'NetAmount': netAmount,
    'DiscountAmount': discountAmount,
    'DiscountPrice': discountPrice,
    'ProductID': productId,
    'ProductStatus': productStatus,
    'DistributorID': distributorId,
    'DistributorName': distributorName,
  };
}

class Filters {
  final String fromDate;
  final String toDate;
  final int productId;

  Filters({
    required this.fromDate,
    required this.toDate,
    required this.productId,
  });

  factory Filters.fromJson(Map<String, dynamic> json) {
    return Filters(
      fromDate: (json['fromDate'] ?? '').toString(),
      toDate: (json['toDate'] ?? '').toString(),
      productId: _asInt(json['productId']),
    );
  }

  Map<String, dynamic> toJson() => {
    'fromDate': fromDate,
    'toDate': toDate,
    'productId': productId,
  };
}

// -------- Safe parsing helpers to avoid runtime type errors --------
int _asInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is double) return value.round();
  if (value is String) {
    final parsed = int.tryParse(value);
    if (parsed != null) return parsed;
    final parsedDouble = double.tryParse(value);
    return parsedDouble != null ? parsedDouble.round() : 0;
  }
  // Unexpected types (e.g., map) -> default 0 to prevent crashes
  return 0;
}

double _asDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0.0;
}

bool _asBool(dynamic value) {
  if (value is bool) return value;
  if (value is int) return value != 0;
  if (value is String) {
    final lower = value.toLowerCase();
    if (lower == 'true') return true;
    if (lower == 'false') return false;
    final asInt = int.tryParse(value);
    if (asInt != null) return asInt != 0;
  }
  return false;
}
