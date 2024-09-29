extends Node

class_name BabyController

@onready var sprite: AnimatedSprite2D = %BabySprite
@onready var tears_left: GPUParticles2D = %BabySprite/TearsLeft
@onready var tears_right: GPUParticles2D = %BabySprite/TearsRight
@onready var window_path: PathFollow2D = $WindowPath/FollowWindowPath
@onready var outlet_path: PathFollow2D = $OutletPath/FollowOutletPath
@onready var hud: HUD = %HUD
@onready var fork = load("res://Fork.tscn")
@onready var poop_container: Control = %PoopContainer
@onready var fork_container: Control = %ForkContainer
@onready var action_timer = $BabyActionTimer
@onready var cry_audio: AudioStreamPlayer2D = $CryAudio
@onready var poop_audio: AudioStreamPlayer2D = $PoopAudio
@onready var fork_pick_up_audio: AudioStreamPlayer2D = $ForkPickUpAudio
@onready var fork_drop_audio: AudioStreamPlayer2D = $ForkDropAudio
@onready var electric_sparks_audio: AudioStreamPlayer2D = $ElectricSparksAudio
@onready var fork_hand: Area2D = $BabySprite/Area2D

var paused: bool = false
var timer: float = 0.0
var state: String = "sit"
var states: Array = [
	"sit",
	"sleep",
	"cry",
	"window",
	"outlet",
]
var rate: float = 1.0
var cry_counter: int = 0
var is_crying: bool = false
var is_doing_action: bool = false
var sit_position: Vector2
var cry_shake_time: float = 0.0
var has_fork: bool = false

func _ready():
	sit_position = sprite.global_position

func _process(delta):
	if paused:
		return

	timer += delta
	# State specific tick rates
	match state:
		"sit":
			rate = 2.0
		"sleep":
			rate = 4.0
		"cry":
			rate = 2.0
		"window", "outlet":
			rate = 4.0

	# State Management
	if timer >= rate:
		timer -= rate
		if [true, false, false, false, false].pick_random():
			does_poop()
		if state == "sit" or state == "sleep":
			state = states.pick_random()
		if state == "cry":
			if is_crying:
				if [true, false].pick_random():
					cry_counter += 1
			else:
				is_crying = true

	if state == "window" or state == "outlet":
		var path = null
		if state == "window":
			path = window_path
		elif state == "outlet":
			path = outlet_path
		sprite.reparent(path)
		if not hud.is_sleeping:
			if path.progress_ratio == 0:
				sprite.reparent(self)
				state = "sit"

	if cry_counter < 0:
		state = "sit"
		cry_counter = 0
		is_crying = false
		emit_tears(false)
	
	# Animations
	match state:
		"sit":
			sprite.animation = "sit"
			sprite.global_position = sit_position
		"sleep":
			sprite.animation = "sleep"
		"cry":
			sprite.animation = "cry"
			# Tears (amount depends on cry_counter)
			emit_tears(true)
			var amount_ratio = clamp(cry_counter * 0.1, 0.25, 1.0)
			tears_left.amount_ratio = amount_ratio
			tears_right.amount_ratio = amount_ratio
			# Shake (magnitude depends on cry_counter)
			cry_shake_time += delta * clamp(cry_counter * 10, 10, 100)
			sprite.global_position.x = sit_position.x + sin(cry_shake_time)
			if not cry_audio.playing:
				cry_audio.play()
		"window":
			sprite.animation = "climb"
		"outlet":
			sprite.animation = "crawl"
			if hud.is_sleeping and not is_doing_action:
				fork_hand.monitorable = true
				fork_hand.monitoring = true
			else:
				fork_hand.monitorable = false
				fork_hand.monitoring = false


func does_poop():
	var poop = Poop.create(sprite.global_position)
	poop.cleaned.connect(hud._on_poop_cleaned)
	poop_container.add_child.call_deferred(poop)
	hud.poop_counter += 1
	poop_audio.play()


func drop_fork():
	var instance = Fork.create(sprite.global_position)
	instance.cleaned.connect(hud._on_fork_cleaned)
	fork_container.add_child.call_deferred(instance)
	fork_drop_audio.play()


func emit_tears(value: bool):
	tears_left.emitting = value
	tears_right.emitting = value


func start_action():
	print_debug("start_action")
	action_timer.start()
	is_doing_action = true
	if state == "outlet" and overcome_obstacle(state):
		electric_sparks_audio.play()


func stop_action():
	print_debug("stop_action")
	action_timer.stop()
	is_doing_action = false
	electric_sparks_audio.stop()


func overcome_obstacle(current_state: String) -> bool:
	match current_state:
		"window":
			return hud.drawer.is_open
		"outlet":
			return not hud.fork.visible
	return false


func reset():
	stop_action()
	emit_tears(false)
	state = "sit"
	timer = 0.0
	rate = 1.0
	cry_counter = 0
	is_crying = false
	cry_shake_time = 0.0
	has_fork = false
	window_path.progress_ratio = 0
	outlet_path.progress_ratio = 0
	for poop_child in poop_container.get_children():
		poop_child.free()
	for fork_child in fork_container.get_children():
		fork_child.free()
	paused = false


func _on_shh_button_pressed():
	if state == "cry":
		cry_counter -= 1


func _on_area_2d_area_entered(_area:Area2D):
	has_fork = true
	# TODO: Swap with different sound
	fork_pick_up_audio.play()
