# Setup Firebase AbsensiGo

Project Firebase: `absensigo-pegawai-2611`
Console: https://console.firebase.google.com/project/absensigo-pegawai-2611/overview

## Sudah dikerjakan (otomatis)
- Project Firebase dibuat dan app Android `com.andikadev.absensigo` terdaftar.
- `android/app/google-services.json` dan `lib/firebase_options.dart` diganti ke project baru.
- `firestore.rules`, `firebase.json`, `.firebaserc` dibuat.

## Yang harus Anda klik sendiri (2 langkah di console)

### 1. Aktifkan Email/Password
1. Buka Console > **Build > Authentication** > **Get started**.
2. Tab **Sign-in method** > **Email/Password** > aktifkan > **Save**.

### 2. Buat database Firestore
1. Buka Console > **Build > Firestore Database** > **Create database**.
2. Edition: Standard. Location: `asia-southeast2` (Jakarta). Pilih **Production mode**.
3. **Create**.

## Deploy aturan keamanan Firestore
Setelah database dibuat:

```powershell
cd D:\dieng-cyber\D-flutter\AbsensiGo
firebase deploy --only firestore:rules
```

## Jalankan app
```powershell
flutter clean
flutter pub get
flutter run
```

Lalu: Welcome > pilih role > **Registrasi** untuk membuat akun pertama.
Akun contoh di README (`bcs` / `lec`) milik project lama dan tidak ada di project ini.

## Cek error kalau masih gagal
| Pesan di app | Penyebab | Solusi |
|---|---|---|
| `operation-not-allowed` | Email/Password belum aktif | Langkah 1 |
| `permission-denied` | Rules belum di-deploy / DB belum dibuat | Langkah 2 + deploy rules |
| `network-request-failed` | Emulator/HP tanpa internet | Cek koneksi |
| `invalid-api-key` / `app-not-authorized` | `google-services.json` lama | `flutter clean`, build ulang |

## Catatan keamanan
`students` dan `lectures` dibaca publik di `firestore.rules` karena login via NIP mencari
email sebelum user login. Ini membuka email semua pegawai. Untuk produksi, pindahkan lookup
NIP ke email ke Cloud Function atau login hanya dengan email.

Fitur pengumuman dosen memakai Cloud Functions, yang butuh paket Blaze. Login/signup tidak butuh ini.
