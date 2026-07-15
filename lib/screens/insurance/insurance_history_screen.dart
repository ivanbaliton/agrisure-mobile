import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../core/utils/storage_helper.dart';
import '../../models/farm_model.dart';
import '../../models/insurance_application_model.dart';
import 'insurance_detail_screen.dart';

class InsuranceHistoryScreen extends StatefulWidget {
  final FarmModel farm;

  const InsuranceHistoryScreen({super.key, required this.farm});

  @override
  State<InsuranceHistoryScreen> createState() => _InsuranceHistoryScreenState();
}

class _InsuranceHistoryScreenState extends State<InsuranceHistoryScreen> {
  static const String baseUrl = 'http://192.168.254.121:8000/api';

  bool isLoading = true;
  String? errorMessage;

  List<InsuranceApplicationModel> applications = [];

  @override
  void initState() {
    super.initState();
    fetchHistory();
  }

  Future<void> fetchHistory() async {
    try {
      final token = await StorageHelper.getToken();

      if (token == null) {
        setState(() {
          errorMessage = 'Login session missing.';
          isLoading = false;
        });
        return;
      }

      final response = await http.get(
        Uri.parse('$baseUrl/insurance-applications/farm/${widget.farm.id}'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        setState(() {
          applications = List<Map<String, dynamic>>.from(
            data,
          ).map((json) => InsuranceApplicationModel.fromJson(json)).toList();
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = data['message'] ?? 'Failed to load history.';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Connection failed.';
        isLoading = false;
      });
    }
  }

  Color statusColor(String status) {
    switch (status) {
      case 'insured':
        return Colors.green;
      case 'submitted_to_pcic':
        return Colors.blue;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  String formatStatus(String value) {
    return value.replaceAll('_', ' ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Insurance History'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: fetchHistory,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : errorMessage != null
            ? ListView(
                children: [
                  const SizedBox(height: 160),
                  Center(child: Text(errorMessage!)),
                ],
              )
            : applications.isEmpty
            ? ListView(
                children: const [
                  SizedBox(height: 160),
                  Center(child: Text('No insurance applications yet.')),
                ],
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: applications.length,
                itemBuilder: (context, index) {
                  final app = applications[index];
                  final color = statusColor(app.status);

                  return Card(
                    child: ListTile(
                      leading: Icon(Icons.assignment, color: color),
                      title: Text(
                        'Application #${app.id}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'Area: ${app.insuredArea} ha\n'
                        'Status: ${formatStatus(app.status)}\n'
                        'Date: ${app.applicationDate}',
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                InsuranceDetailScreen(application: app),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
      ),
    );
  }
}
