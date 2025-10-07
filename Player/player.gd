extends CharacterBody2D

# Signals
signal health_depleted
signal accuracy_changed(multiplier : float)

# Stats
var health = 100.0
var active = true
var level = Stats.PLAYER_LEVEL_START
var arms = 2
var gun_count = 1
var accuracy : float = 1.0
var items = [
	"Sandwhich",
	"Soda",
	"Gun"
]

# Placehoder
var item_choice : int = 0

# Camera shake stuff
var camera : Camera2D

@export var decay : float = 0.6 # Time it takes to reach 0% of trauma
@export var max_offset : Vector2 = Vector2(50, 50) # Max hor/ver shake in pixels
@export var max_roll : float = 0.1 # Maximum rotation in radians (use sparingly)

var trauma : float = 0.0 # Current shake strength
var trauma_power : float = 1.5 # Trauma exponent. Increase for more extreme shaking


# Run before _ready()
@onready var gun = find_child("Gun") 
@onready var game = get_parent()



# Built-in Functions
func _ready():
	%LevelLabel.text = "L" + str(level)
	camera = get_viewport().get_camera_2d()
	connect("accuracy_changed", gun._on_accuracy_changed)


func _physics_process(delta):
	if(active):
		var SPEED = Stats.player_speed
		var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
		velocity = direction * SPEED
		
		move_and_slide()
	
		if velocity.length() > 0.0:
			%HappyBoo.play_walk_animation()
		else:
			%HappyBoo.play_idle_animation()
		
		# Taking damage
		var DAMAGE_RATE = Stats.enemy_damage
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
				health_depleted.emit()
		
		else:
			trauma = 0.3


func _input(event):
	if(active):
		if event.is_action_pressed("select_left"):
			print("Select Left")
			select()
		elif event.is_action_pressed("select_right"):
			print("Select Right")
			select(false)
		elif event.is_action_pressed("use_item"):
			#print("Using item")
			use_item(items[item_choice])
		#if event.is_action_pressed("use_item_1"):
			#use_item("Sandwhich")
		#elif event.is_action_pressed("use_item_2"):
			#use_item("Soda")
		#elif event.is_action_pressed("use_item_3"):
			#use_item("Gun")



# Events
func _on_game_level_up() -> void:
	AudioManager.play_sfx("LevelUp")
	level += 1
	%LevelLabel.text = "L" + str(level)
	
	if(level == 1):
		%Gun_Unlocked.text = "Unlocked: Backpack\nScroll to Choose\nQ to Use"
		if(game):
			game.update_inventory("Sandwhich")
			game.update_inventory("Soda")
			game.update_inventory("Gun")
		Stats.pickup_probability = 0.15
	elif(level == 2):
		%Gun_Unlocked.text = "Unlocked: Shotgun\n(Press E to switch)"
		Stats.pickup_probability = 0.1
	elif(level == 3):
		%Gun_Unlocked.text = "Increased Accuracy\ndamage X accuracy"
		accuracy += 1
		accuracy_changed.emit(accuracy)
	elif(level == 4):
		%Gun_Unlocked.text = "Unlocked Machine Gun"
	elif(level == 5 or level == 6):
		%Gun_Unlocked.text = "Increased Accuracy"
		accuracy += 0.75
		accuracy_changed.emit(accuracy)
	elif(level == 7):
		%Gun_Unlocked.text = ""
		for g in gun.guns:
			g['max_ammo'] *= 10**7
		gun.gun_switch_time = 0
		%SpawnTimer.wait_time = 0.2
	elif(level == 8):
		pass
	elif(level == 9):
		pass
	elif(level == 10):
		%SpawnTimer.wait_time = 0.05
		pass
	else:
		return
		
	%Unlock_Gun.show()
	await get_tree().create_timer(3).timeout
	%Unlock_Gun.hide()



# Helpers
func create_gun():
	gun_count += 1
	var new_gun = preload("res://Player/Gun/gun.tscn")
	var new_obj = new_gun.instantiate()
	call_deferred("add_child", new_obj)
	connect("accuracy_changed", new_obj._on_accuracy_changed)
	Stats.guns.append(new_obj)
	new_obj.gun_num = gun_count


func shake() -> void:
	#? Set the camera's rotation and offset based on the shake strength
	var amount = pow(trauma, trauma_power)
	camera.rotation = max_roll * amount * randf_range(-1, 1)
	camera.offset.x = max_offset.x * amount * randf_range(-1, 1)
	camera.offset.y = max_offset.y * amount * randf_range(-1, 1)


func use_item(item : String):
	var used = false
	used = game.update_inventory(item, false)
	
	if used:
		# Find Params
		var param = GlobalFun.search_params(Stats.PICKUP_PARAMS, item)
		if(param.is_empty()): 
			return
		
		# Consume Pickup
		AudioManager.play_sfx(param["sfx"],0,true)
		update_stat(param)
		if(param['cooldown'] > 0):
			get_tree().create_timer(param['cooldown']).timeout.connect(_on_pickup_cooldown.bind(param))


func select(left : bool = true):
	if game.find_active_item() != "None":
		var not_switch = true
		game.inventory_selector(items[item_choice], false)
		print("Change from ", items[item_choice])
		while(not_switch):
			if left:
				if item_choice > 0:
					item_choice -= 1
				else:
					item_choice = items.size() - 1
			else:
				if item_choice < (items.size() - 1):
					item_choice += 1
				else:
					item_choice = 0
			if(game.check_active(items[item_choice])):
				game.inventory_selector(items[item_choice])
				not_switch = false
		print("Change to ", items[item_choice], "\n")
	else:
		print("No active items")


func update_stat(param : Dictionary):
	
	if(param["stat"] == "speed"):
		if(param["modifier"] == "add"):
			Stats.player_speed += param["value"]
		else:
			Stats.player_speed *= param["value"]
	elif(param["stat"] == "health"):
		if(param["modifier"] == "add"):
			health += param["value"]
		else:
			health *= param["value"]
		%HealthBar.value = health
	elif(param["stat"] == "gun"):
		if(param["modifier"] == "add"):
			create_gun()
			Stats.two_guns = true



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
			health -= param["value"]
		else:
			health /= param["value"]
		%HealthBar.value = health
	elif(param["stat"] == "gun"):
		if(param["modifier"] == "add"):
			if(Stats.guns.size() > 0):
				Stats.guns.pop_back().queue_free()
				gun_count -= 1
