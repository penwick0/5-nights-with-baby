extends Button

class_name Fork

var spawn_position: Vector2

@onready var fork_timer: Timer = $ForkTimer
@onready var progress_bar: CircularProgressBar = $CircularProgressBar

func _ready():
	global_position = spawn_position - Vector2(0.0, 10.0)


func _process(_delta):
	pass


func _on_button_down():
	fork_timer.start()
	progress_bar.start()


func _on_button_up():
	fork_timer.stop()
	progress_bar.stop()


func _on_mouse_exited():
	fork_timer.stop()
	progress_bar.stop()


func _on_fork_timer_timeout():
	queue_free()
	get_parent().fork.visible = true


func _on_area_2d_area_entered(_area):
	queue_free()