extends Control
## Splash screen dengan animasi pembuka lalu berpindah ke menu utama.

const MAIN_MENU_PATH := "res://scenes/menus/main_menu.tscn"

@onready var logo: TextureRect = $Logo

var _done: bool = false


func _ready() -> void:
	AudioManager.play_music()
	modulate.a = 0.0
	logo.scale = Vector2(0.6, 0.6)
	logo.pivot_offset = Vector2(32, 32)
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "modulate:a", 1.0, 0.6)
	tween.tween_property(logo, "scale", Vector2(1.0, 1.0), 0.8).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.chain().tween_interval(1.3)
	tween.chain().tween_property(self, "modulate:a", 0.0, 0.5)
	tween.chain().tween_callback(_go_to_menu)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("flap") and not _done:
		_go_to_menu()


func _go_to_menu() -> void:
	if _done:
		return
	_done = true
	get_tree().change_scene_to_file(MAIN_MENU_PATH)