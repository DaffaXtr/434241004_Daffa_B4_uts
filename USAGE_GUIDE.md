# 📖 PANDUAN PENGGUNAAN E-TICKETING HELPDESK

## 🎯 Panduan Cepat Sesuai Role

---

## 👨‍💼 UNTUK USER / PELAPOR

### Login
```
Username: budi atau siti
Password: 123456
```

### Dashboard
Setelah login, Anda akan melihat:
1. **Statistik Tiket** - Total tiket yang sudah dibuat
2. **Daftar Tiket Terbaru** - 3 tiket terbaru yang Anda buat
3. **Button "Buat Tiket Baru"** - Untuk membuat tiket

#### Tips:
- Swipe dari kiri untuk membuka drawer menu
- Tap notification bell untuk melihat update tiket
- Tap profile icon di AppBar untuk dark mode

---

### Membuat Tiket Baru
1. Tap button **"Buat Tiket Baru"** atau menu **Tiket → Buat Tiket**
2. Isi form:
   - **Judul**: Deskripsi singkat masalah (wajib)
   - **Deskripsi**: Detail lengkap masalah (wajib)
   - **Prioritas**: Low / Medium / High / Critical
   - **Kategori**: Hardware / Software / Network / Account / Other
   - **Lampiran**: Upload gambar (simulasi)
3. Tap **"Buat Tiket"**
4. Tiket akan muncul di daftar dengan status "Open"

---

### Melihat Daftar Tiket
1. Tap menu **Tiket** atau dari dashboard
2. Lihat semua tiket yang Anda buat
3. Tiket ditampilkan dengan:
   - ID tiket (TKT-001, dll)
   - Status badge (warna berbeda per status)
   - Judul tiket
   - Prioritas (warna berbeda per prioritas)
   - Kategori
   - Waktu pembuatan (3 jam lalu, dll)

---

### Melihat Detail Tiket
1. Tap salah satu tiket dari daftar
2. Detail screen menampilkan:
   - **Info tiket**: Status, prioritas, kategori, reporter, tanggal
   - **Deskripsi lengkap**: Masalah yang dilaporkan
   - **Komentar**: Balasan dari helpdesk
   - **Form tambah komentar**: Untuk reply helpdesk

#### Status Tiket Penjelasan:
- **Open** 🔴 - Baru dibuat, menunggu diproses
- **In Progress** 🟠 - Sedang dikerjakan oleh helpdesk
- **Resolved** 🟢 - Sudah diselesaikan
- **Closed** 🔵 - Tiket ditutup

---

### Menambah Komentar
1. Di halaman detail tiket, scroll ke bawah
2. Masuk form **"Tambah Komentar"**
3. Tulis komentar di text field
4. Tap button **"Kirim"**
5. Komentar akan langsung muncul di list

#### Catatan:
- Anda hanya bisa membuat public comment
- Jangan lupa check **internal comment** tidak bisa dilihat user
- Comment dari helpdesk akan ditampilkan dengan nama mereka

---

### Melihat Notifikasi
1. Tap notification bell icon di top-right AppBar
2. Lihat daftar notifikasi:
   - 🟢 Notifikasi yang belum dibaca akan memiliki dot biru
   - Tap untuk mark as read dan membuka tiket terkait
   
#### Tipe Notifikasi:
- **Tiket Berhasil Dibuat** - Ketika Anda buat tiket baru
- **Tiket Diperbarui** - Status tiket berubah
- **Balasan Baru** - Ada comment dari helpdesk
- **Tiket Ditugaskan** - Tiket di-assign ke helpdesk

---

### Profile & Pengaturan
1. Tap menu **Profile** dari drawer atau bottom navigation
2. Lihat informasi:
   - Nama, username, email
   - Departemen/jurusan
   - Role (User/Helpdesk/Admin)
3. **Dark Mode Toggle**: Ubah tema aplikasi
4. Tap **Logout** untuk keluar

---

## 👨‍💻 UNTUK HELPDESK / ADMIN

### Login
```
Helpdesk: andi_hd / 123456
Admin:    admin_rini / 123456
```

---

### Dashboard (Full Access)
1. Lihat statistik **SEMUA** tiket (bukan hanya milik Anda)
2. Daftar tiket terbaru dari semua user
3. Akses cepat ke menu tiket

---

### Melihat Semua Tiket
1. Tap menu **Tiket** dari dashboard atau drawer
2. **Filter Chips** muncul untuk filter berdasarkan status:
   - **Semua** - Tampilkan semua tiket
   - **Open** - Hanya tiket dengan status Open
   - **In Progress** - Hanya tiket yang sedang diproses
   - **Resolved** - Hanya tiket yang sudah diselesaikan
3. Gunakan filter untuk mengelompokkan tiket

#### Tips Workflow:
- Filter **Open** → Lihat tiket baru yang perlu diproses
- Filter **In Progress** → Follow-up tiket yang sedang dikerjakan
- Filter **Resolved** → Persiapan untuk close tiket

---

### Mengelola Tiket (Detail View)

Ketika membuka detail tiket, Anda akan melihat **extra actions** di top-right:

#### Update Status
1. Tap **⋮ (menu icon)** di top-right
2. Pilih opsi:
   - **Update ke In Progress** - Tiket mulai diproses
   - **Update ke Resolved** - Tiket sudah selesai
   - **Update ke Closed** - Tiket ditutup

#### Tambah Komentar (Public & Internal)
1. Scroll ke bawah ke form "Tambah Komentar"
2. Tulis response untuk user
3. **Optional**: Check **"Komentar Internal (hanya staff)"**
   - Internal comment hanya akan dilihat oleh staff lain
   - User tidak bisa melihat internal comment
   - Gunakan untuk koordinasi antar staff
4. Tap **"Kirim"**

#### Assign Tiket
- Di info section ada "Ditugaskan ke"
- (Future feature: akan bisa assign ke staff lain)

---

### Workflow Penanganan Tiket Rekomendasi

```
1. Open Tickets
   ↓
2. Review tiket baru
   ↓
3. Update status ke "In Progress"
   ↓
4. Tambah komentar (public) ke user
   ↓
5. Jika perlu koordinasi, tambah internal comment
   ↓
6. Setelah fixed, update status ke "Resolved"
   ↓
7. Kirim final comment ke user
   ↓
8. Close tiket (update ke "Closed")
```

---

### Internal Comment Use Cases

**Skenario 1: Perlu bantuan staff lain**
```
TKT-001: Hardware issue dengan komputer lab

Public Comment (to user):
"Kami sedang mengecek masalahnya. Akan update dalam 2 jam"

Internal Comment (to staff):
"Butuh bantuan maintenance untuk check power supply"
```

**Skenario 2: Issue sudah solved**
```
Public Comment (to user):
"Masalah sudah kami perbaiki. Silakan test kembali"

Internal Comment (to staff):
"Replacement RAM sudah dilakukan, tested OK"
```

---

### Notifikasi (Same as User)
- Menerima notifikasi tentang update tiket
- Bisa direct tap untuk navigate ke tiket

---

### Logout
- Tap menu **Profile** → Logout

---

## 🎨 DARK MODE

### Toggle Dark Mode
**Option 1**: AppBar (di Dashboard)
- Tap moon/sun icon di top-right

**Option 2**: Profile Screen
- Menu → Profile → Toggle Dark Mode

### Fitur Dark Mode
- Background menjadi gelap (0xFF121212)
- Text menjadi terang untuk contrast
- Cards dan components beradaptasi
- Semua warna di-optimize untuk dark theme

---

## 📋 DEMO DATA SUMMARY

### Akun Demo
| Username | Password | Role | Tiket |
|----------|----------|------|-------|
| budi | 123456 | User | TKT-001, TKT-002, TKT-005 |
| siti | 123456 | User | TKT-003, TKT-004 |
| andi_hd | 123456 | Helpdesk | Bisa assign & update all |
| admin_rini | 123456 | Admin | Full access |

### Tiket Demo
```
TKT-001: Komputer Lab tidak bisa menyala
Status: Open, Prioritas: High, Category: Hardware
Reporter: Budi

TKT-002: Tidak bisa akses portal akademik
Status: In Progress, Prioritas: Medium, Category: Account
Reporter: Budi, Assigned: Andi
Has: 3 comments (1 internal)

TKT-003: Wifi kampus lemot di Gedung C
Status: Resolved, Prioritas: Medium, Category: Network
Reporter: Siti, Assigned: Andi

TKT-004: Software AutoCAD perlu diinstall
Status: Open, Prioritas: Low, Category: Software
Reporter: Siti

TKT-005: Printer di perpustakaan error
Status: Closed, Prioritas: Low, Category: Hardware
Reporter: Budi, Assigned: Andi
```

---

## 🧪 TESTING SCENARIOS

### Skenario 1: User membuat tiket baru
1. Login sebagai `budi`
2. Dashboard → "Buat Tiket Baru"
3. Isi form:
   - Title: "Laptop tidak bisa connect WiFi"
   - Description: "Setiap coba connect ke WiFi_UNAIR error"
   - Priority: High
   - Category: Network
4. Tap "Buat Tiket"
5. Lihat di Ticket List → Tiket baru dengan status "Open"

### Skenario 2: Helpdesk update status
1. Login sebagai `andi_hd`
2. Dashboard → Lihat statistik (semuanya naik)
3. Menu Tiket → Filter "Open"
4. Tap tiket baru yang baru saja dibuat
5. Top-right menu → "Update ke In Progress"
6. Add comment: "Sedang diproses tim network"
7. Status berubah jadi "In Progress"

### Skenario 3: User lihat update
1. Login sebagai `budi`
2. Lihat notifikasi (ada "Tiket Diperbarui")
3. Menu Tiket → Lihat tiket ada comment dari helpdesk
4. Bisa reply dengan komentar

### Skenario 4: Helpdesk selesaikan tiket
1. Login sebagai `andi_hd`
2. Cari tiket yang sudah fixed
3. Add public comment: "Masalah sudah kami atasi"
4. Top-right menu → "Update ke Resolved"
5. Add internal comment: "Sudah install latest WiFi driver"
6. Status berubah jadi "Resolved"

### Skenario 5: Dark Mode
1. Dashboard → Top-right (moon icon)
2. Aplikasi berubah ke dark theme
3. Tap lagi untuk kembali light theme

---

## ⚡ KEYBOARD SHORTCUTS (if any)

Saat ini tidak ada keyboard shortcuts. Semua navigasi via UI buttons.

---

## ❓ FAQ

**Q: Apa bedanya User dan Helpdesk?**
A: 
- User: Hanya lihat tiket sendiri, buat tiket, beri komentar
- Helpdesk: Lihat semua tiket, update status, assign, buat internal comment

**Q: Bagaimana cara login jika lupa password?**
A: Tap "Lupa Password?" di login screen, masukkan email, sistem akan kirim reset link (simulasi)

**Q: Apakah data tersimpan setelah logout?**
A: Tidak. Semua data bersifat dummy. Saat app restart, data akan reset.

**Q: Bisa gak upload gambar asli?**
A: Saat ini simulasi saja. Untuk implementasi real, gunakan `image_picker` package.

**Q: Apakah bisa real-time notification?**
A: Belum. Untuk implementasi real-time, gunakan WebSocket atau Firebase Cloud Messaging.

**Q: Apa itu Internal Comment?**
A: Comment yang hanya bisa dilihat oleh staff (Helpdesk/Admin). User tidak bisa lihat.

---

## 📞 NEED HELP?

Untuk bantuan lebih lanjut:
1. Baca file `README_IMPLEMENTATION.md`
2. Baca file `IMPLEMENTATION_SUMMARY.md`
3. Check code comments di masing-masing file
4. Hubungi instruktur praktikum

---

**Happy Using! 🎉**

---

*Last Updated: April 2026*
*E-Ticketing Helpdesk v1.0.0*
*Universitas Airlangga - DIV Teknik Informatika*
