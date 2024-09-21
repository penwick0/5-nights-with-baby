extends CanvasLayer

class_name GameOver

@onready var title: Label = $CenterContainer/VBoxContainer/GameOverLabel
@onready var retry_button: Button = $CenterContainer/VBoxContainer/RetryButton
@onready var quit_button: Button = $CenterContainer/VBoxContainer/QuitButton
@onready var blur: ColorRect = $Blur

var title_default_values: Dictionary
var retry_button_default_values: Dictionary
var quit_button_default_values: Dictionary

func _ready():
	call_deferred("setup")


func setup() -> void:
	title.pivot_offset = title.size / 2
	title_default_values = {
		"position": title.position,
		"scale": title.scale,
		"rotation": title.rotation,
	}
	retry_button.pivot_offset = retry_button.size / 2
	retry_button_default_values = {
		"position": retry_button.position,
		"scale": retry_button.scale,
		"rotation": retry_button.rotation,
	}
	quit_button.pivot_offset = quit_button.size / 2
	quit_button_default_values = {
		"position": quit_button.position,
		"scale": quit_button.scale,
		"rotation": quit_button.rotation,
	}

	var tween = create_tween()
	tween.tween_property(title, "position", Vector2(0.0, -220.0), 0.0)
	tween.tween_property(retry_button, "scale", Vector2(0.0, 0.0), 0.0)
	tween.tween_property(quit_button, "scale", Vector2(0.0, 0.0), 0.0)
	tween.tween_method(
		func(value): blur.material.set("shader_parameter/lod", value),
		blur.material.get("shader_parameter/lod"),
		0.0,
		0.0
	)

func enter() -> void:
	var blur_tween = create_tween()
	blur_tween.tween_method(
		func(value): blur.material.set("shader_parameter/lod", value),
		blur.material.get("shader_parameter/lod"),
		2.0,
		0.5
	).set_trans(Tween.TransitionType.TRANS_CUBIC).set_ease(Tween.EaseType.EASE_OUT)

	var title_tween = create_tween()
	title_tween.tween_property(
		title,
		"position",
		title_default_values["position"],
		0.8
	).set_trans(Tween.TransitionType.TRANS_BOUNCE).set_ease(Tween.EaseType.EASE_OUT).set_delay(0.1)

	var retry_button_tween = create_tween()
	retry_button_tween.tween_property(
		retry_button,
		"scale",
		retry_button_default_values["scale"],
		0.7
	).set_trans(Tween.TransitionType.TRANS_ELASTIC).set_ease(Tween.EaseType.EASE_OUT).set_delay(0.8)

	var quit_button_tween = create_tween()
	quit_button_tween.tween_property(
		quit_button,
		"scale",
		quit_button_default_values["scale"],
		0.7
	).set_trans(Tween.TransitionType.TRANS_ELASTIC).set_ease(Tween.EaseType.EASE_OUT).set_delay(0.9)
	


func exit() -> void:
	var title_tween = create_tween()
	title_tween.tween_property(
		title,
		"scale",
		Vector2(0.0, 0.0),
		0.2
	).set_trans(Tween.TransitionType.TRANS_CUBIC).set_ease(Tween.EaseType.EASE_IN)
	title_tween.tween_property(
		title,
		"scale",
		title_default_values["scale"],
		0.0
	)
	title_tween.tween_property(
		title,
		"position",
		Vector2(0.0, -220.0),
		0.0
	)
	var retry_button_tween = create_tween()
	retry_button_tween.tween_property(
		retry_button,
		"scale",
		Vector2(0.0, 0.0),
		0.2
	).set_trans(Tween.TransitionType.TRANS_CUBIC).set_ease(Tween.EaseType.EASE_IN).set_delay(0.1)
	var quit_button_tween = create_tween()
	quit_button_tween.tween_property(
		quit_button,
		"scale",
		Vector2(0.0, 0.0),
		0.2
	).set_trans(Tween.TransitionType.TRANS_CUBIC).set_ease(Tween.EaseType.EASE_IN).set_delay(0.2)
	var blur_tween = create_tween()
	blur_tween.tween_method(
		func(value): blur.material.set("shader_parameter/lod", value),
		blur.material.get("shader_parameter/lod"),
		0.0,
		0.5
	).set_trans(Tween.TransitionType.TRANS_CUBIC).set_ease(Tween.EaseType.EASE_OUT).set_delay(0.2)
