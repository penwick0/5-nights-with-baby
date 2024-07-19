extends PathFollow2D

@export var state: String
@onready var baby: BabyController = %BabyController
@onready var hud: HUD = %HUD

func _ready():
	pass # Replace with function body.


func _process(delta):
	if baby.state == state:
		if hud.is_sleeping:
			progress_ratio += 0.25 * delta
		else:
			progress_ratio -= 2 * delta
	if progress_ratio == 1.0 and baby.is_doing_action == false:
		baby.action_timer.start()
		baby.is_doing_action = true