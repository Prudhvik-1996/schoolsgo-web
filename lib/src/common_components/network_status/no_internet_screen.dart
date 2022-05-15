import 'package:flutter/material.dart';

class NoInternetScreen extends StatelessWidget {
  const NoInternetScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor != Colors.blue ? const Color(0xFF2c2c2c) : const Color(0xFFFFFFFF),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
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
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          const SizedBox(
            height: 50,
          ),
          Expanded(
            child: Image.asset(
              'assets/images/no-internet.gif',
              fit: BoxFit.scaleDown,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: const [
                Icon(
                  Icons.warning,
                  color: Colors.amber,
                  size: 15,
                ),
                SizedBox(
                  width: 20,
                ),
                Text(
                  "Please check your internet connection..",
                  style: TextStyle(
                    color: Colors.amber,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          const Center(
            child: Text(
              "© Powered by Epsilon Infinity Services Pvt. Ltd.",
            ),
          ),
          const SizedBox(
            height: 20,
          ),
        ],
      ),
    );
  }
}
