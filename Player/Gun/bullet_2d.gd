extends Area2D


var travelled_distance = 0
var damage = 1

func _ready():
	damage = find_parent("Gun").bullet_damage

func _physics_process(delta):
	const SPEED = 1000
	const RANGE = 1200

	position += Vector2.RIGHT.rotated(rotation) * SPEED * delta
	
	travelled_distance += SPEED * delta
	if travelled_distance > RANGE:
		queue_free()


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
