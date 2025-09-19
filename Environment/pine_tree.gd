extends StaticBody2D

@onready var player = get_node("/root/Game/Player")

var r1 = range(-1920*1.5,-1920/2)
var r2 = range(-1080*1.5, -1080/2)

func _ready():
	r1.append_array(range(1920/2,1920*1.5))
	r2.append_array(range(1080/2, 1080*1.5))

func _process(_delta : float):
	if(player.global_position.distance_to(global_position) > Vector2(1920, 1080).length()):
		global_position = player.global_position + Vector2(r1.pick_random(),r2.pick_random())

func rand4bounds(b, b2, b3 , b4) -> float:
	var pon = randf()
	var n = randf_range(b, b2)
	var p = randf_range(b3, b4)
	if(pon > 0.5):
		return p
	else:
		return n
