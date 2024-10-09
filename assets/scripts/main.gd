extends Node2D

var stamina_started = false
@export var footstep_scene: PackedScene

var enviromental_change = 1 #range 0-2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Player/staminaBar.visible = false
	$Player/healthBar.visible = false
	$Player/barHolder.visible = false
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	$Player/staminaBar.value = $Player.stamina
	if $Player.stamina == 100:
		if not stamina_started:
			$Player/staminaBar/staminaTimer.start(1)
			stamina_started = true
	else:
		$Player/staminaBar.visible = true
		$Player/healthBar.visible = true
		$Player/barHolder.visible = true


func _on_stamina_timer_timeout() -> void:
	$Player/staminaBar.visible = false
	$Player/healthBar.visible = false
	$Player/barHolder.visible = false
	stamina_started = false


func _on_player_stepped() -> void:
	if $Player.is_on_floor():
		var footstep = footstep_scene.instantiate()
		footstep.global_position.y = $Player.global_position.y +8.6
		if $Player.dir == 0:
			footstep.global_position.x = $Player.global_position.x 
		else:
			footstep.global_position.x = $Player.global_position.x +1
		footstep.step_power = $Player.step_power * enviromental_change
		add_child(footstep)
