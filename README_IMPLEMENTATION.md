# 📱 E-Ticketing Helpdesk — Flutter App

Implementasi lengkap **E-Ticketing Helpdesk** berbasis **Flutter** dengan **Riverpod** state management dan **GoRouter** untuk navigasi. Aplikasi ini menggunakan dummy data dan tidak memerlukan backend.

---

## ✨ Fitur Lengkap

### 🔐 Autentikasi & User Management
- ✅ Login dengan username dan password
- ✅ Registrasi akun baru
- ✅ Reset password
- ✅ Logout

### 🎫 Management Tiket
- ✅ **User**: Membuat tiket, upload lampiran (simulasi), melihat daftar tiket, detail tiket, memberikan komentar
- ✅ **Helpdesk/Admin**: Mengelola semua tiket, update status, assign tiket, membuat komentar internal

### 📊 Dashboard
- ✅ Statistik tiket (total, open, in progress, resolved, closed)
- ✅ Daftar tiket terbaru
- ✅ Quick access ke fitur utama

### 🔔 Notifikasi
- ✅ Daftar notifikasi dengan status baca/belum baca
- ✅ Navigasi ke tiket dari notifikasi
- ✅ Mark as read / Mark all read

### 👤 Profile
- ✅ Informasi user
- ✅ Dark mode / Light mode toggle
- ✅ Settings (simulasi)
- ✅ Logout

### 🎨 UI/UX
- ✅ Material Design 3
- ✅ Dark & Light mode
- ✅ Responsive design untuk berbagai ukuran layar
- ✅ Animasi dan transisi smooth

---

## 🚀 Quick Start

### Prerequisites
- Flutter 3.10.0+
- Dart 3.0.0+
- iOS/Android emulator atau device

### Installation

1. **Clone atau buka project:**
   ```bash
   cd ticketing_uts
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run aplikasi:**
   ```bash
   flutter run
   ```

---

## 👤 Demo Akun

Gunakan akun-akun berikut untuk testing:

| Role | Username | Password |
|------|----------|----------|
| **User** | `budi` | `123456` |
| **User** | `siti` | `123456` |
| **Helpdesk** | `andi_hd` | `123456` |
| **Admin** | `admin_rini` | `123456` |

---

## 📁 Project Structure

```
lib/
├── main.dart                           # Entry point
├── app.dart                            # App configuration
│
├── core/
│   ├── constants/
│   │   ├── app_colors.dart            # Warna aplikasi
│   │   ├── app_strings.dart           # String constants
│   │   └── app_sizes.dart             # Ukuran padding, font, etc
│   ├── theme/
│   │   └── app_theme.dart             # Light & Dark theme
│   └── router/
│       └── app_router.dart            # GoRouter configuration
│
├── models/
│   ├── user_model.dart
│   ├── ticket_model.dart
│   ├── comment_model.dart
│   └── notification_model.dart
│
├── data/
│   └── dummy/
│       ├── dummy_users.dart
│       ├── dummy_tickets.dart
│       ├── dummy_comments.dart
│       └── dummy_notifications.dart
│
├── providers/
│   ├── auth_provider.dart              # Authentication state
│   ├── ticket_provider.dart            # Ticket management
│   ├── notification_provider.dart      # Notifications
│   ├── theme_provider.dart             # Theme (dark/light)
│   └── dashboard_provider.dart         # Dashboard statistics
│
└── screens/
    ├── splash/
    │   └── splash_screen.dart
    ├── auth/
    │   ├── login_screen.dart
    │   └── register_screen.dart
    ├── dashboard/
    │   └── dashboard_screen.dart
    ├── ticket/
    │   ├── ticket_list_screen.dart
    │   ├── ticket_detail_screen.dart
    │   └── create_ticket_screen.dart
    ├── notification/
    │   └── notification_screen.dart
    ├── profile/
    │   └── profile_screen.dart
    └── widgets/
        ├── stat_card.dart
        ├── status_badge.dart
        ├── priority_badge.dart
        ├── ticket_card.dart
        └── comment_bubble.dart
```

---

## 🏗️ Architecture

### State Management: **Riverpod**
- `StateNotifierProvider` untuk mutable state (auth, tickets, notifications)
- `Provider` untuk computed state (dashboard stats, unread count)
- `.family` untuk state yang dependent pada parameter (comments per ticket)

### Navigation: **GoRouter**
- Named routes untuk navigasi
- Route guards untuk redirect based on auth state
- Automatic redirect ke login jika belum authenticated

### Theme: **Material 3**
- Light & Dark theme support
- Consistent styling across the app
- Custom colors, typography, dan component styles

---

## 📋 Fitur Sesuai SRS

| ID | Fitur | Status |
|----|-------|--------|
| FR-001 | Login | ✅ |
| FR-002 | Logout | ✅ |
| FR-003 | Register | ✅ |
| FR-004 | Reset Password | ✅ |
| FR-005 | User - Buat Tiket | ✅ |
| FR-005 | User - Upload Lampiran | ✅ |
| FR-005 | User - Lihat Daftar Tiket | ✅ |
| FR-005 | User - Lihat Detail Tiket | ✅ |
| FR-005 | User - Komentar | ✅ |
| FR-006 | Admin - Lihat Semua Tiket | ✅ |
| FR-006 | Admin - Update Status | ✅ |
| FR-006 | Admin - Assign Tiket | ✅ |
| FR-007 | Notifikasi | ✅ |
| FR-008 | Dashboard Statistik | ✅ |
| FR-010 | Riwayat Tiket | ✅ |
| FR-011 | Tracking Tiket | ✅ |
| NFR | Dark & Light Mode | ✅ |
| NFR | Responsive UI | ✅ |
| NFR | Android & iOS | ✅ |

---

## 🎯 User Flows

### Flow untuk User (Pelapor)
1. **Splash Screen** → Auto redirect ke Login jika belum login
2. **Login** dengan akun `budi` / `123456`
3. **Dashboard** → Lihat statistik dan tiket terbaru
4. **Create Ticket** → Buat tiket baru dengan upload lampiran
5. **Ticket List** → Lihat daftar tiket yang dibuat
6. **Ticket Detail** → Lihat detail dan tambah komentar
7. **Notifications** → Lihat update tiket
8. **Profile** → Ubah tema, logout

### Flow untuk Helpdesk/Admin
1. **Login** dengan akun `andi_hd` / `admin_rini`
2. **Dashboard** → Lihat statistik semua tiket
3. **Ticket List** → Filter tiket berdasarkan status
4. **Ticket Detail** → Update status, assign ke staff, buat komentar internal
5. **Notifications** → Lihat notifikasi
6. **Profile** → Settings dan logout

---

## 🧪 Testing Tips

### Test Akun Berbeda
- Login dengan akun user: lihat hanya tiket pribadi
- Login dengan akun helpdesk: lihat semua tiket + bisa update status
- Login dengan akun admin: full access

### Test Fitur
1. **Create Ticket**: Buat tiket baru sebagai user
2. **Update Status**: Login sebagai helpdesk, update status ticket jadi "In Progress"
3. **Add Comment**: Tambah komentar pada ticket detail
4. **Internal Comment**: Sebagai staff, buat comment internal yang hanya staff bisa lihat
5. **Notifications**: Lihat notifikasi update tiket
6. **Dark Mode**: Toggle dark mode di AppBar atau Profile
7. **Filter**: Filter tiket by status sebagai admin

---

## 📚 Dependencies

- **flutter_riverpod** - State management
- **go_router** - Navigation & routing
- **flutter_svg** - SVG image support
- **cached_network_image** - Image caching
- **intl** - Internationalization & date formatting
- **image_picker** - Camera/Gallery (untuk future implementation)
- **uuid** - Generate unique IDs
- **shared_preferences** - Local storage (untuk future use)

---

## 🔄 Data Flow

```
User Input (Login Screen)
    ↓
auth_provider.notifier.login()
    ↓
Update AuthState (currentUser)
    ↓
GoRouter redirect ke /dashboard
    ↓
Dashboard consumes AuthState & TicketState
    ↓
Display Dashboard dengan statistik
```

---

## 🚀 Future Enhancements

- [ ] Backend API integration (REST/GraphQL)
- [ ] Real image upload dengan Firebase Storage
- [ ] Real-time notifications dengan WebSocket
- [ ] Search & advanced filter untuk tiket
- [ ] Export report ke PDF
- [ ] Offline mode dengan local database
- [ ] Multi-language support
- [ ] Rating & feedback sistem
- [ ] Two-factor authentication
- [ ] Team management untuk helpdesk

---

## 📝 Notes

- **Dummy Data**: Semua data disimpan di memory, akan reset saat app restart
- **Simulasi Upload**: Upload lampiran hanya simulasi, gunakan `image_picker` untuk real implementation
- **Password Fixed**: Password semua akun dummy adalah `123456`
- **Internal Comments**: Hanya user dengan role helpdesk/admin yang bisa buat dan lihat internal comments

---

## 👨‍💻 Author

**Universitas Airlangga - DIV Teknik Informatika**
Praktikum Mobile - 2026

---

## 📄 License

This is an educational project. Use freely for learning purposes.

---

## 📞 Support

Untuk bantuan atau pertanyaan tentang project ini, silakan buat issue di repository atau hubungi instruktur praktikum.

---

**Happy Coding! 🎉**
