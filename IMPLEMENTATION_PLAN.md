# IMPLEMENTATION PLAN: BIL_CUT (CapCut Clone - Flutter & Android)

Aplikasi editing video mobile berbasis **Flutter** (UI/UX) dan **Native Video Engine** yang mengadopsi fungsionalitas, alur kerja, dan tampilan presisi layaknya **CapCut**.

---

## 🎯 Target Arsitektur & Tech Stack
- **Framework UI:** Flutter (Dart 3.x, Flutter 3.35+)
- **State Management:** Riverpod (`flutter_riverpod`) untuk reaktivitas tinggi dan isolasi render timeline
- **Design System:** CapCut Dark Aesthetic (`#121212`, `#1E1E1E`, Cyan Accent `#00F0FF`, Clean Typography)
- **Video Engine (Playback):** Hardware-accelerated player (`media_kit` / Android SurfaceTexture) dengan seek milidetik presisi
- **Rendering & Export Engine:** Hardware-accelerated pipeline (AndroidX Media3 Transformer / FFmpeg Kit)
- **Local Persistence:** Hive / Isar / SQLite untuk draft proyek

---

## 🗺️ Roadmap Fase Implementasi

```
+----------------------------------------------------------------------------+
| FASE 1: Fondasi Arsitektur, Design System & Shell UI                       |
|         - Setup dependency, Clean Architecture folder structure            |
|         - CapCut Dark Theme & Design Tokens                                |
|         - Home Screen (Draft Proyek & Tombol New Project)                  |
|         - Editor Screen Shell (Header, Viewport, Timeline Area, Toolbars)  |
+----------------------------------------------------------------------------+
                                      |
                                      v
+----------------------------------------------------------------------------+
| FASE 2: Data Model & Custom Interactive Timeline Engine                    |
|         - Project, Track, TimelineClip data models                         |
|         - Custom Time Ruler (Skala waktu milidetik & zoom dinamis)        |
|         - Playhead Scrubbing (Kursor waktu reaktif)                        |
|         - Multi-track Canvas (Video Track, Audio Track, Text Track)        |
|         - Gestures: Drag, Trim Handle kiri/kanan, Pinch-to-zoom             |
+----------------------------------------------------------------------------+
                                      |
                                      v
+----------------------------------------------------------------------------+
| FASE 3: Media Import & Video Playback Integration                          |
|         - Image/Video Picker dari galeri                                   |
|         - Player Engine Integration (Real-time Preview)                    |
|         - Frame Thumbnail Generator & Caching (LRU Cache)                  |
|         - Sinkronisasi kursor Playhead <-> Video Player                     |
+----------------------------------------------------------------------------+
                                      |
                                      v
+----------------------------------------------------------------------------+
| FASE 4: Core Editing Engine (Tools Pemotong & Modifikasi)                  |
|         - Split / Bagi klip di posisi playhead                             |
|         - Trim Head / Tail durasi klip                                     |
|         - Kontrol Kecepatan (0.1x s/d 100x & Curve Speed)                  |
|         - Volume audio klip & Mute                                         |
|         - Reorder klip & Hapus klip                                        |
|         - Undo / Redo History System (Command Pattern)                     |
+----------------------------------------------------------------------------+
                                      |
                                      v
+----------------------------------------------------------------------------+
| FASE 5: Multi-Track Overlays (Teks, BGM Audio & PIP)                       |
|         - Track Teks: Font kustom, warna, stroke, background, bubble       |
|         - Track Audio: Import musik, pemotong lagu, waveform audio visual  |
|         - Track PIP (Picture-in-Picture): Overlay video di atas video      |
|         - Canvas Aspect Ratio: 9:16 (TikTok), 16:9 (YouTube), 1:1, 4:5     |
+----------------------------------------------------------------------------+
                                      |
                                      v
+----------------------------------------------------------------------------+
| FASE 6: Visual Effects, Filters & Transitions                              |
|         - Transisi antar klip (Fade, Dissolve, Slide, Zoom in/out)         |
|         - Color Grading & Filter (Brightness, Contrast, Saturation, LUT)   |
|         - Animasi Masuk/Keluar (In/Out Animation)                          |
+----------------------------------------------------------------------------+
                                      |
                                      v
+----------------------------------------------------------------------------+
| FASE 7: Video Export Engine (High-Performance Rendering)                   |
|         - Export Pipeline ke MP4 (H.264 / AAC)                             |
|         - Pilihan Resolusi (720p, 1080p, 2K/4K) & FPS (24, 30, 60 fps)     |
|         - Progress Bar Rendering & Background Task                         |
|         - Simpan ke Galeri / DCIM & Tombol Share                           |
+----------------------------------------------------------------------------+
                                      |
                                      v
+----------------------------------------------------------------------------+
| FASE 8: Polish, Optimasi Performa & Rilis Android                          |
|         - Optimasi memori (mencegah OOM saat banyak klip)                  |
|         - Testing di Android Emulator & Device Fisik                       |
|         - Build Release APK / App Bundle                                   |
+----------------------------------------------------------------------------+
```

---

## 📋 Rincian Detail Setiap Fase

### 🔹 FASE 1: Fondasi Arsitektur, Design System & Shell UI
* **Tujuan:** Membuat kerangka aplikasi yang kokoh, modular, dan memiliki tampilan visual yang 100% identik dengan nuansa CapCut.
* **Komponen & Tugas:**
  1. Menambahkan dependensi utama (`flutter_riverpod`, `lucide_icons`, `google_fonts`, `path_provider`, dll.).
  2. Menata struktur folder bersih: `core/`, `data/`, `logic/`, `presentation/`.
  3. Mengatur tema gelap CapCut:
     - Background dasar: `#121212`
     - Card / Container: `#1E1E1E` & `#282828`
     - Accent: Neon Cyan `#00F0FF` / Biru CapCut
     - Teks: Putih & Abu-abu muda `#A0A0A0`
  4. Membangun **Home Screen**:
     - Header profil & tombol pengaturan
     - Banner utama "Proyek Baru" (+ icon besar)
     - Grid/List proyek draft yang tersimpan
  5. Membangun **Editor Screen Shell**:
     - Header: Tombol kembali, Undo, Redo, tombol Export, resolusi picker (1080P)
     - Preview Viewport (container video dengan rasio aspek dinamis)
     - Mini Quick Actions: Play/Pause, Durasi (00:00 / 00:15)
     - Timeline Container Placeholder
     - Bottom Menu Bar (Edit, Audio, Teks, Overlay, Efek, Filter, Format, Kanvas)

---

### 🔹 FASE 2: Data Model & Custom Interactive Timeline Engine
* **Tujuan:** Membangun inti interaksi video editor, yaitu *Timeline Canvas* multi-track yang presisi milidetik dan responsif.
* **Komponen & Tugas:**
  1. Data Class:
     - `ProjectModel`: metadata durasi total, aspect ratio, list tracks.
     - `TrackModel`: tipe (`video`, `audio`, `text`, `overlay`), list clips.
     - `ClipModel`: id, mediaPath, startTime (ms), duration (ms), trimIn (ms), trimOut (ms), speed, volume.
  2. Custom Widget Timeline:
     - **Timeline Ruler:** Garis penunjuk waktu (00:00, 00:01, dll.) dengan tick mark yang menyesuaikan tingkat zoom.
     - **Playhead (Kursor):** Garis vertikal penunjuk waktu di tengah layar.
     - **Scroll & Zoom Controller:** Pinch gesture untuk memperbesar/memperkecil skala waktu (misal: 1 detik = 50px hingga 200px).
     - **Track Clip View:** Kotak klip dengan *trim handle* di ujung kiri dan kanan untuk memotong durasi dengan drag.
     - **Snapping System:** Snapping otomatis ketika playhead mendekati titik potong klip.

---

### 🔹 FASE 3: Media Import & Video Playback Integration
* **Tujuan:** Mengintegrasikan pemutar video asli dan pemilihan media dari penyimpanan perangkat.
* **Komponen & Tugas:**
  1. Integrasi picker media (`image_picker` / `file_picker` / `photo_manager`) dengan akses izin penyimpanan Android.
  2. Integrasi video playback engine dengan performa tinggi & hardware acceleration.
  3. Video Thumbnail Generator: Mengambil snapshot frame video pada interval waktu tertentu untuk ditampilkan sebagai strip di dalam klip timeline.
  4. Memory-safe LRU Cache untuk thumbnail agar timeline tetap lancar 60 FPS tanpa kehabisan RAM.
  5. Sinkronisasi dua arah:
     - Saat video diputar (Play), timeline bergerak otomatis.
     - Saat timeline di-scrub (geser kursor), video seek ke frame yang tepat secara instan.

---

### 🔹 FASE 4: Core Editing Engine (Tools Pemotong & Modifikasi)
* **Tujuan:** Mengaktifkan seluruh fungsi manipulasi klip dasar.
* **Komponen & Tugas:**
  1. **Split (Bagi):** Memotong klip yang dipilih tepat pada posisi playhead menjadi dua klip terpisah.
  2. **Trim (Pangkas):** Memotong awal (*head*) atau akhir (*tail*) klip secara real-time.
  3. **Speed Controller:** Mengatur kecepatan klip (0.1x hingga 100x), otomatis menghitung ulang durasi timeline.
  4. **Volume & Mute:** Pengaturan volume per klip (0% s/d 200%) dan tombol mute audio track utama.
  5. **Delete & Duplicate:** Menghapus klip terpilih atau menduplikasi klip.
  6. **Undo / Redo Architecture:** Menerapkan *Command Pattern* agar setiap aksi edit dapat dibatalkan atau diulangi dengan tombol Undo/Redo di header.

---

### 🔹 FASE 5: Multi-Track Overlays (Teks, Audio BGM & PIP)
* **Tujuan:** Mendukung editing multi-layer layaknya CapCut modern.
* **Komponen & Tugas:**
  1. **Text Track & Editor:**
     - Menambah layer teks di atas video.
     - Pilihan font, ukuran, warna, stroke, background box, dan alignment.
     - Geser, rotasi, dan atur durasi teks langsung dari timeline & preview canvas.
  2. **Audio Track:**
     - Import file audio/musik (MP3, WAV, AAC).
     - Render representasi visual gelombang suara (*waveform*).
     - Trim audio, atur volume, dan fade in / fade out.
  3. **PIP (Overlay Video):** Menaruh klip video kedua di atas video utama dengan pengaturan posisi & ukuran.
  4. **Canvas Format Picker:** Mengubah format rasio tampilan (9:16 untuk TikTok/Shorts/Reels, 16:9 untuk YouTube horizontal, 1:1 untuk feed).

---

### 🔹 FASE 6: Visual Effects, Filters & Transitions
* **Tujuan:** Mempercantik video dengan sentuhan transisi dan penyesuaian visual.
* **Komponen & Tugas:**
  1. **Transitions:**
     - Tombol transisi di antara dua klip yang bersambung.
     - Efek transisi populer: Dissolve, Fade to Black, Slide Left/Right, Zoom in.
  2. **Color Adjustments (Filters):**
     - Brightness, Contrast, Saturation, Exposure, Temperature.
  3. **Animation Presets:** Animasi masuk dan keluar untuk klip dan teks (Fade in, Slide up, Pop).

---

### 🔹 FASE 7: Video Export Engine (High-Performance Rendering)
* **Tujuan:** Mengolah seluruh timeline menjadi satu file video MP4 utuh dengan kualitas tinggi.
* **Komponen & Tugas:**
  1. Pembuatan command / pipeline rendering (Media3 Transformer / FFmpeg Kit) yang menggabungkan:
     - Klip video berurutan sesuai titik trim dan speed.
     - Mixing track audio utama + musik background.
     - Render overlay teks & gambar pada timestamp yang ditentukan.
     - Aplikasi transisi & efek warna.
  2. Dialog Export:
     - Pilihan resolusi: 720p, 1080p, 2K/4K.
     - Pilihan Frame Rate: 24fps, 30fps, 60fps.
  3. Indikator progress bar (0% - 100%) dengan estimasi waktu selesai.
  4. Notifikasi ekspor selesai & opsi simpan ke galeri atau bagikan ke media sosial.

---

### 🔹 FASE 8: Polish, Optimasi Performa & Rilis
* **Tujuan:** Finalisasi aplikasi agar stabil, mulus, dan siap pakai.
* **Komponen & Tugas:**
  1. Profiling performa memori dan CPU saat memproses video panjang.
  2. Handling edge cases: rotasi layar, interupsi telepon saat preview, memori penuh saat ekspor.
  3. Pengujian menyeluruh pada Android Emulator & Perangkat Fisik.
  4. Konfigurasi Android App Manifest (Permissions: Storage, Camera, Microphone) & icon aplikasi.
  5. Build APK Release (`flutter build apk --release`).

---

## 🚦 Aturan Eksekusi
Kita akan mengerjakan proyek ini **secara bertahap per fase**:
1. Setiap fase akan diimplementasikan secara tuntas dan diuji.
2. Setelah satu fase selesai, kita akan melakukan review dan verifikasi bersama Anda sebelum melangkah ke fase berikutnya.

