extends CanvasLayer

class_name HUD

@onready var sleep_delay = $SleepDelay
@onready var shh_timer = $ShhTimer
@onready var portrait = %Portrait
@onready var stamina_bar = %StaminaBar
@onready var sleep_button = %SleepButton
@onready var baby: BabyController = %BabyController

var increment_rate: float = 1.0
var decrement_rate: float = 2.0
var timer: float = 0
var is_sleeping: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	timer += delta
	if timer >= 1.0:
		timer -= 1.0
		if is_sleeping:
			if stamina_bar.value < 100:
				stamina_bar.value += increment_rate
			else:
				stamina_bar.value = 100
		else:
			if stamina_bar.value > 0:
				stamina_bar.value -= decrement_rate
			else:
				stamina_bar.value = 0

	if baby.is_crying:
		sleep_delay.stop()
		is_sleeping = false
		sleep_button.disabled = true
		decrement_rate = 4.0
	else:
		sleep_button.disabled = false
		decrement_rate = 2.0

	if is_sleeping:
		portrait.texture = load("res://assets/parent/Parent_sleep.png")
	else:
		portrait.texture = load("res://assets/parent/Parent.png")

func _on_sleep_button_button_up():
	sleep_delay.stop()
	is_sleeping = false

func _on_sleep_button_button_down():
	if not baby.is_crying:
		sleep_delay.start()

func _on_sleep_delay_timeout():
	is_sleeping = true

func _on_shh_button_pressed():
	pass # Replace with function body.
