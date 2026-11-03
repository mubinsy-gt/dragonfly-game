class_name HUD
extends CanvasLayer
## Tampilan skor, statistik, tombol pause, hint, dan efek transisi map.

signal pause_pressed

@onready var score_label: Label = $Top/ScoreLabel
@onready var obstacles_label: Label = $Top/ObstaclesLabel
@onready var coins_label: Label = $Top/CoinsLabel
@onready var gems_label: Label = $Top/GemsLabel
@onready var shields_label: Label = $Top/ShieldsLabel
@onready var pause_button: Button = $Top/PauseButton
@onready var hint: Label = $Hint
@onready var fade: ColorRect = $Fade
@onready var countdown_label: Label = $Countdown
@onready var map_label: Label = $MapLabel


func _ready() -> void:
	pause_button.focus_mode = Control.FOCUS_NONE
	pause_button.pressed.connect(func() -> void: pause_pressed.emit())
	hint.visible = false
	countdown_label.visible = false
	fade.color = Color(0, 0, 0, 0)
	fade.mouse_filter = Control.MOUSE_FILTER_IGNORE


func update_stats(score: int, obstacles: int, coins: int, gems: int, shields: int) -> void:
	# Hanya angka; makna ditampilkan lewat ikon di panel.
	score_label.text = str(score)
	obstacles_label.text = str(obstacles)
	coins_label.text = str(coins)
	gems_label.text = str(gems)
	shields_label.text = str(shields)
	shields_label.visible = shields >= 0


func set_hint(text: String) -> void:
	hint.text = text
	hint.visible = not text.is_empty()


func show_countdown(text: String) -> void:
	countdown_label.text = text
	countdown_label.visible = true


func hide_countdown() -> void:
	countdown_label.visible = false


func show_map_name(text: String) -> void:
	map_label.text = text
	map_label.modulate.a = 1.0
	var tween := create_tween()
	tween.tween_interval(1.2)
	tween.tween_property(map_label, "modulate:a", 0.0, 1.0)


func set_fade(alpha: float) -> void:
	var c := fade.color
	c.a = alpha
	fade.color = c


func flash_fade(to_alpha: float, duration: float) -> void:
	var tween := create_tween()
	tween.tween_method(set_fade, fade.color.a, to_alpha, duration)


func set_pause_visible(value: bool) -> void:
	pause_button.visible = value