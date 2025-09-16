extends CharacterBody2D

signal health_depleted

var health = 100.0
var active = true
var level = 0

func _ready():
	%Level.text = "Level: " + str(level)

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
	%Level.text = "Level: " + str(level)
	var b_dam = find_child("Gun").bullet_damage
	
	if(level == 1):
		%Gun_Unlocked.text = "Unlocked: Shotgun\n(Press E to switch)"
	elif(level == 2):
		%Gun_Unlocked.text = "Unlocked: Machine Gun\n(Press E to switch)"
	elif(level == 3):
		%Gun_Unlocked.text = "Unlocked: Bullet Damage + 1"
		find_child("Gun").bullet_damage = b_dam + 1
	elif(level == 4):
		%Gun_Unlocked.text = "Unlocked: Bullet Damage * 2"
		find_child("Gun").bullet_damage = b_dam * 2
	elif(level == 5):
		%Gun_Unlocked.text = "Unlocked: Armaggedon"
		%Spawn_Timer.wait_time = 0.1
		
		
	%Unlock_Gun.show()
	await get_tree().create_timer(3).timeout
	%Unlock_Gun.hide()
