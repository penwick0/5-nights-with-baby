extends Button

var spawn_position: Vector2

@onready var clean_timer: Timer = $CleanTimer
@onready var progress_bar: CircularProgressBar = $CircularProgressBar

func _ready():
	global_position = spawn_position - Vector2(0.0, 10.0)


func _process(_delta):
	pass


func _on_button_down():
	clean_timer.start()
	progress_bar.start()


func _on_button_up():
	clean_timer.stop()
	progress_bar.stop()


func _on_mouse_exited():
	clean_timer.stop()
	progress_bar.stop()


func _on_clean_timer_timeout():
	get_parent().poop_counter -= 1
	queue_free()