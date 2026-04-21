# 🛠️ DEVELOPMENT GUIDE & TIPS

---

## ✅ DEVELOPMENT CHECKLIST

### Project Setup
- [x] Create Flutter project
- [x] Setup pubspec.yaml dengan dependencies
- [x] Create folder structure
- [x] Setup Git (optional)

### Core Architecture
- [x] Create constants (colors, strings, sizes)
- [x] Create theme (light & dark)
- [x] Setup router (GoRouter)

### Data Layer
- [x] Create models
- [x] Create dummy data
- [x] Setup providers (Riverpod)

### UI/UX Layer
- [x] Create reusable widgets
- [x] Create screens
- [x] Implement responsive design
- [x] Add dark mode support

### Testing
- [x] Create demo accounts
- [x] Test all flows
- [x] Test dark mode
- [x] Test navigation

### Documentation
- [x] Create README
- [x] Create implementation summary
- [x] Create usage guide
- [x] Add code comments

---

## 🚀 NEXT STEPS FOR FUTURE DEVELOPMENT

### Phase 1: Backend Integration

#### 1. Setup Backend API
```dart
// Create api_service.dart
class ApiService {
  final String baseUrl = 'https://your-api.com/api';
  
  Future<AuthResponse> login(String username, String password) async {
    // Replace dummy login dengan HTTP request
  }
  
  Future<List<Ticket>> getTickets() async {
    // Replace dummy tickets dengan API call
  }
  
  // ... more methods
}
```

#### 2. Replace Dummy Data
```dart
// Before
final tickets = dummyTickets;

// After
final tickets = await apiService.getTickets();
```

#### 3. Update Providers
```dart
// Instead of StateNotifier, use FutureProvider atau AsyncValue
final ticketsProvider = FutureProvider<List<Ticket>>((ref) async {
  return await ref.read(apiServiceProvider).getTickets();
});
```

### Phase 2: Real Image Upload

```dart
// In CreateTicketScreen
import 'package:image_picker/image_picker.dart';

final ImagePicker _picker = ImagePicker();

Future<void> _pickImage() async {
  final XFile? image = await _picker.pickImage(
    source: ImageSource.gallery, // atau ImageSource.camera
  );
  
  if (image != null) {
    // Upload ke server
    final response = await apiService.uploadImage(
      File(image.path),
    );
    _attachments.add(response.url);
  }
}
```

### Phase 3: Real Notifications

#### Push Notifications (FCM)
```dart
// Setup Firebase Cloud Messaging
import 'package:firebase_messaging/firebase_messaging.dart';

final FirebaseMessaging _messaging = FirebaseMessaging.instance;

void _setupNotifications() {
  // Listen for incoming messages
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    ref.read(notificationProvider.notifier).addNotification(...);
  });
}
```

#### WebSocket (Real-time)
```dart
// Setup WebSocket untuk real-time updates
import 'package:web_socket_channel/web_socket_channel.dart';

void _connectWebSocket() {
  final channel = WebSocketChannel.connect(
    Uri.parse('wss://your-api.com/socket'),
  );
  
  channel.stream.listen((message) {
    // Handle real-time updates
  });
}
```

### Phase 4: Local Database

```dart
// Setup SQLite dengan Drift atau Hive
import 'package:drift/drift.dart';

// Create local tables
class Tickets extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  // ...
}

// Use for offline support
```

### Phase 5: Advanced Features

#### Search & Filter
```dart
// Implement full-text search
final searchProvider = StateNotifierProvider((ref) {
  return SearchNotifier(ref);
});

class SearchNotifier extends StateNotifier<List<Ticket>> {
  void search(String query) {
    // Filter tickets by title/description
  }
}
```

#### Export Report
```dart
// Export tickets to PDF
import 'package:pdf/pdf.dart';

Future<void> exportTicketsToPdf() async {
  final pdf = pw.Document();
  
  pdf.addPage(
    pw.Page(
      build: (pw.Context context) {
        return pw.Column(
          children: [
            pw.Text('Tickets Report'),
            // ... add tickets
          ],
        );
      },
    ),
  );
  
  await pdf.save();
}
```

#### Multi-language Support
```dart
// Setup intl package
import 'package:intl/intl.dart';

// Create translations
const Map<String, Map<String, String>> translations = {
  'id': {
    'dashboard': 'Dashboard',
    'tickets': 'Tiket',
  },
  'en': {
    'dashboard': 'Dashboard',
    'tickets': 'Tickets',
  },
};
```

---

## 📚 CODE STRUCTURE BEST PRACTICES

### Folder Organization
```
lib/
├── core/              # Constants, theme, router
├── models/            # Data models
├── data/              # Data sources (dummy, api, local db)
├── providers/         # State management
├── screens/           # UI screens
├── services/          # Business logic (optional)
├── utils/             # Helper functions (optional)
└── widgets/           # Reusable components
```

### Naming Conventions
```dart
// Files: snake_case
- user_model.dart
- auth_provider.dart
- login_screen.dart

// Classes: PascalCase
class UserModel {}
class AuthNotifier {}
class LoginScreen {}

// Variables/Functions: camelCase
final currentUser = ...
void updateStatus() {}

// Constants: UPPER_SNAKE_CASE (via constants folder)
const String APP_NAME = 'E-Ticketing';
```

### Code Organization in File
```dart
// 1. Imports
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 2. Constants (jika ada)
const double PADDING = 16.0;

// 3. Enums
enum UserRole { user, helpdesk, admin }

// 4. Main class
class MyClass {
  // 4a. Final variables
  final String name;
  
  // 4b. Constructor
  const MyClass({required this.name});
  
  // 4c. Getters
  String get displayName => name.toUpperCase();
  
  // 4d. Methods
  void someMethod() {}
}
```

### State Management Patterns

#### StateNotifier Pattern (untuk mutable state)
```dart
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState());
  
  Future<void> login(String username, String password) async {
    state = state.copyWith(isLoading: true);
    try {
      // ... login logic
      state = state.copyWith(currentUser: user, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(),
);
```

#### Provider Pattern (untuk computed state)
```dart
// Simple provider
final userName = Provider((ref) {
  final user = ref.watch(authProvider).currentUser;
  return user?.name ?? 'Guest';
});

// FutureProvider (untuk async)
final ticketsProvider = FutureProvider<List<Ticket>>((ref) async {
  return await getTickets();
});
```

#### Family Pattern (untuk parametrized state)
```dart
final commentProvider = StateNotifierProvider.family<
  CommentNotifier,
  List<CommentModel>,
  String
>(
  (ref, ticketId) => CommentNotifier(ticketId),
);

// Usage
ref.watch(commentProvider('TKT-001'));
```

---

## 🧪 TESTING STRATEGY

### Unit Tests
```dart
// test/models/ticket_model_test.dart
void main() {
  test('TicketModel statusLabel returns correct label', () {
    final ticket = TicketModel(
      status: TicketStatus.open,
      // ... other fields
    );
    expect(ticket.statusLabel, 'Open');
  });
}
```

### Widget Tests
```dart
// test/screens/login_screen_test.dart
void main() {
  testWidgets('LoginScreen renders login button', (WidgetTester tester) async {
    await tester.pumpWidget(const LoginScreen());
    
    expect(find.text('Login'), findsOneWidget);
    expect(find.byType(TextField), findsWidgets);
  });
}
```

### Integration Tests
```dart
// test_driver/app_test.dart
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  testWidgets('Full login flow', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    
    // Login flow
    await tester.enterText(find.byType(TextField).first, 'budi');
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();
    
    expect(find.text('Dashboard'), findsOneWidget);
  });
}
```

---

## 🐛 COMMON ISSUES & SOLUTIONS

### Issue 1: GoRouter redirect infinite loop
```dart
// ❌ WRONG
redirect: (context, state) {
  if (!isLoggedIn) return '/login';
  if (isLoggedIn) return '/dashboard'; // Infinite redirect!
}

// ✅ CORRECT
redirect: (context, state) {
  if (!isLoggedIn && !isAuthScreen) return '/login';
  if (isLoggedIn && isAuthScreen) return '/dashboard';
  return null; // No redirect
}
```

### Issue 2: Riverpod provider rebuild
```dart
// ❌ WRONG - Provider akan rebuild saat auth berubah
final ticketsProvider = StateNotifierProvider((ref) {
  ref.watch(authProvider); // Ini menyebabkan rebuild
  return TicketNotifier(ref);
});

// ✅ CORRECT - Pass ref only when needed
class TicketNotifier extends StateNotifier<TicketState> {
  TicketNotifier(this.ref) : super(...) {
    _loadTickets(); // Load saat init saja
  }
  final Ref ref;
}
```

### Issue 3: Memory leak di StreamSubscription
```dart
// ❌ WRONG
initState() {
  _subscription = streamController.stream.listen((_) {});
  // Tidak di-dispose!
}

// ✅ CORRECT
dispose() {
  _subscription?.cancel();
  super.dispose();
}
```

### Issue 4: Image picker permission
```dart
// AndroidManifest.xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />

// Info.plist
<key>NSCameraUsageDescription</key>
<string>Aplikasi ini membutuhkan akses kamera</string>
```

---

## 📊 PERFORMANCE OPTIMIZATION

### Image Optimization
```dart
// Use cached_network_image
CachedNetworkImage(
  imageUrl: url,
  cacheManager: customCacheManager,
  placeholder: (context, url) => const ShimmerLoading(),
  errorWidget: (context, url, error) => const Icon(Icons.error),
)
```

### List Optimization
```dart
// Use ListView.builder, bukan ListView
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) => ItemWidget(item: items[index]),
)
```

### State Management Optimization
```dart
// Select specific part of state
ref.watch(authProvider.select((state) => state.isLoading))

// Instead of
ref.watch(authProvider) // Watch semua state
```

---

## 🔐 SECURITY BEST PRACTICES

### Never Store Sensitive Data in Dummy Data
```dart
// ❌ WRONG
final String password = '123456'; // Hardcoded!

// ✅ CORRECT
// Use secure storage: flutter_secure_storage
// Or environment variables
```

### Validate User Input
```dart
// ✅ DO
String? validateEmail(String value) {
  if (value.isEmpty) return 'Email tidak boleh kosong';
  if (!value.contains('@')) return 'Email tidak valid';
  return null;
}

// Use in form
TextFormField(
  validator: validateEmail,
)
```

### Implement Rate Limiting
```dart
// ❌ WRONG - User bisa spam login attempts
Future<void> login() async {
  // ... login code
}

// ✅ CORRECT - Limit login attempts
late DateTime _lastLoginAttempt;
int _loginAttempts = 0;

Future<void> login() async {
  if (_loginAttempts >= 5) {
    throw Exception('Terlalu banyak percobaan login');
  }
  _loginAttempts++;
  // ... login code
}
```

---

## 📈 MONITORING & ANALYTICS

### Add Logging
```dart
import 'package:logger/logger.dart';

final log = Logger();

// Usage
log.i('User login berhasil'); // Info
log.w('Low memory warning');  // Warning
log.e('Error occurred');      // Error
```

### Crash Reporting
```dart
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

void setupCrashReporting() {
  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterError(errorDetails);
  };
}
```

---

## 🚢 DEPLOYMENT CHECKLIST

### Before Release
- [ ] Remove debug prints
- [ ] Remove hardcoded URLs
- [ ] Test on both Android & iOS
- [ ] Test on different screen sizes
- [ ] Test dark mode
- [ ] Test all user flows
- [ ] Update version in pubspec.yaml
- [ ] Generate signed APK/IPA
- [ ] Create privacy policy
- [ ] Create terms of service

### Versioning
```yaml
# pubspec.yaml
version: 1.0.0+1
# Format: major.minor.patch+build

# Update untuk bug fixes
version: 1.0.1+2

# Update untuk minor features
version: 1.1.0+3

# Update untuk major changes
version: 2.0.0+4
```

---

## 📖 USEFUL RESOURCES

### Official Documentation
- Flutter: https://flutter.dev/docs
- Riverpod: https://riverpod.dev
- GoRouter: https://pub.dev/packages/go_router
- Material Design 3: https://m3.material.io

### Community Resources
- Dart Language: https://dart.dev
- Pub.dev Packages: https://pub.dev
- Flutter Community: https://fluttercommunity.dev

---

## 🎓 LEARNING PATH

1. **Basics** (Completed)
   - Flutter widgets
   - State management (Riverpod)
   - Navigation (GoRouter)

2. **Intermediate** (Next)
   - API integration
   - Local database
   - Real-time features

3. **Advanced** (Future)
   - Performance optimization
   - Security
   - CI/CD deployment

---

## 💡 TIPS & TRICKS

### Hot Reload vs Hot Restart
```
Hot Reload (Ctrl+S atau Cmd+S)
- Cepat
- Preserves state
- Gunakan saat develop UI

Hot Restart (Ctrl+Shift+R atau Cmd+Shift+R)
- Lebih lambat
- Reset state
- Gunakan saat ubah model atau dependency
```

### Debugging
```dart
// Print debug info
debugPrint('Value: $value');

// Set breakpoint
// Click di line number → akan pause execution

// Use DevTools
flutter pub global activate devtools
flutter pub global run devtools
```

### Common Commands
```bash
# Clean dan rebuild
flutter clean
flutter pub get
flutter run

# Build release
flutter build apk
flutter build ios

# Run tests
flutter test
flutter test --coverage

# Analyze code
flutter analyze

# Format code
dart format lib/

# Generate docs
dart doc
```

---

## 🎯 CONCLUSION

Aplikasi E-Ticketing Helpdesk sudah **production-ready** dengan dummy data.

Untuk implementasi production-grade:
1. **Phase 1**: Backend integration
2. **Phase 2**: Real image upload
3. **Phase 3**: Real-time notifications
4. **Phase 4**: Local database
5. **Phase 5**: Advanced features

Setiap phase memiliki dokumentasi dan tips di file ini. Happy Coding! 🚀

---

**Happy Development! 🎉**

*Last Updated: April 2026*
*E-Ticketing Helpdesk Development Guide v1.0*
