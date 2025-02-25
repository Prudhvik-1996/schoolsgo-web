import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/admin_expenses/admin/admin_employee_wallets_screen.dart';
import 'package:schoolsgo_web/src/admin_expenses/admin/admin_expense_installments_plan_screen.dart';
import 'package:schoolsgo_web/src/admin_expenses/admin/admin_expenses_screen_admin_view.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/common_components/common_components.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';

class AdminExpensesOptionsScreen extends StatefulWidget {
  const AdminExpensesOptionsScreen({
    Key? key,
    this.adminProfile,
    this.receptionistProfile,
  }) : super(key: key);

  final AdminProfile? adminProfile;
  final OtherUserRoleProfile? receptionistProfile;

  static const String routeName = "/admin_expenses";

  @override
  State<AdminExpensesOptionsScreen> createState() => _AdminExpensesOptionsScreenState();
}

class _AdminExpensesOptionsScreenState extends State<AdminExpensesOptionsScreen> {
  Widget _getAdminExpensesOption(String title, String? description, StatefulWidget nextWidget) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return nextWidget;
        }));
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        margin: const EdgeInsets.fromLTRB(20, 5, 20, 0),
        child: ClayButton(
          depth: 40,
          surfaceColor: clayContainerColor(context),
          parentColor: clayContainerColor(context),
          spread: 1,
          borderRadius: 10,
          child: Container(
            padding: const EdgeInsets.all(10), // margin: const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.1,
                  child: const Icon(
                    Icons.adjust,
                  ),
                ),
                SizedBox(width: MediaQuery.of(context).size.width * 0.005),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(top: 10),
                  child: Column(
                    children: <Widget>[
                      Text(
                        description ?? "",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 15),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Expenses"),
      ),
      drawer: widget.adminProfile != null
          ? AdminAppDrawer(adminProfile: widget.adminProfile!)
          : ReceptionistAppDrawer(receptionistProfile: widget.receptionistProfile!),
      body: ListView(
        padding: EdgeInsets.zero,
        primary: false,
        children: <Widget>[
          _getAdminExpensesOption(
            "Admin Expenses",
            null,
            AdminExpenseScreenAdminView(
              adminProfile: widget.adminProfile,
              receptionistProfile: widget.receptionistProfile,
            ),
          ),
          _getAdminExpensesOption(
            "Expense Installments Plan",
            null,
            AdminInstallmentsPlanScreen(
              adminProfile: widget.adminProfile,
              receptionistProfile: widget.receptionistProfile,
            ),
          ),
          if (widget.adminProfile != null)
            _getAdminExpensesOption(
              "Employee Wallets",
              null,
              AdminEmployeeWalletsScreen(
                adminProfile: widget.adminProfile!,
              ),
            ),
        ],
      ),
    );
  }
}
