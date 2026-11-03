extends Node
## AudioManager (autoload) - bus musik/SFX terpisah dan pemutaran efek suara.

const MUSIC_PATH := "res://assets/audio/music/theme.wav"
const SFX_PATHS := {
	"flap": "res://assets/audio/sfx/flap.wav",
	"fire": "res://assets/audio/sfx/fire.wav",
	"coin": "res://assets/audio/sfx/coin.wav",
	"gem": "res://assets/audio/sfx/gem.wav",
	"buy": "res://assets/audio/sfx/buy.wav",
	"click": "res://assets/audio/sfx/click.wav",
	"hit": "res://assets/audio/sfx/hit.wav",
	"game_over": "res://assets/audio/sfx/game_over.wav",
}
const SFX_VOICES := 8

var _music: AudioStreamPlayer
var _sfx_players: Array[AudioStreamPlayer] = []
var _sfx_cache: Dictionary = {}


func _ready() -> void:
	_ensure_bus("Music")
	_ensure_bus("SFX")
	_music = AudioStreamPlayer.new()
	_music.bus = "Music"
	add_child(_music)
	for i in SFX_VOICES:
		var player := AudioStreamPlayer.new()
		player.bus = "SFX"
		add_child(player)
		_sfx_players.append(player)
	if ResourceLoader.exists(MUSIC_PATH):
		_music.stream = load(MUSIC_PATH)
	apply_settings()


func _ensure_bus(bus_name: String) -> void:
	if AudioServer.get_bus_index(bus_name) != -1:
		return
	var index := AudioServer.bus_count
	AudioServer.add_bus(index)
	AudioServer.set_bus_name(index, bus_name)
	AudioServer.set_bus_send(index, "Master")


func apply_settings() -> void:
	var music_bus := AudioServer.get_bus_index("Music")
	var sfx_bus := AudioServer.get_bus_index("SFX")
	if music_bus != -1:
		AudioServer.set_bus_mute(music_bus, SaveManager.muted)
		AudioServer.set_bus_volume_db(music_bus, linear_to_db(maxf(SaveManager.music_volume, 0.0001)))
	if sfx_bus != -1:
		AudioServer.set_bus_mute(sfx_bus, SaveManager.muted)
		AudioServer.set_bus_volume_db(sfx_bus, linear_to_db(maxf(SaveManager.sfx_volume, 0.0001)))


func play_music() -> void:
	if _music.stream != null and not _music.playing:
		_music.play()


func stop_music() -> void:
	_music.stop()


func play_sfx(sfx_name: String) -> void:
	if SaveManager.muted:
		return
	var path: String = SFX_PATHS.get(sfx_name, "")
	if path.is_empty():
		return
	if not _sfx_cache.has(path):
		if not ResourceLoader.exists(path):
			return
		_sfx_cache[path] = load(path)
	var stream: AudioStream = _sfx_cache[path]
	for player in _sfx_players:
		if not player.playing:
			player.stream = stream
			player.play()
			return
	_sfx_players[0].stream = stream
	_sfx_players[0].play()