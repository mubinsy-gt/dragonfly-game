extends Node
## SaveManager (autoload) - penyimpanan lokal di user:// dengan validasi data.

const SAVE_PATH := "user://dragonfly_save.json"
const DEFAULT_DRAGON := "ember_hatchling"

var coins: int = 0
var gems: int = 0
var owned_dragons: Array = [DEFAULT_DRAGON]
var selected_dragon: String = DEFAULT_DRAGON
var high_score: int = 0

var music_volume: float = 0.8
var sfx_volume: float = 0.8
var muted: bool = false
var fullscreen: bool = false


func _ready() -> void:
	load_game()


func load_game() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		save_game()
		return
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		push_warning("DragonFly: tidak dapat membuka file simpanan.")
		return
	var text := file.get_as_text()
	file.close()
	var parsed: Variant = JSON.parse_string(text)
	if typeof(parsed) != TYPE_DICTIONARY:
		push_warning("DragonFly: data simpanan tidak valid, memakai nilai default.")
		return
	var data: Dictionary = parsed
	coins = maxi(0, int(data.get("coins", 0)))
	gems = maxi(0, int(data.get("gems", 0)))
	high_score = maxi(0, int(data.get("high_score", 0)))
	music_volume = clampf(float(data.get("music_volume", 0.8)), 0.0, 1.0)
	sfx_volume = clampf(float(data.get("sfx_volume", 0.8)), 0.0, 1.0)
	muted = bool(data.get("muted", false))
	fullscreen = bool(data.get("fullscreen", false))
	owned_dragons = _sanitize_owned(data.get("owned_dragons", []))
	selected_dragon = String(data.get("selected_dragon", DEFAULT_DRAGON))
	if not owned_dragons.has(selected_dragon):
		selected_dragon = DEFAULT_DRAGON


func _sanitize_owned(raw: Variant) -> Array:
	var result: Array = [DEFAULT_DRAGON]
	if raw is Array:
		for item in raw:
			var id := String(item)
			if id != "" and not result.has(id):
				result.append(id)
	return result


func save_game() -> void:
	var data := {
		"coins": coins,
		"gems": gems,
		"owned_dragons": owned_dragons,
		"selected_dragon": selected_dragon,
		"high_score": high_score,
		"music_volume": music_volume,
		"sfx_volume": sfx_volume,
		"muted": muted,
		"fullscreen": fullscreen,
	}
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_warning("DragonFly: tidak dapat menulis file simpanan.")
		return
	file.store_string(JSON.stringify(data, "\t"))
	file.close()


func is_owned(id: String) -> bool:
	return owned_dragons.has(id)


func own_dragon(id: String) -> void:
	if not owned_dragons.has(id):
		owned_dragons.append(id)
		save_game()


func set_selected(id: String) -> void:
	selected_dragon = id
	save_game()


func add_coins(amount: int) -> void:
	coins = maxi(0, coins + amount)
	save_game()


func add_gems(amount: int) -> void:
	gems = maxi(0, gems + amount)
	save_game()


func set_high_score(value: int) -> void:
	if value > high_score:
		high_score = value
		save_game()