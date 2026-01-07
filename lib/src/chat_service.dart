import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

import 'chat_config.dart';
import 'chat_websocket_client.dart';

/// Service class that handles communication with the chat backend.
///
/// Supports both HTTP REST API and WebSocket connections based on
/// the endpoint URL scheme in [ChatConfig.apiEndpoint].
///
/// - URLs starting with `ws://` or `wss://` use WebSocket
/// - URLs starting with `http://` or `https://` use HTTP POST
class ChatService {
  /// The configuration containing API endpoint and credentials.
  final ChatConfig config;
  ChatWebSocketClient? _wsClient;

  ChatService(this.config);
  Future<String> _sendViaWebSocket(String message) async {
    final chatId = _generateChatId();
    final wsUrl = '${config.apiEndpoint}/${config.apiKey}/$chatId/';

    _wsClient ??= ChatWebSocketClient(wsUrl, chatId);

    final completer = Completer<String>();

    _wsClient!.onMessage = (msg) {
      if (!completer.isCompleted) {
        completer.complete(msg);
      }
    };

    _wsClient!.onError = (err) {
      if (!completer.isCompleted) {
        completer.complete('WebSocket error: $err');
      }
    };

    await _wsClient!.connect();

    _wsClient!.sendMessage(message);

    return completer.future.timeout(
      const Duration(seconds: 40),
      onTimeout: () => 'WebSocket timeout.',
    );
  }

  String _generateChatId() {
    const uuid = Uuid();
    return uuid.v4();
  }

  Future<String> sendMessage(String message) async {
    if (config.apiEndpoint.startsWith('ws://') ||
        config.apiEndpoint.startsWith('wss://')) {
      return _sendViaWebSocket(message);
    }

    if (config.apiKey == null || config.apiKey!.isEmpty) {
      return 'Please configure an API key to enable AI responses.';
    }

    try {
      final response = await http.post(
        Uri.parse(config.apiEndpoint),
        headers: {
          'Authorization': 'Bearer ${config.apiKey}',
          'Content-Type': 'application/json',
          'HTTP-Referer': 'flutter-chatbot-widget',
          'X-Title': 'Chat Widget',
        },
        body: jsonEncode({
          'messages': [
            {'role': 'user', 'content': message},
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices']?[0]?['message']?['content'] ??
            'No response received.';
      } else {
        return 'Error: Failed to get response (${response.statusCode})';
      }
    } catch (e) {
      return 'Something went wrong. Please try again.';
    }
  }
}
