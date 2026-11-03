class_name MapConfig
extends Resource
## Konfigurasi satu map/lingkungan. Dapat diedit melalui Inspector.

@export var id: StringName = &""
@export var display_name: String = ""

@export_group("Layers (parallax)")
## Gambar langit penuh (menutupi seluruh area 640x360).
@export var sky_background: Texture2D
## Modul 64x64 untuk lapisan jauh, tengah, dasar, dan overlay.
@export var far_layer: Texture2D
@export var mid_layer: Texture2D
@export var ground_layer: Texture2D
@export var overlay_layer: Texture2D

@export_group("Layer Placement (640x360)")
@export var far_y: float = 150.0
@export var mid_y: float = 196.0
@export var ground_y: float = 280.0
@export var overlay_y: float = 0.0
## Faktor kecepatan relatif untuk langit, jauh, tengah, dasar, overlay.
@export var parallax_factors: Array[float] = [0.05, 0.25, 0.5, 1.0, 1.4]

@export_group("Contents")
## Jenis rintangan yang boleh muncul di map ini.
@export var obstacle_types: Array[StringName] = [&"pillar"]
@export var bird_enabled: bool = true
@export var bird_count: int = 2
## Warna tint overlay opsional (mis. malam lebih gelap).
@export var tint: Color = Color(1, 1, 1, 1)