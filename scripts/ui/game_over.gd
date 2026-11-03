class_name GameOverMenu
extends CanvasLayer
## Layar hasil akhir permainan.

signal retry_requested
signal home_requested

@onready var score_label: Label = $Root/ScoreLabel
# Kolom nilai statistik. Label dan titik dua ada di scene (GridContainer 3 kolom)
# supaya semua titik dua sejajar secara vertikal.
@onready var obstacles_value: Label = $Root/Stats/ObstaclesValue
@onready var points_value: Label = $Root/Stats/PointsValue
@onready var bonus_value: Label = $Root/Stats/BonusValue
@onready var coins_value: Label = $Root/Stats/CoinsValue
@onready var gems_value: Label = $Root/Stats/GemsValue
@onready var high_score_value: Label = $Root/Stats/HighScoreValue
@onready var retry_button: Button = $Root/RetryButton
@onready var home_button: Button = $Root/HomeButton


func _ready() -> void:
	retry_button.focus_mode = Control.FOCUS_NONE
	home_button.focus_mode = Control.FOCUS_NONE
	retry_button.pressed.connect(func() -> void: retry_requested.emit())
	home_button.pressed.connect(func() -> void: home_requested.emit())


func show_results(data: Dictionary) -> void:
	# Perhitungan tidak diubah; hanya cara menampilkannya yang dirapikan.
	var bonus: float = float(data.get("bonus", 0.0))
	score_label.text = str(int(data.get("score", 0)))
	obstacles_value.text = str(int(data.get("obstacles", 0)))
	points_value.text = str(int(data.get("base_points", 0)))
	bonus_value.text = "%+d%%" % roundi(bonus * 100.0)
	coins_value.text = str(int(data.get("coins", 0)))
	gems_value.text = str(int(data.get("gems", 0)))
	high_score_value.text = str(int(data.get("high_score", 0)))
	visible = true