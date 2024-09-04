import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';

class FinancialReportsScreen extends StatefulWidget {
  const FinancialReportsScreen({
    Key? key,
    required this.adminProfile,
  }) : super(key: key);

  final AdminProfile adminProfile;

  @override
  State<FinancialReportsScreen> createState() => _FinancialReportsScreenState();
}

class _FinancialReportsScreenState extends State<FinancialReportsScreen> {
  bool _isLoading = true;


  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
