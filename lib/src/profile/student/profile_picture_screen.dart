import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/common_components/media_loading_widget.dart';

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
        child: MediaLoadingWidget(
          mediaUrl: widget.pictureUrl,
          mediaFit: BoxFit.cover,
        ),
      ),
    );
  }
}
