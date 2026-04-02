# upi_payment_callback_handler

A Flutter plugin to launch UPI apps via intent link or deeplink and make payment and listen for payment callback events on **Android** and **iOS** for navigating the user according to the payment status.

Sample intentLink: "upi://pay?pa=test@upi&pn=Merchant&am=10&cu=INR&tn=PluginTest",

## 🚀 What problem does this plugin solve?

In many real-world fintech apps, payment gateways:

❌ Do NOT provide a Flutter SDK  
❌ Only provide an **intent link / deeplink**  
❌ Require developers to write **native Android + iOS code**

This creates problems:

- Repeating native code in every project
- Difficult callback handling
- Inconsistent payment result handling
- Hard to maintain across platforms

---

## ✅ Solution

This plugin solves all of that by:

✔ Launching UPI apps using intent/deeplink  
✔ Fetching available UPI apps (iOS)  
✔ Handling payment callbacks (success / failure / cancel / pending)  
✔ Providing a **listener-based API in Flutter**  
✔ Eliminating the need to write native code again  

---

## 🎯 Use Case

Use this plugin when:

- Your payment gateway gives **intent link / deeplink**
- No Flutter SDK is available
- You want to:
  - open UPI apps
  - handle payment result
  - navigate user accordingly

---

## 📱 Supported Platforms

- ✅ Android
- ✅ iOS

---

## 🎥 Demo

### 🤖 Android Flow
![Android Demo](screenshots/android.gif)

### 🍎 iOS Flow
![iOS Demo](https://raw.githubusercontent.com/your-username/upi_payment_callback_handler/main/screenshots/ios_demo.gif)

---

## 📦 Installation

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  upi_payment_callback_handler: ^0.0.1
