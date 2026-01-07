import 'package:flutter/material.dart';
import 'package:chatbot_support_kit/src/base_url.dart';

/// Configuration class for the ChatBot widget.
///
/// Use this to customize the appearance and behavior of the chatbot.
///
/// Example:
/// ```dart
/// const config = ChatConfig(
///   title: 'Support Bot',
///   themeColor: Colors.blue,
///   initialMessage: 'Hello! How can I help you?',
/// );
/// ```
class ChatConfig {
  /// The title displayed in the chat header.
  final String title;

  /// Optional URL for the bot's profile picture.
  final String? profilePicUrl;

  /// Primary theme color for the chat widget.
  ///
  /// Defaults to `Color(0xFF007BFF)` (blue).
  final Color themeColor;

  /// The initial greeting message from the bot.
  ///
  /// Defaults to `'Hi! How can I help you?'`.
  final String initialMessage;

  /// Placeholder text shown in the input field.
  ///
  /// Defaults to `'Type a message'`.
  final String inputPlaceholder;

  /// API key for authenticating with the chat backend.
  ///
  /// Required for AI-powered responses.
  final String? apiKey;

  /// The endpoint URL for the chat API or WebSocket server.
  ///
  /// Supports both HTTP(S) and WS(S) protocols.
  final String apiEndpoint;

  /// Distance from the bottom of the screen for the floating button.
  ///
  /// Defaults to `20.0`.
  final double bottomOffset;

  /// Distance from the right of the screen for the floating button.
  ///
  /// Defaults to `20.0`.
  final double rightOffset;

  /// Size of the floating action button.
  ///
  /// Defaults to `56.0`.
  final double buttonSize;

  /// Border radius of the chat window.
  ///
  /// Defaults to `12.0`.
  final double windowBorderRadius;

  /// Width of the chat window.
  ///
  /// Defaults to `350.0`.
  final double windowWidth;

  /// Height of the chat window.
  ///
  /// Defaults to `500.0`.
  final double windowHeight;

  const ChatConfig({
    required this.title,
    this.profilePicUrl,
    this.themeColor = const Color(0xFF007BFF),
    this.initialMessage = 'Hi! How can I help you?',
    this.inputPlaceholder = 'Type a message',
    this.apiKey,
    this.apiEndpoint = ServiceUrl.baseUrl,
    this.bottomOffset = 20.0,
    this.rightOffset = 20.0,
    this.buttonSize = 56.0,
    this.windowBorderRadius = 12.0,
    this.windowWidth = 350.0,
    this.windowHeight = 500.0,
  });

  ChatConfig copyWith({
    String? title,
    String? profilePicUrl,
    Color? themeColor,
    String? initialMessage,
    String? inputPlaceholder,
    String? apiKey,
    String? apiEndpoint,
    double? bottomOffset,
    double? rightOffset,
    double? buttonSize,
    double? windowBorderRadius,
    double? windowWidth,
    double? windowHeight,
  }) {
    return ChatConfig(
      title: title ?? this.title,
      profilePicUrl: profilePicUrl ?? this.profilePicUrl,
      themeColor: themeColor ?? this.themeColor,
      initialMessage: initialMessage ?? this.initialMessage,
      inputPlaceholder: inputPlaceholder ?? this.inputPlaceholder,
      apiKey: apiKey ?? this.apiKey,
      apiEndpoint: apiEndpoint ?? this.apiEndpoint,
      bottomOffset: bottomOffset ?? this.bottomOffset,
      rightOffset: rightOffset ?? this.rightOffset,
      buttonSize: buttonSize ?? this.buttonSize,
      windowBorderRadius: windowBorderRadius ?? this.windowBorderRadius,
      windowWidth: windowWidth ?? this.windowWidth,
      windowHeight: windowHeight ?? this.windowHeight,
    );
  }
}
