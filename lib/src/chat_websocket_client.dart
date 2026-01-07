import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

/// A WebSocket client for real-time chat communication.
///
/// Handles connecting to WebSocket servers, sending messages,
/// and receiving responses.
///
/// Example:
/// ```dart
/// final client = ChatWebSocketClient('wss://example.com/chat');
/// client.onMessage = (msg) => print('Received: $msg');
/// await client.connect();
/// client.sendMessage('Hello!');
/// ```
class ChatWebSocketClient {
  /// The WebSocket server URL to connect to.
  final String url;
  late WebSocketChannel _channel;

  /// Callback invoked when a message is received from the server.
  void Function(String message)? onMessage;

  /// Callback invoked when the connection is closed.
  void Function()? onDone;

  /// Callback invoked when an error occurs.
  void Function(dynamic error)? onError;

  ChatWebSocketClient(this.url, String chatId);

  Future<void> connect() async {
    _channel = WebSocketChannel.connect(Uri.parse(url));
    _channel.stream.listen((event) {
      try {
        final data = jsonDecode(event);
        if (data is Map && data['response'] != null) {
          onMessage?.call(data['response']);
        }
      } catch (_) {}
    }, onDone: onDone, onError: onError);
  }

  void sendMessage(String message) {
    _channel.sink.add(message);
  }

  void disconnect() {
    _channel.sink.close();
  }
}
