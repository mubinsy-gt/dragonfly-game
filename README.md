# DRAGON FLY

Game arcade 2D *endless flyer* pixel art bertema naga api dan dunia vulkanik.
Dibuat sepenuhnya sebagai proyek Godot (scene, script, resource, tekstur, dan audio)
sehingga dapat dibuka, dijalankan, dan diedit melalui editor Godot.

---

## 1. Versi Godot

- **Godot Engine 4.7.2** (stable)
- Bahasa: **GDScript**
- Renderer: **Forward+** (2D)

## 2. Cara membuka proyek

1. Buka Godot 4.7.2.
2. Pilih **Import** lalu arahkan ke file `project.godot` di folder ini.
3. Klik **Import & Edit**. Tunggu hingga Godot selesai mengimpor aset
   (tekstur dan audio) pada kali pertama.

## 3. Cara menjalankan game

- Tekan **F5** (atau tombol ▶ Run Project). Scene utama adalah
  `res://scenes/menus/splash.tscn`.
- Untuk menjalankan scene tertentu saja, buka scene tersebut lalu tekan **F6**.
- Urutan layar: **Splash → Menu Utama → (PLAY) Gameplay → Game Over → Retry / Home**.

## 4. Kontrol permainan

| Aksi | Kontrol |
|---|---|
| Terbang (kepakan sayap) | **Tap layar**, **Klik kiri mouse**, atau **Spasi** |
| Pause | Tombol **II** di HUD, tombol **Esc**, atau tombol **P** |
| Lanjut setelah pause | Tombol **LANJUT** (ada hitung mundur 3-2-1) |
| Navigasi tombol UI | Mouse / sentuh / Tab + Enter |

Satu tap = satu kepakan. Menekan tombol UI tidak memicu kepakan. Saat aplikasi
kehilangan fokus, permainan otomatis dijeda.

## 5. Cara mengganti tekstur melalui Inspector

1. Buka scene yang diinginkan (mis. `res://scenes/dragons/ember_hatchling.tscn`).
2. Pilih node **Sprite** (AnimatedSprite2D) → **SpriteFrames** → klik animasi →
   ganti **Texture** pada keyframe.
3. Untuk node `Sprite2D`/`TextureRect` biasa, cukup ubah properti **Texture**
   pada panel Inspector, lalu simpan scene (Ctrl+S).

Semua berkas gambar disimpan pada folder `assets/` dan berukuran **64×64 px**
(kecuali gambar langit penuh 640×360 dan font/audio).

## 6. Cara mengedit animasi SpriteFrames

- Buka scene naga → pilih node **Sprite** (AnimatedSprite2D) → tab **SpriteFrames**
  di panel bawah.
- Animasi bernama **`fly`** berisi 6 frame 64×64.
- Anda dapat menambah frame, mengubah kecepatan (FPS), atau menyalakan
  **Autoplay** dan **Loop**.

## 7. Cara mengubah harga dan statistik naga

Setiap naga adalah resource **DragonData** (`res://resources/dragons/*.tres`).

1. Klik dua kali file `.tres` (mis. `obsidian_king.tres`) untuk membukanya di Inspector.
2. Ubah: **Price**, **Currency** (`coin`/`gem`), **Point Bonus** (0.05 = +5%),
   **Magnet Radius**, **Shields**, **Description**, **Scene**, **Icon**.
3. Urutan dan daftar naga diatur pada `res://resources/dragons/dragon_catalog.tres`.

## 8. Cara mengubah background, map, rintangan, dan tingkat kesulitan

- **Map**: resource **MapConfig** pada `res://resources/maps/*.tres`
  (tekstur langit/jauh/tengah/dasar/overlay, posisi lapisan, faktor parallax,
  jenis rintangan, burung, warna tint). Urutan map pada `map_catalog.tres`
  (`Obstacles Per Map` = 25).
- **Rintangan**: scene pada `res://scenes/gameplay/obstacles/`. Rintangan
  pasangan (pilar, stalaktit) memakai modul 64×64 untuk badan dan ujung;
  rintangan `floating` adalah batu mengambang tunggal.
- **Kesulitan & fisika**: resource **GameConfig**
  (`res://resources/config/game_config.tres`) — gravitasi, impuls kepakan,
  kecepatan dasar/maksimum, interval spawn, tinggi celah, dsb.
- **Pergantian map** memakai jumlah rintangan yang dilewati (0–24, 25–49,
  50–74, 75–99, lalu berulang dengan kesulitan lebih tinggi).

## 9. Cara mengubah bonus poin dan hadiah

- **Bonus Poin** berasal dari naga yang dipakai (`Point Bonus` pada DragonData).
  Rumus: `Skor = poin dasar × (1 + bonus)`, dibulatkan ke bawah.
- **Hadiah** diatur pada **GameConfig**: `Coin Value`, `Coins Per Obstacle`
  (koin per rintangan), `Gem Every Obstacles` (gem tiap N rintangan),
  `Rare Gem Chance` (peluang gem langka).

## 10. Cara menambahkan naga atau map baru

**Naga baru**
1. Siapkan atlas animasi 64×64 (spanduk 6×1 frame) di `assets/characters/`.
2. Duplikat scene naga di `scenes/dragons/`, ganti tekstur SpriteFrames.
3. Duplikat satu `.tres` di `resources/dragons/`, isi data, arahkan **Scene** dan **Icon**.
4. Tambahkan resource tersebut ke `dragon_catalog.tres`.

**Map baru**
1. Duplikat `.tres` di `resources/maps/`, isi tekstur dan parameter.
2. Tambahkan ke `map_catalog.tres`.

## 11. Cara mengekspor game untuk Android

1. **Editor Settings → Export → Android**: atur *Android SDK Path* dan
   *Debug Keystore* (lihat dokumentasi Godot "Exporting for Android").
2. **Project → Export → Add… → Android**.
3. Pastikan orientasi **Landscape** dan resolusi sudah diatur (lihat di bawah).
4. Isi *Package Name*, *Keystore*, klik **Export Project**, lalu pilih lokasi `.apk`.
5. Untuk menguji di perangkat: **Project → Run on device**.

### Pengaturan proyek yang sudah disiapkan

| Setting | Nilai |
|---|---|
| Base resolution | 640 × 360 |
| Window size | 1280 × 720 |
| Stretch mode / aspect | `canvas_items` / `keep` |
| Texture filter | Nearest (pixel art tajam) |
| Orientasi handheld | Landscape |

---

## Struktur proyek

```
assets/                 characters, backgrounds, obstacles, items, effects, ui, audio
resources/              dragons, maps, config (resource .tres yang dapat diedit)
scenes/                 menus, gameplay, dragons, items, effects
scripts/                autoload, gameplay, ui, dragons, items, effects
docs/                   dokumentasi & pemetaan aset
```

Lihat **`docs/asset_mapping.md`** untuk daftar lengkap pemetaan aset.

## Catatan teknis

- Layer rintangan/skor memakai grup `obstacle`, item memakai grup `item`.
  Collision mengikuti bagian utama tubuh naga, bukan seluruh sprite transparan.
- Data pemain disimpan di `user://dragonfly_save.json` (koin, gem, naga dimiliki,
  naga terpilih, skor tertinggi, pengaturan audio/tampilan).
- Hadiah permainan dikreditkan tepat satu kali (saat game over atau saat memilih HOME).
- Audio: bus **Music** dan **SFX** terpisah; berkas WAV pada `assets/audio/`.