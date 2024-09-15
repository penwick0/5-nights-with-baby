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
@onready var drawer: Drawer = $Drawer
@onready var fork: Sprite2D = %Fork

@onready var fade: ColorRect = $Sleep/Fade
@onready var blur: ColorRect = $Sleep/Blur
@onready var eyelid_top: ColorRect = $Sleep/EyelidTop
@onready var eyelid_bottom: ColorRect = $Sleep/EyelidBottom

var increment_rate: float
var decrement_rate: float
var timer: float = 0
var is_sleeping: bool = false
var deep_sleep: bool = false
var poop_counter: int = 0

var fade_tween: Tween
var blur_tween: Tween
var eyelid_top_tween: Tween
var eyelid_bottom_tween: Tween


# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if (stamina_bar.value <= 0):
		game_over()

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
	open_eyelids()


func open_eyelids():
	create_property_tween("fade_tween", fade, "color", Color(0, 0, 0, 0), 0.1)
	create_property_tween("eyelid_top_tween", eyelid_top, "scale", Vector2(1.0, 0.0), 0.1)
	create_property_tween("eyelid_bottom_tween", eyelid_bottom, "scale", Vector2(1.0, 0.0), 0.1)
	create_blur_tween(0.0, 0.4)


func close_eyelids():
	create_property_tween("fade_tween", fade, "color", Color(0, 0, 0, 1), sleep_delay.wait_time * 2)
	create_property_tween("eyelid_top_tween", eyelid_top, "scale", Vector2(1.0, 1.0), sleep_delay.wait_time)
	create_property_tween("eyelid_bottom_tween", eyelid_bottom, "scale", Vector2(1.0, 1.0), sleep_delay.wait_time)
	create_blur_tween(2.0, sleep_delay.wait_time)


func create_property_tween(tween_var_name: String, object: Object, property: NodePath, final_value: Variant, duration: float):
	var tween = get(tween_var_name)
	if (tween):
		tween.kill()
	tween = create_tween()
	tween.tween_property(object, property, final_value, duration)
	set(tween_var_name, tween)


func create_blur_tween(lod: float, duration: float):
	if (blur_tween):
		blur_tween.kill()
	blur_tween = create_tween()
	blur_tween.tween_method(
		func(value): blur.material.set("shader_parameter/lod", value),
		blur.material.get("shader_parameter/lod"),
		lod,
		duration
	)


func game_over():
	print("game over")
	eyelid_top.scale.y = 0.0
	eyelid_bottom.scale.y = 0.0
	fade.color = Color(0.0, 0.0, 0.0, 0.0)
	blur.material.set("shader_parameter/lod", 0.0)
	get_tree().paused = true


func _on_sleep_button_button_up():
	wake_up()
	baby.stop_action()
	if baby.has_fork:
		baby.has_fork = false
		baby.drop_fork()


func _on_sleep_button_button_down():
	if not baby.is_crying:
		sleep_delay.start()
		close_eyelids()


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
		if drawer.is_open:
			if room_window.is_open:
				game_over()
			else:
				room_window.open()
				baby.start_action()
		else:
			drawer.open()
			baby.stop_action()

	if baby.state == "outlet":
		if baby.has_fork:
			game_over()
		else:
			baby.has_fork = true
			baby.stop_action()
			fork.visible = false
		pass


func _on_poop_cleaned():
	poop_counter -= 1


func _on_fork_cleaned():
	fork.visible = true
