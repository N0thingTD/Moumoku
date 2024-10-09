extends Node2D

var opacity = 255
var step_power = 1 # range 0-1
var malicious = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	opacity = step_power * opacity
	modulate.a = opacity/255
	if malicious:
		modulate.b = 0
		modulate.g = 0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	modulate.a = opacity/255
	opacity -= 200 * delta
	if 0 >= opacity:
		queue_free()
