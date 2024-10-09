extends CharacterBody2D

const speed = 5000
var hp = 5
var stamina = 100

var stamina_recovery = 25
var stamina_time = 1.5
var recovering_stamina = false
var stamina_timer_started = false

var attack_cost = 20
var run_cost = 0.5
var dash_cost = 15
var jump_cost = 15

var footstep_timer_started = false
var footstep_time = 0.2
signal stepped

const gravity = 800

const jump_force = 10000
const dash_force = 5000

var attack = 0
var running = false
var walking = false
var dodging = false
var idling = false
var turning = false
var blocking = false

var in_combat = false
var can_undo_block = false

#1 = right, 0 = left
var dir = 1
var step_power = 0.6

var idle_time = 1.5
var idle_timer_started = false

func is_stationary(state):
	if not running and attack == 0 and not dodging and is_on_floor():
		if state == "blocking": 
			return true
		elif not walking:
			return true
	else:
		return false


func reset_animation():
	if dir:
		$sprite.animation = "attack1"
	else:
		$sprite.animation = "attack1l"
	$sprite.frame = 0
	running = false


func idle_cancel():
	idling = false
	idle_timer_started = false
	$IdleTimer.stop()


func idle_timer_start():
	$IdleTimer.start(idle_time)
	idle_timer_started = true


func _ready():
	$hitbox.visible = false
	recovering_stamina = false
	$sprite.animation = "idle"


func _physics_process(delta):
	if dir and $hurtbox.visible == false:
		$hurtboxL.visible = false
		$hurtbox.visible = true
	if not dir and $hurtboxL.visible == false:
		$hurtbox.visible = false
		$hurtboxL.visible = true
	
	if 0 >= stamina:
		stamina = 0
		if $staminaTimer.is_stopped():
			$staminaTimer.start(stamina_time)
	if recovering_stamina == true and stamina != 100:
		stamina += stamina_recovery * delta
	if stamina > 100:
		stamina = 100
	if stamina_timer_started and blocking:
		$staminaTimer.stop()
	
	if not dodging:
		if running:
			if not footstep_timer_started:
				$footstepTimer.start(footstep_time/2)
				footstep_timer_started = true
			if velocity.x == 0:
				running = false
		elif walking:
			if not footstep_timer_started:
				$footstepTimer.start(footstep_time)
				footstep_timer_started = true
			if velocity.x == 0:
				walking = false
		else:
			if footstep_timer_started:
				$footstepTimer.stop()
		
		velocity.x = 0
		if Input.is_action_just_pressed("lmb") and not dodging and (stamina != 0 or not in_combat) and not turning and not blocking:
			idle_cancel()
			if is_on_floor() and not running:
				$staminaTimer.stop()
				$staminaTimer.start(stamina_time)
				stamina_timer_started = true
				recovering_stamina = false
				if attack == 1:
					attack = 2
					$staminaTimer.stop()
					$staminaTimer.start(stamina_time)
					stamina_timer_started = true
					recovering_stamina = false
				elif attack == 0 and dir == 1:
					if in_combat:
						stamina -= attack_cost
					$staminaTimer.stop()
					$staminaTimer.start(stamina_time)
					stamina_timer_started = true
					recovering_stamina = false
					$sprite.play("attack1")
					$hitbox.visible = true
					attack = 1
				elif attack == 0 and dir == 0:
					if in_combat:
						stamina -= attack_cost
					$staminaTimer.stop()
					$staminaTimer.start(stamina_time)
					stamina_timer_started = true
					recovering_stamina = false
					$sprite.play("attack1l")
					$hitboxL.visible = true
					attack = 1
			
			elif not is_on_floor():
				if in_combat:
					stamina -= attack_cost
				$staminaTimer.start(stamina_time)
				stamina_timer_started = true
				recovering_stamina = false
				running = false
				walking = false
				if attack == 0 and dir == 1:
					attack = 3
					$sprite.play("attack3")
		
		if Input.is_action_pressed("rmb") and is_stationary("blocking"):
			if dir and not blocking:
				$sprite.play("block")
			elif not dir and not blocking:
				$sprite.play("blockl")
			blocking = true
			$IdleTimer.stop()
			idle_timer_started = false
			$staminaTimer.stop()
			recovering_stamina = false
		
		if (not Input.is_action_pressed("rmb")) and blocking and can_undo_block:
			$sprite.stop()
			blocking = false
			can_undo_block = false
		
		if Input.is_action_just_released("d") and (running or walking) and attack == 0 and not turning and not blocking:
			if not stamina_timer_started:
				$staminaTimer.start(stamina_time)
				stamina_timer_started = true
			if running:
				running = false
			if walking:
				walking = false
			$sprite.stop()
			$footstepTimer.stop()
			footstep_timer_started = false
			reset_animation()
			if Input.is_action_pressed("a") and running:
				$sprite.stop()
				$sprite.play("turn")
				turning = true
		
		if Input.is_action_just_released("a") and (running or walking) and attack == 0 and not turning and not blocking:
			if not stamina_timer_started:
				$staminaTimer.start(stamina_time)
				stamina_timer_started = true
			if running:
				running = false
			if walking:
				walking = false
			$sprite.stop()
			$footstepTimer.stop()
			footstep_timer_started = false
			reset_animation()
			if Input.is_action_pressed("d") and running:
				$sprite.play("turnl")
				turning = true
		
		if Input.is_action_just_released("shift") and not turning:
			if not stamina_timer_started:
				$staminaTimer.start(stamina_time)
				stamina_timer_started = true
				$footstepTimer.stop()
				footstep_timer_started = false
		
		if Input.is_action_just_pressed("shift"):
			$footstepTimer.stop()
			$footstepTimer.start(footstep_time/2)
		
		if Input.is_action_pressed("d") and attack == 0 and not turning and not blocking:
			dir = 1
			idle_cancel()
			if Input.is_action_pressed("shift") and (stamina != 0 or not in_combat):
				velocity.x += speed * delta
				$sprite.play("run")
				if in_combat:
					stamina -= run_cost
				running = true
				walking = false
				recovering_stamina = false
				$staminaTimer.stop()
				stamina_timer_started = false
			else:
				velocity.x += speed * delta*0.5
				$sprite.play("walk")
				walking = true
				running = false
		
		elif Input.is_action_pressed("a") and attack == 0 and not turning and not blocking:
			dir = 0
			idle_cancel()
			if Input.is_action_pressed("shift") and (stamina != 0 or not in_combat):
				velocity.x -= speed * delta
				$sprite.play("runl")
				if in_combat:
					stamina -= run_cost
				running = true
				walking = false
				recovering_stamina = false
				$staminaTimer.stop()
				stamina_timer_started = false
			else:
				velocity.x -= speed * delta*0.5
				$sprite.play("walkl")
				walking = true
				running = false

		if Input.is_action_just_pressed("q") and attack == 0 and is_on_floor() and (stamina != 0 or not in_combat) and not turning and not blocking:
			dodging = true
			if in_combat:
				stamina -= dash_cost
			$staminaTimer.stop()
			$staminaTimer.start(stamina_time)
			stamina_timer_started = true
			recovering_stamina = false
			idle_cancel()
			if dir:
				velocity.y = -dash_force * delta *0.85
				velocity.x = -dash_force *2 *delta
				$sprite.stop()
				$sprite.play("dash")
			
			else:
				velocity.y = -dash_force * delta *0.85
				velocity.x = dash_force *2 *delta
				$sprite.stop()
				$sprite.play("dashl")
		
		if attack == 0 and not running and not walking and is_on_floor() and not idling and not idle_timer_started and not turning and not blocking:
			idle_timer_start()
		
		velocity.y += gravity * delta
		if Input.is_action_just_pressed("sapce") and is_on_floor() and attack == 0 and (stamina != 0 or not in_combat) and not turning and not blocking:
			velocity.y = -jump_force * delta
			if in_combat:
				stamina -= jump_cost
			$staminaTimer.stop()
			$staminaTimer.start(stamina_time)
			recovering_stamina = false
			$footstepTimer.stop()
			footstep_timer_started = false
			idle_cancel()
	
		
	else:
		if dir:
			if velocity.x >= 0:
				velocity.x = 0
				dodging = false
			else:
				velocity.x += 500 * delta
				velocity.y += gravity * delta
		else:
			if 0 >= velocity.x:
				velocity.x = 0
				dodging = false
			else:
				velocity.x -= 500 * delta
				velocity.y += gravity * delta
	move_and_slide()


func _on_sprite_animation_finished() -> void:
	if $sprite.animation == "attack1":
		if attack == 1:
			$hitbox.visible = false
			$sprite.play("seathe1")
		elif attack == 2:
			$sprite.stop()
			$sprite.play("attack2")
	elif $sprite.animation == "attack2":
		$sprite.play("seathe2")
		$hitbox.visible = false
	elif $sprite.animation == "seathe1" or $sprite.animation == "seathe2":
		attack = 0
	
	if $sprite.animation == "turn" or $sprite.animation == "turnl":
		turning = false
	
	if $sprite.animation == "attack1l":
		if attack == 1:
			$hitboxL.visible = false
			$sprite.play("seathe1l")
		elif attack == 2:
			$sprite.stop()
			$sprite.play("attack2l")
	elif $sprite.animation == "attack2l":
		$sprite.play("seathe2l")
		$hitboxL.visible = false
	elif $sprite.animation == "seathe1l" or $sprite.animation == "seathe2l":
		attack = 0
	
	elif $sprite.animation == "attack3":
		attack = 0
		reset_animation()
	
	if $sprite.animation == "dash":
		$sprite.animation = "attack1"                                         
		$sprite.frame = 0 
	if $sprite.animation == "dashl":
		$sprite.animation = "attack1l"                                         
		$sprite.frame = 0 
	
	if $sprite.animation == "dash" or $sprite.animation == "dashl":
		stepped.emit()   
	
	if $sprite.animation == "block" or "blockl":
		can_undo_block = true                                                                   


func _on_stamina_timer_timeout() -> void:
	recovering_stamina = true
	stamina_timer_started = false


func _on_sprite_animation_changed() -> void:
	if $sprite.animation == "attack2" or $sprite.animation == "attack2l":
		if in_combat:
			stamina -= attack_cost
		$staminaTimer.stop()
		$staminaTimer.start(stamina_time)
		recovering_stamina = false


func _on_idle_timer_timeout() -> void:
	idling = true
	if dir:
		$sprite.play("idle")
	else:
		$sprite.play("idlel")
	idle_timer_started = false


func _on_footstep_timer_timeout() -> void:
	stepped.emit()
