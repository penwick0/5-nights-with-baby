extends Button

class_name RoomWindow

@onready var open_close_timer: Timer = $OpenCloseTimer
@onready var progress_bar: CircularProgressBar = $CircularProgressBar
@onready var open_audio: AudioStreamPlayer2D = $OpenAudio
@onready var close_audio: AudioStreamPlayer2D = $CloseAudio
@onready var hud: HUD = %HUD

var is_open: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_button_down():
	open_close_timer.start()
	progress_bar.start()


func _on_button_up():
	open_close_timer.stop()
	progress_bar.stop()


func _on_mouse_exited():
	open_close_timer.stop()
	progress_bar.stop()


func _on_open_close_timer_timeout():
	if is_open:
		close()
	else:
		open()


func open():
	is_open = true
	icon = load("res://assets/room/windowopen.png")
	if not hud.deep_sleep:
		open_audio.play()

func close():
	is_open = false
	icon = load("res://assets/room/windowclose.png")
	if not hud.deep_sleep:
		close_audio.play()