class_name Collectible
extends Area2D
## Koin dan gem yang dapat ditarik magnet dan diambil pemain.

@export_enum("coin", "gem") var kind: int = 0
@export var value: int = 1
@export var bob_amplitude: float = 4.0
@export var bob_speed: float = 3.0

var _collected: bool = false
var _magnet_target: Node2D
var _base_y: float = 0.0
var _t: float = 0.0


func _ready() -> void:
	add_to_group("item")
	_base_y = position.y


func set_magnet_target(target: Node2D) -> void:
	_magnet_target = target


func collect() -> Dictionary:
	if _collected:
		return {}
	_collected = true
	monitoring = false
	queue_free()
	return {"kind": kind, "value": value}


func _process(delta: float) -> void:
	if _collected:
		return
	if _magnet_target != null and is_instance_valid(_magnet_target):
		var to_target: Vector2 = _magnet_target.global_position - global_position
		if to_target.length() > 2.0:
			global_position += to_target.normalized() * 320.0 * delta
		return
	_t += delta
	position.y = _base_y + sin(_t * bob_speed) * bob_amplitude