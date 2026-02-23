import 'package:intl/intl.dart';

String getCurrentLoginTime() {
  final now = DateTime.now();                
  final formattedTime = DateFormat('HH:mm').format(now); 
  return formattedTime;
}

