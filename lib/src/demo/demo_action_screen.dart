import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:schoolsgo_web/src/demo/demo.dart';

class DemoActionScreen extends StatefulWidget {
  const DemoActionScreen({
    super.key,
    required this.action,
  });

  final ModuleAction action;

  @override
  State<DemoActionScreen> createState() => _DemoActionScreenState();
}

class _DemoActionScreenState extends State<DemoActionScreen> {
  bool _isGuidedView = true;


  @override
  void initState() {
    super.initState();
    if (widget.action.defaultToStepByStep ?? false) {
      _isGuidedView = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.action.action ?? "-"),
        actions: [
          IconButton(
            onPressed: () => setState(() => _isGuidedView = !_isGuidedView),
            icon: _isGuidedView ? const Icon(Icons.list_outlined) : const Icon(Icons.video_collection_outlined),
          ),
        ],
      ),
      body: Center(
        child: HtmlWidget(
          _isGuidedView ? (widget.action.guidedView ?? "") : (widget.action.stepByStepGuide ?? ""),
          enableCaching: true,
        ),
      ),
    );
  }
}
