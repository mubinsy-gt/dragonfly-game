# Pemetaan Aset — DRAGON FLY

Format: **Nama aset → Lokasi file → Scene → Nama node → Resource terkait**

## Karakter / Naga (semua 64×64, atlas animasi 384×64 = 6 frame)

| Aset | Lokasi | Scene | Node | Resource |
|---|---|---|---|---|
| Ember Hatchling | `assets/characters/dragon_ember_hatchling.png` + `_fly.png` | `scenes/dragons/ember_hatchling.tscn` | `Sprite` (AnimatedSprite2D, anim `fly`) | `resources/dragons/ember_hatchling.tres` |
| Cinder Wing | `assets/characters/dragon_cinder_wing.png` + `_fly.png` | `scenes/dragons/cinder_wing.tscn` | `Sprite` | `resources/dragons/cinder_wing.tres` |
| Ashfang | `assets/characters/dragon_ashfang.png` + `_fly.png` | `scenes/dragons/ashfang.tscn` | `Sprite` | `resources/dragons/ashfang.tres` |
| Magma Claw | `assets/characters/dragon_magma_claw.png` + `_fly.png` | `scenes/dragons/magma_claw.tscn` | `Sprite` | `resources/dragons/magma_claw.tres` |
| Inferno Drake | `assets/characters/dragon_inferno_drake.png` + `_fly.png` | `scenes/dragons/inferno_drake.tscn` | `Sprite` | `resources/dragons/inferno_drake.tres` |
| Azure Flame | `assets/characters/dragon_azure_flame.png` + `_fly.png` | `scenes/dragons/azure_flame.tscn` | `Sprite` | `resources/dragons/azure_flame.tres` |
| Obsidian King | `assets/characters/dragon_obsidian_king.png` + `_fly.png` | `scenes/dragons/obsidian_king.tscn` | `Sprite` | `resources/dragons/obsidian_king.tres` |
| Eclipse Dragon | `assets/characters/dragon_eclipse.png` + `_fly.png` | `scenes/dragons/eclipse.tscn` | `Sprite` | `resources/dragons/eclipse.tres` |

Semua naga di atas dipakai oleh:
- Pemain gameplay: `scenes/gameplay/player.tscn` → node `Visual` (di-instance saat runtime dari `DragonData.scene`).
- Menu utama: `scenes/menus/main_menu.tscn` → node `DragonHolder`.
- Toko: `scenes/menus/shop.tscn` → node `PreviewHolder`.

## Background (langit penuh 640×360)

| Aset | Lokasi | Dipakai oleh MapConfig | Node |
|---|---|---|---|
| Langit siang | `assets/backgrounds/bg_sky_day_full.png` | `volcanic_day` | `Background/Sky` |
| Langit senja | `assets/backgrounds/bg_sky_sunset_full.png` | `ember_sunset` | `Background/Sky` |
| Langit malam | `assets/backgrounds/bg_sky_night_full.png` | `obsidian_night` | `Background/Sky` |
| Gua lava | `assets/backgrounds/bg_sky_cavern_full.png` | `lava_cavern` | `Background/Sky` |

## Modul parallax (64×64, tile/transparan)

| Aset | Lokasi | MapConfig field | Node |
|---|---|---|---|
| Gunung jauh | `assets/backgrounds/bg_mountain_far.png` | `far_layer` | `Background/Far` |
| Reruntuhan | `assets/backgrounds/bg_ruins_mid.png` | `mid_layer` (sunset) | `Background/Mid` |
| Kristal malam | `assets/backgrounds/bg_crystal_mid.png` | `mid/ground_layer` (night/cavern) | `Background/Mid` / `Ground` |
| Dinding gua | `assets/backgrounds/bg_cavern_sky.png` | `far_layer` (cavern) | `Background/Far` |
| Batu/lava dasar | `assets/backgrounds/bg_ground_rock.png` | `ground_layer` (day/sunset) | `Background/Ground` |
| Sungai lava | `assets/backgrounds/bg_lava.png` | `ground_layer` (cavern) | `Background/Ground` |
| Bara api | `assets/backgrounds/bg_ember.png` | `overlay_layer` | `Background/Overlay` |
| Burung | `assets/backgrounds/deco_bird.png` | menu: `bird_enabled` | `main_menu/Birds/Bird1..3` |
| Asap | `assets/backgrounds/deco_smoke.png` | (dekorasi opsional) | — |

## Rintangan

| Aset | Lokasi | Scene | Node | Resource |
|---|---|---|---|---|
| Badan pilar | `assets/obstacles/obstacle_pillar_mid.png` | `scenes/gameplay/obstacles/pillar_obstacle.tscn`, `stalactite_obstacle.tscn` | `Top/Body`, `Bottom/Body` (TextureRect) | dipakai oleh `GameConfig` |
| Ujung pilar | `assets/obstacles/obstacle_pillar_top.png` | `pillar_obstacle.tscn` | `Top/Cap`, `Bottom/Cap` | — |
| Stalaktit | `assets/obstacles/obstacle_stalactite.png` | `stalactite_obstacle.tscn` | `Top/Cap`, `Bottom/Cap` | — |
| Batu mengambang | `assets/obstacles/obstacle_floating_rock.png` | `floating_obstacle.tscn` | `Rock` | — |
| Penanda bahaya | `assets/obstacles/warn_marker.png` | (siap pakai untuk geiser lava) | — | — |

Semua rintangan punya: `Hit` (Area2D layer 2, grup `obstacle`) + `PassArea`
(Area2D layer 4, memancarkan sinyal `passed` satu kali).

## Item

| Aset | Lokasi | Scene | Node | Resource |
|---|---|---|---|---|
| Koin | `assets/items/item_coin.png` + `item_coin_spin.png` | `scenes/items/coin.tscn` | `Sprite` (anim `spin`) | `Collectible.kind=0` |
| Gem | `assets/items/item_gem.png` + `item_gem_shine.png` | `scenes/items/gem.tscn` | `Sprite` (anim `shine`) | `Collectible.kind=1` |

## Efek

| Aset | Lokasi | Scene | Node |
|---|---|---|---|
| Percikan ambil item | `assets/effects/fx_spark.png` | `scenes/effects/one_shot_effect.tscn` | `Sprite` (efek tembak gameplay) |
| Ledakan benturan | `assets/effects/fx_impact.png` | `scenes/effects/one_shot_effect.tscn` | `Sprite` |
| Semburan lava | `assets/effects/fx_lava_jet.png` | (siap pakai) | — |

## UI

| Aset | Lokasi | Scene | Node | Resource |
|---|---|---|---|---|
| Logo wordmark "DRAGON FLY" (512x160) | `assets/ui/ui_logo_wordmark.png` | splash, main_menu | `LogoWord`, `LogoImage` (TextureRect) | — |
| Logo emblem naga (64x64) | `assets/ui/ui_logo_emblem.png` | splash | `Logo` (TextureRect) | — |
| Bingkai obsidian berornamen 9-slice (64x64) | `assets/ui/ui_frame_obsidian.png` | hud, main_menu, shop | `ScoreBar`, `StatBar`, `CurrencyPanel`, `Backdrop` | — |
| Bingkai dialog 9-slice (64x64) | `assets/ui/ui_frame_dialog.png` | settings, pause_menu, game_over | `Backdrop`, `Panel` | — |
| Ikon skor (mahkota, 64x64) | `assets/ui/ui_icon_score.png` | hud, game_over | `ScoreIcon` | — |
| Ikon rintangan (64x64) | `assets/ui/ui_icon_obstacle.png` | hud | `ObstacleIcon` | — |
| Ikon pelindung (64x64) | `assets/ui/ui_icon_shield.png` | hud | `ShieldIcon` | — |
| Ikon peta (64x64) | `assets/ui/ui_icon_map.png` | (siap pakai) | — | — |
| Ikon koin (dipakai di panel) | `assets/items/item_coin.png` | hud, main_menu, shop, game_over | `CoinIcon` | — |
| Ikon gem (dipakai di panel) | `assets/items/item_gem.png` | hud, main_menu, shop, game_over | `GemIcon` | — |
| Tombol 9-slice | `assets/ui/ui_nine.png` | semua menu & HUD | semua `Button` | `resources/config/ui_theme.tres` |
| Modul panel (bar) | `assets/ui/ui_panel_obsidian.png`, `assets/ui/ui_panel_dialog.png` | (alternatif) | — | — |
| Panel lama | `assets/ui/ui_panel.png`, `assets/ui/ui_button.png`, `assets/ui/ui_button_ornate.png` | (alternatif) | — | — |

Angka skor, koin, gem, rintangan, dan pelindung tetap berupa node `Label` yang
diperbarui lewat script (`hud.gd`, `main_menu.gd`, `shop.gd`, `game_over.gd`);
gambar hanya dipakai sebagai panel/ikon/dekorasi.

## Tombol & Font

| Aset | Lokasi | Dipakai di |
|---|---|---|
| Font pixel "Press Start 2P" (SIL OFL 1.1) | `assets/fonts/PressStart2P-Regular.ttf` (+ `OFL.txt`) | seluruh UI lewat project setting `gui/theme/custom` |
| Bingkai tombol batu | `assets/ui/buttons/btn_style_stone.png` (64x64) | variasi tema `BtnStone` (tombol sekunder) |
| Bingkai tombol emas | `assets/ui/buttons/btn_style_gold.png` (64x64) | variasi tema `BtnGold` (aksi utama) |
| Bingkai tombol lava | `assets/ui/buttons/btn_style_lava.png` (64x64) | variasi tema `BtnLava` (keluar / retry) |
| Ikon play, gear, home, retry | `assets/ui/buttons/icon_play.png`, `icon_gear.png`, `icon_home.png`, `icon_retry.png` (64x64) | PLAY, SETTING, HOME, RETRY |
| Ikon panah, pause, keluar | `assets/ui/buttons/icon_arrow.png`, `icon_pause.png`, `icon_exit.png` (64x64) | tombol pilih naga ( < > ), PAUSE di HUD, EXIT |
| Ikon checkbox & slider | `assets/ui/buttons/icon_check_on.png`, `icon_check_off.png`, `icon_slider_grab.png` | CheckBox & HSlider di Setting |

`resources/config/ui_theme.tres` memuat font default, tiga variasi tipe tombol
(`BtnGold`, `BtnStone`, `BtnLava`) dengan stylebox normal/hover/pressed/disabled,
ditambah gaya CheckBox dan HSlider. Tombol memilih gaya lewat
`theme_type_variation`; ikonnya adalah node `TextureRect` anak dengan
`mouse_filter = 2` supaya klik tetap sampai ke tombol. Hover = stylebox lebih
terang, pressed = stylebox bergeser 2 px ke bawah.

## Audio

| Aset | Lokasi | Dipakai oleh |
|---|---|---|
| Musik latar | `assets/audio/music/theme.wav` | `AudioManager` bus `Music` |
| Kepakan | `assets/audio/sfx/flap.wav` | naga saat terbang |
| Suara api (belum dipakai setelah fitur semburan dihapus) | `assets/audio/sfx/fire.wav` | — |
| Ambil koin | `assets/audio/sfx/coin.wav` | item koin & melewati rintangan |
| Ambil gem | `assets/audio/sfx/gem.wav` | item gem |
| Beli naga | `assets/audio/sfx/buy.wav` | toko |
| Tombol UI | `assets/audio/sfx/click.wav` | navigasi menu |
| Benturan | `assets/audio/sfx/hit.wav` | tabrakan |
| Game over | `assets/audio/sfx/game_over.wav` | akhir permainan |

## Script & Resource penting

| Nama | Lokasi | Fungsi |
|---|---|---|
| `SaveManager` | `scripts/autoload/save_manager.gd` | simpan/muat `user://dragonfly_save.json` |
| `AudioManager` | `scripts/autoload/audio_manager.gd` | bus Music/SFX & pemutaran SFX |
| `Game` | `scripts/autoload/game.gd` | katalog, status run, rumus skor |
| `DragonData` | `resources/dragons/dragon_data.gd` | data naga |
| `MapConfig` | `resources/maps/map_config.gd` | data map |
| `GameConfig` | `resources/config/game_config.gd` | fisika, spawn, hadiah |
| `gameplay.gd` | `scripts/gameplay/gameplay.gd` | loop utama |
| `player.gd` | `scripts/gameplay/player.gd` | fisika naga |
| `obstacle.gd` | `scripts/gameplay/obstacle.gd` | perakitan & skor rintangan |
| `collectible.gd` | `scripts/items/collectible.gd` | koin/gem & magnet |
| `runner_background.gd` | `scripts/gameplay/runner_background.gd` | parallax |