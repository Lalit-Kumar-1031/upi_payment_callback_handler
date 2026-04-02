import 'dart:io';
import 'package:flutter/services.dart';

abstract class UpiPaymentListener {
  void onSuccess(Map data) {}
  void onFailure(Map data) {}
  void onCancel() {}
  void onError(dynamic error) {}
  void onInitiated(Map data) {}
  void onPendingVerification() {}
}

class UpiPaymentCallbackHandler {
  static const MethodChannel _channel =
      MethodChannel('upi_payment_callback_handler');

  static UpiPaymentListener? _listener;

  static void setListener(UpiPaymentListener listener) {
    _listener = listener;

    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onUpiEvent') {
        final Map data = Map<String, dynamic>.from(call.arguments);

        final String event = data['eventType']?.toString() ?? '';
        final dynamic response = data['response'];

        _handleEvent(event, response);
      }
    });
  }

  static void _handleEvent(String event, dynamic response) {
    if (_listener == null) return;

    switch (event) {
      case 'onPaymentInitiated':
        _listener!.onInitiated(Map<String, dynamic>.from(response ?? {}));
        break;

      case 'onPaymentSuccess':
        _listener!.onSuccess(Map<String, dynamic>.from(response ?? {}));
        break;

      case 'onPaymentFailure':
        _listener!.onFailure(Map<String, dynamic>.from(response ?? {}));
        break;

      case 'onPaymentCancelled':
        _listener!.onCancel();
        break;

      case 'onPaymentPendingVerification':
        _listener!.onPendingVerification();
        break;

      case 'onError':
        _listener!.onError(response);
        break;
    }
  }

  static Future<List<dynamic>> getUpiApps() async {
    if (Platform.isIOS) {
      final result = await _channel.invokeMethod<List<dynamic>>('getUpiApps');
      return result ?? [];
    }
    return [];
  }

  static Future<void> startPayment({
    String? intentLink,
    String? app,
    String? params,
  }) async {
    if (Platform.isAndroid) {
      await _channel.invokeMethod('startUPIPayment', {
        'intentLink': intentLink,
      });
    } else if (Platform.isIOS) {
      await _channel.invokeMethod('startUPIPayment', {
        'app': app,
        'params': params,
      });
    }
  }

  static void removeListener() {
    _listener = null;
    _channel.setMethodCallHandler(null);
  }
}