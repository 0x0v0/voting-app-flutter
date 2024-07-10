# project_voteapp_api

Project UAS menggunakan API membuat aplikasi Sistem Voting

## Login Cridential
- Administrator
Username: faiz

Password: 12345

- User Biasa
Username: dummy

Password: 123

Atau lakukan register untuk membuat akun user biasa.

## Getting Started (Persyaratan)

Sebelum Anda mulai, pastikan Anda memiliki perangkat lunak berikut terinstal di komputer Anda:

- [Flutter](https://flutter.dev/docs/get-started/install)
- [Dart](https://dart.dev/get-dart)
- [Android Studio](https://developer.android.com/studio)
- [Xcode (untuk pengembangan iOS)](https://developer.apple.com/xcode/)
- [Visual Studio Code (opsional)](https://code.visualstudio.com/)

## Langkah Instalasi

### 1. Clone Repository

Clone repository proyek ini ke komputer Anda menggunakan perintah berikut:

git clone [https://github.com/0x0v0/votingapp-flutter.git](https://github.com/0x0v0/voting-app-flutter.git)

cd nama-proyek-flutter

### 2. Instal Dependencies
Jalankan perintah berikut untuk menginstal semua dependencies yang diperlukan oleh proyek:

- flutter pub get

Tunggu sampai instalasi berhasil dan Anda dapat menjalankan program tersebut dengan memilih jenis emulator yang ingin Anda gunakan untuk menampilkan output aplikasi tersebut, lalu running. (tidak direkomendasikan menggunakan browser)

### 3. Konfigurasi Android
Untuk menjalankan proyek di Android, ikuti langkah-langkah berikut:

Buka proyek di Android Studio:

- open -a "Android Studio"

Hubungkan perangkat Android atau nyalakan emulator Android.
Jalankan proyek dari Android Studio atau gunakan perintah berikut:

- flutter run

### 4. Konfigurasi iOS
Untuk menjalankan proyek di iOS, ikuti langkah-langkah berikut:

Buka proyek di Xcode:

- pen ios/Runner.xcworkspace

Hubungkan perangkat iOS atau nyalakan simulator iOS.
Jalankan proyek dari Xcode atau gunakan perintah berikut:

- flutter run

### 5. Konfigurasi Web
Untuk menjalankan proyek di web, ikuti langkah-langkah berikut:

Jalankan perintah berikut:

- flutter run -d chrome

### 6. Konfigurasi Desktop (opsional)
Jika Anda ingin menjalankan proyek di platform desktop (Windows, macOS, atau Linux), pastikan Anda sudah mengaktifkan dukungan desktop di Flutter:

Aktifkan dukungan desktop:

- flutter config --enable-windows-desktop
- flutter config --enable-macos-desktop
- flutter config --enable-linux-desktop

Jalankan proyek di platform desktop yang diinginkan, contoh untuk Windows:

- flutter run -d windows

### Struktur Direktori
Berikut adalah struktur direktori utama dalam proyek ini:

- nama-proyek-flutter/
- │
- ├── android/             # Konfigurasi dan kode spesifik untuk platform Android
- ├── build/               # Hasil build (termasuk dalam .gitignore)
- ├── ios/                 # Konfigurasi dan kode spesifik untuk platform iOS
- ├── lib/                 # Kode sumber utama aplikasi Flutter
- ├── macos/               # Konfigurasi dan kode spesifik untuk platform macOS
- ├── web/                 # Kode sumber untuk platform web
- ├── windows/             # Konfigurasi dan kode spesifik untuk platform Windows
- ├── test/                # Unit test untuk proyek
- ├── .gitignore           # File untuk mengabaikan file dan direktori tertentu dalam git
- └── pubspec.yaml         # File konfigurasi proyek Flutter

Ini hanya contoh struktur direktori, pada VotingApp tersebut diperuntukan untuk desktop/laptop windows dan menggunakan emulator handphone sebagai output, tidak di rekomendasikan lewat browser.

### Kontribusi
Jika Anda ingin berkontribusi pada proyek ini, silakan fork repository ini, buat branch baru untuk fitur atau bug fix Anda, dan buat pull request setelah selesai.

### Lisensi
Lisensi proyek ini di bawah MIT License.


### This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
