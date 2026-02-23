import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:orangtre/StoredData/LoginData.dart';
import 'package:orangtre/model/manage_Stock_request_response.dart';
import 'package:orangtre/utils/auth_handler.dart';
import 'package:orangtre/utils/convert_base64.dart';

class ManagestockRequest {
  Future<ManageStockRequestResponse> getStockRequests() async {
    final url = Uri.parse("https://demoapi.wavelift.in/api/ProductService/GetStockRequests");

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
    };

    try {
      print('🔍 Making request to: $url');
      print('🔍 Headers: $headers');
      
      final response = await http.get(url, headers: headers);
      
      print('📡 Response Status: ${response.statusCode}');
      print('📡 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        print('✅ API Response: $jsonResponse');

        // Convert JSON to ManageStockRequestResponse object
        final stockRequestResponse = ManageStockRequestResponse.fromJson(jsonResponse);
        return stockRequestResponse;
      } else if (response.statusCode == 401) {
        print('⚠️ 401 Unauthorized - Triggering automatic logout');
        // Automatically handle 401 - logout user
        await handle401Unauthorized();
        throw UnauthorizedException('Session expired. Please login again.');
      } else {
        print('❌ API Error: ${response.statusCode}');
        print('❌ Error Response: ${response.body}');
        throw Exception('Failed to load stock requests: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error in stock request service: $e');
      // Re-throw UnauthorizedException without wrapping
      if (e is UnauthorizedException) {
        rethrow;
      }
      throw Exception('Error loading stock requests: $e');
    }
  }

  Future<void> acceptOrRejectRequest({
    required String action,
    required int requestId,
    String approvalNotes = '',
    int? approvedQuantity,
    String? attachmentFileBase64,
  }) async {

    final url = Uri.parse("https://demoapi.wavelift.in/api/ProductService/ProcessStockRequest");

    // Get the authentication token from stored login data
    final loginResponse = await LoginStorage.getLoginResponse();
    final token = loginResponse?.token ?? '';

    if (token.isEmpty) {
      throw Exception('Authentication token not found. Please login again.');
    }

    // Validate approval notes for reject action
    if (action == 'REJECT' && approvalNotes.isEmpty) {
      throw Exception('Approval notes are required when rejecting a request.');
    }

    // Prepare headers with new structure
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'AuthenicationToken': token,
      'RequestID': requestId.toString(),
      'Action': action,
      'ApprovalNotes': approvalNotes,
      'ApprovedQuantity': approvedQuantity?.toString() ?? '0',  // Always pass, default to 0 if null
    };

    // Prepare request body with base64 file attachment
    final requestBody = <String, dynamic>{};
    if (attachmentFileBase64 != null && attachmentFileBase64.isNotEmpty) {
      requestBody['attachmentFile'] = attachmentFileBase64;
    }

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        print('Aceept and reject api Response: ${response.body}');
        // print('✅ Request $action successfully: $jsonResponse');
        return;
      } else if (response.statusCode == 401) {
        print('⚠️ 401 Unauthorized - Triggering automatic logout');
        await handle401Unauthorized();
        throw UnauthorizedException('Session expired. Please login again.');
      } else {
        print('❌ API Error: ${response.statusCode}');
        print('❌ Response: ${response.body}');
        throw Exception('Failed to $action request: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error in accept/reject service: $e');
      if (e is UnauthorizedException) {
        rethrow;
      }
      throw Exception('Error processing request: $e');
    }
  }

  // Helper method to convert file to base64 and process request
  Future<void> acceptOrRejectRequestWithFile({
    required String action,
    required int requestId,
    String approvalNotes = '',
    int? approvedQuantity,
    String? filePath,
  }) async {
    String? attachmentFileBase64;
    
    if (filePath != null && filePath.isNotEmpty) {
      try {
        // Convert file to base64 using the utility function
        attachmentFileBase64 = await fileToBase64(File(filePath));
        print('📎 File converted to base64 successfully');
      } catch (e) {
        print('❌ Error converting file to base64: $e');
        throw Exception('Error converting file to base64: $e');
      }
    }

    // Call the main acceptOrRejectRequest method
    await acceptOrRejectRequest(
      action: action,
      requestId: requestId,
      approvalNotes: approvalNotes,
      approvedQuantity: approvedQuantity,
      attachmentFileBase64: attachmentFileBase64,
    );
  }
}
