import 'dart:async';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ChipInPaymentScreen extends StatefulWidget {
  final String paymentUrl;
  final String successUrl;

  const ChipInPaymentScreen({
    super.key,
    required this.paymentUrl,
    required this.successUrl,
  });

  @override
  State<ChipInPaymentScreen> createState() => _ChipInPaymentScreenState();
}

class _ChipInPaymentScreenState extends State<ChipInPaymentScreen> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) {
            // Check if the URL is the success URL
            if (request.url.startsWith(widget.successUrl)) {
              // Payment is successful, pop the screen with a success result
              Navigator.of(context).pop(true);
              return NavigationDecision.prevent; // Stop the navigation
            }
            // Allow all other navigations
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Payment'),
        backgroundColor: const Color(0xFFF6F0FF), // Using the consistent app bar color
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}
