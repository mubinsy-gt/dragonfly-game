class_name OneShotEffect
extends Node2D
## Efek sekali pakai: mengembang, memudar, lalu menghapus diri.

@export var lifetime: float = 0.35
@export var grow: float = 1.5

@onready var sprite: Sprite2D = $Sprite

var _texture: Texture2D


func setup(texture: Texture2D, effect_lifetime: float = 0.35) -> void:
	_texture = texture
	lifetime = effect_lifetime


func _ready() -> void:
	if _texture != null:
		sprite.texture = _texture
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(sprite, "scale", Vector2(grow, grow), lifetime)
	tween.tween_property(sprite, "modulate:a", 0.0, lifetime)
	tween.chain().tween_callback(queue_free)