extends Node2D

# Constants
const MAX_LEVEL : int = 20
const FOREST_SIZE : int = 100
const MIN_DIST_TREE_TO_PLAYER : int = 175
const ITEM_CAP : int = 5
const MAX_ROUNDS : int = 3
const HORDE_SIZE : int = 10

# Signals used to communicate with other classes
signal level_up
signal clear_board

# Counter variables
var kill_count : int = 0
var player_level : int = Stats.PLAYER_LEVEL_START
var round_count : int = Stats.GAME_ROUND_START
var inventory : Dictionary = {
	"Sandwhich" = 0,
	"Soda" = 0,
	"Gun" = 0
}
var spawn_limiter = 0

# flags
var active : bool = true
var run_tests : bool = Stats.run_tests
var empty_inv : bool = true
var boss : bool = false

# Resoures
var level : Array = range(0, MAX_LEVEL).map(func(n): return n**2*1000)
var player_experience : float = level[player_level]

# Placeholders
var spawn_time : float
var text : String



# Built in functions
func _ready():
	spawn_trees()
	
	# Uncomment tests you want to run
	if(run_tests):
		#test_inventory_selector()
		active = false
		spawn_zombie()
		
		pass


func _process(_delta : float) -> void:
	%TimeBar.value = remap(%PlayTimer.time_left, 0, %PlayTimer.wait_time, 0, 100)
	update_exp_UI()



# Events
func _on_spawntimer_timeout() -> void:
	if(active):
		spawn_zombie()


func _on_playtimer_timeout() -> void:
	if(round_count > 3):
		show_endgame(%Score.text) #Note: Change score calculation
	else:
		spawn_boss()


func _on_player_health_depleted():
	AudioManager.stop_all_sfx()
	AudioManager.play_sfx("Death")
	show_endgame(%Score.text)



func _on_zombie_death(experience : int, is_boss : bool):
	credit_player(experience)
	
	# Respond to killing boss
	if(is_boss):
		if(spawn_limiter > 0):
			spawn_zombie()
			return
		boss = false
		
		# Need to queue these cutscenes as they don't run when their are conflicts!
		# Notify Player of boss round end
		text = "Round " + str(round_count) + " Boss\nDefeated!"
		%Display.queue_display_text(text)
		
		# Update round_count
		round_count += 1
		
		# Notify Player of next round start
		text = "Round " + str(round_count) + " Start!"
		%Display.queue_display_text(text)
		
		# Reset Timers and UI
		%BossOverlay.hide() # hide Boss Overlay
		%SpawnTimer.wait_time = 0.3 # Reset spawntimer
		%SpawnTimer.start()
		%PlayTimer.start() # Restart playtimer
		
		return
	
	if(run_tests):
		spawn_zombie()



# Helpers
func spawn_trees():
	# Get bounding box
	var bounds = get_viewport_rect()
	var boundX = bounds.size.x
	var boundY = bounds.size.y
	
	# Repeat X times
	for i in range(FOREST_SIZE):
		# Randomization
		var randV2 : Vector2 = Vector2(randf_range(-boundX, boundX),randf_range(-boundY, boundY))
		while(randV2.length() < MIN_DIST_TREE_TO_PLAYER):
			randV2 = Vector2(randf_range(-boundX, boundX),randf_range(-boundY, boundY))
		
		# Object instantiation
		var new_tree = preload("res://Environment/pine_tree.tscn").instantiate()
		new_tree.global_position = find_child("Player").global_position + randV2
		add_child(new_tree)


func spawn_zombie():
	#boss : bool = false, mob : bool = false):
	# randomization
	%PathFollow2D.progress_ratio = randf()
	
	# object instantiation
	var zombie_inst = preload("res://NPCs/Enemies/zombie.tscn").instantiate()
	if(boss): zombie_inst.boss = true
	zombie_inst.round_count = round_count
	zombie_inst.global_position = %PathFollow2D.global_position
	call_deferred("add_child", zombie_inst)
	
	# connect signals
	zombie_inst.connect("death", _on_zombie_death)
	connect("clear_board", zombie_inst._on_game_clear_board)
	
	# Update spawn limiter
	if boss: spawn_limiter = max(spawn_limiter - 1, 0)


func spawn_boss():
	# Run Boss Fight
	clear_board.emit() # Remove all enemies
	%SpawnTimer.stop() # Stop Spawning enemies
	boss = true
	
	# Notify Player of boss round
	text = "Round " + str(round_count) + " Boss!"
	%Display.queue_display_text(text)
	
	var timer : bool = true
	
	# Spawn boss enemy based on round
	if(round_count == 1):
		# Spawn one boss
		spawn_zombie()
		boss = false
	elif(round_count == 2):
		# Need to set a total for zombie spawn
		# Spawn those zombies on a timer
		# Once those zombies are depleted, end round
		# Can count them in the _on_zombie_death
		# Can count them in the _on_spawntimer_timeout
		# Can spawn new one after each kill instaed of on timer
		spawn_limiter = HORDE_SIZE
		spawn_zombie()
		timer = false
	elif(round_count == 3):
		spawn_zombie()
		boss = false
	
	%SpawnTimer.wait_time = 2 # Reset Spawn Timer
	if timer: %SpawnTimer.start() # Restart Spawn Timer
	%BossOverlay.show() # Show Boss Overlay
	

func show_endgame(scoreText):
	clear_board.emit() # remove zombies
	%FinalScore.text = scoreText # update score text
	%GameOver.show() # show gameover screen
	get_tree().paused = true # pause tree


func update_exp_UI():
	if(player_level < level.size()):
		%ExpBar.value = remap(player_experience, level[player_level], level[player_level+1], 0, 100)
	else:
		%ExpBar.value = 100


func update_inventory(item : String, increment : bool = true, amount : int = 1) -> bool:
	# Update back_end
	if increment:
		if(inventory[item] == 0):
			inventory_selector(item,false) # Clear panel at start.
		inventory[item] = min(inventory[item] + amount, ITEM_CAP)
		if(empty_inv): 
			inventory_selector(item)
			var player = find_child("Player")
			player.item_choice = player.items.rfind(item)
			empty_inv = false
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
		inventory_selector(item, false)
		var next_active = find_active_item()
		if(next_active != "None"):
			inventory_selector(next_active)
			var player = find_child("Player")
			player.item_choice = player.items.rfind(next_active)
	else:
		entry.show()

	return true


func inventory_selector(item : String, select : bool = true):
	var entry = %Inventory.find_child(item)
	var panel = entry.get_parent()
	var stylebox = StyleBoxFlat.new()
	stylebox.bg_color = Color(0, 0, 0, 0)
	if select:
		#print("Selecting ", item)
		stylebox.border_width_bottom = 5
		stylebox.border_width_left = 5
		stylebox.border_width_right = 5
		stylebox.border_width_top = 5
		stylebox.border_color = Color(0, 0, 0)
		stylebox.border_blend = true
	panel.add_theme_stylebox_override("panel", stylebox)


func find_active_item() -> String:
	for k in inventory.keys():
		if check_active(k):
			return k
	empty_inv = true
	return "None"


func check_active(item : String) -> bool:
	var entry = %Inventory.find_child(item)
	if entry.visible: return true
	else: return false


func credit_player(experience : float):
	kill_count += 1
	var temp = player_experience + experience
	for i in range(level.size()):
		if(player_experience < level[i] and temp >= level[i]):
			level_up.emit()
			player_level += 1
	player_experience = temp
	%Score.text = "Kills: " + str(kill_count)


# Test Suite
func test_inventory_selector():
	inventory_selector("Sandwhich")
	await get_tree().create_timer(1).timeout
	inventory_selector("Soda")
	await get_tree().create_timer(1).timeout
	inventory_selector("Gun")
	await get_tree().create_timer(1).timeout
	
	inventory_selector("Sandwhich", false)
	await get_tree().create_timer(1).timeout
	inventory_selector("Soda", false)
	await get_tree().create_timer(1).timeout
	inventory_selector("Gun", false)
