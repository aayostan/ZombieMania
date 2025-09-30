extends Node2D

# Constants
const MAX_LEVEL : int = 20
const FOREST_SIZE : int = 100

# Signals used to communicate with other classes
signal level_up
signal endgame
signal bossround

# Counter variables
var kill_count : int = 0
var player_experience : int = 0
var player_level : int = 0
var round_count : int = 1

# flags
var active : bool = true
var spawn_boss : bool = false

# Resoures
var level : Array = range(1, MAX_LEVEL).map(func(n): return n**2*1000)

# Placholders
var spawn_time



# Built in functions
func _ready():
	spawn_trees()


func _process(_delta : float) -> void:
	%TimeBar.value = remap(%PlayTimer.time_left, 0, %PlayTimer.wait_time, 0, 100)
	update_exp_UI()



# Events
func _on_spawntimer_timeout() -> void:
	if(active):
		spawn_mob()


func _on_playtimer_timeout() -> void:
	# Run Boss Fight
	bossround.emit() # Remove all enemies
	%SpawnTimer.stop() # Stop Spawning enemies
	%BossOverlay.show() # Show Boss Overlay
	
	# Notify Player of boss round
	%Gun_Unlocked.text = "Round " + str(round_count) + " Boss!"
	%Unlock_Gun.show()
	await get_tree().create_timer(3).timeout
	%Unlock_Gun.hide()
	
	# Spawn boss enemy
	spawn_boss = true
	spawn_mob()
	spawn_boss = false
	
	# Reconfigure SpawnTimer
	%SpawnTimer.wait_time = 1
	%SpawnTimer.start()
	#var score = kill_count + round_count(Stats.player_health)
	#show_endgame("Score = " + str(score))


func _on_player_health_depleted():
	AudioManager.stop_all_sfx()
	AudioManager.play_sfx("Death")
	show_endgame(%Score.text)


func _on_mob_died(experience : int, is_boss : bool):
	# Respond to killing boss
	if(is_boss):
		round_count += 1
		print(round_count)
		%BossOverlay.hide() # Show Boss Overlay
		%SpawnTimer.wait_time = 0.3
		%PlayTimer.start() # Restart playtimer
		return
	
	kill_count += 1
	var temp = player_experience + experience
	for i in range(level.size()):
		if(player_experience < level[i] and temp >= level[i]):
			level_up.emit()
			player_level += 1
	player_experience = temp
	%Score.text = "Kills: " + str(kill_count)


func _on_button_pressed() -> void:
	Stats._player_health = 100.0
	Stats.gun_type = 0
	get_tree().reload_current_scene()


func _on_pickup_cooldown(param: Dictionary):
# This function nullifies the pickup effect after the pickup cooldown

	# Did i make it here?
	#print("I made it to the cooldown signal")
	
	# There are definitely still some synchronization issues here!
	
	if(param["stat"] == "speed"):
		if(param["modifier"] == "add"):
			Stats.player_speed -= param["value"]
		else:
			Stats.player_speed /= param["value"]
	elif(param["stat"] == "health"):
		if(param["modifier"] == "add"):
			Stats.player_health -= param["value"]
		else:
			Stats.player_health /= param["value"]
	elif(param["stat"] == "gun"):
		if(param["modifier"] == "add"):
			if(Stats.guns.size() > 0):
				Stats.guns.pop_back().queue_free()
				find_child("Player").gun_count -= 1



# Helpers
func spawn_trees():
	# Get bounding box
	var bounds = get_viewport_rect()
	var boundX = bounds.size.x
	var boundY = bounds.size.y
	
	# Repeat X times
	for i in range(FOREST_SIZE):
		# Randomization
		var randV2 = Vector2(randf_range(-boundX, boundX),randf_range(-boundY, boundY))
		
		# Object instantiation
		var new_tree = preload("res://Environment/pine_tree.tscn").instantiate()
		new_tree.global_position = find_child("Player").global_position + randV2
		add_child(new_tree)


func spawn_mob():
	# ranomization
	%PathFollow2D.progress_ratio = randf()
	
	# object instantiation
	var new_mob = preload("res://NPCs/Enemies/mob.tscn").instantiate()
	new_mob.global_position = %PathFollow2D.global_position
	add_child(new_mob)
	
	# connect signals
	new_mob.connect("mob_died", _on_mob_died)
	connect("endgame", new_mob._on_game_endgame)
	connect("bossround", new_mob._on_game_bossround)


func show_endgame(scoreText):
	active = false
	endgame.emit()
	%PlayTimer.stop()
	%FinalScore.text = scoreText
	%GameOver.show()


func update_exp_UI():
	if(player_level < level.size()):
		if(player_level > 0):
			%ExpBar.value = remap(player_experience, level[player_level-1], level[player_level], 0, 100)
		elif(player_level < 1):
			%ExpBar.value = remap(player_experience, 0, level[player_level], 0, 100)
	else:
		%ExpBar.value = 100
