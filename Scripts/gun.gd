extends Area2D


# Resource section
func RESOURCES():
	pass


var active : bool = true
var ammo = 0
var reload_time = 0
var gun_num : int = -1
var ammo_label
var gun_type_label
var spread_arr
var player_level
var reload_active = false;
var gun_switch_time = 0.5

# Class Param Definitions
enum GUN_TYPE {PISTOL, SHOTGUN, MACHINE_GUN}
@export var guns = [
	{ 
		"name" = "Pistol",
		"max_ammo" = 12,
		"reload_time" = 1, #seconds
		"fire_type" = "single"
	},
	{
		"name" = "Shotgun",
		"max_ammo" = 8,
		"reload_time" = 1.5, #seconds
		"fire_type" = "spread"
	},
	{ 
		"name" = "Machine Gun",
		"max_ammo" = 30,
		"reload_time" = 1.25, #seconds
		"fire_type" = "burst"
	}
]


# Not used here
var num_shots : int = 1
var bullet_damage = 1



# Built-in section
func BUILTINS():
	pass


func _ready() -> void:
	# Set base gun type
	ammo = guns[Stats.gun_type]["max_ammo"]
	
	# Grab the ammo label and update (deprecated)
	ammo_label = find_parent("Game").find_child("Ammo")
	ammo_label.text = "Ammo = " + str(ammo)
	
	# Grab the Stats.gun_type label and update
	gun_type_label = find_parent("Player").find_child("GunLabel") 
	gun_type_label.text = guns[Stats.gun_type]['name']
	
	# Grab a reference to the player level
	player_level = find_parent("Player").level
	bullet_damage = find_parent("Player").accuracy
	
	# For Shotgun bulllet pattern
	spread_arr = [%ShootingPoint, %ShootingPoint2, %ShootingPoint3]


func _process(_delta):
	
	# Point Gun at mouse cursor
	if(gun_num == 0):
		rotation = (global_position - get_global_mouse_position()).angle()
	elif(gun_num == -1):
		look_at(get_global_mouse_position())
	else:
		var enemies_in_range = get_overlapping_bodies()
		if enemies_in_range.size() > 0:
			var target_enemy = enemies_in_range.front()
			look_at(target_enemy.global_position)
	
	# Reload Countdown Bar
	if(reload_active):
		%ReloadBar.value = remap(%Timer.time_left, %Timer.wait_time, 0, 0, 100.0)
	else:
		%ReloadBar.value = remap(ammo, 0, guns[Stats.gun_type]['max_ammo'], 0, 100.0)
	
	# Auto Reload
	if(ammo <= 0 and not reload_active):
		reload(guns[Stats.gun_type]['reload_time'], false)
	
	# Debug
	#print(name, bullet_damage)



# Events section
func EVENTS():
	pass


func _input(event):
	if(active):
		if event.is_action_pressed("shoot"):
				shoot()
		elif event.is_action_pressed("reload"):
			reload(guns[Stats.gun_type]["reload_time"], false)
		elif event.is_action_pressed("cycle_guns"):
			if(gun_num == 1): change_gun()


func _on_accuracy_changed(multiplier : float):
	bullet_damage = multiplier



# Helper section
func HELPERS():
	pass


func shoot():
	if(ammo > 0):
		if(guns[Stats.gun_type]['fire_type'] == "single"): 
			AudioManager.play_sfx("Pistol",0,true)
			inst_bullet(%ShootingPoint)
			ammo -= 1
		elif(guns[Stats.gun_type]['fire_type'] == "burst"):
			for i in range(3):
				AudioManager.play_sfx("MachineGun", 0, true)
				inst_bullet(%ShootingPoint)
				await get_tree().create_timer(0.1).timeout
				ammo -= 1	
		elif(guns[Stats.gun_type]['fire_type'] == "spread"):
			AudioManager.play_sfx("Shotgun", 0, true)
			for point in spread_arr:
				inst_bullet(point)
			ammo -= 1
		else:
			printerr("Unknown fire_type")
		ammo_label.text = "Ammo = " + str(ammo)


func inst_bullet(shooting_point : Marker2D):
	const BULLET = preload("res://Scenes/bullet_2d.tscn")
	var new_bullet = BULLET.instantiate()
	new_bullet.global_transform = shooting_point.global_transform
	shooting_point.add_child(new_bullet)


func reload(time : float, switch : bool):
	if(switch):
		AudioManager.play_sfx("GunSwitch")
	else:
		AudioManager.play_sfx("Reload")
	active = false
	reload_active = true;
	%Timer.start(time)
	await %Timer.timeout
	reload_active = false
	active = true
	ammo = guns[Stats.gun_type]["max_ammo"]


func change_gun(debug : bool = false):
	# Bug: Runs each time there is a gun for global variable
	# Fix: either move gun_type to local, or move change_gun global
	
	# Grab a reference to the player level
	player_level = find_parent("Player").level
	
	if(debug):
		print("Gun Number: " + str(gun_num))
		print("Level: " + str(player_level))
		print("Gun Start: " + str(Stats.gun_type))
	
	# Branch actions based on player level
	if(player_level < 2):
		return
	elif(Stats.gun_type == GUN_TYPE.PISTOL and player_level >= 2):
		Stats.gun_type = GUN_TYPE.SHOTGUN
	elif(Stats.gun_type == GUN_TYPE.SHOTGUN and player_level < 4):
		Stats.gun_type = GUN_TYPE.PISTOL
	elif(Stats.gun_type == GUN_TYPE.SHOTGUN and player_level >= 4):
		Stats.gun_type = GUN_TYPE.MACHINE_GUN
	elif(Stats.gun_type == GUN_TYPE.MACHINE_GUN):
		Stats.gun_type = GUN_TYPE.PISTOL

	if(debug):
		print("Gun After: " + str(Stats.gun_type))
		print("Gun Stats: " + str(guns[Stats.gun_type])  + "\n")
	
	# Reload timer for switching gun
	reload(gun_switch_time, true)
	
	# Change gun label
	gun_type_label.text = guns[Stats.gun_type]['name']
