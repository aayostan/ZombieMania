extends Area2D

var num_shots : int = 1
var active : bool = true
const ammo_start = 12
var ammo = ammo_start
var reload_time = 1.5 #seconds

enum GUN_TYPE {
	PISTOL,
	SHOTGUN,
	MACHINE_GUN
}

func _ready() -> void:
	find_parent("Game").find_child("Ammo").text = "Ammo = " + str(ammo)
	#%Ammo.text = "Ammo = 12"

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
			#for shot in num_shots:
			shoot()
			#	await get_tree().create_timer(0.05).timeout # Waits for 1/30 seconds

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
	find_parent("Game").find_child("Reload").show()
	await get_tree().create_timer(reload_time).timeout
	find_parent("Game").find_child("Reload").hide()
	ammo = ammo_start
	find_parent("Game").find_child("Ammo").text = "Ammo = " + str(ammo)
	active = true
		
	
