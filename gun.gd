extends Area2D

var num_shots : int = 1
var active : bool = true


func _process(_delta):
	#var enemies_in_range = get_overlapping_bodies()
	#if enemies_in_range.size() > 0:
		#var target_enemy = enemies_in_range.front()
		#look_at(target_enemy.global_position)
	look_at(get_global_mouse_position())
	
func _input(event):
	if(active):
		if event.is_action_pressed("shoot"):
			for shot in num_shots:
				shoot()
				await get_tree().create_timer(0.05).timeout # Waits for 1/30 seconds

func shoot():
	const BULLET = preload("res://bullet_2d.tscn")
	var new_bullet = BULLET.instantiate()
	new_bullet.global_transform = %ShootingPoint.global_transform
	%ShootingPoint.add_child(new_bullet)
