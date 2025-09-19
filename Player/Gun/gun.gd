extends Area2D

var num_shots : int = 1
var active : bool = true
var gun_type = null
var ammo = 0
var reload_time = 0
var bullet_damage = 1

var pistol = { 
	"name" = "Pistol",
	"max_ammo" = 12,
	"reload_time" = 1, #seconds
	"fire_type" = "single"
}

var shotgun = { 
	"name" = "Shotgun",
	"max_ammo" = 8,
	"reload_time" = 1.75, #seconds
	"fire_type" = "spread"
}

var machine_gun = { 
	"name" = "Machine Gun",
	"max_ammo" = 30,
	"reload_time" = 1.5, #seconds
	"fire_type" = "burst"
}

enum GUN_TYPE {
	PISTOL,
	SHOTGUN,
	MACHINE_GUN
}

var guns = [pistol, shotgun, machine_gun]

var ammo_label
var gun_type_label
var spread_arr
var player_level
var reload_active = false;
var gun_switch_time = 0.5
var gun_switch_active
var reload_label_prefix

func _ready() -> void:
	# Set base gun type
	gun_type = GUN_TYPE.PISTOL
	ammo = guns[gun_type]["max_ammo"]
	
	# Grab the ammo label and update
	ammo_label = find_parent("Game").find_child("Ammo")
	ammo_label.text = "Ammo = " + str(ammo)
	
	# Grab the gun_type label and update
	gun_type_label = find_parent("Player").find_child("GunLabel") 
	gun_type_label.text = guns[gun_type]['name']
	
	# Grab a reference to the player level
	player_level = find_parent("Player").level
	
	# For Shotgun bulllet pattern
	spread_arr = [%ShootingPoint, %ShootingPoint2, %ShootingPoint3]

func _process(_delta):
	
	# Point Gun at mouse cursor 
	look_at(get_global_mouse_position())
	
	# Reload Countdown Bar
	if(reload_active):
		%ReloadBar.value = remap(%Timer.time_left, %Timer.wait_time, 0, 0, 100.0)
	else:
		%ReloadBar.value = remap(ammo, 0, guns[gun_type]['max_ammo'], 0, 100.0)
	
	# Auto Reload
	if(ammo <= 0 and not reload_active):
		reload(guns[gun_type]['reload_time'], false)
		

func _input(event):
	if(active):
		if event.is_action_pressed("shoot"):
				shoot()
		elif event.is_action_pressed("reload"):
			reload(guns[gun_type]["reload_time"], false)
		elif event.is_action_pressed("cycle_guns"):
			change_gun()

func shoot():
	if(ammo > 0):
		if(guns[gun_type]['fire_type'] == "single"): 
			AudioManager.play_sfx("Pistol",0,true)
			inst_bullet(%ShootingPoint)
			ammo -= 1
		elif(guns[gun_type]['fire_type'] == "burst"):
			for i in range(3):
				AudioManager.play_sfx("MachineGun", 0, true)
				inst_bullet(%ShootingPoint)
				await get_tree().create_timer(0.1).timeout
				ammo -= 1	
		elif(guns[gun_type]['fire_type'] == "spread"):
			AudioManager.play_sfx("Shotgun", 0, true)
			for point in spread_arr:
				inst_bullet(point)
			ammo -= 1
		else:
			printerr("Unknown fire_type")
		ammo_label.text = "Ammo = " + str(ammo)


func inst_bullet(shooting_point : Marker2D):
	const BULLET = preload("res://Player/Gun/bullet_2d.tscn")
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
	ammo = guns[gun_type]["max_ammo"]

func change_gun():	
	# Grab a reference to the player level
	player_level = find_parent("Player").level

	# Branch actions based on player level
	if(player_level < 1):
		return
	elif(gun_type == GUN_TYPE.PISTOL and player_level >= 1):
		gun_type = GUN_TYPE.SHOTGUN
	elif(gun_type == GUN_TYPE.SHOTGUN and player_level < 2):
		gun_type = GUN_TYPE.PISTOL
	elif(gun_type == GUN_TYPE.SHOTGUN and player_level >= 2):
		gun_type = GUN_TYPE.MACHINE_GUN
	elif(gun_type == GUN_TYPE.MACHINE_GUN):
		gun_type = GUN_TYPE.PISTOL
	
	# Reload timer for switching gun
	reload(gun_switch_time, true)
	
	# Change gun label
	gun_type_label.text = guns[gun_type]['name']
