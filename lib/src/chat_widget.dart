import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'chat_config.dart';
import 'chat_message.dart';
import 'chat_service.dart';

/// A floating chatbot widget that overlays your app content.
///
/// Wrap your app's main content with [ChatBotWidget] to add a floating
/// chat button that opens a beautiful chat interface.
///
/// Example:
/// ```dart
/// ChatBotWidget(
///   config: const ChatConfig(
///     title: 'Support Bot',
///     themeColor: Colors.blue,
///   ),
///   child: Scaffold(
///     body: YourContent(),
///   ),
/// )
/// ```
///
/// The widget displays a floating action button that, when tapped,
/// opens an animated chat window with:
/// - Custom header with bot title
/// - Message list with user/bot bubbles
/// - Input field with send button
/// - Typing indicator animation
class ChatBotWidget extends StatefulWidget {
  /// The main content of your app that the chat button overlays.
  final Widget child;

  /// Configuration for the chatbot appearance and behavior.
  ///
  /// See [ChatConfig] for available options.
  final ChatConfig config;

  const ChatBotWidget({
    super.key,
    required this.child,
    this.config = const ChatConfig(title: ''),
  });

  @override
  State<ChatBotWidget> createState() => _ChatBotWidgetState();
}

class _ChatBotWidgetState extends State<ChatBotWidget>
    with SingleTickerProviderStateMixin {
  bool _isOpen = false;
  bool _isTyping = false;
  final List<ChatMessage> _messages = [];
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  late ChatService _chatService;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _chatService = ChatService(widget.config);

    _messages.add(ChatMessage(
      text: widget.config.initialMessage,
      sender: MessageSender.bot,
    ));

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    );
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _toggleChat() {
    setState(() {
      _isOpen = !_isOpen;
      if (_isOpen) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(
        text: text,
        sender: MessageSender.user,
      ));
      _isTyping = true;
    });

    _inputController.clear();
    _scrollToBottom();

    try {
      final response = await _chatService.sendMessage(text);
      setState(() {
        _messages.add(ChatMessage(
          text: response,
          sender: MessageSender.bot,
        ));
        _isTyping = false;
      });
    } catch (e) {
      setState(() {
        _messages.add(ChatMessage(
          text: 'Something went wrong.',
          sender: MessageSender.bot,
        ));
        _isTyping = false;
      });
    }

    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Color _mixColor(Color base, Color mix, double amount) {
    return Color.lerp(base, mix, amount)!;
  }

  @override
  Widget build(BuildContext context) {
    final config = widget.config;
    final headerColor = _mixColor(config.themeColor, Colors.black, 0.3);
    final bodyColor = _mixColor(config.themeColor, Colors.white, 0.88);
    final userMsgColor = _mixColor(config.themeColor, Colors.black, 0.3);
    final botMsgColor = _mixColor(config.themeColor, Colors.black, 0.1);

    double windowWidth = 90.w;
    double windowHeight = 60.h;
    double minPadding = 2.w;

    if (MediaQuery.of(context).size.shortestSide >= 600) {
      windowWidth = 60.w;
      windowHeight = 55.h;
    }

    final mediaQuery = MediaQuery.of(context);
    final viewInsets = mediaQuery.viewInsets;
    final keyboardVisible = viewInsets.bottom > 0;

    double availableHeight = mediaQuery.size.height -
        (keyboardVisible ? viewInsets.bottom : 0) -
        (config.bottomOffset + config.buttonSize + 40.0);
    double minChatHeight = 30.h;
    double responsiveHeight = keyboardVisible
        ? (availableHeight > minChatHeight ? minChatHeight : availableHeight)
        : windowHeight;

    return Stack(
      children: [
        widget.child,
        if (_isOpen)
          AnimatedPadding(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            padding: EdgeInsets.only(
              bottom: keyboardVisible
                  ? viewInsets.bottom + 8.0
                  : config.bottomOffset + config.buttonSize + 24.0,
              right: config.rightOffset,
              left: minPadding,
            ),
            child: Align(
              alignment: Alignment.bottomRight,
              child: ScaleTransition(
                scale: _scaleAnimation,
                alignment: Alignment.bottomRight,
                child: Material(
                  elevation: 8,
                  borderRadius:
                      BorderRadius.circular(config.windowBorderRadius),
                  child: Container(
                    width: windowWidth,
                    height: responsiveHeight,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(config.windowBorderRadius),
                    ),
                    child: Column(
                      children: [
                        _buildHeader(config, headerColor),
                        _buildMessageList(
                            config, bodyColor, userMsgColor, botMsgColor),
                        _buildInputArea(config),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        Positioned(
          bottom: config.bottomOffset,
          right: config.rightOffset,
          child: _buildChatButton(config),
        ),
      ],
    );
  }

  Widget _buildHeader(ChatConfig config, Color headerColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: headerColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(config.windowBorderRadius),
          topRight: Radius.circular(config.windowBorderRadius),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.white24,
            backgroundImage: config.profilePicUrl != null
                ? NetworkImage(config.profilePicUrl!)
                : null,
            child: config.profilePicUrl == null
                ? const Icon(Icons.smart_toy, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  config.title,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16.sp,
                  ),
                ),
                Text(
                  _isTyping ? 'typing...' : 'online',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 13.sp,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: _toggleChat,
            child: const Icon(
              Icons.close,
              color: Colors.white,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList(
    ChatConfig config,
    Color bodyColor,
    Color userMsgColor,
    Color botMsgColor,
  ) {
    return Expanded(
      child: Container(
        color: bodyColor,
        child: ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(12),
          itemCount: _messages.length + (_isTyping ? 1 : 0),
          itemBuilder: (context, index) {
            if (_isTyping && index == _messages.length) {
              return _buildTypingIndicator(botMsgColor);
            }

            final message = _messages[index];
            return _buildMessageBubble(
              message,
              message.isUser ? userMsgColor : botMsgColor,
            );
          },
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message, Color bgColor) {
    double maxBubbleWidth = 70.w;

    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(bottom: 1.h),
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
        constraints: BoxConstraints(
          maxWidth: maxBubbleWidth,
        ),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          message.text,
          style: TextStyle(
            color: Colors.white,
            fontSize: 14.sp,
          ),
        ),
      ),
    );
  }

  Widget _buildTypingIndicator(Color bgColor) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDot(0),
            const SizedBox(width: 4),
            _buildDot(1),
            const SizedBox(width: 4),
            _buildDot(2),
          ],
        ),
      ),
    );
  }

  Widget _buildDot(int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600 + (index * 200)),
      builder: (context, value, child) {
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.5 + (0.5 * value)),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }

  Widget _buildInputArea(ChatConfig config) {
    final footerColor = _mixColor(config.themeColor, Colors.white, 0.9);

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: footerColor,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(config.windowBorderRadius),
          bottomRight: Radius.circular(config.windowBorderRadius),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Container(
              constraints: const BoxConstraints(maxHeight: 100),
              child: TextField(
                controller: _inputController,
                focusNode: _focusNode,
                maxLines: null,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
                decoration: InputDecoration(
                  hintText: config.inputPlaceholder,
                  hintStyle: TextStyle(color: Colors.grey[600]),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(color: config.themeColor),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Material(
            color: config.themeColor,
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              onTap: _sendMessage,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.all(10),
                child: const Icon(
                  Icons.send,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatButton(ChatConfig config) {
    return Material(
      elevation: 4,
      shape: const CircleBorder(),
      color: config.themeColor,
      child: InkWell(
        onTap: _toggleChat,
        customBorder: const CircleBorder(),
        child: Container(
          width: config.buttonSize,
          height: config.buttonSize,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
          ),
          child: Icon(
            _isOpen ? Icons.close : Icons.chat_bubble,
            color: Colors.white,
            size: 28,
          ),
        ),
      ),
    );
  }
}
