# Pakebun Rain Aggregator (Node-RED)

Flow ini menghitung metrik turunan hujan dari payload AWS kumulatif dan menggabungkannya kembali ke `aws/<deviceId>/data` (retained):
- `rain_today` (mm)
- `rain_last_hour` (mm)
- `rain_rate_10m` (mm/h)

## Cara pakai

1) Buka Node-RED (http://localhost:1880).
2) Menu (kiri atas) → Import → pilih file `flow_rain_aggregator.json` dari folder ini → Import.
3) Klik node `pentarium` (broker) → atur host `pentarium.id`, port `1883` (default sudah benar) → Deploy.
4) Pastikan perangkat ESP mengirim ke topik `aws/<deviceId>/data` dengan payload berisi `aws.rain` dan `ts` (epoch). Contoh:
```
{"id":"C45120B7B3F8","ts":1761101778,"aws":{"rain":3.81,...}}
```
5) Setelah beberapa pesan masuk, Node-RED akan mem-publish kembali ke `aws/<deviceId>/data` (retained) dengan tambahan field:
```
{"id":"...","ts":...,"aws":{"rain":3.81,"rain_today":0.2,"rain_last_hour":0.05,"rain_rate_10m":0.8,...},"_agg":{"source":"pakebun-nodered","v":1}}
```

## Catatan
- Node ini menyisipkan `_agg.source = pakebun-nodered` untuk mencegah loop (pesan yang sudah diperkaya tidak diproses ulang).
- Perhitungan memakai jendela bergerak 60 menit (last hour) dan 10 menit (rate) dengan data kumulatif dari perangkat.
- Reset harian dilakukan di tengah malam waktu lokal.

## Kapan memilih Node-RED?
- Jika Anda ingin solusi server-side tanpa menulis Python, cepat di-deploy, dan gampang dipantau.
- Untuk produksi, jalankan Node-RED sebagai service dan amankan akses broker bila perlu.

## Menjalankan via Docker (disarankan untuk server/VPS)

Di folder ini sudah ada `docker-compose.yml`.

Langkah ringkas:

1) Pastikan Docker sudah terpasang (Windows: Docker Desktop; Linux: Docker Engine/Compose).  
2) Opsional: buat folder `data/` secara otomatis saat pertama kali jalan (akan dibuat oleh Compose).  
3) Jalankan:

	 - Windows (PowerShell atau CMD):
		 - `docker compose up -d`

	 - Linux:
		 - `docker compose up -d`

4) Buka http://localhost:1880 lalu Import `flow_rain_aggregator.json`, atau copy file ini menjadi `./data/flows.json` sebelum run pertama supaya otomatis ter-load.

Catatan:
- Data (flows, credentials) akan persist di `./data`. Backup/migrasi cukup copy folder `data`.
- Untuk auto-restart, Compose sudah `restart: unless-stopped`.
- Ubah port 1880 jika perlu.
