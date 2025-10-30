import 'package:flutter/foundation.dart';

class ShopProvider with ChangeNotifier {
  bool _isOpen = true;
  String? _currentUser;
  String? _userType; // 'employee' or 'customer'

  bool get isOpen => _isOpen;
  String? get currentUser => _currentUser;
  String? get userType => _userType;
  bool get isEmployee => _userType == 'employee';
  bool get isCustomer => _userType == 'customer';

  void toggleShopStatus() {
    _isOpen = !_isOpen;
    notifyListeners();
  }

  void setShopStatus(bool status) {
    _isOpen = status;
    notifyListeners();
  }

  void login(String username, String type) {
    _currentUser = username;
    _userType = type;
    notifyListeners();
  }

  void logout() {
    _currentUser = null;
    _userType = null;
    notifyListeners();
  }
}
