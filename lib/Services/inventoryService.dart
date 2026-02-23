import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:orangtre/StoredData/LoginData.dart';
import 'package:orangtre/model/inventoryResponse.dart';
import 'package:orangtre/utils/auth_handler.dart';

class Inventoryservice {
  Future<ProductResponse> inventory() async
  {
    final url = Uri.parse("https://demoapi.wavelift.in/api/ProductService/GetProductListStock");

    // Get the authentication token from stored login data
    final loginResponse = await LoginStorage.getLoginResponse();
    final token = loginResponse?.token ?? '';

    if (token.isEmpty) {
      throw Exception('Authentication token not found. Please login again.');
    }

    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'AuthenicationToken': token,
    };

    try {
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        print('API Response: $jsonResponse');

        // Convert JSON to ProductResponse object
        final productResponse = ProductResponse.fromJson(jsonResponse);

        return productResponse;
      } else if (response.statusCode == 401) {
        print('⚠️ 401 Unauthorized - Triggering automatic logout');
        // Automatically handle 401 - logout user
        await handle401Unauthorized();
        throw UnauthorizedException('Session expired. Please login again.');
      } else {
        print('API Error: ${response.statusCode}');
        throw Exception('Failed to load inventory: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in inventory service: $e');
      // Re-throw UnauthorizedException without wrapping
      if (e is UnauthorizedException) {
        rethrow;
      }
      throw Exception('Error loading inventory: $e');
    }
  }

  Future<void> addProduct({
    required String productName,
    required String price,
    required String stockQuantity,
    String operation = "INSERT",
    String productID = '',
    String group = '',
    String shadeNameAndCode = '',
    String packSize = '',
    String fixedBar5Digit = '',
    String barCodeHarshit = '',
    String sku = '',
    String barCode12Digit = '',
    String totalNoOfDigit = '',
    String productImageDriveLink = '',
  }) async
  {
    final url = Uri.parse("https://demoapi.wavelift.in/api/ProductService/ManageProduct");

    // Get the authentication token from stored login data
    final loginResponse = await LoginStorage.getLoginResponse();
    final token = loginResponse?.token ?? '';

    if (token.isEmpty) {
      throw Exception('Authentication token not found. Please login again.');
    }

    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'AuthenticationToken': token,
      'ProductName': productName,
      'Price': price,
      'StockQuantity': stockQuantity,
      'Operation': operation,
      'ProductID': productID ="",
      'Group': group,
      'ShadeNameAndCode': shadeNameAndCode,
      'PackSize': packSize,
      'FixedBar5Digit': fixedBar5Digit,
      'BarCodeHarshit': barCodeHarshit,
      'SKU': sku,
      'BarCode12Digit': barCode12Digit,
      'TotalNoOfDigit': totalNoOfDigit,
      'ProductImageDriveLink': productImageDriveLink = "",
    };

    try {
      final response = await http.post(url, headers: headers);

      if (response.statusCode == 200) {
        print('Add Product API Response: ${response.body}');
        return;
      } else if (response.statusCode == 401) {
        // print('⚠️ 401 Unauthorized - Triggering automatic logout');
        await handle401Unauthorized();
        throw UnauthorizedException('Session expired. Please login again.');
      } else {
        // print('❌ API Error: ${response.statusCode}');
        // print('❌ API Response Body: ${response.body}');
        throw Exception('Failed to add product: ${response.statusCode}');
      }
    } catch (e) {
      // print('Error in add product service: $e');
      // Re-throw UnauthorizedException without wrapping
      if (e is UnauthorizedException) {
        rethrow;
      }
      throw Exception('Error adding product: $e');
    }
  }


  Future<void> addStock({
    required String productID,
    required String qty,
  }) async
  {
      final url = Uri.parse("https://demoapi.wavelift.in/api/ProductService/AddStock");

    // Get the authentication token from stored login data
    final loginResponse = await LoginStorage.getLoginResponse();
    final token = loginResponse?.token ?? '';

    if (token.isEmpty) {
      throw Exception('Authentication token not found. Please login again.');
    }

    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'AuthenticationToken': token,
      'ProductID': productID,
      'QtyToAdd': qty,
    };

    try {
      final response = await http.post(url, headers: headers);

      if (response.statusCode == 200) {
        print('Add Stock API Response: ${response.body}');
        return;
      } else if (response.statusCode == 401) {
        print('⚠️ 401 Unauthorized - Triggering automatic logout');
        await handle401Unauthorized();
        throw UnauthorizedException('Session expired. Please login again.');
      } else {
        print('❌ API Error: ${response.statusCode}');
        print('❌ API Response Body: ${response.body}');
        throw Exception('Failed to add stock: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in add stock service: $e');
      // Re-throw UnauthorizedException without wrapping
      if (e is UnauthorizedException) {
        rethrow;
      }
      throw Exception('Error adding stock: $e');
    }
  }
}
