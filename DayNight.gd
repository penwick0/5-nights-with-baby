extends Sprite2D

@onready var hud: HUD = %HUD
@export var rotation_speed: float = 10.0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if rotation_degrees < 360.0:
		rotation_degrees += rotation_speed * delta
	else:
		rotation_degrees = 360.0