extends CharacterBody2D

signal health_depleted

var health = 100.0
var active = true
var level = 0

func _ready():
	%LevelLabel.text = "L" + str(level)

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
			if health <= 0.0:
				health_depleted.emit()
			


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
