import 'package:flutter/material.dart';

import '../models/claim_model.dart';
import '../services/claim_service.dart';

class ClaimProvider extends ChangeNotifier {
  final ClaimService _claimService = ClaimService();

  bool isLoading = false;
  List<ClaimModel> claims = [];

  Future<void> fetchMyClaims({
    required String token,
    required int userId,
  }) async {
    isLoading = true;
    notifyListeners();

    try {
      final response = await _claimService.getMyClaims(
        token: token,
        userId: userId,
      );

      claims = response
          .map<ClaimModel>((json) => ClaimModel.fromJson(json))
          .toList();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<ClaimModel> fetchClaimDetails({
    required String token,
    required int claimId,
  }) async {
    final response = await _claimService.getClaimDetails(
      token: token,
      claimId: claimId,
    );

    return ClaimModel.fromJson(response);
  }
}
