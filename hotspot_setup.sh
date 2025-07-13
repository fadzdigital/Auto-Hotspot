#!/system/bin/sh
# ==========================================================================
# Judul       : Skrip Pengaturan Hotspot untuk Android
# Deskripsi   : Mengotomatiskan aktivasi tethering di Android 10 (Hades ROM)
#               dengan fokus pada rndis0 untuk USB tethering.
# Persyaratan : Akses root, busybox, dan lingkungan Android
# ==========================================================================

# Keluar jika terjadi error
set -e

# Variabel Konfigurasi
LOGFILE="/data/adb/hotspot.log"
SUBNET="192.168.42.1/24"  # Disesuaikan dengan IP tethering default
AP="rndis0"  # Menggunakan rndis0 berdasarkan data Anda

# Fungsi untuk mencatat pesan dengan timestamp
log_pesan() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOGFILE"
}

# Header untuk file log
echo "===========================================" > "$LOGFILE"
echo "      Skrip Pengaturan Hotspot Android" >> "$LOGFILE"
echo "===========================================" >> "$LOGFILE"
log_pesan "Memulai konfigurasi tethering..."

# Memeriksa keberadaan antarmuka jaringan
log_pesan "Memeriksa antarmuka jaringan..."
if ifconfig | grep -q "^$AP"; then
    has_rndis0="ya"
else
    has_rndis0="tidak"
fi
log_pesan "$AP: $has_rndis0"

# Logika utama: Konfigurasi tethering jika antarmuka tidak tersedia
if [ "$has_rndis0" = "tidak" ]; then
    log_pesan "Antarmuka $AP tidak ditemukan. Mencoba mengaktifkan tethering..."

    # Coba metode tethering alternatif untuk Android 10
    if su -c 'cmd connectivity tether apply 1' >> "$LOGFILE" 2>&1; then
        log_pesan "Tethering berhasil diaktifkan dengan cmd connectivity."
    elif su -c 'svc usb setFunction tethering' >> "$LOGFILE" 2>&1; then
        log_pesan "Tethering USB berhasil diaktifkan dengan svc usb."
    else
        log_pesan "ERROR: Gagal mengaktifkan tethering. Periksa pengaturan sistem."
        exit 1
    fi

    # Menunggu antarmuka stabil
    sleep 2

    # Memeriksa dan menetapkan alamat IP ke rndis0
    log_pesan "Memeriksa konfigurasi IP untuk $AP..."
    if ! ip addr show dev "$AP" | grep -q "inet ${SUBNET}"; then
        log_pesan "Tidak ada alamat IP untuk $AP. Menetapkan ${SUBNET}..."
        if su -c "ip address add ${SUBNET} dev $AP" >> "$LOGFILE" 2>&1; then
            log_pesan "Berhasil menetapkan ${SUBNET} ke $AP."
        else
            log_pesan "ERROR: Gagal menetapkan alamat IP ke $AP. Periksa antarmuka."
            exit 1
        fi
    else
        log_pesan "Alamat IP ${SUBNET} sudah dikonfigurasi di $AP."
    fi
else
    log_pesan "Antarmuka $AP tersedia. Melewati konfigurasi tethering."
fi

# Catatan akhir
log_pesan "Konfigurasi tethering selesai."
echo "===========================================" >> "$LOGFILE"
