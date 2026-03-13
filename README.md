# Quidec Mobile App - Flutter

A beautiful, feature-rich real-time chat application for Android built with Flutter. Combines the WhatsApp-like UI/UX from the web version with native mobile capabilities including OS-level push notifications.

## Features

✨ **Real-time Messaging**
- WebSocket-based instant messaging
- Message read receipts with timestamps
- Auto-scrolling to latest messages

🔔 **Push Notifications**
- OS-level Android notifications for new messages
- Friend request notifications
- Sound and vibration alerts

🎨 **Beautiful UI/UX**
- Dark theme with gradient accents
- WhatsApp-like message bubbles
- Smooth animations and transitions
- Responsive material design

🔐 **Authentication**
- Secure login and registration
- Password visibility toggle
- Token-based authentication
- Local storage of credentials

👥 **Friend Management**
- Friend list with online/offline status
- Last message preview
- Unread message count

## Prerequisites

- Flutter SDK 3.0.0 or higher
- Android SDK 21 (API level 21) or higher
- Android Studio or VS Code with Flutter extension

## Installation

### 1. Clone the Project
```bash
cd Mobile
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Configure Backend URL

Edit `lib/services/api_service.dart`:
```dart
static const String baseUrl = 'https://quidec-server.onrender.com';
// For local testing: 'http://10.0.2.2:3000'
```

Also update the WebSocket URL in `lib/screens/chat_home_screen.dart`:
```dart
await _wsService.connect('wss://quidec-server.onrender.com');
// For local: 'ws://10.0.2.2:3000'
```

## Running the App

### Development
```bash
flutter run
```

### Run on Specific Device
```bash
flutter run -d <device_id>
```

### List Available Devices
```bash
flutter devices
```

### Build Release APK
```bash
flutter build apk --release
```

### Build Release App Bundle
```bash
flutter build appbundle --release
```

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── screens/
│   ├── login_screen.dart    # Login/Register with password toggle
│   ├── chat_home_screen.dart # Friend list
│   └── chat_detail_screen.dart # Chat conversation
├── services/
│   ├── api_service.dart     # HTTP client for REST API
│   ├── websocket_service.dart # WebSocket client
│   ├── notification_service.dart # Push notifications
│   └── storage_service.dart # Local storage (SharedPreferences)
├── models/
│   ├── user.dart            # User model
│   ├── friend.dart          # Friend model
│   └── message.dart         # Message model
└── widgets/                 # Reusable widgets

android/
├── app/build.gradle         # Android build config
└── src/main/
    ├── AndroidManifest.xml  # Permissions & app config
    └── kotlin/com/quidec/app/MainActivity.kt
```

## Features Breakdown

### Login Screen
- Username and password input
- Password visibility toggle (eye icon)
- Register/Login mode switch
- Error message display
- Loading indicator

### Chat Home Screen
- Friend list with avatars
- Online/offline status indicators
- Unread message badges
- Last message preview
- Logout functionality

### Chat Detail Screen
- Message history with timestamps
- Auto-scroll to latest message
- Message bubbles (different colors for sent/received)
- Read receipts (checkmark icons)
- Message input with send button
- Friend online status in header

### Notifications
- New message notifications
- Friend request notifications
- Sound and vibration alerts
- Tappable notifications to open chat

## API Integration

The app connects to the backend API at:
- **REST**: `https://quidec-server.onrender.com/api/`
- **WebSocket**: `wss://quidec-server.onrender.com`

### Supported Endpoints

**Authentication**
- `POST /api/login` - User login
- `POST /api/register` - User registration

**Friends**
- `GET /api/friends/:username` - Get friend list

**Messages**
- `GET /api/messages/:username/:withUser` - Get chat history
- `POST /api/messages/send` - Send message
- `POST /api/messages/read` - Mark message as read

## Notification Configuration

### Android Setup

Push notifications are automatically configured via:
1. `flutter_local_notifications` package
2. Android notification channel: `quidec_messages`
3. High priority notifications with sound/vibration

To test notifications, send a message from another user while the app is running.

## Customization

### Change Theme Colors

Edit `lib/main.dart`:
```dart
primaryColor: Color(0xFF234C6A),  // Primary blue
Color(0xFF0a0a14),                // Dark background
Color(0xFF4ade80),                // Success green
```

### Adjust Font Sizes

Edit individual screen files:
```dart
fontSize: 16,  // Adjust as needed
fontWeight: FontWeight.w600,
```

### Modify Notification Sound

Replace the notification sound at:
- `android/app/src/main/res/raw/notification.mp3`

## Troubleshooting

### App Crashes on Launch
1. Run `flutter clean`
2. Run `flutter pub get`
3. Rebuild with `flutter run`

### Notifications Not Showing
1. Check Android notifications are enabled in Settings
2. Verify notification channel is created
3. Check app permissions: Settings > Apps > Quidec > Notifications

### WebSocket Connection Issues
1. Ensure backend server is running
2. Check backend URL in code matches actual server
3. For local testing, use emulator IP: `10.0.2.2` instead of `localhost`
4. Check internet permission is granted

### Messages Not Syncing
1. Ensure WebSocket is connected
2. Check network connectivity
3. Verify token is valid and stored
4. Try logging out and back in

## Building for Production

1. **Generate Keystore**
```bash
keytool -genkey -v -keystore ~/quidec.keystore -keyalg RSA -keysize 2048 -validity 10000
```

2. **Create signing config** in `android/app/build.gradle`:
```gradle
signingConfigs {
    release {
        keyStore file(System.getenv("KEYSTORE_PATH"))
        keyStorePassword System.getenv("KEYSTORE_PASSWORD")
        keyAlias System.getenv("KEY_ALIAS")
        keyPassword System.getenv("KEY_PASSWORD")
    }
}
```

3. **Build Release APK**
```bash
KEYSTORE_PATH=~/quidec.keystore \
KEYSTORE_PASSWORD=your_password \
KEY_ALIAS=your_alias \
KEY_PASSWORD=your_password \
flutter build apk --release
```

The release APK will be at `build/app/outputs/apk/release/app-release.apk`

## Performance Tips

- Message list uses `ListView.builder` for efficient rendering
- Images are not cached on disk (can be added with `cached_network_image`)
- WebSocket auto-reconnects on disconnection
- Notifications are grouped by conversation

## Contributing

This is a personal project but improvements are welcome!

1. Create feature branch: `git checkout -b feature/amazing-feature`
2. Commit changes: `git commit -m 'Add amazing feature'`
3. Push to branch: `git push origin feature/amazing-feature`
4. Open a Pull Request

## License

MIT License - See LICENSE file for details

## Support

For issues and feature requests, please open an issue on GitHub.

---

**Built with ❤️ using Flutter**
