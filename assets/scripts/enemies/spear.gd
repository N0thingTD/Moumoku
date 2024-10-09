extends Node2D

var footstep_weight = 1
var footstep_time = 1
var footstep_timer_started = false
var walking = false
signal stepped

var target

var hp = 10
const speed = 20
var vel = Vector2(0,0)

@onready var animation_player = $attack

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$aggroRange.visible = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	vel.x = 0
	if not target == null:
		var offset = target.global_position.x - global_position.x
		if offset > 10:
			vel.x += speed * delta
		elif -10 > offset:
			vel.x -= speed * delta
		
		if vel.x != 0:
			walking = true
		
		global_position.x += vel.x


func _on_aggro_area_area_entered(body: Node2D) -> void:
	if body.get_parent().name == "Player":
		target = body.get_parent()


func _on_aggro_range_area_exited(area: Area2D) -> void:
	if area.get_parent().name == "Player":
		target = null


func _on_attack_range_area_entered(area: Area2D) -> void:
	if area.get_parent().name == "Player":
		if not animation_player.is_playing():
			animation_player.play("attack")
