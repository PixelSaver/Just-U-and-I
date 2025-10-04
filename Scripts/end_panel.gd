extends CanvasLayer
class_name EndPanel

@export_category("1")
@export var panel1 : Panel
@export_category("2")
@export var panel2 : Panel
@export_category("3")
@export var notif_man : NotificationManagerMenu

func _ready():
	panel1.hide()
	panel2.hide()
	#start_anim()

func start_anim():
	panel1.show()
	
	panel1.start_anim()
