/// Represents who sent a message in the chat.
enum MessageSender {
  /// Message sent by the user.
  user,

  /// Message sent by the bot.
  bot,
}

/// Represents a single message in the chat conversation.
///
/// Each message has text content, a sender, and a timestamp.
///
/// Example:
/// ```dart
/// final message = ChatMessage(
///   text: 'Hello!',
///   sender: MessageSender.user,
/// );
/// ```
class ChatMessage {
  /// The text content of the message.
  final String text;

  /// Who sent this message ([MessageSender.user] or [MessageSender.bot]).
  final MessageSender sender;

  /// When the message was created.
  ///
  /// Defaults to [DateTime.now] if not provided.
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.sender,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  bool get isUser => sender == MessageSender.user;

  bool get isBot => sender == MessageSender.bot;
}
