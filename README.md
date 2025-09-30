<div align="center">

## 🌱 Pakebun App
Smart garden assistant: monitoring, scheduling, and automation for your plants.

![Platforms](https://img.shields.io/badge/platform-Android%20%7C%20iOS%20%7C%20Web-blue)
![Flutter](https://img.shields.io/badge/flutter-3.x-blue.svg)
![License](https://img.shields.io/badge/license-MIT-green)

</div>

---

### 📌 Overview
Pakebun App membantu pengguna mengelola kebun/planting zone secara cerdas: memantau sensor lingkungan, mengatur jadwal otomatis (penyiraman, pendinginan, cahaya), dan mengelola perangkat serta tanaman dalam satu aplikasi. Terintegrasi dengan Firebase Authentication (Google Sign-In) dan mendukung offline-first caching untuk profil pengguna.

---

### ✨ Fitur Utama
- 🔐 Autentikasi Google (Firebase Auth)
- 👤 Profil dengan cache offline (nama, email, foto)
- 🪴 Manajemen Kebun & Zona (list, detail, perangkat)
- 📊 Monitoring lingkungan (kelembapan tanah/udara, suhu, intensitas cahaya, panel surya, baterai, dll.)
- 🧩 Penyesuaian UI ikon SVG (konversi PNG embedded via Base64)
- 🕒 Penjadwalan Otomatis (Penyiraman / Pendinginan / Cahaya):
	- Dropdown tipe & media
	- Input waktu HH:MM dengan formatter
	- Toggle hari individual (Hijau = aktif, Merah = nonaktif)
	- Status aktif/mati per jadwal
	- Dinamis list card jadwal
- 🚀 Onboarding + Splash otomatis redirect (onboarding → login → dashboard)
- 🧪 Struktur siap untuk penambahan test

> Catatan: Saat ini konfigurasi `firebase_options.dart` masih manual surrogate. Disarankan menjalankan `flutterfire configure` untuk regenerasi file resmi.

---

### 🧱 Arsitektur Ringkas
- State sederhana dengan StatefulWidget + controller custom (belum menggunakan Riverpod/Bloc)
- Routing: `go_router` (lihat `lib/common/routes/app_router.dart`)
- Lapis Fitur: `features/<domain>/`
- Persistence ringan: `SharedPreferences` untuk flags onboarding & cache user
- Asset handling: Custom `Base64SvgImage` untuk kompatibilitas ikon

Struktur utama:
```
lib/
	common/
		routes/          # App router
		widgets/         # Reusable UI
		theme/           # Theming
	features/
		auth/            # Login, register, reset
		onboarding/      # Splash + onboarding flow
		dashboard/       # Dashboard + nav shell
		garden/          # Garden list/detail/monitoring/scheduling
		monitoring/      # Sensor monitoring components
		peralatan/       # Device related screens
		profile/         # Profile & logout
```

---

### 🔧 Prasyarat
Pastikan sudah ter-install:
- Flutter SDK (3.x)
- Dart
- Android Studio / Xcode (untuk Android/iOS build)
- Firebase Project (Console) + file `google-services.json`

Opsional:
- Firebase CLI (untuk `flutterfire configure`)
- Git

---

### 🚀 Menjalankan Proyek
Clone lalu jalankan:
```bash
git clone https://github.com/prianurislam1825/Pakebun_App.git
cd Pakebun_App
flutter pub get
flutter run
```

Jika perlu mengganti paket aplikasi Android (sudah di-set `com.pakebun.app`).

---

### 🔥 Firebase Setup (Android)
1. Buat project di Firebase Console
2. Tambah aplikasi Android:
	 - Package Name: `com.pakebun.app`
	 - SHA1/SH256 (opsional untuk Google Sign-In penuh) – gunakan `gradlew signingReport`
3. Download `google-services.json` → letakkan di `android/app/`
4. (Nanti) Jalankan:
	 ```bash
	 flutterfire configure
	 ```
5. Pastikan inisialisasi di `main.dart` menggunakan `Firebase.initializeApp()`.

---

### 🕒 Modul Penjadwalan (Scheduling)
Lokasi file: `lib/features/garden/screens/setting_jadwal_screen.dart`

Komponen:
- Modal bottom sheet untuk tambah jadwal
- Validasi format waktu HH:MM (`_TimeTextInputFormatter`)
- Toggle hari (array boolean + label)
- Status global penjadwalan + status per jadwal
- Rencana pengembangan:
	- Persist ke local storage (JSON via SharedPreferences)
	- Edit / duplicate jadwal
	- Sinkronisasi ke backend / perangkat IoT

---

### 📦 Dependensi Penting
- firebase_core
- firebase_auth
- google_sign_in
- shared_preferences
- go_router
- flutter_screenutil

---

### ✅ Rencana Next (Roadmap Singkat)
- [ ] Persist jadwal otomatis secara lokal
- [ ] Edit & hapus jadwal via long-press / tap
- [ ] Integrasi notifikasi lokal
- [ ] Integrasi backend / device command queue
- [ ] Mode gelap (dark mode)
- [ ] Refactor ke state management terstruktur (e.g., Riverpod)
- [ ] Unit & widget tests untuk auth + scheduling

---

### 🤝 Kontribusi
1. Fork repo
2. Buat branch fitur: `git checkout -b fitur/nama-fitur`
3. Commit terstruktur (conventional commits):
	 - `feat: ...` / `fix: ...` / `chore: ...` / `refactor: ...`
4. Push & buka Pull Request

---

### 🐞 Debug & Tips
- Masalah ikon SVG blank → pastikan gunakan `Base64SvgImage` jika format embed PNG
- Crash Firebase awal → cek package name dan `google-services.json`
- Tidak redirect setelah splash → pastikan flag `onboarding_done` terset
- Waktu jadwal invalid → valid format 24 jam: `HH:MM`

---

### 📄 Lisensi
Proyek ini dirilis di bawah lisensi MIT. Silakan gunakan dan modifikasi sesuai kebutuhan.

---

### ❤️ Kredit
Dikembangkan dengan Flutter untuk membantu otomasi kebun pintar. Kontribusi & masukan sangat dihargai.

---

Jika butuh bantuan lanjutan (CI, persistence jadwal, atau backend sync), buat issue atau hubungi maintainer.

Selamat berkebun digital! 🌿
