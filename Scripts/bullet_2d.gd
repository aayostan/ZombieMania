extends Area2D


# Resource section
func RESOURCES():
	pass


var travelled_distance = 0
var damage = 1
var gun_num



# Built-in section
func BUILTINS():
	pass


func _ready():
	# Ineloquent solution
	damage = get_parent().get_parent().get_parent().get_parent().bullet_damage

func _physics_process(delta):
	const SPEED = 1000
	const RANGE = 1200

	position += Vector2.RIGHT.rotated(rotation) * SPEED * delta
	
	travelled_distance += SPEED * delta
	if travelled_distance > RANGE:
		queue_free()



# Events section
func EVENTS():
	pass


func _on_body_entered(body):
	if(damage <= 0):
		queue_free()
	elif body.has_method("take_damage"):
		var temp = damage - body.mob_type['health']
		body.take_damage(damage)
		damage = temp
		if(damage <= 0):
			AudioManager.play_sfx("TongueClick",0,true)
			queue_free()
