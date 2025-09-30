extends StaticBody2D

@onready var player = get_node("/root/Game/Player")

var r1 = range(-1920*1.5,-1920/2.0)
var r2 = range(-1080*1.5, -1080/2.0)


func _ready():
	r1.append_array(range(1920/2.0,1920*1.5))
	r2.append_array(range(1080/2.0, 1080*1.5))


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
func rand4bounds(b, b2, b3 , b4) -> float:
	var pon = randf()
	var n = randf_range(b, b2)
	var p = randf_range(b3, b4)
	if(pon > 0.5):
		return p
	else:
		return n


func move_tree():
	global_position = player.global_position + rand_out_bounds()


func rand_out_bounds() -> Vector2:
	var randx = randf_range(-1920 * 1.5, 1920 * 1.5)
	var randy
	if(randx < -1920/2.0 or randx > 1920/2.0):
		randy = randf_range(-1080 * 1.5, 1080 * 1.5)
	else:
		randy = r2.pick_random()
	return Vector2(randx, randy)
