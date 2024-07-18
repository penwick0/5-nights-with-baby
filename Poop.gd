extends Button

var spawn_position: Vector2
@onready var clean_timer = $CleanTimer

func _ready():
	global_position = spawn_position - Vector2(0.0, 10.0)

func _on_clean_timer_timeout():
	get_parent().poop_counter -= 1
	queue_free()

func _on_button_up():
	clean_timer.stop()

func _on_button_down():
	clean_timer.start()
