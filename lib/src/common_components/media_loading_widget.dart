import 'package:flutter/material.dart';

class MediaLoadingWidget extends StatefulWidget {
  const MediaLoadingWidget({
    Key? key,
    required this.mediaUrl,
    this.placeHolderImageUri = 'assets/images/gear-loader.gif',
    this.placeHolderHeight = 30,
    this.placeHolderWidth = 30,
    this.mediaFit = BoxFit.scaleDown,
  }) : super(key: key);

  final String mediaUrl;
  final String placeHolderImageUri;
  final double placeHolderHeight;
  final double placeHolderWidth;
  final BoxFit mediaFit;

  @override
  State<MediaLoadingWidget> createState() => _MediaLoadingWidgetState();
}

class _MediaLoadingWidgetState extends State<MediaLoadingWidget> {
  bool _isLoading = false;
  late Image img;
  late Widget placeholder;

  @override
  void initState() {
    _loadData();
    super.initState();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    placeholder = FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.center,
      child: SizedBox(
        height: widget.placeHolderHeight,
        width: widget.placeHolderWidth,
        child: Image.asset(
          widget.placeHolderImageUri,
        ),
      ),
    );
    img = Image.network(
      widget.mediaUrl,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null || (loadingProgress.cumulativeBytesLoaded == (loadingProgress.expectedTotalBytes ?? 0))) {
          return child;
        }
        return placeholder;
      },
      fit: widget.mediaFit,
    );
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading ? placeholder : img;
  }
}
