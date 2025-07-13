#!/system/bin/sh
# ==========================================================================
# Judul       : Skrip Pengaturan Hotspot untuk Android
# Deskripsi   : Mengotomatiskan aktivasi hotspot/tethering di Android
#               dengan memeriksa antarmuka jaringan dan menetapkan IP.
#               Android 10 On
# Persyaratan : Akses root, busybox, dan lingkungan Android
# ==========================================================================

# Keluar jika terjadi error
set -e

# Variabel Konfigurasi
LOGFILE="/data/adb/hotspot.log"
SUBNET="192.168.43.1/24"
AP="wlan0"

# Fungsi untuk mencatat pesan dengan timestamp
log_pesan() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOGFILE"
}

# Header untuk file log
echo "===========================================" > "$LOGFILE"
echo "      Skrip Pengaturan Hotspot Android" >> "$LOGFILE"
echo "===========================================" >> "$LOGFILE"
log_pesan "Memulai konfigurasi hotspot..."

# Memeriksa keberadaan antarmuka jaringan (wlan0 dan rndis0)
log_pesan "Memeriksa antarmuka jaringan..."
has_wlan0=$(ifconfig | grep -q '^wlan0' && echo "ya" || echo "tidak")
has_rndis0=$(ifconfig | grep -q '^rndis0' && echo "ya" || echo "tidak")
log_pesan "wlan0: $has_wlan0, rndis0: $has_rndis0"

# Logika utama: Konfigurasi tethering jika antarmuka tidak tersedia
if [ "$has_wlan0" = "tidak" ] && [ "$has_rndis0" = "tidak" ]; then
    log_pesan "Tidak ada wlan0 atau rndis0. Mengaktifkan tethering..."

    # Mengaktifkan tethering Android
    if su -c 'service call tethering 4 null s16 random' >> "$LOGFILE" 2>&1; then
        log_pesan "Tethering berhasil diaktifkan."
    else
        log_pesan "ERROR: Gagal mengaktifkan tethering."
        exit 1
    fi

    # Menunggu antarmuka stabil
    sleep 1

    # Memeriksa dan menetapkan alamat IP ke wlan0
    log_pesan "Memeriksa konfigurasi IP untuk $AP..."
    if ! ip addr show dev "$AP" | grep -q "inet ${SUBNET}"; then
        log_pesan "Tidak ada alamat IP untuk $AP. Menetapkan ${SUBNET}..."
        if su -c "ip address add ${SUBNET} dev $AP" >> "$LOGFILE" 2>&1; then
            log_pesan "Berhasil menetapkan ${SUBNET} ke $AP."
        else
            log_pesan "ERROR: Gagal menetapkan alamat IP ke $AP."
            exit 1
        fi
    else
        log_pesan "Alamat IP ${SUBNET} sudah dikonfigurasi di $AP."
    fi
else
    log_pesan "Antarmuka jaringan sudah tersedia. Melewati konfigurasi tethering."
fi

# Catatan akhir
log_pesan "Konfigurasi hotspot selesai."
echo "===========================================" >> "$LOGFILE"
