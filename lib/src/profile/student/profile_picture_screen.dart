import 'package:flutter/material.dart';

class ProfilePictureScreen extends StatefulWidget {
  ProfilePictureScreen({
    Key? key,
    required this.name,
    required this.pictureUrl,
  }) : super(key: key);

  String name;
  String pictureUrl;

  @override
  _ProfilePictureScreenState createState() => _ProfilePictureScreenState();
}

class _ProfilePictureScreenState extends State<ProfilePictureScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.name),
      ),
      body: Center(
        child: FadeInImage(
          placeholder: const AssetImage(
            'assets/images/loading_grey_white.gif',
          ),
          image: NetworkImage(
            widget.pictureUrl,
          ),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
