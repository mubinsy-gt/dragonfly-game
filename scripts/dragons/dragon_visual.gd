class_name DragonVisual
extends Node2D
## Tampilan naga yang dapat dipakai ulang di menu, toko, dan gameplay.
## Menjalankan animasi terbang naga.

@onready var sprite: AnimatedSprite2D = $Sprite


func _ready() -> void:
	if sprite.sprite_frames != null and sprite.sprite_frames.has_animation(&"fly"):
		sprite.play(&"fly")