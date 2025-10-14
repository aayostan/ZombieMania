extends CharacterBody2D

class_name zombie

# Run before _ready
@onready var player = get_node("/root/Game/Player") # playerref
@onready var game = get_parent() # gameref
@onready var player_level = player.level
@onready var animator = find_child("AnimationPlayer")

# Declare signals
signal death(experience : int, isboss : bool)

# Resources
var base_mob = {
	"name" = "base_zombie",
 	"speed" = randf_range(225, 300),
	"health" = 3,
	"experience" = 100,
	"sfx" = ["Ow"],
	"pickupprob" = Stats.pickup_probability,
	"scale" = Vector2(1, 1),
	"color" = Color.GREEN,
	"hurt_color" = Color(Color.ORANGE, 0),
	"ignore_trees" = false
}

var fast_mob = {
	"name" = "fast_zombie",
 	"speed" = base_mob["speed"] * 2.25,
	"health" = base_mob['health'] - 1,
	"experience" = base_mob['experience'] + 50,
	"sfx" = ["OwHi"],
	"pickupprob" = base_mob['pickupprob'] * 0.9,
	"scale" = Vector2(0.8, 0.8),
	"color" = Color.RED,
	"hurt_color" = Color(Color.BLACK, 0),
	"ignore_trees" = false
}

var big_mob = {
	"name" = "big_zombie",
 	"speed" = base_mob["speed"] - 50,
	"health" = base_mob['health'] * 15,
	"experience" = base_mob['experience'] * 10,
	"sfx" = ["OwLo"],
	"pickupprob" = base_mob['pickupprob'] * 1.5,
	"scale" = Vector2(2, 2),
	"color" = Color.GREEN,
	"hurt_color" = Color(Color.ORANGE, 0),
	"ignore_trees" = true
}

var big_mob_boss = {
	"name" = "uber_zombie",
 	"speed" = big_mob['speed'] - 50,
	"health" = big_mob['health'] * 5,
	"experience" = big_mob['experience'] * 10,
	"sfx" = ["OwLo"],
	"pickupprob" = 1,
	"scale" = Vector2(5, 5),
	"color" = Color.GREEN,
	"hurt_color" = Color(Color.ORANGE, 0),
	"ignore_trees" = true
}

var fast_mob_boss = {
	"name" = "zombie_hoard",
 	"speed" = randf_range(1000, 1500),
	"health" = 10,
	"experience" = 300,
	"sfx" = ["OwHi"],
	"pickupprob" = 1,
	"scale" = Vector2(1, 1),
	"color" = Color.RED,
	"hurt_color" = Color(Color.BLACK, 0),
	"ignore_trees" = false
}

var big_fast_mob_boss = {
	"name" = "uber_zombie",
 	"speed" = fast_mob["speed"],
	"health" = big_mob['health'] * 5,
	"experience" = big_mob['experience'] * 5,
	"sfx" = ["OwHi"],
	"pickupprob" = 1,
	"scale" = Vector2(2, 2),
	"color" = Color.ORANGE_RED,
	"hurt_color" = Color(Color.BLACK, 0),
	"ignore_trees" = true
}

var reg_zombies : Array = [base_mob, big_mob, fast_mob]
var reg_zombies_probs : Array = [0.7, 0.1, 0.2]


# Probabilities
var base_mob_prob = 0.65
var fast_mob_prob = 0.175
var big_mob_prob = 0.175

# Placeholder
var mob_type : Dictionary
var curr_health : float
var boss : bool = false
var round_count : int = 1

# Flags
var ignore_trees : bool = false



# Built-in Functions
func _ready():
	choose_mob()
	%Slime.play_walk()
	curr_health = mob_type['health']
	animator.connect("animation_changed", _on_animation_changed)


func _physics_process(_delta):
	var direction = global_position.direction_to(player.global_position)
	velocity = direction * mob_type['speed']
	move_and_slide()
	#move_and_collide() here?



# Events
func _on_game_clear_board():
	queue_free()



# Helpers
func choose_mob():
	if(boss):
		if(round_count == 1):
			mob_type = big_mob_boss
		elif(round_count == 2): # Every Other Round
			mob_type = fast_mob_boss
		elif(round_count == 3):
			mob_type = big_fast_mob_boss
	else:
		# Slice zombie and probs arrays by round_count
		reg_zombies_probs = reg_zombies_probs.slice(0, round_count)
		reg_zombies = reg_zombies.slice(0, round_count)
		# Choose a regular zombie at random based on probs
		mob_type = GlobalFun._choose_random_w_probs(reg_zombies_probs, reg_zombies)
	# Update zombie paramaters for scene
	scale = mob_type['scale'] # Scale scene
	ignore_trees = mob_type['ignore_trees'] # Flag ignore trees
	%Slime.find_child("SlimeBody").self_modulate = mob_type['color'] # Modulate sprite
	%Slime.find_child("SlimeBodyHurt").modulate = mob_type['hurt_color']


func take_damage(amount : int):
	if(amount < 0):
		return
	var prev_health = curr_health
	
	%Slime.play_hurt()
	curr_health -= amount
	
	# Update boss health
	if(boss):
		#print(mob_type['name'], " is boss")
		if(round_count != 2):
			get_parent().find_child("BossHealthBar").value = remap(curr_health, 0, mob_type['health'], 0, 100)
		else:
			get_parent().find_child("BossHealthBar").value = remap(\
								curr_health + mob_type['health'] * (get_parent().spawn_limiter-1),\
								0, mob_type['health'] * get_parent().HORDE_SIZE, 0, 100)
	
	if prev_health > 0 and curr_health <= 0: # Dead condition met
		death.emit(mob_type['experience'], boss)
		queue_scene("res://NPCs/Enemies/smoke_explosion/smoke_explosion.tscn")
		pickup_drop()
		queue_free()


func queue_scene(scene : String):
		var the_scene = load(scene)
		var the_obj = the_scene.instantiate()
		# these throw an error whenn calling from pickup_drop()
		# don't see a problem in the game yet
		#var game = get_parent()
		game.call_deferred("add_child", the_obj)
		the_obj.global_position = global_position


func pickup_drop():
	var rand = randf()
	if(rand < mob_type['pickupprob']):
		queue_scene("res://Pickups/pickup.tscn")



# Not used
func update_animator():
	# Get the AnimationPlayer node
	var animation_player = %Slime.find_child("AnimationPlayer")

	# Get the animation you want to modify
	var animation = animation_player.get_animation("hurt")
	if animation == null:
		print("Animation not found!")
		return

	# Modify an existing track
	#Animation.new().find_track()
	var track_index = animation.find_track("Anchor/SlimeBody:modulate", Animation.TrackType.TYPE_VALUE)
	if track_index != -1:
		# Change the key value at a specific time
		if(Stats.run_tests):
			print(animation.track_get_key_count(track_index))
			print(animation.track_get_key_value(track_index, 0))
			print(mob_type['hurt_color'])
			animation.track_set_key_value(track_index, 0, mob_type['hurt_color'])
			print(animation.track_get_key_value(track_index, 0))
			print(animation.track_get_key_value(track_index, 1))
			print(mob_type['color'])
			animation.track_set_key_value(track_index, 1, mob_type['color'])
			print(animation.track_get_key_value(track_index, 1))
			#Animation.new().track_set_key_value()
			print("Track modified successfully!")
			print()
		else:
			animation.track_set_key_value(track_index, 0, mob_type['hurt_color'])
			animation.track_set_key_value(track_index, 1, mob_type['color'])
	else:
		printerr("Track not found!")
func _on_animation_changed(old_name: StringName, new_name: StringName):
	if Stats.run_tests:
		("\nAnimation changed")
		print("From: ",old_name)
		print("To: ", new_name)
		print("Modulate: ", %Slime.find_child("SlimeBody").modulate, "\n")
	#%Slime.find_child("SlimeBody").modulate = mob_type['color']# I used bing's AI to come up with this
