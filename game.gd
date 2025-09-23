extends Node2D

signal level_up
signal endgame
var active = true

var death_count = 0
var player_experience = 0
var player_level = 0

var level = range(1, 11).map(func(n): return n**2*1000)

var forest_size = 40


func _ready():
	init_spawn_trees()


func spawn_mob():
	%PathFollow2D.progress_ratio = randf()
	var new_mob = preload("res://NPCs/Enemies/mob.tscn").instantiate()
	new_mob.global_position = %PathFollow2D.global_position
	add_child(new_mob)
	new_mob.connect("died", _on_died)
	connect("endgame", new_mob._on_game_endgame)


func init_spawn_trees():
	# Get bounding box
	#var bounds = get_viewport_rect()
	# Create trees at random in bounding box
	#print(bounds.position)
	#print(bounds.end)
	#print(bounds.size)
	
	# In each tree have a function that dequeue's it after character leaves
	# Create trees in bounding box initially
	# better to do so off screen, make bounding box bigger?
	# possible problem, no trees show up near player
	for i in range(forest_size):
		var new_tree = preload("res://Environment/pine_tree.tscn").instantiate()
		new_tree.global_position = find_child("Player").global_position + \
									Vector2(randf_range(-1920,1920),randf_range(-1080,1080))
		add_child(new_tree)


func _on_timer_timeout():
	if(active):
		spawn_mob()


func _on_player_health_depleted():
	AudioManager.stop_all_sfx()
	AudioManager.play_sfx("Death")
	show_endgame(%Score.text)


func _on_died(experience : int):
	death_count += 1
	var temp = player_experience + experience
	for i in range(level.size()):
		if(player_experience < level[i] and temp >= level[i]):
			level_up.emit()
			player_level += 1
	player_experience = temp
	%Score.text = "Kills: " + str(death_count)


func _on_timer_2_timeout() -> void:
	var score = death_count + round(find_child("Player").health)
	show_endgame("Score = " + str(score))


func _process(_delta : float) -> void:
	%TimeBar.value = remap(%PlayTimer.time_left, 0, %PlayTimer.wait_time, 0, 100)
	if(player_level > 0):
		%ExpBar.value = remap(player_experience, level[player_level-1], level[player_level], 0, 100)
	elif(player_level < 1):
		%ExpBar.value = remap(player_experience, 0, level[player_level], 0, 100)


func _on_button_pressed() -> void:
	get_tree().reload_current_scene()


func show_endgame(scoreText):
	active = false
	endgame.emit()
	%PlayTimer.stop()
	%FinalScore.text = scoreText
	%GameOver.show()


func _on_pickup_cooldown(param: Dictionary):
	# Did i make it here?
	#print("I made it to the cooldown signal")
	
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
