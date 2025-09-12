extends Node2D

signal level_up
signal endgame
var active = true

var death_count = 0

func spawn_mob():
	%PathFollow2D.progress_ratio = randf()
	var new_mob = preload("res://mob.tscn").instantiate()
	new_mob.global_position = %PathFollow2D.global_position
	add_child(new_mob)
	new_mob.connect("died", _on_died)
	connect("endgame", new_mob._on_game_endgame)

func _on_timer_timeout():
	if(active):
		spawn_mob()

func _on_player_health_depleted():
	show_endgame(%Score.text)
	
func _on_died():
	death_count += 1
	if(death_count % 15 == 0):
		level_up.emit()
		%Level.text
	%Score.text = "Score = " + str(death_count)

func _on_timer_2_timeout() -> void:
	var score = death_count + round(find_child("Player").health)
	show_endgame("Score = " + str(score))
	#get_tree().paused = true
	
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
	#get_tree().paused = true
	# need to replace this with: 
	# stop player movement
	# stop player shooting
	# stop playtimer
	# stop enemies
	
