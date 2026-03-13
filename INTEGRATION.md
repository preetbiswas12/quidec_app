# Mobile App Integration Guide

This document explains how the Flutter Mobile app integrates with the existing Quidec backend and web frontend.

## Architecture Overview

```
┌─────────────────────┐
│   Flutter Mobile    │  (Android via WebSocket + HTTP)
│   (lib/main.dart)   │
└──────────┬──────────┘
           │
           ├─ REST API (HTTP)
           │  └─ Login, Register, Fetch Messages, Friends
           │
           └─ WebSocket (wss://)
              └─ Real-time Messages, Read Receipts, Status Updates

           │
           ▼
┌──────────────────────────┐
│   Backend Server         │  (Node.js + Express)
│ (server/src/server.js)   │
│                          │
│ ├─ REST endpoints        │
│ ├─ WebSocket handlers    │
│ └─ MongoDB database      │
└──────────────────────────┘
           │
           ▼
┌──────────────────────────┐
│  MongoDB Database        │  (Cloud)
│ (free-cluely database)   │
│                          │
│ ├─ users                 │
│ ├─ friendships           │
│ ├─ chatHistory           │
│ └─ friendRequests        │
└──────────────────────────┘
```

## 🔌 Connection Points

### 1. REST API Endpoint
**Location**: `lib/services/api_service.dart`
```dart
static const String baseUrl = 'https://quidec-server.onrender.com';
```

**Used for**:
- User login/registration
- Fetching initial friend list
- Loading message history
- Marking messages as read

### 2. WebSocket Endpoint
**Location**: `lib/screens/chat_home_screen.dart`
```dart
await _wsService.connect('wss://quidec-server.onrender.com');
```

**Used for**:
- Real-time message delivery
- Friend online/offline status
- Read receipt notifications
- Typing indicators

### 3. Backend Server Integration

The mobile app uses the same backend as the web app. Key endpoints:

**Authentication**
```
POST /api/login
{
  "username": "user123",
  "password": "password"
}
Response:
{
  "token": "jwt_token",
  "username": "user123",
  "userId": "12345678"
}
```

**Friends**
```
GET /api/friends/{username}
Response:
{
  "friends": [
    {
      "username": "friend1",
      "online": true,
      "lastSeen": "2024-03-12T10:30:00Z"
    }
  ]
}
```

**Messages**
```
GET /api/messages/{username}/{withUser}
Response:
{
  "messages": [
    {
      "_id": "msgid",
      "from": "user1",
      "to": "user2",
      "content": "Hello!",
      "timestamp": "2024-03-12T10:30:00Z",
      "read": true,
      "readAt": "2024-03-12T10:31:00Z"
    }
  ]
}

POST /api/messages/send
{
  "from": "user1",
  "to": "user2",
  "content": "Hello!"
}

POST /api/messages/read
{
  "messageId": "msgid",
  "readBy": "user2"
}
```

## 🔄 Data Flow

### Message Sending Flow

```
1. User types message in Flutter UI
   ↓
2. User taps send button
   ↓
3. Local Message object created
   ↓
4. Message sent via:
   - HTTP POST to /api/messages/send (persistent)
   - WebSocket to recipient (real-time)
   ↓
5. Backend saves to MongoDB
   ↓
6. Recipient receives:
   - WebSocket message (if online)
   - Notification via notification service
   ↓
7. Message displayed in recipient's chat
   ↓
8. Recipient marks as read
   ↓
9. Read receipt sent back via WebSocket
   ↓
10. Sender sees checkmark in message bubble
```

### Message Receiving Flow

```
1. WebSocket message from backend
   ↓
2. WebSocketService parses JSON
   ↓
3. Checks message.type == 'message'
   ↓
4. If from friend in current chat:
   - Add to _messages list
   - Auto-scroll to bottom
   - Show read receipt
   ↓
5. If from different friend:
   - Show Android notification
   - Play sound/vibration
   - Update unread count in friend list
   ↓
6. Auto-mark visible messages as read
   ↓
7. Send mark-read WebSocket message to backend
```

### Read Receipt Flow

```
Recipient marks message as read:

1. Message becomes visible in chat
   ↓
2. Intersection Observer detects visibility
   ↓
3. Client sends mark-read WebSocket message
   ↓
4. Backend updates MongoDB:
   - message.read = true
   - message.readAt = current timestamp
   ↓
5. Backend broadcasts read-receipt to sender
   ↓
6. Sender receives read-receipt message
   ↓
7. Updates message in local list
   ↓
8. Message bubble shows double checkmark ✓✓
   ↓
9. Sender is notified message was read
```

## 📱 Notification Flow

```
New message received while app running:

1. Message arrives via WebSocket
2. NotificationService checks if from different friend
3. If yes, shows Android notification:
   - Title: "Message from {sender}"
   - Body: Message preview
   - Sound + vibration
   - Large icon with sender avatar

User can:
- Tap notification → Opens chat with that friend
- Swipe to dismiss
- Reply (optional enhancement)

Notification shows even if:
- App is in background
- App is closed
- Screen is locked
```

## 🔐 Authentication Flow

```
First login:

1. User enters username & password
2. Send POST /api/login
3. Backend validates credentials
4. Backend returns JWT token
5. StorageService saves:
   - User object (username, userId)
   - JWT token
   - Auto-login enabled
6. WebSocketService connects with token
7. User is authenticated and ready to chat

Subsequent logins:

1. App starts
2. StorageService checks for saved user
3. If user exists:
   - Skip login screen
   - Restore user session
   - Maintain WebSocket connection
4. User goes directly to chat home
5. No need to login again (until logout)
```

## 💾 Local Storage Usage

**SharedPreferences stores**:
```
- user (JSON): Username, userId
- token (string): JWT token
- notifications_enabled (bool): Notification preference
- sound_enabled (bool): Sound preference
```

**NOT stored locally** (for privacy):
- Messages (only kept in memory during session)
- Friend list (fetched fresh each session)
- Chat history (loaded from API as needed)

## 🔔 Different from Web App

### What's Better in Mobile

1. **Native Notifications**: OS-level alerts, doesn't need app running
2. **Better UX**: Full-screen chat, optimized for touch
3. **Offline Support**: Can cache and show cached messages
4. **Battery Efficient**: WebSocket over HTTP for real-time
5. **Always Available**: Keep-alive connections
6. **Faster**: Native compilation vs web browser
7. **System Integration**: Can appear in notification bar, lock screen

### What's Similar

1. **Same Backend**: Uses exact same server code
2. **Same Database**: Reads/writes same MongoDB collections
3. **Same Authentication**: Same JWT tokens
4. **Same Message Format**: Identical message objects
5. **Same UI/UX**: WhatsApp-like design applied
6. **Same Features**: All core features present

## 🚀 Deployment

### Development
```
Backend: http://localhost:3000
Mobile: ws://10.0.2.2:3000 (if testing on emulator)
```

### Production
```
Backend: https://quidec-server.onrender.com
Mobile: wss://quidec-server.onrender.com
```

## 🔧 Configuration

To switch between servers, edit:

**`lib/services/api_service.dart`**:
```dart
// Production
static const String baseUrl = 'https://quidec-server.onrender.com';

// Local development
// static const String baseUrl = 'http://10.0.2.2:3000';
```

**`lib/screens/chat_home_screen.dart`** (line ~55):
```dart
// Production
await _wsService.connect('wss://quidec-server.onrender.com');

// Local development
// await _wsService.connect('ws://10.0.2.2:3000');
```

## 📊 Performance Considerations

### Message Loading
- **First time**: Loads full history from API (HTTP)
- **After**: Receives new messages via WebSocket
- **Optimization**: Only loads 100 latest messages initially

### Friend List Refresh
- **On app start**: Fetches from API
- **Real-time updates**: Via WebSocket user-status messages
- **Polling interval**: None (event-driven only)

### Read Receipts
- **Sent**: Immediately when message visible
- **Received**: Broadcasts to sender via WebSocket
- **Display**: Updates in ~100ms after visibility

### Notifications
- **Delivered**: Via Android Notification Channel
- **Grouped**: One channel for all messages
- **Storage**: Handled by Android OS (up to 5 recent)

## 🐛 Debugging

To debug WebSocket messages, add to `websocket_service.dart`:
```dart
void send(Map<String, dynamic> message) {
  if (_isConnected) {
    print('📤 Sent: $message'); // Debug log
    _channel.sink.add(jsonEncode(message));
  }
}
```

To debug API calls, add to `api_service.dart`:
```dart
print('📡 Request: $url');
print('📬 Response: ${response.body}'); // After response
```

To debug notifications:
```dart
print('🔔 Notification: $sender - $message');
```

## 🔗 Related Files

**Backend**:
- `/server/src/server.js` - Main server code

**Web Frontend**:
- `/web/src/components/ChatPanel.jsx` - Web chat
- `/web/src/components/Sidebar.jsx` - Web sidebar

**Mobile App**:
- `/lib/services/websocket_service.dart` - Connection handler
- `/lib/services/api_service.dart` - REST client
- `/lib/services/notification_service.dart` - Notifications

---

**The mobile app is 100% compatible with your existing backend and adds native mobile capabilities!**
