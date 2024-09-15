extends Button

class_name Fork

const scene: PackedScene = preload("res://Fork.tscn")

@onready var clean_timer: Timer = $CleanTimer
@onready var progress_bar: CircularProgressBar = $CircularProgressBar

signal cleaned

func _ready():
	pass


static func create(spawn_position: Vector2) -> Fork:
	var fork: Fork = scene.instantiate()
	fork.global_position = spawn_position
	return fork


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
	cleaned.emit()
	queue_free()


func _on_area_2d_area_entered(_area):
	queue_free()