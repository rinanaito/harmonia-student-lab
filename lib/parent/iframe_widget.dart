import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';

class IframeView extends StatefulWidget {
  final String url;

  const IframeView({super.key, required this.url});

  @override
  State<IframeView> createState() => _IframeViewState();
}

class _IframeViewState extends State<IframeView> {
  late final String viewType;

  @override
  void initState() {
    super.initState();

    viewType = 'iframe-${widget.url.hashCode}';

    ui_web.platformViewRegistry.registerViewFactory(viewType, (int viewId) {
      return html.IFrameElement()
        ..src = widget.url
        ..style.border = '0'
        ..style.width = '100%'
        ..style.height = '100%'
        ..allow = 'fullscreen';
    });
  }

  @override
  Widget build(BuildContext context) {
    return HtmlElementView(viewType: viewType);
  }
}
