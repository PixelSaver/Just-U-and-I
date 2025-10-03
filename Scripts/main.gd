extends CanvasLayer

func _ready():
	Global.root = self
	Global.go_main_menu()

func _input(event: InputEvent) -> void:
	if OS.is_debug_build() and Input.is_action_just_pressed("esc"):
		print("esc pressed")
