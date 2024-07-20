extends TextureProgressBar

class_name CircularProgressBar

@export var timer: Timer

var parent_node: CanvasItem
var conversion_multiplier: float

# Called when the node enters the scene tree for the first time.
func _ready():
	parent_node = get_parent()
	conversion_multiplier = max_value / timer.wait_time
	timer.timeout.connect(_on_timer_timeout)
	z_index = 10
	hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	value = (timer.wait_time - timer.time_left) * conversion_multiplier
	global_position = parent_node.get_global_mouse_position() - (size / 2)


func _on_timer_timeout():
	hide()


func start():
	value = 0
	show()


func stop():
	hide()