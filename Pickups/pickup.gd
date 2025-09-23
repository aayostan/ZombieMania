extends Area2D

# Each pickup has it's own bonus (affects one of the stats of the players or enemeies)
	# need communicate with each class
# Each pickup has it's own cooldown time
	# need create timer and respond to timeout
# Each pickup has it's own probability of being dropped by an enemy
	# Need to define paramaters of instantiation in enemy
# Each pickup has it's own sound
	# Need to create and define, easy global access.

const PICKUP_PARAMS = [
	{
		"stat" = "speed",
		"modifier" = "multiply",
		"value" = 1.5,
		"cooldown" = 12,
		"spritepath" = "res://Pickups/soda_can.png",
		"scale" = Vector2(0.05,0.05),
		"sfx" = "PUSo",
		"lifetime" = 5
	}, 
	{
		"stat" = "health",
		"modifier" = "add",
		"value" = 10,
		"cooldown" = 0,
		"spritepath" = "res://Pickups/sandwhich.png",
		"scale" = Vector2(0.1,0.1),
		"sfx" = "PUSa",
		"lifetime" = 10
	},
	{
		"stat" = "n/a",
		"modifier" = "n/a",
		"value" = 1,
		"cooldown" = 0
	}
]

enum pickup {
	CAFFEINE,
	SANDWHICH
}

var param

func _ready():
	# Choose random pickup and change visuals
	var p = pickup.keys()[randi() % pickup.size()]
	param = PICKUP_PARAMS[pickup[p]]
	%Sprite2D.texture = load(param["spritepath"])
	%Sprite2D.scale = param["scale"]
	get_tree().create_timer(param['lifetime']).timeout.connect(_on_lifetime_end)
	


func _on_body_entered(body: Node2D) -> void:
	if(body.name == "Player"):
		AudioManager.play_sfx(param['sfx'],0,true)
		create_connect()
		update_stat()
		queue_free()


func create_connect():
	var tree = get_tree()
	if(param['cooldown'] > 0):
		var timer = tree.create_timer(param['cooldown'])
		var game = get_parent()
		timer.timeout.connect(game._on_pickup_cooldown.bind(param))


func update_stat():
	if(param["stat"] == "speed"):
		if(param["modifier"] == "add"):
			Stats.player_speed += param["value"]
		else:
			Stats.player_speed *= param["value"]
	elif(param["stat"] == "health"):
		if(param["modifier"] == "add"):
			Stats.player_health += param["value"]
		else:
			Stats.player_health *= param["value"]


func _on_lifetime_end():
	queue_free()
