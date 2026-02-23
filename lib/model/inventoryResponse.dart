class ProductResponse {
  final int code;
  final String message;
  final List<Product> data;
  final int totalProducts;

  ProductResponse({
    required this.code,
    required this.message,
    required this.data,
    required this.totalProducts,
  });

  factory ProductResponse.fromJson(Map<String, dynamic> json) {
    return ProductResponse(
      code: json['Code'] ?? json['code'] ?? 0,
      message: json['Message'] ?? json['message'] ?? '',
      data: ((json['Data'] ?? json['data']) as List<dynamic>?)
              ?.map((item) => Product.fromJson(item))
              .toList() ??
          [],
      totalProducts: json['TotalProducts'] ?? json['totalProducts'] ?? 0,
    );
  }
}

class Product {
  final int code;
  final String message;
  final int productID;
  final String productName;
  final double price;
  final int stock;
  final dynamic mrp;
  final dynamic sku;
  final dynamic productGroup;
  final dynamic shadeNameAndShade;
  final dynamic packSize;
  final dynamic fixedBar5Digit;
  final dynamic barCodeHarshit;
  final dynamic barCode12Digit;
  final dynamic totalNoOfDigit;
  final dynamic productImageDriveLink;
  final String statusText;
  final bool status;
  final String createdAt;
  final String updatedAt;
  final dynamic productDate;
  final String stockStatus;

  Product({
    required this.code,
    required this.message,
    required this.productID,
    required this.productName,
    required this.price,
    required this.stock,
    this.mrp,
    this.sku,
    this.productGroup,
    this.shadeNameAndShade,
    this.packSize,
    this.fixedBar5Digit,
    this.barCodeHarshit,
    this.barCode12Digit,
    this.totalNoOfDigit,
    this.productImageDriveLink,
    required this.statusText,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.productDate,
    required this.stockStatus,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      code: json['Code'] ?? 0,
      message: json['Message'] ?? '',
      productID: json['ProductID'] ?? 0,
      productName: json['ProductName'] ?? '',
      price: (json['Price'] ?? 0).toDouble(),
      stock: json['Stock'] ?? 0,
      mrp: json['MRP'],
      sku: json['SKU'],
      productGroup: json['ProductGroup'],
      shadeNameAndShade: json['ShadeNameAndShade'],
      packSize: json['PackSize'],
      fixedBar5Digit: json['FixedBar5Digit'],
      barCodeHarshit: json['BarCodeHarshit'],
      barCode12Digit: json['BarCode12Digit'],
      totalNoOfDigit: json['TotalNoOfDigit'],
      productImageDriveLink: json['ProductImageDriveLink'],
      statusText: json['StatusText'] ?? '',
      status: json['Status'] ?? false,
      createdAt: json['CreatedAt'] ?? '',
      updatedAt: json['UpdatedAt'] ?? '',
      productDate: json['ProductDate'],
      stockStatus: json['StockStatus'] ?? '',
    );
  }
}
