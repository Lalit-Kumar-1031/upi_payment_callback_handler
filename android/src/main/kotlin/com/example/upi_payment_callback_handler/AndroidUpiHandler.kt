package com.example.upi_payment_callback_handler

import android.app.Activity
import android.content.Intent
import android.net.Uri
import io.flutter.plugin.common.MethodChannel
import java.net.URLDecoder

class AndroidUpiHandler(
    private val activity: Activity,
    private val channel: MethodChannel
) {

    companion object {
        const val UPI_REQUEST_CODE = 2001
    }

    fun startPayment(intentLink: String) {
        try {
            if (intentLink.isEmpty()) {
                sendEvent(
                    event = "onError",
                    data = mapOf("errorMsg" to "Invalid intent link")
                )
                return
            }

            val uri = Uri.parse(intentLink)

            val intent = Intent(Intent.ACTION_VIEW).apply {
                data = uri
            }

            val chooser = Intent.createChooser(intent, "Pay with")

            sendEvent(
                event = "onPaymentInitiated",
                data = mapOf(
                    "status" to "submitted",
                    "message" to "UPI app opened"
                )
            )

            activity.startActivityForResult(chooser, UPI_REQUEST_CODE)

        } catch (e: Exception) {
            sendEvent(
                event = "onError",
                data = mapOf("errorMsg" to (e.message ?: "Unknown error"))
            )
        }
    }

    fun handleResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        if (requestCode != UPI_REQUEST_CODE) return false

        if (resultCode == Activity.RESULT_CANCELED && data == null) {
            sendEvent("onPaymentCancelled", null)
            return true
        }

        val response = data?.getStringExtra("response")

        if (response.isNullOrEmpty()) {
            sendEvent(
                event = "onPaymentPendingVerification",
                data = mapOf("errorMsg" to "No response from UPI app")
            )
            return true
        }

        val parsed = parseResponse(response)
        val status = parsed["status"]?.lowercase()?.trim()

        val txnId = parsed["txnref"]
            ?: parsed["txnid"]
            ?: parsed["approvalrefno"]

        when {
            status == "success" && !txnId.isNullOrEmpty() -> {
                sendEvent("onPaymentSuccess", parsed)
            }

            status == "failure" || status == "failed" -> {
                sendEvent("onPaymentFailure", parsed)
            }

            status == "submitted" || status == "pending" -> {
                sendEvent("onPaymentPendingVerification", parsed)
            }

            else -> {
                sendEvent("onPaymentPendingVerification", parsed)
            }
        }

        return true
    }

    private fun sendEvent(event: String, data: Any?) {
        val response = HashMap<String, Any?>()
        response["eventType"] = event
        if (data != null) {
            response["response"] = data
        }
        channel.invokeMethod("onUpiEvent", response)
    }

    private fun parseResponse(response: String): HashMap<String, String> {
        val map = HashMap<String, String>()

        response.split("&").forEach {
            val parts = it.split("=", limit = 2)
            if (parts.size >= 2) {
                map[parts[0].lowercase()] =
                    URLDecoder.decode(parts[1], Charsets.UTF_8.name())
            }
        }

        return map
    }
}