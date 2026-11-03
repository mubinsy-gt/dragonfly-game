extends Control
## Menu utama dengan latar parallax, naga terpilih, dan empat tombol.

const GAMEPLAY_PATH := "res://scenes/gameplay/gameplay.tscn"
const SHOP_PATH := "res://scenes/menus/shop.tscn"
const SETTINGS_PATH := "res://scenes/menus/settings.tscn"

@onready var background: RunnerBackground = $Background
@onready var dragon_holder: Node2D = $DragonHolder
@onready var birds: Node2D = $Birds
@onready var play_button: Button = $Menu/PlayButton
@onready var change_button: Button = $Menu/ChangeButton
@onready var setting_button: Button = $Menu/SettingButton
@onready var exit_button: Button = $Menu/ExitButton
@onready var coins_label: Label = $Currency/CoinsLabel
@onready var gems_label: Label = $Currency/GemsLabel
@onready var high_label: Label = $Currency/HighLabel
@onready var exit_dialog: ConfirmationDialog = $ExitDialog

var _birds: Array = []
var _t: float = 0.0


func _ready() -> void:
	AudioManager.play_music()
	if Game.map_catalog.size() > 0:
		background.apply_map(Game.map_catalog.maps[0])
	for button in [play_button, change_button, setting_button, exit_button]:
		button.focus_mode = Control.FOCUS_NONE
	play_button.pressed.connect(_goto.bind(GAMEPLAY_PATH))
	change_button.pressed.connect(_goto.bind(SHOP_PATH))
	setting_button.pressed.connect(_goto.bind(SETTINGS_PATH))
	exit_button.pressed.connect(_confirm_exit)
	exit_dialog.confirmed.connect(func() -> void: get_tree().quit())
	_update_currency()
	_spawn_dragon()
	_setup_birds()


func _spawn_dragon() -> void:
	for child in dragon_holder.get_children():
		child.queue_free()
	var data := Game.selected_dragon()
	if data != null and data.scene != null:
		dragon_holder.add_child(data.scene.instantiate())


func _setup_birds() -> void:
	_birds.clear()
	for child in birds.get_children():
		_birds.append({"node": child, "speed": randf_range(16.0, 38.0)})


func _update_currency() -> void:
	coins_label.text = str(SaveManager.coins)
	gems_label.text = str(SaveManager.gems)
	high_label.text = "TERTINGGI  %d" % SaveManager.high_score


func _process(delta: float) -> void:
	background.advance(Game.config.base_scroll_speed * 0.5 * delta)
	_t += delta
	dragon_holder.position.y = 150.0 + sin(_t * 2.0) * 10.0
	for bird in _birds:
		var node: Node2D = bird["node"]
		node.position.x -= bird["speed"] * delta
		if node.position.x < -40.0:
			node.position.x = 680.0
			node.position.y = randf_range(40.0, 210.0)


func _goto(path: String) -> void:
	AudioManager.play_sfx("click")
	get_tree().change_scene_to_file(path)


func _confirm_exit() -> void:
	AudioManager.play_sfx("click")
	exit_dialog.popup_centered()