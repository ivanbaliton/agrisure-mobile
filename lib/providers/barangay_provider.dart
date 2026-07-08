import 'package:flutter/material.dart';
import '../services/barangay_service.dart';

class BarangayProvider extends ChangeNotifier {
  final BarangayService _barangayService = BarangayService();

  List<Map<String, dynamic>> _barangays = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Map<String, dynamic>> get barangays => _barangays;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchBarangays() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _barangays = await _barangayService.fetchBarangays();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
