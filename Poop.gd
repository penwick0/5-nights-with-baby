extends Button

class_name Poop

const scene: PackedScene = preload("res://Poop.tscn")

@onready var clean_timer: Timer = $CleanTimer
@onready var progress_bar: CircularProgressBar = $CircularProgressBar

signal cleaned

func _ready():
	pass


static func create(spawn_position: Vector2) -> Poop:
	var poop: Poop = scene.instantiate()
	poop.global_position = spawn_position - Vector2(0.0, 10.0)
	return poop


func _process(_delta):
	pass


func _on_button_down():
	clean_timer.start()
	progress_bar.start()


func _on_button_up():
	clean_timer.stop()
	progress_bar.stop()


# TODO: Fix issue with button press interruption.
# When a poop is spawned on top of a poop button that's currently being pressed and the mouse moves.
# If the mouse is not moved, the progress bar continues.
func _on_mouse_exited():
	clean_timer.stop()
	progress_bar.stop()


func _on_clean_timer_timeout():
	cleaned.emit()
	queue_free()