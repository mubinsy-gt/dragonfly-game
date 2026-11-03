class_name GameConfig
extends Resource
## Konfigurasi gameplay global. Semua angka dapat diedit lewat Inspector.

@export_group("Flight")
## Gravitasi dalam piksel/detik^2.
@export var gravity: float = 760.0
## Impuls ke atas tiap kepakan.
@export var flap_impulse: float = -255.0
@export var max_fall_speed: float = 430.0
@export var max_rise_speed: float = -310.0
## Sudut kemiringan badan maksimum (derajat).
@export var max_tilt_degrees: float = 35.0

@export_group("World Scroll")
@export var base_scroll_speed: float = 95.0
@export var speed_increase_per_obstacle: float = 1.1
@export var max_scroll_speed: float = 215.0
## Tambahan kecepatan tiap siklus 100 rintangan.
@export var difficulty_increase_per_cycle: float = 0.2

@export_group("Spawning")
@export var spawn_interval: float = 1.8
@export var min_spawn_interval: float = 1.05
@export var spawn_interval_shrink_per_obstacle: float = 0.006
## Tinggi celah awal.
@export var gap_height: float = 142.0
@export var min_gap_height: float = 104.0
@export var gap_shrink_per_obstacle: float = 0.45
@export var obstacle_width: float = 64.0
## Margin atas/bawah agar celah tidak menempel ke layar.
@export var spawn_margin_top: float = 40.0
@export var spawn_margin_bottom: float = 48.0

@export_group("Rewards (mata uang)")
@export var coin_value: int = 1
@export var coins_per_obstacle: int = 2
@export var gem_every_obstacles: int = 25
## Peluang gem langka muncul di jalur (0-1).
@export var rare_gem_chance: float = 0.08

@export_group("Player")
@export var player_start_x: float = 150.0
@export var player_start_y: float = 170.0
@export var shield_invuln_time: float = 1.0
@export var countdown_seconds: int = 3