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