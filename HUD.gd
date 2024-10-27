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
@onready var level_label: Label = $LevelLabel
@onready var fork_clean_audio: AudioStreamPlayer2D = $ForkCleanAudio
@onready var explosion_audio: AudioStreamPlayer2D = $ExplosionAudio
@onready var chimes_audio: AudioStreamPlayer2D = $ChimesAudio
@onready var children_cheering_audio: AudioStreamPlayer2D = $ChildrenCheeringAudio

@onready var fade: ColorRect = $Sleep/Fade
@onready var blur: ColorRect = $Sleep/Blur
@onready var eyelid_top: ColorRect = $Sleep/EyelidTop
@onready var eyelid_bottom: ColorRect = $Sleep/EyelidBottom

@onready var end_level_screen: CanvasLayer = $EndLevel
@onready var end_level_screen_timer: Timer = $EndLevel/Timer
@onready var game_over_screen: CanvasLayer = $GameOver
@onready var day_night: DayNight = %DayNight

var shh_button_text: String
var paused: bool = false
var increment_rate: float
var decrement_rate: float
var base_decrement_rate: float = 2.0
var timer: float = 0
var is_sleeping: bool = false
var deep_sleep: bool = false
var poop_counter: int = 0
var level: int

var fade_tween: Tween
var blur_tween: Tween
var eyelid_top_tween: Tween
var eyelid_bottom_tween: Tween


# Called when the node enters the scene tree for the first time.
func _ready():
	shh_button_text = shh_button.text
	set_level(1)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if paused:
		return
	
	# Press "D" to quickly reduce stamina for testing
	if (Input.is_action_just_pressed("die")):
		stamina_bar.value = stamina_bar.value / 2

	# Press "E" to end the level for testing
	if (Input.is_action_just_pressed("end level")):
		day_night.rotation_degrees = 360.0

	if (stamina_bar.value <= 0):
		game_over()
		# Consider forced sleep instead? This won't actually work if the baby is crying...
		return

	if day_night.rotation_degrees == 360.0:
		end_level()
		return

	timer += delta
	increment_rate = (2.0 * (1 + int(deep_sleep))) / (1.0 + float((poop_counter / (1.0 + float(room_window.is_open)))))
	decrement_rate = (base_decrement_rate + (poop_counter / (1.0 + float(room_window.is_open)))) * (1 + int(baby.is_crying))
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
		if not sleep_button.disabled && (sleep_button.pressed || is_sleeping):
			wake_up()
		sleep_button.disabled = true
		shh_button.text = str(shh_button_text, "\n[", baby.cry_counter + 1, "]")
	else:
		sleep_button.disabled = false
		shh_button.text = shh_button_text

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
	create_property_tween("fade_tween", fade, "color", Color(0, 0, 0, 0), 0.2)
	create_property_tween("eyelid_top_tween", eyelid_top, "scale", Vector2(1.0, 0.0), 0.2)
	create_property_tween("eyelid_bottom_tween", eyelid_bottom, "scale", Vector2(1.0, 0.0), 0.2)
	create_blur_tween(0.0, 0.4)


func close_eyelids():
	create_property_tween("fade_tween", fade, "color", Color(0, 0, 0, 1), sleep_delay.wait_time * 2)
	create_property_tween("eyelid_top_tween", eyelid_top, "scale", Vector2(1.0, 1.0), sleep_delay.wait_time)
	create_property_tween("eyelid_bottom_tween", eyelid_bottom, "scale", Vector2(1.0, 1.0), sleep_delay.wait_time)
	create_blur_tween(2.0, sleep_delay.wait_time)


func create_property_tween(
	tween_var_name: String,
	object: Object,
	property: NodePath,
	final_value: Variant,
	duration: float,
	transition: Tween.TransitionType = Tween.TransitionType.TRANS_CUBIC,
	easing: Tween.EaseType = Tween.EaseType.EASE_OUT
):
	var tween = get(tween_var_name)
	if (tween):
		tween.kill()
	tween = create_tween()
	tween.tween_property(object, property, final_value, duration).set_trans(transition).set_ease(easing)
	set(tween_var_name, tween)


func create_blur_tween(
	lod: float,
	duration: float,
	transition: Tween.TransitionType = Tween.TransitionType.TRANS_LINEAR,
	easing: Tween.EaseType = Tween.EaseType.EASE_OUT
):
	if (blur_tween):
		blur_tween.kill()
	blur_tween = create_tween()
	blur_tween.tween_method(
		func(value): blur.material.set("shader_parameter/lod", value),
		blur.material.get("shader_parameter/lod"),
		lod,
		duration
	).set_trans(transition).set_ease(easing)


func set_level(newLevel: int):
	level = newLevel
	level_label.text = str("Level ", newLevel)
	baby.set_level(newLevel)


func pause():
	paused = true
	baby.pause()
	day_night.paused = true
	sleep_button.disabled = true
	shh_button.disabled = true


func end_level():
	pause()
	wake_up()
	end_level_screen.visible = true
	end_level_screen_timer.start()
	chimes_audio.play()


func game_over():
	pause()
	wake_up()
	game_over_screen.enter()


func reset():
	sleep_button.disabled = false
	shh_button.disabled = false
	shh_button.text = shh_button_text
	timer = 0.0
	is_sleeping = false
	deep_sleep = false
	poop_counter = 0
	stamina_bar.value = 100.0
	day_night.rotation_degrees = 0.0
	day_night.paused = false
	sleep_delay.stop()
	deep_sleep_delay.stop()
	room_window.close()
	drawer.close()
	fork.visible = true
	baby.reset()
	paused = false


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
			explosion_audio.play()
			game_over()
		else:
			baby.has_fork = true
			baby.stop_action()
			fork.visible = false
			if not deep_sleep:
				baby.fork_pick_up_audio.play()
		pass


func _on_poop_cleaned():
	poop_counter -= 1


func _on_fork_cleaned():
	fork.visible = true
	fork_clean_audio.play()


func _on_retry_button_pressed():
	game_over_screen.exit()
	await get_tree().create_timer(0.5).timeout
	set_level(1)
	reset()


func _on_quit_button_pressed():
	get_tree().quit()


func _on_end_level_screen_timer_timeout():
	if (level == 5):
		end_level_screen.visible = false
		children_cheering_audio.play()
		game_over()
	else:
		set_level(level + 1)
		end_level_screen.visible = false
		reset()

