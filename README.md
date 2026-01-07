# Chatbot Support Kit

[![pub package](https://img.shields.io/pub/v/chatbot_support_kit.svg)](https://pub.dev/packages/chatbot_support_kit)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A customizable floating chatbot widget for Flutter apps. Similar to web chat widgets, this package adds a floating chat button to your app that opens a beautiful chat interface with AI integration support.

## ✨ Features

- 🎯 **Drop-in Widget** - Wrap any widget to add chat functionality
- 💬 **Beautiful Chat UI** - Modern chat interface with smooth animations
- 🎨 **Fully Customizable** - Colors, sizes, messages, and positioning
- 🤖 **AI Integration** - Built-in support for AI-powered responses
- 🔌 **WebSocket Support** - Real-time communication via WebSocket
- ⌨️ **Typing Indicator** - Animated typing indicator for bot responses
- 📱 **Responsive** - Works on all screen sizes

## 📸 Preview

<div align="center">
  <img src="https://raw.githubusercontent.com/Avya-Technologies/chatbot-support-kit/main/assets/demo.gif" alt="chatbot-support-kit" width="320"/>
</div>

## 🚀 Installation

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  chatbot_support_kit: ^1.0.0
```

Then run:

```bash
flutter pub get
```

## 📖 Usage

### Basic Usage

Wrap your app content with `ChatBotWidget`:

```dart
import 'package:chatbot_support_kit/chatbot_support_kit.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ChatBot Widget Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const ChatBotWidget(
        config: ChatConfig(
          title: 'Support Bot',
          themeColor: Color(0xFF007BFF),
          initialMessage: 'Hi! How can I help you today?',
          profilePicUrl: 'https://i.pravatar.cc/40',
          apiKey:
              "your-api-key",// See API Key Configuration
        ),
        child: HomePage(),
      ),
    );
  }
}
```

## 🔐 API Key Configuration

This package requires a valid **API key** to enable AI-powered chatbot functionality.

> **Note**  
> To obtain a customized AI integration API key for your application,  
> please contact the development team at **https://avya.lk/**

## ⚙️ Configuration Options

| Property           | Type      | Default                     | Description                        |
| ------------------ | --------- | --------------------------- | ---------------------------------- |
| `title`            | `String`  | _required_                  | Title displayed in the chat header |
| `themeColor`       | `Color`   | `Color(0xFF007BFF)`         | Primary color for the chat widget  |
| `initialMessage`   | `String`  | `'Hi! How can I help you?'` | Bot's greeting message             |
| `inputPlaceholder` | `String`  | `'Type a message'`          | Placeholder text in input field    |
| `apiKey`           | `String?` | `null`                      | API key for backend authentication |
| `profilePicUrl`    | `String?` | `null`                      | URL for bot's profile picture      |

## 🏗️ Architecture

```
lib/
├── chatbot_support_kit.dart        # Main export file
└── src/
    ├── chat_widget.dart          # Main ChatBotWidget
    ├── chat_config.dart          # ChatConfig configuration class
    ├── chat_message.dart         # ChatMessage model
    ├── chat_service.dart         # API/WebSocket service
    └── chat_websocket_client.dart # WebSocket client
```

## 📱 Platform Support

| Platform | Supported |
| -------- | --------- |
| Android  | ✅        |
| iOS      | ✅        |
| Web      | ✅        |
| macOS    | ✅        |
| Windows  | ✅        |
| Linux    | ✅        |

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## ❤️ Support

If you find this package helpful, please give it a ⭐️ on GitHub!

## 🐛 Issues

Found a bug? Please file an issue on [GitHub](https://github.com/Avya-Technologies/chatbot-support-kit/issues).
