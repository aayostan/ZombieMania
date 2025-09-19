extends CharacterBody2D

signal health_depleted

var health = 100.0
var active = true
var level = 0

# Camera shake stuff
var camera : Camera2D

@export var decay : float = 0.8 # Time it takes to reach 0% of trauma
@export var max_offset : Vector2 = Vector2(100, 75) # Max hor/ver shake in pixels
@export var max_roll : float = 0.1 # Maximum rotation in radians (use sparingly)

var trauma : float = 0.0 # Current shake strength
var trauma_power : int = 2 # Trauma exponent. Increase for more extreme shaking

func _ready():
	%LevelLabel.text = "L" + str(level)
	camera = get_viewport().get_camera_2d()

func _physics_process(delta):
	if(active):
		const SPEED = 600.0
		var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
		velocity = direction * SPEED
		
		move_and_slide()
	
		if velocity.length() > 0.0:
			%HappyBoo.play_walk_animation()
		else:
			%HappyBoo.play_idle_animation()
		
		# Taking damage
		const DAMAGE_RATE = 10.0
		var overlapping_mobs = %HurtBox.get_overlapping_bodies()
		if overlapping_mobs:
			health -= DAMAGE_RATE * overlapping_mobs.size() * delta
			%HealthBar.value = health
			
			# SoundFX
			AudioManager.play_sfx("Ow", 0, false, false, true)
			
			# Camera Shake
			trauma = min(trauma + (DAMAGE_RATE * overlapping_mobs.size()) / 1000, 1.2)
			shake()
			
			if health <= 0.0:
				AudioManager.play_sfx("Death")
				health_depleted.emit()
		
		else:
			trauma = 0.3


func shake() -> void:
	#? Set the camera's rotation and offset based on the shake strength
	var amount = pow(trauma, trauma_power)
	camera.rotation = max_roll * amount * randf_range(-1, 1)
	camera.offset.x = max_offset.x * amount * randf_range(-1, 1)
	camera.offset.y = max_offset.y * amount * randf_range(-1, 1)


func _on_game_endgame() -> void:
	# Deactivate player  movement
	active = false
	
	# Deactivate gun, account for reloading
	var child_gun = find_child("Gun")
	if(child_gun.active == true):
		child_gun.active = false
	else:
		await get_tree().create_timer(child_gun.reload_time).timeout
		child_gun.active = false
		


func _on_game_level_up() -> void:
	level += 1
	%LevelLabel.text = "L" + str(level)
	var gun = find_child("Gun")
	var b_dam = gun.bullet_damage
	
	if(level == 1):
		%Gun_Unlocked.text = "Unlocked: Shotgun\n(Press E to switch)"
	elif(level == 2):
		%Gun_Unlocked.text = "Unlocked: Machine Gun\n(Press E to switch)"
	elif(level == 3):
		%Gun_Unlocked.text = "Plus one to bullet damage\nAnd Fast Enemies!"
		find_child("Gun").bullet_damage = b_dam + 1
	elif(level == 4):
		%Gun_Unlocked.text = "Times two to bullet damage\nAnd Big Enemies!"
		find_child("Gun").bullet_damage = b_dam * 2
	elif(level == 5 or level == 6):
		%Gun_Unlocked.text = "Double Ammo + Half Reload Time\nFaster Enemy Spawn"
		for g in gun.guns:
			g['max_ammo'] *= 2
			g['reload_time'] /= 2
		%Spawn_Timer.wait_time -= 0.1
	elif(level == 7):
		%Gun_Unlocked.text = "ARMAGEDDON: UNLIMITED Ammo\nSuper Fast Enemy Spawn"
		for g in gun.guns:
			g['max_ammo'] *= 10**7
		gun.gun_switch_time = 0
		%Spawn_Timer.wait_time = 0.05
	else:
		return
		
	%Unlock_Gun.show()
	await get_tree().create_timer(3).timeout
	%Unlock_Gun.hide()
