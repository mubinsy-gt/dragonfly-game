class_name RunnerBackground
extends Node2D
## Latar parallax untuk gameplay dan menu.
## Lapisan dibuat sebagai node di dalam scene; tekstur diisi dari MapConfig.

@export var view_size: Vector2 = Vector2(640, 360)

@onready var _sky: TextureRect = $Sky
@onready var _far: TextureRect = $Far
@onready var _mid: TextureRect = $Mid
@onready var _ground: TextureRect = $Ground
@onready var _overlay: TextureRect = $Overlay

var _layers: Array = []
var _offset: float = 0.0


func _ready() -> void:
	_layers = [
		{"node": _sky, "factor": 0.05, "tile": 640.0},
		{"node": _far, "factor": 0.25, "tile": 64.0},
		{"node": _mid, "factor": 0.5, "tile": 64.0},
		{"node": _ground, "factor": 1.0, "tile": 64.0},
		{"node": _overlay, "factor": 1.4, "tile": 64.0},
	]


func apply_map(map: MapConfig) -> void:
	if map == null:
		return
	_setup_band(_sky, map.sky_background, 640.0, 360.0, 0.0)
	_setup_band(_far, map.far_layer, 64.0, 64.0, map.far_y)
	_setup_band(_mid, map.mid_layer, 64.0, 64.0, map.mid_y)
	_setup_band(_ground, map.ground_layer, 64.0, 64.0, map.ground_y)
	_setup_band(_overlay, map.overlay_layer, 64.0, 64.0, map.overlay_y)
	_sky.modulate.a = 1.0
	_far.modulate.a = 0.75
	_mid.modulate.a = 0.9
	_ground.modulate.a = 1.0
	_overlay.modulate.a = 0.9
	modulate = map.tint
	var factors: Array = map.parallax_factors
	if factors.size() >= 5:
		for i in 5:
			_layers[i]["factor"] = factors[i]


func _setup_band(node: TextureRect, texture: Texture2D, tile_w: float, band_h: float, y: float) -> void:
	if node == null:
		return
	if texture == null:
		node.visible = false
		return
	node.visible = true
	node.texture = texture
	node.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	node.stretch_mode = TextureRect.STRETCH_TILE
	node.size = Vector2(view_size.x + tile_w, band_h)
	node.position = Vector2(0, y)


## Menggeser latar sejauh `distance` piksel dunia.
func advance(distance: float) -> void:
	_offset += distance
	for layer in _layers:
		var node: TextureRect = layer["node"]
		if node == null or not node.visible:
			continue
		var factor: float = layer["factor"]
		var tile: float = layer["tile"]
		node.position.x = -fmod(_offset * factor, tile)


func set_scroll_offset(value: float) -> void:
	_offset = value