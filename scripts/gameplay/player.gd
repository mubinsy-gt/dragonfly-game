class_name Player
extends CharacterBody2D
## Naga yang dikendalikan pemain. Fisika, kepakan, magnet, dan pelindung.

signal obstacle_hit
signal item_picked(kind: int, value: int)

@onready var visual_holder: Node2D = $Visual
@onready var hurtbox: Area2D = $Hurtbox
@onready var magnet_area: Area2D = $Magnet
@onready var magnet_shape: CollisionShape2D = $Magnet/Shape

var dragon_data: DragonData
var active: bool = false
var shields_left: int = 0
var invulnerable: bool = false

var _invuln_left: float = 0.0
var _visual: DragonVisual


func _ready() -> void:
	hurtbox.area_entered.connect(_on_hurtbox_area_entered)
	magnet_area.area_entered.connect(_on_magnet_area_entered)
	if dragon_data != null:
		configure(dragon_data)


func configure(data: DragonData) -> void:
	dragon_data = data
	if data == null or visual_holder == null:
		return
	if _visual != null and is_instance_valid(_visual):
		_visual.queue_free()
	if data.scene != null:
		_visual = data.scene.instantiate() as DragonVisual
		if _visual != null:
			visual_holder.add_child(_visual)
	var circle := CircleShape2D.new()
	circle.radius = maxf(8.0, data.magnet_radius)
	magnet_shape.shape = circle
	shields_left = data.shields


func start() -> void:
	active = true
	velocity = Vector2.ZERO


func stop() -> void:
	active = false


func flap() -> void:
	if not active:
		return
	velocity.y = Game.config.flap_impulse
	AudioManager.play_sfx("flap")


func reset_for_new_run() -> void:
	shields_left = dragon_data.shields if dragon_data != null else 0
	invulnerable = false
	_invuln_left = 0.0
	visible = true
	velocity = Vector2.ZERO
	rotation_degrees = 0.0
	if visual_holder != null:
		visual_holder.position = Vector2.ZERO


## Mengembalikan true bila benturan ini mengakhiri permainan.
func on_hit() -> bool:
	if invulnerable:
		return false
	if shields_left > 0:
		shields_left -= 1
		invulnerable = true
		_invuln_left = Game.config.shield_invuln_time
		return false
	return true


func _physics_process(delta: float) -> void:
	if not active:
		visual_holder.position.y = sin(Time.get_ticks_msec() * 0.004) * 3.0
		return
	visual_holder.position.y = 0.0
	var cfg := Game.config
	velocity.y += cfg.gravity * delta
	velocity.y = clampf(velocity.y, cfg.max_rise_speed, cfg.max_fall_speed)
	position.y += velocity.y * delta
	var tilt: float = clampf(velocity.y / cfg.max_fall_speed, -1.0, 1.0) * cfg.max_tilt_degrees
	rotation_degrees = lerpf(rotation_degrees, tilt, 10.0 * delta)
	if position.y < 16.0:
		position.y = 16.0
		if velocity.y < 0.0:
			velocity.y = 0.0
	elif position.y > 344.0:
		position.y = 344.0
		if velocity.y > 0.0:
			velocity.y = 0.0
	if _invuln_left > 0.0:
		_invuln_left -= delta
		visible = fmod(_invuln_left * 12.0, 2.0) < 1.0
		if _invuln_left <= 0.0:
			visible = true
			invulnerable = false


func _on_hurtbox_area_entered(area: Area2D) -> void:
	# Tanggung jawab collision dipisah dengan jelas:
	#   - item (punya method collect)  -> pengambilan, TIDAK PERNAH damage
	#   - area grup "obstacle"         -> damage
	# Item dikenali dari kemampuannya, bukan dari grup, sehingga item tidak
	# mungkin lagi memicu jalur kematian walaupun berada dekat rintangan.
	if area.has_method("collect"):
		var info: Dictionary = area.collect()
		if not info.is_empty():
			item_picked.emit(int(info.get("kind", 0)), int(info.get("value", 1)))
		return
	if area.is_in_group("obstacle"):
		obstacle_hit.emit()


func _on_magnet_area_entered(area: Area2D) -> void:
	if area.is_in_group("item") and area.has_method("set_magnet_target"):
		area.set_magnet_target(self)