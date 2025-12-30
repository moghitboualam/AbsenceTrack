import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';
import '../../services/api_service.dart';

class WebSocketService {
  StompClient? _client;
  final ApiService _apiService = ApiService();

  // Singleton pattern
  static final WebSocketService _instance = WebSocketService._internal();
  factory WebSocketService() => _instance;
  WebSocketService._internal();

  // Stream controller to broadcast notifications to the UI
  final _notificationController =
      StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get notificationStream =>
      _notificationController.stream;

  bool _isConnected = false;
  String? _currentClassId;

  /// Initialize and connect the WebSocket
  void connect(String classId) {
    if (_isConnected && _currentClassId == classId) return;

    _cleanup(); // Close existing connection if any
    _currentClassId = classId;

    // Build the WebSocket URL (ws:// or wss://)
    final baseUrl = _apiService.baseUrl;
    final wsUrl = '${baseUrl.replaceFirst('http', 'ws')}/ws';

    _client = StompClient(
      config: StompConfig(
        url: wsUrl,
        onConnect: _onConnect,
        onWebSocketError: (dynamic error) =>
            debugPrint('WebSocket Error: $error'),
        onDisconnect: (frame) {
          _isConnected = false;
          debugPrint('WebSocket Disconnected');
        },
        // Auto reconnect is handled by the library by default
      ),
    );

    _client?.activate();
  }

  void _onConnect(StompFrame frame) {
    _isConnected = true;
    debugPrint('WebSocket Connected!');
    debugPrint(
      'Successfully connected to WebSocket server at ${_apiService.baseUrl}',
    );
    print('Testing connection: SENT TEST MESSAGE TO SERVER');

    // Subscribe to class-specific topic
    if (_currentClassId != null) {
      final topic = '/topic/classe/$_currentClassId';
      _client?.subscribe(
        destination: topic,
        callback: (StompFrame frame) {
          if (frame.body != null) {
            try {
              final data = jsonDecode(frame.body!);
              debugPrint('Received Notification: $data');
              _notificationController.add(data);
            } catch (e) {
              debugPrint('Error parsing notification: $e');
            }
          }
        },
      );
    }
  }

  void disconnect() {
    _cleanup();
  }

  void _cleanup() {
    _client?.deactivate();
    _client = null;
    _isConnected = false;
  }

  void dispose() {
    _notificationController.close();
    _cleanup();
  }
}
