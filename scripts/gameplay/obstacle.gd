class_name Obstacle
extends Node2D
## Rintangan yang dirakit dari modul (badan + ujung) atau batu mengambang.
## Memancarkan `passed` tepat satu kali ketika pemain melewatinya.

signal passed

@export_enum("pair", "single") var mode: int = 0
@export var width: float = 64.0
@export var cap_size: float = 64.0

@onready var top: Node2D = $Top
@onready var bottom: Node2D = $Bottom
@onready var pass_area: Area2D = $PassArea

var _passed: bool = false


func _ready() -> void:
	add_to_group("obstacle")
	for path in ["Top/Hit", "Bottom/Hit", "Hit"]:
		var hit := get_node_or_null(path)
		if hit != null:
			hit.add_to_group("obstacle")
	# Bentuk collision unik per instance.
	for path in ["Top/Hit/Shape", "Bottom/Hit/Shape", "Hit/Shape", "PassArea/Shape"]:
		var shape_node := get_node_or_null(path)
		if shape_node != null and shape_node.shape != null:
			shape_node.shape = shape_node.shape.duplicate()
	pass_area.body_entered.connect(_on_pass_body_entered)


## Rintangan pasangan atas-bawah dengan celah di tengah.
func configure_pair(gap_center: float, gap: float) -> void:
	mode = 0
	top.visible = true
	bottom.visible = true
	_apply_pair(top, true, gap_center - gap * 0.5)
	_apply_pair(bottom, false, gap_center + gap * 0.5)
	pass_area.visible = true
	pass_area.position = Vector2(0.0, gap_center)
	pass_area.get_node("Shape").shape.size = Vector2(8.0, gap)


func _apply_pair(segment: Node2D, is_top: bool, edge: float) -> void:
	var body: TextureRect = segment.get_node("Body")
	var cap: Sprite2D = segment.get_node("Cap")
	var hit: Area2D = segment.get_node("Hit")
	if is_top:
		# Kolom dari atas layar turun sampai `edge`.
		cap.position = Vector2(0.0, edge - cap_size * 0.5)
		body.position = Vector2(-width * 0.5, 0.0)
		body.size = Vector2(width, maxf(0.0, edge - cap_size))
		hit.position = Vector2(0.0, edge * 0.5)
		hit.get_node("Shape").shape.size = Vector2(width, maxf(1.0, edge))
	else:
		# Kolom dari dasar layar naik sampai `edge`.
		cap.position = Vector2(0.0, edge + cap_size * 0.5)
		body.position = Vector2(-width * 0.5, edge + cap_size)
		body.size = Vector2(width, maxf(0.0, 360.0 - (edge + cap_size)))
		hit.position = Vector2(0.0, (edge + 360.0) * 0.5)
		hit.get_node("Shape").shape.size = Vector2(width, maxf(1.0, 360.0 - edge))


## Rintangan batu mengambang tunggal.
func configure_single(center_y: float) -> void:
	mode = 1
	top.visible = false
	bottom.visible = false
	var rock: Sprite2D = get_node("Rock")
	rock.visible = true
	rock.position = Vector2(0.0, center_y)
	var hit: Area2D = get_node("Hit")
	hit.position = Vector2(0.0, center_y)
	hit.get_node("Shape").shape.size = Vector2(52.0, 52.0)
	pass_area.visible = true
	pass_area.position = Vector2(48.0, 180.0)
	pass_area.get_node("Shape").shape.size = Vector2(8.0, 360.0)


func _on_pass_body_entered(body: Node2D) -> void:
	if _passed or not (body is Player):
		return
	_passed = true
	passed.emit()