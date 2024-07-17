extends AnimatedSprite2D
var timer: float = 0.0
var state: String = "sit"
var states: Array = ["sit", "sleep", "cry", "window", "outlet"]
var rate: float = 1.0
var cry_counter: int = 0
var is_crying: bool = false
var is_parent_sleeping: bool = false

signal start_crying
signal stop_crying

func _ready():
	pass # Replace with function body.


func _process(delta):
	timer += delta
	match state:
		"sit":
			rate = 2.0
		"sleep":
			rate = 4.0
		"cry":
			rate = 2.0

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
				start_crying.emit()
				is_parent_sleeping = false
				is_crying = true
			print(cry_counter)

	if state == "window" or state == "outlet":
		if not is_parent_sleeping:
			if get_parent().progress_ratio == 0:
				state = "sit"
				print(state)

	if cry_counter < 0:
		state = "sit"
		cry_counter = 0
		is_crying = false
		stop_crying.emit()
	
	# Animations
	match state:
		"sit":
			animation = "sit"
		"sleep":
			animation = "sleep"
		"cry":
			animation = "cry"
		"window":
			animation = "climb"
		"outlet":
			animation = "crawl"

func _on_shh_button_pressed():
	if state == "cry":
		cry_counter -= 1

func _on_sleep_delay_timeout():
	is_parent_sleeping = true

func _on_sleep_button_button_up():
	is_parent_sleeping = false
