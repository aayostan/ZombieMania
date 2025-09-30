extends CharacterBody2D

class_name mob

# Run before _ready
@onready var player = get_node("/root/Game/Player") # playerref
@onready var game = get_parent() # gameref
@onready var boss : bool = game.spawn_boss # bossround?
@onready var round_count : int = game.round_count # roundnum
@onready var player_level = player.level


# Declare signals
signal mob_died(experience : int, isboss : bool)

# Resources
var base_mob = {
 	"speed" = randf_range(225, 300),
	"health" = 3,
	"experience" = 100,
	"sfx" = ["Ow"],
	"pickupprob" = Stats.pickup_probability
}

var fast_mob = {
 	"speed" = base_mob["speed"] * 2.25,
	"health" = base_mob['health'] - 1,
	"experience" = base_mob['experience'] + 50,
	"sfx" = ["OwHi"],
	"pickupprob" = base_mob['pickupprob'] * 0.9
}

var big_mob = {
 	"speed" = base_mob["speed"] - 50,
	"health" = base_mob['health'] * 15,
	"experience" = base_mob['experience'] * 10,
	"sfx" = ["OwLo"],
	"pickupprob" = base_mob['pickupprob'] * 1.5
}

var boss_mob = {
 	"speed" = big_mob['speed'] - 50,
	"health" = big_mob['health'] * 5,
	"experience" = big_mob['experience'] * 10,
	"sfx" = ["OwLo"],
	"pickupprob" = 1
}

# Probabilities
var base_mob_prob = 0.65
var fast_mob_prob = 0.175
var big_mob_prob = 0.175

# Placeholder
var mob_type
var curr_health 

# Flags
var ignore_trees : bool = false



# Built-in Functions
func _ready():
	choose_mob()
	%Slime.play_walk()
	curr_health = mob_type['health']


func _physics_process(_delta):
	var direction = global_position.direction_to(player.global_position)
	velocity = direction * mob_type['speed']
	move_and_slide()


func _process(_delta):
	# Update boss health
	if(boss):
		get_parent().find_child("BossHealthBar").value = remap(curr_health, 0, mob_type['health'], 0, 100)


# Events
func _on_game_endgame():
	queue_free()


func _on_game_bossround():
	queue_free()


# Helpers
func choose_mob():
	if(boss):
		mob_type = boss_mob
		scale = Vector2(5, 5) # Make big
		ignore_trees = true
		return
	
	# Randomization
	var rand = randf()
	
	# Decision Tree
	if(round_count == 1):
		mob_type = base_mob
	elif(round_count == 2):
		if(rand < base_mob_prob):
			mob_type = base_mob
		else:
			mob_type = big_mob
			scale = Vector2(2, 2)
	else:
		if(rand < base_mob_prob):
			mob_type = base_mob
		elif(rand >= base_mob_prob and rand < (base_mob_prob + fast_mob_prob)):
			mob_type = fast_mob
			%Slime.find_child("SlimeBody").modulate = Color(255, 0, 0, 255)
		else:
			mob_type = big_mob
			scale = Vector2(2, 2)


func take_damage(amount : int):
	if(amount < 0):
		return
	# For Testing
	#print("I'm taking damage")
	#print(amount)
	#print("\n")
	%Slime.play_hurt()
	curr_health -= amount
	
	if curr_health <= 0: # Dead condition met
		mob_died.emit(mob_type['experience'], boss)
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
