# Mental Health Assistant (Flutter Frontend)

![Flutter](https://img.shields.io/badge/Flutter-3.0%2B-02569B?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-2.17%2B-0175C2?logo=dart)
![License](https://img.shields.io/badge/License-MIT-green)

> **Aplikasi pendamping kesehatan emosional pribadi dengan konsep "Admin-less" untuk menjamin privasi mutlak pengguna.**

## Tentang Proyek

**Mental Health Assistant** adalah aplikasi mobile berbasis Flutter yang dirancang untuk menjadi ruang aman (*safe space*) bagi pengguna. Berbeda dengan aplikasi konseling konvensional, aplikasi ini **tidak memiliki Admin manusia** yang memantau data.

Sebagai gantinya, aplikasi ini menggunakan **AI Companion** dan sistem pemantauan mandiri (*Self-monitoring*) untuk membantu pengguna mencatat jurnal, melacak suasana hati, dan mengurangi stres kapan saja dan di mana saja.

---

## Fitur Unggulan

### 1. Privasi Terjamin (Admin-less Architecture)
Sistem autentikasi mandiri. Data jurnal dan chat hanya dapat diakses oleh pengguna. Tidak ada dashboard admin untuk mengintip data pengguna.

### 2. AI Companion (Smart Chat)
Teman cerita cerdas yang tersedia 24/7.
- Antarmuka *Bubble Chat* modern membedakan pesan User dan AI.
- Riwayat percakapan tersimpan rapi per sesi.

### 3. Daily Check-in & Journaling
Pencatatan kondisi harian yang interaktif.
- Input **Mood** (Slider 1-5), **Energi**, dan **Tidur**.
- Jurnal harian dengan *prompt* otomatis untuk memancing refleksi diri.

### 4. Visualisasi Data (Mood Trends)
Analisis kesehatan mental jangka panjang.
- Grafik kurva (*Curved Line Chart*) menggunakan `fl_chart`.
- Sumbu Y dikustomisasi menggunakan **Ikon Emotikon** untuk representasi data yang intuitif.

### 5. Wellness Tools
Alat pertolongan pertama psikologis.
- **Toolbox:** Latihan pernapasan dan kontak darurat (SOS).
- **Quiz:** Deteksi dini tingkat stres.


## Teknologi (Tech Stack)

- **Frontend:** Flutter (Dart)
- **State Management:** Native `setState` & `FutureBuilder` (Simpel & Efisien)
- **Charting Library:** [`fl_chart`](https://pub.dev/packages/fl_chart) untuk grafik history.
- **Networking:** `http` package untuk komunikasi dengan REST API.
- **Formatting:** `intl` package untuk format tanggal.

---

## 📂 Struktur Folder

```text
lib/
├── main.dart                 # Entry point
├── models/                   # Data Models (User, Checkin, Chat)
├── services/                 # API Connection Logic
└── screens/                  # UI Implementation
    ├── auth_screen.dart      # Login/Register Logic
    ├── home_screen.dart      # Dashboard & Navigation
    ├── checkin_screen.dart   # Mood Input Logic
    ├── chat_screen.dart      # Chat Interface
    ├── history_screen.dart   # Chart Visualization
    ├── toolbox_screen.dart   # Breathing/SOS Tools
    └── quiz_screen.dart      # Stress Assessment
