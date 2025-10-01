extends Node2D

# Constants
const MAX_LEVEL : int = 20
const FOREST_SIZE : int = 100
const ITEM_CAP : int = 5

# Signals used to communicate with other classes
signal level_up
signal endgame
signal bossround

# Counter variables
var kill_count : int = 0
var player_experience : int = 0
var player_level : int = 0
var round_count : int = 1
var inventory : Dictionary = {
	"Sandwhich" = 0,
	"Soda" = 0,
	"Gun" = 0
}

# flags
var active : bool = true
var spawn_boss : bool = false

# Resoures
var level : Array = range(1, MAX_LEVEL).map(func(n): return n**2*1000)

# Placeholders
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
	
	# Notify Player of boss round
	%Gun_Unlocked.text = "Round " + str(round_count) + " Boss!"
	%Unlock_Gun.show()
	await get_tree().create_timer(3).timeout
	%Unlock_Gun.hide()
	
	# Spawn boss enemy
	spawn_boss = true
	spawn_mob()
	spawn_boss = false
	%BossOverlay.show() # Show Boss Overlay
	
	# Reconfigure SpawnTimer
	%SpawnTimer.wait_time = 2
	%SpawnTimer.start()


func _on_player_health_depleted():
	AudioManager.stop_all_sfx()
	AudioManager.play_sfx("Death")
	show_endgame(%Score.text)


func _on_mob_died(experience : int, is_boss : bool):
	# Respond to killing boss
	if(is_boss):
		round_count += 1
		if(round_count > 3):
			show_endgame(%Score.text)
			return
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


func _on_restartbutton_pressed() -> void:
	Stats._player_health = 100.0
	Stats.gun_type = 0
	get_tree().reload_current_scene()



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


func update_inventory(item : String, increment : bool = true, amount : int = 1) -> bool:
	# Check Player Reach Level 1
	#if(player_level < 1):
	#	return false
	
	# Update back_end
	if increment:
		inventory[item] = min(inventory[item] + amount, ITEM_CAP)
	else:
		if(inventory[item] == 0):
			return false
		inventory[item] = inventory[item] - amount
	
	# Update front-end
	var entry = %Inventory.find_child(item)
	var label = entry.find_child("Count")
	label.text = " X " + str(inventory[item])
	
	if(inventory[item] == 0):
		entry.hide() # Change to invisible if empty
	else:
		entry.show()

	return true
