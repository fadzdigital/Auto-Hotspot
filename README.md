# Skrip Pengaturan Hotspot Android

## Ikhtisar
Skrip ini mengotomatiskan konfigurasi hotspot Wi-Fi atau tethering USB pada perangkat Android, terutama untuk Android 11l0. Skrip memeriksa keberadaan antarmuka jaringan (`wlan0` untuk Wi-Fi atau `rndis0` untuk tethering USB), mengaktifkan tethering jika perlu, dan menetapkan alamat IP default (`192.168.43.1/24`) ke antarmuka yang ditentukan (`wlan0`). Aktivitas dicatat ke `/data/adb/hotspot.log` untuk debugging, dan skrip dapat dijalankan secara otomatis menggunakan `crontab`.

## Fitur
- Memeriksa keberadaan antarmuka jaringan `wlan0` dan `rndis0`.
- Mengaktifkan tethering Android jika tidak ada antarmuka yang ditemukan.
- Menetapkan alamat IP statis (`192.168.43.1/24`) ke `wlan0` jika belum dikonfigurasi.
- Mencatat semua aktivitas dengan timestamp ke `/data/adb/hotspot.log`.
- Mendukung otomatisasi melalui `crontab`.

## Persyaratan
- **Akses Root**: Skrip memerlukan hak akses root untuk menjalankan perintah `su`.
- **Busybox**: Perintah seperti `ifconfig` dan `ip` harus tersedia (biasanya disediakan oleh Busybox).
- **Perangkat Android**: Android 10+ dengan kemampuan tethering.
- **Akses ADB**: Untuk menjalankan skrip melalui ADB atau mengakses file log dan `crontab`.

## Instalasi
1. **Salin Skrip**:
   - Simpan skrip sebagai `hotspot_setup.sh` di perangkat Android (misalnya, di `/data/adb/`).
   - Berikan izin eksekusi:
     ```bash
     chmod +x /data/adb/hotspot_setup.sh
     ```

2. **Verifikasi Dependensi**:
   - Pastikan perangkat sudah di-root dan Busybox terinstal.
   - Konfirmasi bahwa perintah `ifconfig`, `ip`, dan `su` tersedia.

## Cara Penggunaan
1. **Jalankan Secara Manual**:
   - Jalankan skrip sebagai root menggunakan terminal emulator atau ADB:
     ```bash
     su -c /data/adb/hotspot_setup.sh
     ```
   - Atau via ADB:
     ```bash
     adb shell su -c /data/adb/hotspot_setup.sh
     ```

2. **Otomatisasi dengan Crontab**:
   - Edit file `crontab` di `/data/adb/box/crontab.cfg` (sesuaikan dengan lokasi yang digunakan):
     ```bash
     crontab -e
     ```
   - Tambahkan baris untuk menjalankan skrip setiap 1 menit (misalnya):
     ```plaintext
     */1 * * * * /data/adb/hotspot_setup.sh >/dev/null 2>&1
     ```
   - Simpan dan restart `crond` jika perlu:
     ```bash
     /system/bin/crond -c /data/adb/box/
     ```

3. **Periksa Log**:
   - Lihat file log untuk memverifikasi konfigurasi atau mendiagnosis masalah:
     ```bash
     cat /data/adb/hotspot.log
     ```

4. **Perilaku yang Diharapkan**:
   - Jika `wlan0` atau `rndis0` terdeteksi, skrip melewati aktivasi tethering.
   - Jika tidak ada antarmuka, skrip mengaktifkan tethering dan menetapkan IP `192.168.43.1/24` ke `wlan0`.
   - Error akan dicatat, dan skrip keluar dengan kode error jika gagal.

## Contoh Output Log
```
===========================================
      Skrip Pengaturan Hotspot Android
===========================================
[2025-07-13 11:46:12] Memulai konfigurasi hotspot...
[2025-07-13 11:46:12] Memeriksa antarmuka jaringan...
[2025-07-13 11:46:12] wlan0: tidak, rndis0: tidak
[2025-07-13 11:46:12] Tidak ada wlan0 atau rndis0. Mengaktifkan tethering...
[2025-07-13 11:46:13] Tethering berhasil diaktifkan.
[2025-07-13 11:46:14] Memeriksa konfigurasi IP untuk wlan0...
[2025-07-13 11:46:14] Tidak ada alamat IP untuk wlan0. Menetapkan 192.168.43.1/24...
[2025-07-13 11:46:14] Berhasil menetapkan 192.168.43.1/24 ke wlan0.
[2025-07-13 11:46:14] Konfigurasi hotspot selesai.
===========================================
```

## Catatan
- **Subnet Default**: Skrip menggunakan `192.168.43.1/24`. Ubah variabel `SUBNET` jika perangkat menggunakan subnet lain.
- **Persyaratan Root**: Tanpa root, skrip tidak akan berfungsi.
- **File Log**: Pastikan `/data/adb/` dapat ditulis.
- **Crontab**: Sesuaikan jadwal di `crontab.cfg` sesuai kebutuhan (misalnya, `*/5` untuk setiap 5 menit).

## Pemecahan Masalah
- **Skrip Gagal Berjalan**:
  - Verifikasi akses root dengan `su`.
  - Pastikan Busybox terinstal.
- **Tethering Tidak Aktif**:
  - Periksa dukungan tethering dan validitas perintah untuk versi Android.
- **IP Tidak Ditetapkan**:
  - Konfirmasi `wlan0` sebagai antarmuka yang benar.
  - Periksa log untuk pesan error.
