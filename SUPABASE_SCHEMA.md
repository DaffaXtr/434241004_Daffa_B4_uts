# Dokumentasi Schema Database Supabase

Dokumen ini menjelaskan struktur database, tabel, storage, dan pengaturan keamanan (Row Level Security) yang dibutuhkan untuk aplikasi Helpdesk ini di Supabase. Semua struktur tabel ini didasarkan pada model yang sudah ada di dalam folder `lib/models/`.

## 1. Authentication (Supabase Auth)
Aplikasi ini menggunakan sistem autentikasi bawaan dari Supabase. Ketika user baru mendaftar atau login, data kredensial (email, password) akan disimpan di skema `auth.users` milik Supabase. 

Nantinya, kita akan menghubungkan `auth.users` dengan tabel `public.users` (tabel kustom kita) menggunakan *Trigger* atau secara manual setiap ada registrasi.

## 2. Tipe Data Enum (Postgres Enums)
Sebaiknya buat tipe data Enum di Supabase (SQL Editor) agar lebih aman dan sesuai dengan enum di Dart:

```sql
CREATE TYPE user_role AS ENUM ('user', 'helpdesk', 'admin');
CREATE TYPE ticket_status AS ENUM ('open', 'inProgress', 'resolved', 'closed');
CREATE TYPE ticket_priority AS ENUM ('low', 'medium', 'high', 'critical');
CREATE TYPE ticket_category AS ENUM ('hardware', 'software', 'network', 'account', 'other');
CREATE TYPE history_action AS ENUM ('created', 'statusUpdated', 'assigned');
CREATE TYPE notif_type AS ENUM ('ticketCreated', 'statusUpdated', 'newReply', 'ticketAssigned');
```
*(Catatan: Anda juga bisa menggunakan tipe data `text` biasa jika tidak ingin memakai Enum di Postgres, namun penggunaan Enum lebih disarankan untuk integritas data).*

---

## 3. Struktur Tabel Database

### A. Tabel `users`
Menyimpan profil tambahan user yang terhubung ke `auth.users`.
- `id` (uuid, primary key, referensi ke `auth.users(id)`)
- `name` (text, not null)
- `email` (text, not null)
- `username` (text, not null, unique)
- `role` (user_role, not null, default: 'user')
- `avatar_url` (text, nullable)
- `department` (text, not null)
- `created_at` (timestamp with time zone, default: now())

### B. Tabel `tickets`
Menyimpan data tiket yang dibuat oleh user.
- `id` (uuid, primary key, default: uuid_generate_v4())
- `title` (text, not null)
- `description` (text, not null)
- `status` (ticket_status, not null, default: 'open')
- `priority` (ticket_priority, not null)
- `category` (ticket_category, not null)
- `reporter_id` (uuid, not null, referensi ke `users(id)`)
- `assigned_to_id` (uuid, nullable, referensi ke `users(id)`)
- `attachments` (text[], nullable) - array of URLs / path ke file storage
- `created_at` (timestamp with time zone, default: now())
- `updated_at` (timestamp with time zone, default: now())

### C. Tabel `comments`
Menyimpan komentar atau balasan dari tiket (baik dari user maupun helpdesk).
- `id` (uuid, primary key, default: uuid_generate_v4())
- `ticket_id` (uuid, not null, referensi ke `tickets(id)` cascade delete)
- `author_id` (uuid, not null, referensi ke `users(id)`)
- `content` (text, not null)
- `is_internal` (boolean, not null, default: false) - Jika true, hanya helpdesk/admin yang bisa melihat
- `created_at` (timestamp with time zone, default: now())

### D. Tabel `histories`
Menyimpan riwayat perubahan atau log dari sebuah tiket.
- `id` (uuid, primary key, default: uuid_generate_v4())
- `ticket_id` (uuid, not null, referensi ke `tickets(id)` cascade delete)
- `action` (history_action, not null)
- `description` (text, not null)
- `actor_id` (uuid, not null, referensi ke `users(id)`)
- `created_at` (timestamp with time zone, default: now())

### E. Tabel `notifications`
Menyimpan data notifikasi untuk user.
- `id` (uuid, primary key, default: uuid_generate_v4())
- `user_id` (uuid, not null, referensi ke `users(id)`) - Siapa yang menerima notifikasi
- `title` (text, not null)
- `body` (text, not null)
- `type` (notif_type, not null)
- `ticket_id` (uuid, nullable, referensi ke `tickets(id)`)
- `is_read` (boolean, not null, default: false)
- `created_at` (timestamp with time zone, default: now())

---

## 4. Supabase Storage (Buckets)

Anda perlu membuat *Buckets* di Supabase Storage untuk menyimpan file.
1. **`avatars`** (Public) - Untuk menyimpan foto profil user (`avatar_url`).
2. **`attachments`** (Bisa Public atau Private) - Untuk menyimpan lampiran gambar/dokumen pada tabel tiket (`attachments`).

---

## 5. Keamanan & Row Level Security (RLS)
Sangat disarankan untuk mengaktifkan RLS di semua tabel, agar data aman dan hanya bisa diakses oleh pihak yang berwenang. Contoh kebijakan RLS sederhana:

- **Tabel `users`**: Semua user yang sudah login bisa membaca data, tapi hanya dirinya sendiri atau Admin yang bisa mengubah data.
- **Tabel `tickets`**:
  - `User` hanya bisa melihat tiket miliknya (`reporter_id = auth.uid()`).
  - `Helpdesk` & `Admin` bisa melihat seluruh tiket.
- **Tabel `comments`**:
  - `User` hanya bisa melihat komen yang `is_internal = false` dan berada di tiketnya.
  - `Helpdesk` & `Admin` bisa melihat semua komen.

## 6. Realtime (Opsional tapi Direkomendasikan)
Aktifkan fitur Realtime di dashboard Supabase (Database -> Replication -> Supabase Realtime) untuk tabel:
- `tickets` (agar helpdesk tahu saat ada tiket masuk tanpa refresh)
- `comments` (untuk live chat balasan)
- `notifications` (untuk notif realtime)
