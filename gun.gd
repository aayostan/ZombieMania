extends Area2D

var num_shots : int = 1
var active : bool = true
var gun_type = null
var ammo = 0
var reload_time = 0

var pistol = { 
	"name" = "pistol",
	"max_ammo" = 12,
	"reload_time" = 1, #seconds
	"fire_type" = "single"
}

var shotgun = { 
	"name" = "shotgun",
	"max_ammo" = 8,
	"reload_time" = 2, #seconds
	"fire_type" = "spread"
}

var machine_gun = { 
	"name" = "machine gun",
	"max_ammo" = 30,
	"reload_time" = 1.5, #seconds
	"fire_type" = "continuous"
}

enum GUN_TYPE {
	PISTOL,
	SHOTGUN,
	MACHINE_GUN
}

var guns = [pistol, shotgun, machine_gun]

var ammo_label
var reload_canvas

func _ready() -> void:
	gun_type = GUN_TYPE.PISTOL
	ammo = guns[gun_type]["max_ammo"]
	reload_time = guns[gun_type]["reload_time"]
	ammo_label = find_parent("Game").find_child("Ammo")
	reload_canvas = find_parent("Game").find_child("Reload") 
	ammo_label.text = "Ammo = " + str(ammo)

func _process(_delta):
	# Point Gun at mouse cursor 
	look_at(get_global_mouse_position())
	
	# Point Gun at Random Enemy
	#var enemies_in_range = get_overlapping_bodies()
	#if enemies_in_range.size() > 0:
		#var target_enemy = enemies_in_range.front()
		#look_at(target_enemy.global_position)
	
	
func _input(event):
	if(active):
		if event.is_action_pressed("shoot"):
			shoot()
		if event.is_action_pressed("reload"):
			reload()

func shoot():
	if(ammo > 0):
		const BULLET = preload("res://bullet_2d.tscn")
		var new_bullet = BULLET.instantiate()
		new_bullet.global_transform = %ShootingPoint.global_transform
		%ShootingPoint.add_child(new_bullet)
		ammo -= 1
		find_parent("Game").find_child("Ammo").text = "Ammo = " + str(ammo)
	else: # Reload
		reload() 

func reload():
	active = false
	reload_canvas.show()
	await get_tree().create_timer(reload_time).timeout
	reload_canvas.hide()
	ammo = guns[gun_type]["max_ammo"]
	ammo_label.text = "Ammo = " + str(ammo)
	active = true
		
	
