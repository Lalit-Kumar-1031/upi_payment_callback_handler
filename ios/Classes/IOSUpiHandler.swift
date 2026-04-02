import Flutter
import UIKit

public final class IOSUpiHandler: NSObject {
    private weak var channel: FlutterMethodChannel?

    private var isUpiFlow = false
    private var didReceiveCallback = false

    init(channel: FlutterMethodChannel?) {
        self.channel = channel
    }

    func getAvailableUpiApps() -> [[String: String]] {
        let apps: [(id: String, scheme: String)] = [
            ("phonepe", "phonepe://"),
            ("gpay", "tez://"),
            ("paytm", "paytmmp://"),
            ("bhim", "bhim://")
        ]

        return apps.compactMap { app in
            guard let url = URL(string: app.scheme),
                  UIApplication.shared.canOpenURL(url) else {
                return nil
            }

            return ["id": app.id]
        }
    }

    func startPayment(app: String, params: String, result: @escaping FlutterResult) {
        var urlString: String?

        let encodedParams =
            params.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? params

        switch app {
        case "phonepe":
            urlString = "phonepe://pay?\(encodedParams)"
        case "gpay":
            urlString = "tez://upi/pay?\(encodedParams)"
        case "paytm":
            urlString = "paytmmp://pay?\(encodedParams)"
        case "bhim":
            urlString = "bhim://upi/pay?\(encodedParams)"
        default:
            sendEvent(
                event: "onError",
                data: ["errorMsg": "Unsupported UPI app"]
            )
            result(false)
            return
        }

        guard let finalUrlString = urlString,
              let url = URL(string: finalUrlString) else {
            sendEvent(
                event: "onError",
                data: ["errorMsg": "Invalid URL"]
            )
            result(false)
            return
        }

        if UIApplication.shared.canOpenURL(url) {
            isUpiFlow = true
            didReceiveCallback = false

            UIApplication.shared.open(url, options: [:]) { success in
                if success {
                    self.sendEvent(
                        event: "onPaymentInitiated",
                        data: [
                            "status": "submitted",
                            "message": "UPI app opened"
                        ]
                    )
                } else {
                    self.sendEvent(
                        event: "onError",
                        data: [
                            "errorMsg": "Unable to open UPI app"
                        ]
                    )
                }
            }

            result(true)
        } else {
            sendEvent(
                event: "onError",
                data: [
                    "errorMsg": "\(app) not installed"
                ]
            )
            result(false)
        }
    }

    func handleOpenUrl(_ url: URL) {
        didReceiveCallback = true

        // Optional:
        // Later you can parse the returned callback URL here
        // and directly emit success/failure if gateway/app provides that data.
    }

    func handleAppDidBecomeActive() {
        if isUpiFlow {
            sendEvent(event: "onPaymentPendingVerification", data: nil)
        }

        isUpiFlow = false
        didReceiveCallback = false
    }

    private func sendEvent(event: String, data: Any?) {
        var response: [String: Any] = [
            "eventType": event
        ]

        if let data = data {
            response["response"] = data
        }

        DispatchQueue.main.async {
            self.channel?.invokeMethod("onUpiEvent", arguments: response)
        }
    }
}