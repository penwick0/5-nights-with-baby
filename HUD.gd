extends CanvasLayer

class_name HUD

@onready var sleep_delay: Timer = $SleepDelay
@onready var deep_sleep_delay: Timer = $DeepSleepDelay
@onready var shh_timer: Timer = $ShhTimer
@onready var portrait: TextureRect = %Portrait
@onready var stamina_bar: ProgressBar = %StaminaBar
@onready var sleep_button: Button = %SleepButton
@onready var shh_button: Button = %ShhButton
@onready var baby: BabyController = %BabyController
@onready var room_window: RoomWindow = $RoomWindow

var increment_rate: float
var decrement_rate: float
var timer: float = 0
var is_sleeping: bool = false
var deep_sleep: bool = false
var poop_counter: int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	timer += delta
	increment_rate = (2.0 * (1 + int(deep_sleep))) / (1.0 + float(poop_counter))
	decrement_rate = (2.0 + poop_counter) * (1 + int(baby.is_crying))
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
		wake_up()
		sleep_button.disabled = true
		shh_button.text = str("Shh (", baby.cry_counter + 1, ")")
	else:
		sleep_button.disabled = false
		shh_button.text = "Shh"

	# Portrait management
	if is_sleeping:
		portrait.texture = load("res://assets/parent/Parent_sleep.png")
	else:
		if stamina_bar.value == 0:
			portrait.texture = load("res://assets/parent/0%.png")
		elif stamina_bar.value < 5:
			portrait.texture = load("res://assets/parent/5%.png")
		elif stamina_bar.value < 10:
			portrait.texture = load("res://assets/parent/10%.png")
		elif stamina_bar.value < 25:
			portrait.texture = load("res://assets/parent/25%.png")
		elif stamina_bar.value < 50:
			portrait.texture = load("res://assets/parent/50%.png")
		elif stamina_bar.value < 75:
			portrait.texture = load("res://assets/parent/75%.png")
		else:
			portrait.texture = load("res://assets/parent/100%.png")


func wake_up():
	sleep_delay.stop()
	deep_sleep_delay.stop()
	is_sleeping = false
	deep_sleep = false


func _on_sleep_button_button_up():
	wake_up()
	baby.stop_action()


func _on_sleep_button_button_down():
	if not baby.is_crying:
		sleep_delay.start()


func _on_sleep_delay_timeout():
	is_sleeping = true
	deep_sleep_delay.start()


func _on_deep_sleep_delay_timeout():
	deep_sleep = true
	# deep sleep will reduce baby movement volume


func _on_shh_button_pressed():
	pass # Replace with function body.


func _on_baby_action_timer_timeout():
	if baby.state == "window":
		if room_window.is_open:
			print("game over")
			get_tree().paused = true
		else:
			room_window.open()
			baby.start_action()

	if baby.state == "outlet":
		pass
