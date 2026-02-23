import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:orangtre/StoredData/LoginData.dart';
import 'package:orangtre/model/updateSales_response.dart';
import 'package:orangtre/utils/auth_handler.dart';

class UpdateSaleServices {
  Future<SalesResponse> getUpdatedSalesList({
    String fromDate = '',
    String toDate = '',
  }) async
  {
    final url = Uri.parse("https://demoapi.wavelift.in/api/ManageSaleReport/UpdatedSalelist");

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
      if (fromDate.isNotEmpty) 'fromDate': fromDate,
      if (toDate.isNotEmpty) 'toDate': toDate,
    };

    try {
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        print('API Response: $jsonResponse');

        // Convert JSON to SalesResponse object
        final salesResponse = SalesResponse.fromJson(jsonResponse);
        return salesResponse;
      } else if (response.statusCode == 401) {
        print('⚠️ 401 Unauthorized - Triggering automatic logout');
        // Automatically handle 401 - logout user
        await handle401Unauthorized();
        throw UnauthorizedException('Session expired. Please login again.');
      } else {
        print('API Error: ${response.statusCode}');
        print('Error response body : ${response.body}');
        throw Exception('Failed to load sales list: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in sales list service: $e');
      // Re-throw UnauthorizedException without wrapping
      if (e is UnauthorizedException) {
        rethrow;
      }
      throw Exception('Error loading sales list: $e');
    }
  }

  Future<void> updateSales({
    required String stockId,
    required String quantitySold,
    required String salePrice,
    String discountPrice = "0.0",
    required String paymentMethod,
    required String saleDate,
    required String saleTime,
  }) async
  {
    final url = Uri.parse("https://demoapi.wavelift.in/api/ManageSaleReport/ProcessRetailerSale");

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
      'StockId': stockId,
      'QuantitySold': quantitySold,
      'SalePrice': salePrice,
      'DiscountPrice': discountPrice,
      'PaymentMethod': paymentMethod,
      'SaleDate': saleDate,
      'SaleTime': saleTime,
    };

    try {
      final response = await http.post(url, headers: headers);

      if (response.statusCode == 200) {
        print('Update Sales API Response: ${response.body}');
        return;
      } else if (response.statusCode == 401) {
        print('⚠️ 401 Unauthorized - Triggering automatic logout');
        // Automatically handle 401 - logout user
        await handle401Unauthorized();
        throw UnauthorizedException('Session expired. Please login again.');
      } else {
        print('API Error: ${response.statusCode}');
        print('Error response body: ${response.body}');
        throw Exception('Failed to update sales: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in update sales service: $e');
      // Re-throw UnauthorizedException without wrapping
      if (e is UnauthorizedException) {
        rethrow;
      }
      throw Exception('Error updating sales: $e');
    }
  }
}
