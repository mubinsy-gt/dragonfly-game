class_name PauseMenu
extends CanvasLayer
## Menu pause. Selalu memproses agar dapat melanjutkan saat tree dijeda.

signal resume_requested
signal home_requested

@onready var resume_button: Button = $Root/ResumeButton
@onready var home_button: Button = $Root/HomeButton


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	resume_button.focus_mode = Control.FOCUS_NONE
	home_button.focus_mode = Control.FOCUS_NONE
	resume_button.pressed.connect(func() -> void: resume_requested.emit())
	home_button.pressed.connect(func() -> void: home_requested.emit())


func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("pause"):
		resume_requested.emit()
		get_viewport().set_input_as_handled()