extends Node

class_name BabyController

@onready var sprite: AnimatedSprite2D = %BabySprite
@onready var tears_left: GPUParticles2D = %BabySprite/TearsLeft
@onready var tears_right: GPUParticles2D = %BabySprite/TearsRight
@onready var window_path: PathFollow2D = $WindowPath/FollowWindowPath
@onready var outlet_path: PathFollow2D = $OutletPath/FollowOutletPath
@onready var hud: HUD = %HUD
@onready var poop = load("res://poop.tscn")
@onready var action_timer = $BabyActionTimer

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

func _ready():
	sit_position = sprite.global_position

func _process(delta):
	timer += delta
	# State specific tick rates
	match state:
		"sit":
			rate = 2.0
		"sleep":
			rate = 4.0
		"cry":
			rate = 2.0

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
		"window":
			sprite.animation = "climb"
		"outlet":
			sprite.animation = "crawl"

func _on_shh_button_pressed():
	if state == "cry":
		cry_counter -= 1

func does_poop():
	var instance = poop.instantiate()
	instance.spawn_position = sprite.global_position
	hud.add_child.call_deferred(instance)
	hud.poop_counter += 1

func emit_tears(value: bool):
	tears_left.emitting = value
	tears_right.emitting = value

func start_action():
	action_timer.start()
	is_doing_action = true

func stop_action():
	action_timer.stop()
	is_doing_action = false