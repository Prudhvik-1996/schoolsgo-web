import 'package:flutter/material.dart';

Widget defaultSplashScreen(BuildContext context) {
  return Scaffold(
    body: ListView(
      physics: const BouncingScrollPhysics(),
      children: [
        const SizedBox(
          height: 50,
        ),
        const Center(
          child: Text(
            "Epsilon Diary",
            style: TextStyle(
              color: Colors.blue,
              fontSize: 48,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(
          height: 15,
        ),
        const Center(
          child: Text(
            "An effortless School Management system",
            style: TextStyle(
              color: Colors.black87,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
        const SizedBox(
          height: 50,
        ),
        Center(
          child: Image.asset(
            'assets/images/eis_loader.gif',
            height: 300,
            width: 300,
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        const Center(
          child: Text(
            "© Powered by Epsilon Infinity Services Pvt. Ltd.",
            style: TextStyle(
              color: Colors.black87,
            ),
          ),
        ),
      ],
    ),
  );
}
