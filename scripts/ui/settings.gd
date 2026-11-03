extends Control
## Menu pengaturan audio dan tampilan.

const MAIN_MENU_PATH := "res://scenes/menus/main_menu.tscn"

@onready var music_slider: HSlider = $Panel/MusicSlider
@onready var sfx_slider: HSlider = $Panel/SfxSlider
@onready var mute_check: CheckBox = $Panel/MuteCheck
@onready var fullscreen_check: CheckBox = $Panel/FullscreenCheck
@onready var back_button: Button = $Panel/BackButton
@onready var background: RunnerBackground = $Background


func _ready() -> void:
	AudioManager.play_music()
	if Game.map_catalog.size() > 0:
		background.apply_map(Game.map_catalog.maps[0])
	music_slider.value = SaveManager.music_volume * 100.0
	sfx_slider.value = SaveManager.sfx_volume * 100.0
	mute_check.button_pressed = SaveManager.muted
	fullscreen_check.button_pressed = SaveManager.fullscreen
	music_slider.value_changed.connect(_on_music_changed)
	sfx_slider.value_changed.connect(_on_sfx_changed)
	mute_check.toggled.connect(_on_mute_toggled)
	fullscreen_check.toggled.connect(_on_fullscreen_toggled)
	back_button.focus_mode = Control.FOCUS_NONE
	back_button.pressed.connect(_on_back)
	_apply_fullscreen(SaveManager.fullscreen)


func _on_music_changed(value: float) -> void:
	SaveManager.music_volume = value / 100.0
	AudioManager.apply_settings()
	SaveManager.save_game()


func _on_sfx_changed(value: float) -> void:
	SaveManager.sfx_volume = value / 100.0
	AudioManager.apply_settings()
	AudioManager.play_sfx("click")
	SaveManager.save_game()


func _on_mute_toggled(pressed: bool) -> void:
	SaveManager.muted = pressed
	AudioManager.apply_settings()
	SaveManager.save_game()


func _on_fullscreen_toggled(pressed: bool) -> void:
	SaveManager.fullscreen = pressed
	_apply_fullscreen(pressed)
	SaveManager.save_game()


func _apply_fullscreen(enabled: bool) -> void:
	if enabled:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)


func _on_back() -> void:
	AudioManager.play_sfx("click")
	get_tree().change_scene_to_file(MAIN_MENU_PATH)