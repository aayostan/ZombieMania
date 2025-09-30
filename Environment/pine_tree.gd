extends StaticBody2D

@onready var player = get_node("/root/Game/Player")

var rY_exc = range(-1080*1.5, -1080/2.0)


func _ready():
	rY_exc.append_array(range(1080/2.0, 1080*1.5))


func _process(_delta : float):
	# Need to ammend to make trees respawn in the direction 
	# the player is headed once they leave the bounds
	# could do completely differently by creating queue
	# of trees which randomly generate as player approaches new area
	if(player.global_position.distance_to(global_position) > Vector2(1920, 1080).length()):
		move_tree()


func _physics_process(_delta: float) -> void:
	var overlapping_mobs = %DetectionBox.get_overlapping_bodies()
	if(overlapping_mobs):
		for m in overlapping_mobs:
			if(m.boss):
				move_tree()



# Helpers
func move_tree():
	global_position = player.global_position + rand_out_bounds()


func rand_out_bounds() -> Vector2:
	var randx = randf_range(-1920 * 1.5, 1920 * 1.5)
	var randy
	if(randx < -1920/2.0 or randx > 1920/2.0):
		randy = randf_range(-1080 * 1.5, 1080 * 1.5)
	else:
		randy = rY_exc.pick_random()
	return Vector2(randx, randy)
