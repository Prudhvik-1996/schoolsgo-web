import 'package:flutter/material.dart';

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
      body: Center(
        child: Image.asset(
          "assets/images/404_error.png",
          fit: BoxFit.cover,
        ),
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
