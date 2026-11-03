extends Control
## Halaman CHANGE DRAGON: pilih, beli, dan equip naga.

const MAIN_MENU_PATH := "res://scenes/menus/main_menu.tscn"

@onready var background: RunnerBackground = $Background
@onready var preview_holder: Node2D = $PreviewHolder
@onready var name_label: Label = $Info/NameLabel
@onready var desc_label: Label = $Info/DescLabel
@onready var stats_label: Label = $Info/StatsLabel
@onready var status_label: Label = $Info/StatusLabel
@onready var message_label: Label = $Info/MessageLabel
@onready var action_button: Button = $Actions/ActionButton
@onready var prev_button: Button = $Actions/PrevButton
@onready var next_button: Button = $Actions/NextButton
@onready var back_button: Button = $Actions/BackButton
@onready var coins_label: Label = $Currency/CoinsLabel
@onready var gems_label: Label = $Currency/GemsLabel
@onready var confirm_dialog: ConfirmationDialog = $ConfirmDialog

var _index: int = 0
var _t: float = 0.0


func _ready() -> void:
	AudioManager.play_music()
	if Game.map_catalog.size() > 0:
		background.apply_map(Game.map_catalog.maps[0])
	for button in [action_button, prev_button, next_button, back_button]:
		button.focus_mode = Control.FOCUS_NONE
	action_button.pressed.connect(_on_action)
	prev_button.pressed.connect(_on_prev)
	next_button.pressed.connect(_on_next)
	back_button.pressed.connect(_on_back)
	confirm_dialog.confirmed.connect(_on_confirm_purchase)
	_index = maxi(0, Game.dragon_catalog.index_of(StringName(SaveManager.selected_dragon)))
	_refresh()


func _process(delta: float) -> void:
	_t += delta
	preview_holder.position.y = 145.0 + sin(_t * 2.0) * 8.0


func _current() -> DragonData:
	if _index < 0 or _index >= Game.dragon_catalog.size():
		return null
	return Game.dragon_catalog.dragons[_index]


func _refresh() -> void:
	var data := _current()
	if data == null:
		return
	for child in preview_holder.get_children():
		child.queue_free()
	if data.scene != null:
		preview_holder.add_child(data.scene.instantiate())
	name_label.text = data.display_name
	desc_label.text = data.description
	stats_label.text = "Bonus Poin : %s\nRadius Magnet : %d px\nPelindung : %d" % [
		data.bonus_percent_text(), int(data.magnet_radius), data.shields
	]
	coins_label.text = str(SaveManager.coins)
	gems_label.text = str(SaveManager.gems)
	message_label.text = ""
	var id := String(data.id)
	if SaveManager.selected_dragon == id:
		status_label.text = "EQUIPPED"
		action_button.text = "DIGUNAKAN"
		action_button.disabled = true
	elif SaveManager.is_owned(id):
		status_label.text = "OWNED"
		action_button.text = "EQUIP"
		action_button.disabled = false
	else:
		status_label.text = "LOCKED"
		action_button.text = "BELI  %s %s" % [data.price_text(), data.currency_label()]
		action_button.disabled = false
	var multiple: bool = Game.dragon_catalog.size() > 1
	prev_button.disabled = not multiple
	next_button.disabled = not multiple


func _on_prev() -> void:
	_index = (_index - 1 + Game.dragon_catalog.size()) % Game.dragon_catalog.size()
	AudioManager.play_sfx("click")
	_refresh()


func _on_next() -> void:
	_index = (_index + 1) % Game.dragon_catalog.size()
	AudioManager.play_sfx("click")
	_refresh()


func _on_back() -> void:
	AudioManager.play_sfx("click")
	get_tree().change_scene_to_file(MAIN_MENU_PATH)


func _on_action() -> void:
	var data := _current()
	if data == null:
		return
	var id := String(data.id)
	if SaveManager.is_owned(id):
		SaveManager.set_selected(id)
		AudioManager.play_sfx("click")
		_refresh()
		return
	confirm_dialog.dialog_text = "Beli %s seharga %s %s?" % [data.display_name, data.price_text(), data.currency_label()]
	confirm_dialog.popup_centered()


func _on_confirm_purchase() -> void:
	var data := _current()
	if data == null:
		return
	if not _can_afford(data):
		message_label.text = "Saldo tidak cukup untuk membeli naga ini."
		return
	if data.currency == "gem":
		SaveManager.add_gems(-data.price)
	else:
		SaveManager.add_coins(-data.price)
	SaveManager.own_dragon(String(data.id))
	SaveManager.set_selected(String(data.id))
	AudioManager.play_sfx("buy")
	message_label.text = "%s berhasil dibeli dan dipakai!" % data.display_name
	_refresh()


func _can_afford(data: DragonData) -> bool:
	if data.currency == "gem":
		return SaveManager.gems >= data.price
	return SaveManager.coins >= data.price