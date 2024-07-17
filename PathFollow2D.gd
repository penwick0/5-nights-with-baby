extends PathFollow2D

@onready var baby = $Baby

func _ready():
	pass # Replace with function body.


func _process(delta):
	if baby.state == "window":
		if baby.is_parent_sleeping:
			progress_ratio += 0.25 * delta
		else:
			progress_ratio -= 2 * delta