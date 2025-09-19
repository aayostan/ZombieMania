extends CharacterBody2D

signal died(experience : int)

@export var speedMult : float

var base_mob = {
 	"speed" = randf_range(225, 300),
	"health" = 3,
	"experience" = 100
}

var fast_mob = {
 	"speed" = base_mob["speed"] * 2.25,
	"health" = base_mob['health'] - 1,
	"experience" = base_mob['experience'] + 50
}

var big_mob = {
 	"speed" = base_mob["speed"] - 50,
	"health" = base_mob['health'] * 15,
	"experience" = base_mob['experience'] * 10
}

@onready var player = get_node("/root/Game/Player")

var base_mob_prob = 0.65
var fast_mob_prob = 0.175
var big_mob_prob = 0.175

var mob_type

func _ready():
	var rand = randf()
	if(player.level <  3):
		mob_type = base_mob
	elif(player.level == 3):
		if(rand < base_mob_prob):
			mob_type = base_mob
		else:
			mob_type = fast_mob
			%Slime.find_child("SlimeBody").modulate = Color(255, 0, 0, 255)
	else:
		if(rand < base_mob_prob):
			mob_type = base_mob
		elif(rand >= base_mob_prob and rand < (base_mob_prob + fast_mob_prob)):
			mob_type = fast_mob
			%Slime.find_child("SlimeBody").modulate = Color(255, 0, 0, 255)
		else:
			mob_type = big_mob
			scale = Vector2(2, 2)
			
	
	
	%Slime.play_walk()


func _physics_process(_delta):
	var direction = global_position.direction_to(player.global_position)
	velocity = direction * mob_type['speed']
	move_and_slide()


func take_damage(amount : int):
	if(amount < 0):
		return
	
	print("I'm taking damage")
	print(amount)
	print("\n")
	
	%Slime.play_hurt()
	mob_type['health'] -= amount
	
	if mob_type['health'] <= 0:
		died.emit(mob_type['experience'])
		var smoke_scene = preload("res://smoke_explosion/smoke_explosion.tscn")
		var smoke = smoke_scene.instantiate()
		get_parent().add_child(smoke)
		smoke.global_position = global_position
		queue_free()

func _on_game_endgame():
	queue_free()
