import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../../injection_container.dart' as di;
import '../../domain/entities/order.dart';
import '../bloc/order_bloc.dart';
import '../bloc/order_event.dart';
import '../bloc/order_state.dart';

class PaymentWebView extends StatelessWidget {
  final String paymentUrl;

  const PaymentWebView({super.key, required this.paymentUrl});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<OrderBloc>(),
      child: _PaymentWebViewBody(paymentUrl: paymentUrl),
    );
  }
}

class _PaymentWebViewBody extends StatefulWidget {
  final String paymentUrl;

  const _PaymentWebViewBody({required this.paymentUrl});

  @override
  State<_PaymentWebViewBody> createState() => _PaymentWebViewBodyState();
}

class _PaymentWebViewBodyState extends State<_PaymentWebViewBody> {
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
              // Delegate to Bloc — UI does NOT call http directly
              context.read<OrderBloc>().add(
                    ConfirmVnpayEvent(returnUrl: request.url),
                  );
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
          onPageStarted: (_) => setState(() => _isLoading = true),
          onPageFinished: (_) => setState(() => _isLoading = false),
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OrderBloc, OrderState>(
      listener: (context, state) {
        if (state is VnpayConfirmSuccess) {
          Navigator.of(context).pop(true); // Success
        } else if (state is VnpayConfirmFailure) {
          Navigator.of(context).pop(false); // Failed
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Thanh toán VNPay'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(false),
          ),
        ),
        body: Stack(
          children: [
            WebViewWidget(controller: _controller),
            if (_isLoading) const Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }
}
