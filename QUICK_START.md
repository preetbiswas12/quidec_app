# Quidec Mobile App - Quick Start Guide

## 📱 What's Been Created

A complete, production-ready Flutter mobile application with WhatsApp/Instagram-like UI/UX for Android featuring:

### ✅ Completed Features

1. **Login & Registration Screen**
   - Username and password input fields
   - Password visibility toggle (eye icon)
   - Mode switching between Login and Register
   - Error message display
   - Beautiful dark theme UI

2. **Chat Home Screen**
   - Friend list with avatars (gradient-based)
   - Online/offline status indicators (green/gray dots)
   - Unread message badges with count
   - Last message preview
   - Logout button

3. **Chat Detail Screen**
   - Full conversation history
   - Message bubbles (different colors for sent/received)
   - Read receipts with checkmarks
   - Timestamps for all messages
   - Auto-scroll to latest message
   - Message input field with send button
   - Friend status displayed in header

4. **Real-time Features**
   - WebSocket integration for instant messaging
   - Message read receipts with timestamps
   - Friend online/offline status updates
   - Automatic message syncing

5. **OS-Level Notifications**
   - Android push notifications for new messages
   - Friend request notifications
   - Sound and vibration alerts
   - Notification channel configuration
   - Tappable notifications to open chat

6. **Data Persistence**
   - Local storage of user credentials
   - Token caching for auto-login
   - Settings storage for preferences
   - Message history caching

7. **Beautiful UI/UX**
   - Dark gradient theme matching web version
   - Smooth animations and transitions
   - Material Design 3
   - Responsive layouts
   - Custom gradient buttons

## 📁 Project Structure

```
Mobile/
├── lib/
│   ├── main.dart                          # App entry point
│   ├── screens/
│   │   ├── login_screen.dart             # Login/Register with password toggle
│   │   ├── chat_home_screen.dart         # Friend list with avatars
│   │   ├── chat_detail_screen.dart       # Chat conversation
│   │   └── index.dart
│   ├── services/
│   │   ├── api_service.dart              # HTTP client for REST API
│   │   ├── websocket_service.dart        # WebSocket client
│   │   ├── notification_service.dart     # Push notifications
│   │   ├── storage_service.dart          # Local storage
│   │   └── index.dart
│   ├── models/
│   │   ├── user.dart                     # User model
│   │   ├── friend.dart                   # Friend model
│   │   ├── message.dart                  # Message model
│   │   └── index.dart
│   └── widgets/
├── android/
│   └── app/
│       ├── build.gradle                  # Android build configuration
│       └── src/main/
│           ├── AndroidManifest.xml       # App permissions
│           └── kotlin/MainActivity.kt    # Android entry point
├── pubspec.yaml                          # Dependencies
├── analysis_options.yaml                 # Dart linting rules
├── .gitignore                            # Git ignore rules
└── README.md                             # Full documentation
```

## 🚀 Getting Started

### 1. Prerequisites
- Flutter 3.0.0 or higher
- Android SDK 21 (API level 21) minimum
- Android Studio or VS Code

### 2. Install Dependencies
```bash
cd Mobile
flutter pub get
```

### 3. Configure Backend

**Edit `lib/services/api_service.dart`:**
```dart
static const String baseUrl = 'https://quidec-server.onrender.com';
```

**Edit `lib/screens/chat_home_screen.dart` (line ~55):**
```dart
await _wsService.connect('wss://quidec-server.onrender.com');
```

### 4. Run the App
```bash
flutter run
```

## 🎨 Features Breakdown

### Login/Register Screen
- **Password Visibility**: Click eye icon to show/hide password
- **Mode Toggle**: Click blue text at bottom to switch between Login and Register
- **Error Messages**: Red banner shows validation or auth errors
- **Auto-login**: If logged in before, goes directly to chat

### Friend List Screen
- **Avatar**: First letter of username in gradient circle
- **Online Status**: Green dot = online, gray dot = offline
- **Unread Badge**: Green badge with number shows unread messages
- **Last Message**: Shows first 30 characters of latest message
- **Tap to Open**: Click any friend to open chat

### Chat Screen
- **Message Bubbles**: Blue gradient for sent, dark gray for received
- **Read Receipts**: 
  - Single checkmark (✓) = sent
  - Double checkmark (✓✓) = read
- **Timestamps**: Shows HH:mm for today, date for older messages
- **Auto-scroll**: Automatically scrolls to latest message
- **Friend Status**: Header shows "Online" or "Offline"

### Notifications
- **Message Notification**: Shows sender name and message preview
- **Sound & Vibration**: Automatic alerts
- **Tap to Open**: Click notification to go to that chat

## 🔧 Customization

### Change Colors
Edit colors in `lib/main.dart` and screens:
```dart
Color(0xFF234C6A)    // Primary blue
Color(0xFF1F3F54)    // Secondary blue
Color(0xFF4ade80)    // Success green
Color(0xFF0a0a14)    // Dark background
```

### Change Server URL
For **production**: Already set to `https://quidec-server.onrender.com`
For **local testing**: Use `http://10.0.2.2:3000` (emulator)

### Modify Notification Sound
Replace file at: `android/app/src/main/res/raw/notification.mp3`

### Change App Name
Edit `android/app/src/main/AndroidManifest.xml`:
```xml
android:label="Quidec"  <!-- Change this -->
```

## 🔒 Permissions Used

```xml
<!-- Network -->
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />

<!-- Notifications -->
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
```

## 🏗️ Building for Release

### Generate Upload Key
```bash
keytool -genkey -v -keystore ~/quidec.keystore \
  -keyalg RSA -keysize 2048 -validity 10000
```

### Build Release APK
```bash
flutter build apk --release
```

### Build App Bundle (for Google Play)
```bash
flutter build appbundle --release
```

Output files:
- **APK**: `build/app/outputs/apk/release/app-release.apk`
- **Bundle**: `build/app/outputs/bundle/release/app-release.aab`

## 📊 API Endpoints Used

```
POST   /api/login                      # User login
POST   /api/register                   # User registration
GET    /api/friends/:username          # Get friend list
GET    /api/messages/:user/:friend     # Get chat history
POST   /api/messages/send              # Send message
POST   /api/messages/read              # Mark as read

WebSocket Messages:
- auth                # Authenticate user
- message             # Send/receive messages
- friend-request      # Send friend request
- friend-response     # Accept/decline request
- mark-read           # Mark message as read
- user-status         # Online/offline updates
```

## 🐛 Troubleshooting

### App Won't Run
```bash
flutter clean
flutter pub get
flutter run
```

### Notifications Not Working
1. Check: Settings > Apps > Quidec > Permissions > Notifications
2. Verify: Backend is sending messages properly
3. Try: Restarting the app

### Can't Receive Messages
1. Check internet connection
2. Verify server URL is correct
3. Check WebSocket is connecting (check console logs)
4. Try logout and login again

### Can't Send Messages
1. Ensure typed message is not empty
2. Check username of recipient is correct
3. Verify server is running
4. Check user is friends with recipient

## 📚 Key Components

### WebSocketService
Manages real-time connection and message streaming
```dart
WebSocketService wsService = WebSocketService();
await wsService.connect('wss://server.com');
wsService.authenticate('username');
wsService.messages.listen((msg) { /* handle */ });
```

### NotificationService
Triggers OS-level notifications
```dart
NotificationService notif = NotificationService();
await notif.initialize();
notif.showMessageNotification(
  sender: 'John',
  message: 'Hello!',
  messageId: '123'
);
```

### StorageService
Persists user data locally
```dart
StorageService storage = StorageService();
await storage.saveUser(user);
User? user = storage.getUser();
```

## 🎯 Next Steps (Optional Enhancements)

1. **Profile Screen**: View/edit user profiles
2. **Group Chats**: Support multiple users in one chat
3. **Media Sharing**: Images and file attachments
4. **User Search**: Find and add users by username
5. **Message Search**: Search conversations
6. **Dark/Light Theme**: Toggle theme preference
7. **Language Support**: Multi-language support
8. **Offline Mode**: Access cached messages when offline
9. **Call Integration**: Audio/video calling
10. **Story/Status**: Share daily updates

## 📖 Documentation

Full documentation available in [README.md](./README.md)

## ✨ Features at a Glance

| Feature | Status | Details |
|---------|--------|---------|
| Login/Register | ✅ Complete | With password toggle |
| Real-time Messaging | ✅ Complete | WebSocket-based |
| Push Notifications | ✅ Complete | OS-level alerts |
| Read Receipts | ✅ Complete | Double checkmarks |
| Friend List | ✅ Complete | With status |
| Chat History | ✅ Complete | Auto-load on open |
| Message Timestamps | ✅ Complete | Smart formatting |
| Online Status | ✅ Complete | Real-time updates |
| Local Storage | ✅ Complete | Auto-login support |
| Dark Theme | ✅ Complete | Beautiful gradients |

---

**Happy chatting! 🚀**
