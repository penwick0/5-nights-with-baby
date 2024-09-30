extends PathFollow2D

@export var state: String
@export var obstacle: float
@onready var baby: BabyController = %BabyController
@onready var hud: HUD = %HUD

func _ready():
	pass # Replace with function body.


func _process(delta):
	if baby.paused:
		return

	if baby.state == state:
		if hud.is_sleeping:
			if not baby.is_doing_action:
				if progress_ratio >= obstacle and not baby.overcome_obstacle(state):
					baby.start_action()
				elif progress_ratio == 1.0:
					baby.start_action()
				else:
					progress_ratio += baby.movement_speed * delta
		else:
			progress_ratio -= 2 * delta
