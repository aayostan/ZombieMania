extends Area2D

var num_shots : int = 1
var active : bool = true
var gun_type = null
var ammo = 0
var reload_time = 0
var bullet_damage = 1

var pistol = { 
	"name" = "pistol",
	"max_ammo" = 12,
	"reload_time" = 1, #seconds
	"fire_type" = "single"
}

var shotgun = { 
	"name" = "shotgun",
	"max_ammo" = 8,
	"reload_time" = 1.75, #seconds
	"fire_type" = "spread"
}

var machine_gun = { 
	"name" = "machine gun",
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
var reload_canvas
var reload_label
var gun_type_label
var spread_arr
var reload_timer
var reload_active = false;

func _ready() -> void:
	gun_type = GUN_TYPE.PISTOL
	ammo = guns[gun_type]["max_ammo"]
	reload_time = guns[gun_type]["reload_time"]
	ammo_label = find_parent("Game").find_child("Ammo")
	reload_canvas = find_parent("Game").find_child("Reload")
	reload_label = find_parent("Game").find_child("Reload_Time")
	gun_type_label = find_parent("Game").find_child("Gun_Type") 
	reload_timer = find_parent("Game").find_child("ReloadTimer")
	ammo_label.text = "Ammo = " + str(ammo)
	gun_type_label.text = "Gun: " + guns[gun_type]['name']
	spread_arr = [%ShootingPoint, %ShootingPoint2, %ShootingPoint3]

func _process(_delta):
	# Point Gun at mouse cursor 
	look_at(get_global_mouse_position())
	
	# Point Gun at Random Enemy
	#var enemies_in_range = get_overlapping_bodies()
	#if enemies_in_range.size() > 0:
		#var target_enemy = enemies_in_range.front()
		#look_at(target_enemy.global_position)
	if(reload_active):
		reload_label.text = "Reloading (" + str(round(reload_timer.time_left * pow(10, 1)) / pow(10, 1)) + "s)"
	
	
func _input(event):
	if(active):
		if event.is_action_pressed("shoot"):
			if(guns[gun_type]['fire_type'] == "burst"):
				for shot in range(3):
					shoot()
					await get_tree().create_timer(0.1).timeout
			else:
				shoot()
		elif event.is_action_pressed("reload"):
			reload()
		elif event.is_action_pressed("cycle_guns"):
			change_gun()
			
				
func change_gun():
	if(gun_type == GUN_TYPE.PISTOL):
		gun_type = GUN_TYPE.SHOTGUN
	elif(gun_type == GUN_TYPE.SHOTGUN):
		gun_type = GUN_TYPE.MACHINE_GUN
	elif(gun_type == GUN_TYPE.MACHINE_GUN):
		gun_type = GUN_TYPE.PISTOL
	else:
		printerr("Unknown Gun Type")
	reload_time = 0.75
	reload()
	reload_time = guns[gun_type]['reload_time']
	gun_type_label.text = "Gun: " + guns[gun_type]['name']

func shoot():
	if(ammo > 0):
		if(guns[gun_type]['fire_type'] == "single" or guns[gun_type]['fire_type'] == "burst"):
			inst_bullet(%ShootingPoint)
		elif(guns[gun_type]['fire_type'] == "spread"):
			for point in spread_arr:
				inst_bullet(point)
		else:
			printerr("Unknown fire_type")
		ammo -= 1
		ammo_label.text = "Ammo = " + str(ammo)
	else: # Reload
		reload() 

func inst_bullet(shooting_point : Marker2D):
	const BULLET = preload("res://bullet_2d.tscn")
	var new_bullet = BULLET.instantiate()
	new_bullet.global_transform = shooting_point.global_transform
	shooting_point.add_child(new_bullet)

func reload():
	active = false
	reload_active = true
	reload_canvas.show()
	reload_timer = get_tree().create_timer(reload_time)
	await reload_timer.timeout
	reload_canvas.hide()
	ammo = guns[gun_type]["max_ammo"]
	ammo_label.text = "Ammo = " + str(ammo)
	active = true
	reload_active = false
		
	
