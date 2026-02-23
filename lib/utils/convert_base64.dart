import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';


Future<String> fileToBase64(File file) async {
  try {
    // Read file as bytes
    Uint8List bytes = await file.readAsBytes();
    
    // Convert bytes to base64
    String base64String = base64Encode(bytes);
    
    return base64String;
  } catch (e) {
    throw Exception('Error converting file to base64: $e');
  }
}


Future<String> fileToBase64WithPrefix(File file) async {
  try {
    // Read file as bytes
    Uint8List bytes = await file.readAsBytes();
    
    // Convert bytes to base64
    String base64String = base64Encode(bytes);
    
    // Get file extension
    String extension = file.path.split('.').last.toLowerCase();
    
    // Determine MIME type
    String mimeType = _getMimeType(extension);
    
    // Return with data URL prefix
    return 'data:$mimeType;base64,$base64String';
  } catch (e) {
    throw Exception('Error converting file to base64 with prefix: $e');
  }
}


String bytesToBase64(Uint8List bytes) {
  return base64Encode(bytes);
}


String bytesToBase64WithPrefix(Uint8List bytes, String mimeType) {
  String base64String = base64Encode(bytes);
  return 'data:$mimeType;base64,$base64String';
}


Uint8List base64ToBytes(String base64String) {
  try {
    // Remove data URL prefix if present
    String cleanBase64 = base64String;
    if (base64String.contains(',')) {
      cleanBase64 = base64String.split(',').last;
    }
    
    return base64Decode(cleanBase64);
  } catch (e) {
    throw Exception('Error converting base64 to bytes: $e');
  }
}


Future<File> base64ToFile(String base64String, String filePath) async {
  try {
    // Convert base64 to bytes
    Uint8List bytes = base64ToBytes(base64String);
    
    // Create file
    File file = File(filePath);
    
    // Write bytes to file
    await file.writeAsBytes(bytes);
    
    return file;
  } catch (e) {
    throw Exception('Error converting base64 to file: $e');
  }
}


int getBase64FileSize(String base64String) {
  // Remove data URL prefix if present
  String cleanBase64 = base64String;
  if (base64String.contains(',')) {
    cleanBase64 = base64String.split(',').last;
  }
  
  // Calculate size (base64 is ~4/3 of original size)
  int base64Length = cleanBase64.length;
  int paddingCount = cleanBase64.endsWith('==') ? 2 : (cleanBase64.endsWith('=') ? 1 : 0);
  
  return ((base64Length * 3) / 4).floor() - paddingCount;
}


String formatFileSize(int bytes) {
  if (bytes < 1024) {
    return '$bytes B';
  } else if (bytes < 1024 * 1024) {
    return '${(bytes / 1024).toStringAsFixed(2)} KB';
  } else if (bytes < 1024 * 1024 * 1024) {
    return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  } else {
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }
}


String _getMimeType(String extension) {
  switch (extension.toLowerCase()) {
    // Images
    case 'jpg':
    case 'jpeg':
      return 'image/jpeg';
    case 'png':
      return 'image/png';
    case 'gif':
      return 'image/gif';
    case 'bmp':
      return 'image/bmp';
    case 'webp':
      return 'image/webp';
    case 'svg':
      return 'image/svg+xml';
    case 'ico':
      return 'image/x-icon';
    
    // Documents
    case 'pdf':
      return 'application/pdf';
    case 'doc':
      return 'application/msword';
    case 'docx':
      return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
    case 'xls':
      return 'application/vnd.ms-excel';
    case 'xlsx':
      return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
    case 'ppt':
      return 'application/vnd.ms-powerpoint';
    case 'pptx':
      return 'application/vnd.openxmlformats-officedocument.presentationml.presentation';
    case 'txt':
      return 'text/plain';
    case 'csv':
      return 'text/csv';
    
    // Archives
    case 'zip':
      return 'application/zip';
    case 'rar':
      return 'application/x-rar-compressed';
    case '7z':
      return 'application/x-7z-compressed';
    
    // Audio
    case 'mp3':
      return 'audio/mpeg';
    case 'wav':
      return 'audio/wav';
    case 'ogg':
      return 'audio/ogg';
    
    // Video
    case 'mp4':
      return 'video/mp4';
    case 'avi':
      return 'video/x-msvideo';
    case 'mov':
      return 'video/quicktime';
    case 'wmv':
      return 'video/x-ms-wmv';
    
    // Default
    default:
      return 'application/octet-stream';
  }
}

/// Validate if string is valid base64
bool isValidBase64(String str) {
  try {
    // Remove data URL prefix if present
    String cleanBase64 = str;
    if (str.contains(',')) {
      cleanBase64 = str.split(',').last;
    }
    
    // Try to decode
    base64Decode(cleanBase64);
    return true;
  } catch (e) {
    return false;
  }
}

/// Get file extension from MIME type
String getExtensionFromMimeType(String mimeType) {
  switch (mimeType.toLowerCase()) {
    case 'image/jpeg':
      return 'jpg';
    case 'image/png':
      return 'png';
    case 'image/gif':
      return 'gif';
    case 'application/pdf':
      return 'pdf';
    case 'application/msword':
      return 'doc';
    case 'application/vnd.openxmlformats-officedocument.wordprocessingml.document':
      return 'docx';
    case 'application/vnd.ms-excel':
      return 'xls';
    case 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet':
      return 'xlsx';
    case 'text/plain':
      return 'txt';
    case 'text/csv':
      return 'csv';
    case 'application/zip':
      return 'zip';
    default:
      return 'bin';
  }
}

