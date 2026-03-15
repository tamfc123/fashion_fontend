import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;

class PaymentWebView extends StatefulWidget {
  final String paymentUrl;

  const PaymentWebView({super.key, required this.paymentUrl});

  @override
  State<PaymentWebView> createState() => _PaymentWebViewState();
}

class _PaymentWebViewState extends State<PaymentWebView> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.contains('api/payment/vnpay_return')) {
              _handleVNPayReturn(request.url);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thanh toán VNPay'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(false), // User cancelled
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }

  Future<void> _handleVNPayReturn(String returnUrl) async {
    setState(() {
      _isLoading = true;
    });

    // Handle localhost resolution issue for iOS WebViews by using Dart's HTTP
    final urlToCall = returnUrl.replaceAll('localhost', '127.0.0.1');

    try {
      // Fire the request to the backend so the DB gets updated
      await http.get(Uri.parse(urlToCall));
      
      // Parse the response code straight from the URL
      final uri = Uri.parse(returnUrl);
      final responseCode = uri.queryParameters['vnp_ResponseCode'];
      
      if (mounted) {
        if (responseCode == '00') {
           Navigator.of(context).pop(true); // Success
        } else {
           Navigator.of(context).pop(false); // Failed or Canceled
        }
      }
    } catch (e) {
       if (mounted) {
         // Fallback if network request failed (e.g timeout)
         Navigator.of(context).pop(false);
       }
    }
  }
}
