
import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NetworkController extends GetxController {
final Connectivity _connectivity = Connectivity();

StreamSubscription<List<ConnectivityResult>>?
_connectivitySubscription;

bool _isConnected = true;
bool _isFirstCheck = true;

@override
void onInit() {
super.onInit();

_checkInitialConnection();

_connectivitySubscription =
_connectivity.onConnectivityChanged.listen(
(List<ConnectivityResult> results) {
_updateConnectionStatus(results);
},
);
}

// ============================================================
// CHECK INITIAL INTERNET CONNECTION
// ============================================================

Future<void> _checkInitialConnection() async {
try {
final results = await _connectivity.checkConnectivity();

_updateConnectionStatus(
results,
showNotification: false,
);
} catch (e) {
_isConnected = false;
}
}

// ============================================================
// UPDATE CONNECTION STATUS
// ============================================================

void _updateConnectionStatus(
List<ConnectivityResult> results, {
bool showNotification = true,
}) {
final bool hasConnection =
results.contains(ConnectivityResult.wifi) ||
results.contains(ConnectivityResult.mobile) ||
results.contains(ConnectivityResult.ethernet) ||
results.contains(ConnectivityResult.vpn);

if (_isFirstCheck) {
_isConnected = hasConnection;
_isFirstCheck = false;
return;
}

// Don't show duplicate notifications
if (_isConnected == hasConnection) {
return;
}

_isConnected = hasConnection;

if (!showNotification) {
return;
}

if (_isConnected) {
_showConnectedNotification();
} else {
_showDisconnectedNotification();
}
}

// ============================================================
// SHOW INTERNET INTERRUPTED
// ============================================================

void _showDisconnectedNotification() {
Get.snackbar(
'Internet',
'Internet Interrupted',
snackPosition: SnackPosition.TOP,
backgroundColor: const Color(0xFFFF5252),
colorText: Colors.white,
icon: const Icon(
Icons.wifi_off,
color: Colors.white,
),
margin: const EdgeInsets.all(8),
borderRadius: 12,
duration: const Duration(seconds: 4),
isDismissible: true,
dismissDirection: DismissDirection.horizontal,
);
}

// ============================================================
// SHOW INTERNET CONNECTED
// ============================================================

void _showConnectedNotification() {
Get.snackbar(
'Internet',
'Internet Connected',
snackPosition: SnackPosition.TOP,
backgroundColor: const Color(0xFF4CAF50),
colorText: Colors.white,
icon: const Icon(
Icons.wifi,
color: Colors.white,
),
margin: const EdgeInsets.all(8),
borderRadius: 12,
duration: const Duration(seconds: 3),
isDismissible: true,
dismissDirection: DismissDirection.horizontal,
);
}

// ============================================================
// SHOW NETWORK ERROR
// ============================================================
//
// This method is used by FirestoreService when a
// Firestore operation fails because of network problems.
//

void showNetworkError() {
// Avoid showing multiple network errors at the same time.
if (Get.isSnackbarOpen) {
return;
}

Get.snackbar(
'Internet',
'Internet Interrupted',
snackPosition: SnackPosition.TOP,
backgroundColor: const Color(0xFFFF5252),
colorText: Colors.white,
icon: const Icon(
Icons.wifi_off,
color: Colors.white,
),
margin: const EdgeInsets.all(8),
borderRadius: 12,
duration: const Duration(seconds: 4),
isDismissible: true,
dismissDirection: DismissDirection.horizontal,
);
}

// ============================================================
// CLOSE CONTROLLER
// ============================================================

@override
void onClose() {
_connectivitySubscription?.cancel();
super.onClose();
}
}

