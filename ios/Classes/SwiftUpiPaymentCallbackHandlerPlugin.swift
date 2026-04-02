import Flutter
import UIKit

public class SwiftUpiPaymentCallbackHandlerPlugin: NSObject, FlutterPlugin, UIApplicationDelegate {
  private static var channel: FlutterMethodChannel?
  private static var upiHandler: IOSUpiHandler?

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: "upi_payment_callback_handler",
      binaryMessenger: registrar.messenger()
    )

    let instance = SwiftUpiPaymentCallbackHandlerPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
    registrar.addApplicationDelegate(instance)

    SwiftUpiPaymentCallbackHandlerPlugin.channel = channel
    SwiftUpiPaymentCallbackHandlerPlugin.upiHandler = IOSUpiHandler(channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let upiHandler = SwiftUpiPaymentCallbackHandlerPlugin.upiHandler else {
      result(
        FlutterError(
          code: "HANDLER_NULL",
          message: "UPI handler not initialized",
          details: nil
        )
      )
      return
    }

    switch call.method {
    case "getUpiApps":
      result(upiHandler.getAvailableUpiApps())

    case "startUPIPayment":
      guard let args = call.arguments as? [String: Any] else {
        result(
          FlutterError(
            code: "INVALID_ARGS",
            message: "Arguments missing",
            details: nil
          )
        )
        return
      }

      guard let app = args["app"] as? String,
            let params = args["params"] as? String else {
        result(
          FlutterError(
            code: "INVALID",
            message: "Missing app or params",
            details: nil
          )
        )
        return
      }

      upiHandler.startPayment(app: app, params: params, result: result)

    default:
      result(FlutterMethodNotImplemented)
    }
  }

  public func application(
    _ application: UIApplication,
    open url: URL,
    options: [UIApplication.OpenURLOptionsKey : Any] = [:]
  ) -> Bool {
    SwiftUpiPaymentCallbackHandlerPlugin.upiHandler?.handleOpenUrl(url)
    return true
  }

  public func applicationDidBecomeActive(_ application: UIApplication) {
    SwiftUpiPaymentCallbackHandlerPlugin.upiHandler?.handleAppDidBecomeActive()
  }
}