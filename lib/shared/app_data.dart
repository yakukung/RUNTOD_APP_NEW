//app_data.dart
import 'package:flutter/material.dart';

class Appdata with ChangeNotifier {
  String username = '';
  late UserProfile user;
}

class UserProfile {
  int uid = 0;
  int type = 0;
  String fullname = '';
  String oid = '';
}
