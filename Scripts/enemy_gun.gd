extends Area2D


var spread_arr : Array
var ammo : int
var range : bool = false
var bullet_damage = 5

@onready var player = find_parent("Game").find_child("Player")

# Built-ins section
func BUILT_IN():
	pass


func _ready() -> void:
	# Set base gun type
	ammo = Stats.ENEMY_AMMO
	
	# For Shotgun bulllet pattern
	spread_arr = [%ShootingPoint, %ShootingPoint2, %ShootingPoint3]


func _process(_delta: float) -> void:
	look_at(player.position)



# Events section
func EVENTS():
	pass


# Player is within range
	# Fire
	# Run fire timer
func _in_range():
	range = true
	pass

# Player is in range and gun timer ends
	# Fire
func _on_timer_timeout() -> void:
	if(range):
		var shooting_point = get_child(1).get_child(0).get_child(2)
		inst_bullet(shooting_point)
	pass # Replace with function body.

# Player exits range
	# Reset gun fire timer and wait
func _out_range():
	range = false
	pass

# Helper section
func HELPERS():
	pass


func inst_bullet(shooting_point : Marker2D):
	const BULLET = preload("res://Scenes/bullet_2d.tscn")
	var new_bullet = BULLET.instantiate()
	new_bullet.global_transform = shooting_point.global_transform
	shooting_point.add_child(new_bullet)
