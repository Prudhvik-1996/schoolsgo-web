import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/settings/app_drawer_helper.dart';

class E404NotFoundScreen extends StatefulWidget {
  const E404NotFoundScreen({Key? key}) : super(key: key);

  static const routeName = "404";

  @override
  _E404NotFoundScreenState createState() => _E404NotFoundScreenState();
}

class _E404NotFoundScreenState extends State<E404NotFoundScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor != Colors.blue ? const Color(0xFF2c2c2c) : const Color(0xFFFFFFFF),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor != Colors.blue ? const Color(0xFF2c2c2c) : const Color(0xFFFFFFFF),
        leading: BackButton(
          color: Theme.of(context).primaryColor != Colors.blue ? const Color(0xFF2c2c2c) : const Color(0xFFFFFFFF),
        ),
      ),
      drawer: AppDrawerHelper.instance.isAppDrawerDisabled() ? null : null,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        // child: Image.asset(
        //   "assets/images/404_error.png",
        //   fit: BoxFit.cover,
        // ),
        children: const [
          Center(
            child: Text(
              "Loading...\n",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Center(
            child: Text(
              "Please Wait...",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class E401Unauthorized extends StatefulWidget {
  const E401Unauthorized({Key? key}) : super(key: key);

  @override
  _E401UnauthorizedState createState() => _E401UnauthorizedState();
}

class _E401UnauthorizedState extends State<E401Unauthorized> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset(
          "assets/images/401_error.png",
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
