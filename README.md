# upi_payment_callback_handler

A Flutter plugin to launch UPI apps via intent link or deeplink and listen for payment callback events on **Android** and **iOS**.

Sample intentLink: "upi://pay?pa=test@upi&pn=Merchant&am=10&cu=INR&tn=PluginTest",

## What problem does this plugin solve?

Many payment gateways do not provide a Flutter SDK for handling app-based UPI or deep-link payment flows.

In such cases, Flutter developers often have to write native Android and iOS code in every project to:
- open the target UPI/payment app,
- receive callback events when the user returns,
- detect payment states such as success, failure, cancel, or pending,
- connect those native events back to Flutter.

This plugin solves that problem by providing a reusable Flutter API for:
- launching available UPI apps using an intent link or app-specific deeplink flow,
- listening to payment callback events,
- handling results directly in Flutter without rewriting native integration in every app.

## Use case

Use this plugin when:
- your payment gateway gives an intent link or deeplink flow,
- the gateway does **not** provide a Flutter SDK,
- you want to launch the payment app from Flutter,
- you want to listen for callback events like payment success, failure, cancelled, pending verification, or error,
- you want to navigate the user to different screens based on payment result.

## Features

- Launch UPI apps from Flutter
- Android intent-based payment app opening
- Android payment callback event parsing
- iOS available UPI app fetching
- iOS selected-app launch support
- Event-based callback handling
- Flutter-friendly listener API

## Supported callback events

- `onPaymentInitiated`
- `onPaymentSuccess`
- `onPaymentFailure`
- `onPaymentCancelled`
- `onPaymentPendingVerification`
- `onError`

## Important note

This plugin helps launch payment apps and receive callback events.

It should **not** be treated as the final source of truth for transaction success.

For production payment flows, always verify the final transaction status using your backend or payment gateway verification API after receiving the callback event.

---

## Installation

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  upi_payment_callback_handler: ^0.0.1
