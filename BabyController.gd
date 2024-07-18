extends Node

class_name BabyController

@onready var sprite: AnimatedSprite2D = %BabySprite
@onready var window_path: PathFollow2D = $WindowPath/FollowWindowPath
@onready var outlet_path: PathFollow2D = $OutletPath/FollowOutletPath
@onready var hud: HUD = %HUD

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

func _ready():
	pass # Replace with function body.

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
		if state == "sit" or state == "sleep":
			state = states.pick_random()
			print(state)
		if state == "cry":
			if is_crying:
				if [true, false].pick_random():
					cry_counter += 1
			else:
				is_crying = true
			print(cry_counter)

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
	
	# Animations
	match state:
		"sit":
			sprite.animation = "sit"
		"sleep":
			sprite.animation = "sleep"
		"cry":
			sprite.animation = "cry"
		"window":
			sprite.animation = "climb"
		"outlet":
			sprite.animation = "crawl"

func _on_shh_button_pressed():
	if state == "cry":
		cry_counter -= 1