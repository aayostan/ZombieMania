extends Node2D

signal level_up
signal endgame
var active = true

var death_count = 0
var player_experience = 0

var level = range(1, 11).map(func(n): return n**2*1000)

func _ready():
	spawn_trees()

func spawn_mob():
	%PathFollow2D.progress_ratio = randf()
	var new_mob = preload("res://characters/mob.tscn").instantiate()
	new_mob.global_position = %PathFollow2D.global_position
	add_child(new_mob)
	new_mob.connect("died", _on_died)
	connect("endgame", new_mob._on_game_endgame)

func spawn_trees():
	# Get bounding box
	var bounds = get_viewport_rect()
	# Create trees at random in bounding box
	print(bounds.position)
	print(bounds.end)
	print(bounds.size)
	# In each tree have a function that dequeue's it after character leaves
	

func _on_timer_timeout():
	if(active):
		spawn_mob()

func _on_player_health_depleted():
	show_endgame(%Score.text)
	
func _on_died(experience : int):
	death_count += 1
	var temp = player_experience + experience
	for i in range(level.size()):
		if(player_experience < level[i] and temp >= level[i]):
			level_up.emit()
	player_experience = temp
	%Score.text = "Score = " + str(death_count)

func _on_timer_2_timeout() -> void:
	var score = death_count + round(find_child("Player").health)
	show_endgame("Score = " + str(score))
	
func _process(delta: float) -> void:
	%Time.text = "Time Left: " + str(round(%PlayTimer.time_left))

func _on_button_pressed() -> void:
	get_tree().reload_current_scene()

func show_endgame(scoreText):
	active = false
	endgame.emit()
	%PlayTimer.stop()
	%FinalScore.text = scoreText
	%Score.hide()
	%GameOver.show()
	
